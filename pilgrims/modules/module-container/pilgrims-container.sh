#!/bin/bash

# ============================================================================
# PILGRIMS-CONTAINER - Container & Kubernetes Security Module
# ============================================================================

MODULE_NAME="container"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

MODE="docker"
IMAGES=""
K8S=0

for arg in "$@"; do
    case $arg in
        --docker) MODE="docker" ;;
        --k8s) MODE="k8s"; K8S=1 ;;
        --images=*) IMAGES="${arg#*=}" ;;
    esac
done

OUTPUT_DIR="$MODULE_DIR/reports/container_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "CONTAINER" "🐳 CONTAINER SECURITY ASSESSMENT"
print_info "Mode: $MODE"
echo ""

# ============================================================================
# DOCKER SECURITY
# ============================================================================
if [ "$MODE" = "docker" ]; then
    
    if ! command_exists docker; then
        print_error "Docker not installed"
        exit 1
    fi
    
    # Docker Daemon Security
    print_phase_header "1" "🔒 DOCKER DAEMON SECURITY"
    print_task "Checking Docker daemon configuration"
    
    > "$OUTPUT_DIR/daemon_findings.txt"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_warning "Docker running as root"
        echo "[MEDIUM] Docker daemon running as root" >> "$OUTPUT_DIR/daemon_findings.txt"
    fi
    
    # Check for privileged containers
    PRIVILEGED=$(docker ps --format '{{.Names}}' | xargs -I {} docker inspect {} --format '{{.Name}} {{.HostConfig.Privileged}}' 2>/dev/null | grep -c "true" || echo "0")
    if [ $PRIVILEGED -gt 0 ]; then
        print_critical "$PRIVILEGED privileged containers running"
        echo "[CRITICAL] $PRIVILEGED privileged containers" > "$OUTPUT_DIR/privileged_findings.txt"
    fi
    
    # Check for containers with host network
    HOST_NET=$(docker ps --format '{{.Names}}' | xargs -I {} docker inspect {} --format '{{.Name}} {{.HostConfig.NetworkMode}}' 2>/dev/null | grep -c "host" || echo "0")
    if [ $HOST_NET -gt 0 ]; then
        print_warning "$HOST_NET containers using host network"
        echo "[HIGH] $HOST_NET containers with host network" > "$OUTPUT_DIR/network_findings.txt"
    fi
    
    # Image Vulnerability Scanning
    print_phase_header "2" "🔍 IMAGE VULNERABILITY SCANNING"
    
    if [ -n "$IMAGES" ]; then
        IFS=',' read -ra IMAGE_ARRAY <<< "$IMAGES"
    else
        # Get all local images
        IMAGE_ARRAY=($(docker images --format '{{.Repository}}:{{.Tag}}' | grep -v "<none>"))
    fi
    
    print_task "Scanning ${#IMAGE_ARRAY[@]} images"
    
    > "$OUTPUT_DIR/image_findings.txt"
    
    for image in "${IMAGE_ARRAY[@]}"; do
        print_info "Scanning: $image"
        
        if command_exists trivy; then
            trivy image --quiet --severity HIGH,CRITICAL "$image" > "$OUTPUT_DIR/trivy_$(echo $image | tr '/:' '_').txt" 2>&1
            
            VULNS=$(grep -cE "(HIGH|CRITICAL)" "$OUTPUT_DIR/trivy_$(echo $image | tr '/:' '_').txt" 2>/dev/null || echo "0")
            if [ $VULNS -gt 0 ]; then
                echo "[HIGH] $image: $VULNS vulnerabilities" >> "$OUTPUT_DIR/image_findings.txt"
            fi
        else
            print_warning "Trivy not installed, skipping vulnerability scan"
            print_info "Install with: sudo apt install trivy"
            break
        fi
    done
    
    # Docker Bench Security
    print_phase_header "3" "🔐 DOCKER BENCH SECURITY"
    print_task "Running Docker CIS benchmark"
    
    if docker run --rm -it --net host --pid host --userns host --cap-add audit_control \
        -v /var/lib:/var/lib \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /usr/lib/systemd:/usr/lib/systemd \
        -v /etc:/etc \
        docker/docker-bench-security > "$OUTPUT_DIR/bench.txt" 2>&1; then
        
        WARNINGS=$(grep -c "WARN" "$OUTPUT_DIR/bench.txt" 2>/dev/null || echo "0")
        print_warning "Found $WARNINGS warnings"
        echo "[MEDIUM] Docker bench: $WARNINGS warnings" > "$OUTPUT_DIR/bench_findings.txt"
    fi
