#!/bin/bash
# Strict mode guard (errexit + nounset + pipefail)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/strict.sh"
# Auto-installer untuk module yang missing

echo "🔧 PILGRIMS MODULE INSTALLER"
echo "═══════════════════════════════════════════════════"
echo ""

# Check & create module-web
if [ ! -f "modules/module-web/pilgrims-web.sh" ]; then
    echo "[1/2] 📦 Creating module-web..."
    mkdir -p modules/module-web/{plugins,reports,logs}
    
    cat > modules/module-web/pilgrims-web.sh << 'WEB_EOF'
#!/bin/bash
# PILGRIMS-WEB: Web Application Security Module

MODULE_NAME="web"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load core
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"

TARGET="$1"
shift

PROFILE="quick"
for arg in "$@"; do
    case $arg in
        --quick) PROFILE="quick" ;;
        --deep) PROFILE="deep" ;;
        --stealth) STEALTH=1 ;;
    esac
done

if [ -z "$TARGET" ]; then
    print_error "Target not specified"
    exit 1
fi

# Format target
if [[ ! "$TARGET" =~ ^https?:// ]]; then
    TARGET="https://$TARGET"
fi

OUTPUT_DIR="$MODULE_DIR/reports/web_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "WEB" "🌐 WEB APPLICATION SECURITY"
print_info "Target: $TARGET"
print_info "Profile: $PROFILE"
echo ""

# Phase 1: Reconnaissance
print_phase_header "1" "🔍 RECONNAISSANCE"
print_task "Checking HTTP headers"
curl -k -I -s "$TARGET" > "$OUTPUT_DIR/headers.txt" 2>&1
print_success "Headers captured"

print_task "Checking SSL certificate"
echo | openssl s_client -connect "$(echo $TARGET | sed 's|https://||'):443" -servername "$(echo $TARGET | sed 's|https://||')" 2>/dev/null | openssl x509 -noout -dates > "$OUTPUT_DIR/ssl.txt" 2>&1
print_success "SSL info captured"

# Phase 2: Security Headers
print_phase_header "2" "🛡️ SECURITY HEADERS CHECK"
> "$OUTPUT_DIR/header_findings.txt"

HEADERS=("strict-transport-security" "x-frame-options" "x-content-type-options" "content-security-policy" "x-xss-protection")
MISSING=0

for header in "${HEADERS[@]}"; do
    if ! grep -qi "$header" "$OUTPUT_DIR/headers.txt" 2>/dev/null; then
        echo "[MEDIUM] Missing header: $header" >> "$OUTPUT_DIR/header_findings.txt"
        print_vuln "MEDIUM" "Missing: $header"
        ((MISSING++))
    else
        print_success "Found: $header"
    fi
done

# Phase 3: Basic Vulnerability Checks
print_phase_header "3" "⚠️ VULNERABILITY CHECKS"

# Check for common paths
print_task "Checking common paths"
> "$OUTPUT_DIR/paths.txt"

PATHS=("/admin" "/login" "/api" "/.env" "/wp-admin" "/phpmyadmin" "/.git/config")
for path in "${PATHS[@]}"; do
    STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -m 3 "$TARGET$path" 2>/dev/null)
    if [ "$STATUS" != "404" ] && [ "$STATUS" != "000" ]; then
        echo "[INFO] Found: $path (HTTP $STATUS)" >> "$OUTPUT_DIR/paths.txt"
        print_vuln "INFO" "Found: $path (HTTP $STATUS)"
    fi
done

# Phase 4: Generate Report
print_phase_header "4" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << REPORT_EOF
# 🌐 Web Security Report

**Target:** $TARGET
**Date:** $(date)
**Profile:** $PROFILE

## 📊 Summary

- **Missing Headers:** $MISSING
- **Paths Found:** $(wc -l < "$OUTPUT_DIR/paths.txt" 2>/dev/null || echo "0")

## 🔍 Findings

### Missing Security Headers
\`\`\`
$(cat "$OUTPUT_DIR/header_findings.txt" 2>/dev/null || echo "None")
\`\`\`

### Discovered Paths
\`\`\`
$(cat "$OUTPUT_DIR/paths.txt" 2>/dev/null || echo "None")
\`\`\`

## 🛡️ Recommendations

- Implement all missing security headers
- Restrict access to sensitive paths
- Enable HSTS with long max-age
- Configure CSP properly
- Regular security assessments
REPORT_EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
print_mission_complete "web" "$TARGET" "$OUTPUT_DIR" "0"
WEB_EOF
    
    chmod +x modules/module-web/pilgrims-web.sh
    echo "   ✓ module-web created"
else
    echo "   ✓ module-web already exists"
fi

# Check & create module-network
if [ ! -f "modules/module-network/pilgrims-net.sh" ]; then
    echo "[2/2] 📦 Creating module-network..."
    mkdir -p modules/module-network/{plugins,reports,logs}
    
    cat > modules/module-network/pilgrims-net.sh << 'NET_EOF'
#!/bin/bash
# PILGRIMS-NET: Network Security Assessment Module

MODULE_NAME="network"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load core
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"

TARGET="$1"
shift

PROFILE="quick"
for arg in "$@"; do
    case $arg in
        --quick) PROFILE="quick" ;;
        --deep) PROFILE="deep" ;;
        --vuln) PROFILE="vuln" ;;
    esac
done

if [ -z "$TARGET" ]; then
    print_error "Target not specified"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/net_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "NET" "🌐 NETWORK SECURITY ASSESSMENT"
print_info "Target: $TARGET"
print_info "Profile: $PROFILE"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    print_warning "Some features require root privileges"
fi

# Phase 1: Host Discovery
print_phase_header "1" "🔍 HOST DISCOVERY"
print_task "Scanning for live hosts"

if command -v nmap &> /dev/null; then
    sudo nmap -sn "$TARGET" -oG "$OUTPUT_DIR/hosts.txt" > /dev/null 2>&1
    HOSTS=$(grep "Status: Up" "$OUTPUT_DIR/hosts.txt" 2>/dev/null | wc -l)
    print_success "Found $HOSTS live hosts"
else
    print_error "nmap not installed"
    print_info "Install with: sudo apt install nmap"
    HOSTS=0
fi

# Phase 2: Port Scanning
print_phase_header "2" "🔌 PORT SCANNING"
print_task "Scanning open ports"

if command -v nmap &> /dev/null; then
    if [ "$PROFILE" = "quick" ]; then
        sudo nmap -F "$TARGET" -oN "$OUTPUT_DIR/ports.txt" > /dev/null 2>&1
    else
        sudo nmap -sS -sV -O -p- "$TARGET" -oN "$OUTPUT_DIR/ports.txt" > /dev/null 2>&1
    fi
    
    OPEN_PORTS=$(grep -c "open" "$OUTPUT_DIR/ports.txt" 2>/dev/null || echo "0")
    print_success "Found $OPEN_PORTS open ports"
else
    print_error "nmap not installed"
    OPEN_PORTS=0
fi

# Phase 3: Service Enumeration
print_phase_header "3" "🔧 SERVICE ENUMERATION"
print_task "Enumerating services"

if command -v nmap &> /dev/null; then
    sudo nmap -sC "$TARGET" -oN "$OUTPUT_DIR/services.txt" > /dev/null 2>&1
    print_success "Service enumeration complete"
fi

# Phase 4: Vulnerability Scanning
if [ "$PROFILE" = "vuln" ] || [ "$PROFILE" = "deep" ]; then
    print_phase_header "4" "⚠️ VULNERABILITY SCANNING"
    print_task "Scanning for vulnerabilities"
    
    if command -v nmap &> /dev/null; then
        sudo nmap --script vuln "$TARGET" -oN "$OUTPUT_DIR/vulns.txt" > /dev/null 2>&1
        VULNS=$(grep -c "VULNERABLE" "$OUTPUT_DIR/vulns.txt" 2>/dev/null || echo "0")
        
        if [ $VULNS -gt 0 ]; then
            print_critical "Found $VULNS vulnerabilities"
            echo "[CRITICAL] $VULNS vulnerabilities found" > "$OUTPUT_DIR/vuln_summary.txt"
        else
            print_success "No vulnerabilities detected"
        fi
    fi
fi

# Phase 5: Generate Report
print_phase_header "5" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << REPORT_EOF
# 🌐 Network Security Report

**Target:** $TARGET
**Date:** $(date)
**Profile:** $PROFILE

## 📊 Summary

- **Live Hosts:** $HOSTS
- **Open Ports:** $OPEN_PORTS
- **Vulnerabilities:** ${VULNS:-0}

## 🖥️ Live Hosts

\`\`\`
$(grep "Status: Up" "$OUTPUT_DIR/hosts.txt" 2>/dev/null | awk '{print $2}' || echo "None")
\`\`\`

## 🔌 Open Ports

\`\`\`
$(grep "open" "$OUTPUT_DIR/ports.txt" 2>/dev/null | head -20 || echo "None")
\`\`\`

## ⚠️ Vulnerabilities

\`\`\`
$(cat "$OUTPUT_DIR/vulns.txt" 2>/dev/null | grep "VULNERABLE" || echo "None found")
\`\`\`

## 🛡️ Recommendations

- Close unnecessary ports
- Update vulnerable services
- Implement network segmentation
- Regular vulnerability scanning
- Monitor network traffic
REPORT_EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
print_mission_complete "network" "$TARGET" "$OUTPUT_DIR" "0"
NET_EOF
    
    chmod +x modules/module-network/pilgrims-net.sh
    echo "   ✓ module-network created"
else
    echo "   ✓ module-network already exists"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ Module installation complete!"
echo ""
echo "🧪 Test now:"
echo "   ./pilgrims.sh --modules"
echo "   ./pilgrims.sh --module=web example.com --quick"
echo "   ./pilgrims.sh --module=network 192.168.1.1 --quick"
echo "═══════════════════════════════════════════════════"