fi

# ============================================================================
# KUBERNETES SECURITY
# ============================================================================
if [ "$MODE" = "k8s" ] || [ $K8S -eq 1 ]; then
    
    if ! command_exists kubectl; then
        print_error "kubectl not installed"
        exit 1
    fi
    
    print_phase_header "4" "☸️  KUBERNETES SECURITY"
    
    # Check cluster access
    print_task "Checking cluster access"
    if ! kubectl cluster-info > /dev/null 2>&1; then
        print_error "Cannot access Kubernetes cluster"
        exit 1
    fi
    print_success "Cluster accessible"
    
    # Kube-bench (CIS Benchmark)
    print_phase_header "5" "🔐 CIS BENCHMARK"
    print_task "Running kube-bench"
    
    if command_exists kube-bench; then
        kube-bench --json > "$OUTPUT_DIR/kubebench.json" 2>&1
        
        FAILS=$(jq '[.Controls[].tests[].results[] | select(.status == "FAIL")] | length' "$OUTPUT_DIR/kubebench.json" 2>/dev/null || echo "0")
        if [ $FAILS -gt 0 ]; then
            print_critical "$FAILS CIS benchmark failures"
            echo "[CRITICAL] Kube-bench: $FAILS failures" > "$OUTPUT_DIR/k8s_findings.txt"
        fi
    else
        print_warning "kube-bench not installed"
        print_info "Install from: https://github.com/aquasecurity/kube-bench"
    fi
    
    # Check for privileged pods
    print_phase_header "6" "🔍 POD SECURITY"
    print_task "Checking for privileged pods"
    
    PRIV_PODS=$(kubectl get pods --all-namespaces -o json | jq '[.items[] | select(.spec.containers[].securityContext.privileged == true)] | length' 2>/dev/null || echo "0")
    if [ $PRIV_PODS -gt 0 ]; then
        print_critical "$PRIV_PODS privileged pods found"
        echo "[CRITICAL] $PRIV_PODS privileged pods" > "$OUTPUT_DIR/priv_pod_findings.txt"
    fi
    
    # Check for secrets
    print_task "Checking for exposed secrets"
    SECRET_COUNT=$(kubectl get secrets --all-namespaces --no-headers | wc -l)
    print_info "Found $SECRET_COUNT secrets in cluster"
    
    # Check RBAC
    print_task "Analyzing RBAC configuration"
    CLUSTER_ROLES=$(kubectl get clusterroles --no-headers | wc -l)
    print_info "Found $CLUSTER_ROLES cluster roles"
    
    # Check for overly permissive roles
    WILDCARD_ROLES=$(kubectl get clusterroles -o json | jq '[.items[] | select(.rules[]?.resources[] == "*" and .rules[]?.verbs[] == "*")] | length' 2>/dev/null || echo "0")
    if [ $WILDCARD_ROLES -gt 0 ]; then
        print_critical "$WILDCARD_ROLES wildcard roles found"
        echo "[CRITICAL] $WILDCARD_ROLES wildcard RBAC roles" > "$OUTPUT_DIR/rbac_findings.txt"
    fi
    
    # Network Policies
    print_task "Checking network policies"
    NET_POL=$(kubectl get networkpolicies --all-namespaces --no-headers | wc -l)
    if [ $NET_POL -eq 0 ]; then
        print_warning "No network policies found"
        echo "[HIGH] No network policies - pods can communicate freely" > "$OUTPUT_DIR/netpol_findings.txt"
    else
        print_success "Found $NET_POL network policies"
    fi
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 🐳 Container Security Report

**Mode:** $MODE  
**Date:** $(date)

## 📊 Summary

$(find "$OUTPUT_DIR" -name "*_findings.txt" -exec cat {} \; 2>/dev/null | sort)

## 🔍 Findings

### Docker
- Privileged containers: $PRIVILEGED
- Host network containers: $HOST_NET

### Kubernetes
- Privileged pods: ${PRIV_PODS:-0}
- Wildcard RBAC roles: ${WILDCARD_ROLES:-0}
- Network policies: ${NET_POL:-0}

## 🛡️ Recommendations

- Avoid privileged containers/pods
- Use specific network modes
- Implement network policies
- Follow CIS benchmarks
- Regular image vulnerability scanning
- Implement RBAC best practices
- Use secrets management solution
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
