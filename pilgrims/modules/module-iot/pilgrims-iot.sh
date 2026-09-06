#!/bin/bash

# ============================================================================
# PILGRIMS-IOT - IoT & Firmware Security Module
# ============================================================================

MODULE_NAME="iot"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

MODE="firmware"
EXTRACT=1
ANALYZE=1

for arg in "$@"; do
    case $arg in
        --firmware) MODE="firmware" ;;
        --device) MODE="device" ;;
        --no-extract) EXTRACT=0 ;;
        --no-analyze) ANALYZE=0 ;;
    esac
done

if [ ! -f "$TARGET" ] && [ "$MODE" = "firmware" ]; then
    print_error "Firmware file not found: $TARGET"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/iot_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "IOT" "🔌 IOT & FIRMWARE SECURITY"
print_info "Target: $TARGET"
print_info "Mode: $MODE"
echo ""

# ============================================================================
# FIRMWARE ANALYSIS
# ============================================================================
if [ "$MODE" = "firmware" ]; then
    
    # Extract firmware
    if [ $EXTRACT -eq 1 ]; then
        print_phase_header "1" "📦 FIRMWARE EXTRACTION"
        print_task "Analyzing firmware with binwalk"
        
        if command_exists binwalk; then
            binwalk -e "$TARGET" --directory="$OUTPUT_DIR/extracted" > /dev/null 2>&1
            print_success "Firmware extracted"
            
            # List extracted contents
            EXTRACTED_DIRS=$(find "$OUTPUT_DIR/extracted" -type d | wc -l)
            print_info "Extracted $EXTRACTED_DIRS directories"
        else
            print_error "binwalk not installed"
            print_info "Install with: sudo apt install binwalk"
            exit 1
        fi
    fi
    
    # Analyze filesystem
    if [ $ANALYZE -eq 1 ] && [ -d "$OUTPUT_DIR/extracted" ]; then
        print_phase_header "2" "🔍 FILESYSTEM ANALYSIS"
        
        # Search for hardcoded credentials
        print_task "Searching for hardcoded credentials"
        > "$OUTPUT_DIR/credentials.txt"
        
        grep -rEn "(password|passwd|admin|root|user|login)" "$OUTPUT_DIR/extracted" \
            --include="*.conf" --include="*.cfg" --include="*.ini" --include="*.xml" \
            --include="*.json" --include="*.txt" --include="*.sh" \
            2>/dev/null | head -50 > "$OUTPUT_DIR/credentials.txt"
        
        CREDS=$(wc -l < "$OUTPUT_DIR/credentials.txt")
        if [ $CREDS -gt 0 ]; then
            print_critical "Found $CREDS potential credentials"
            echo "[CRITICAL] $CREDS hardcoded credentials" > "$OUTPUT_DIR/cred_findings.txt"
        fi
        
        # Search for API keys
        print_task "Searching for API keys"
        > "$OUTPUT_DIR/api_keys.txt"
        
        grep -rEn "(api[_-]?key|apikey|secret[_-]?key|token|AWS_|firebase)" "$OUTPUT_DIR/extracted" \
            2>/dev/null | head -30 > "$OUTPUT_DIR/api_keys.txt"
        
        API_KEYS=$(wc -l < "$OUTPUT_DIR/api_keys.txt")
        if [ $API_KEYS -gt 0 ]; then
            print_critical "Found $API_KEYS API keys"
            echo "[CRITICAL] $API_KEYS API keys exposed" > "$OUTPUT_DIR/api_findings.txt"
        fi
        
        # Check for binaries
        print_task "Analyzing binaries"
        BINARIES=$(find "$OUTPUT_DIR/extracted" -type f -executable | wc -l)
        print_info "Found $BINARIES executable files"
        
        # Check for known vulnerable binaries
        VULN_BINS=$(find "$OUTPUT_DIR/extracted" -type f -executable -exec file {} \; | grep -c "ELF" || echo "0")
        if [ $VULN_BINS -gt 0 ]; then
            print_warning "Found $VULN_BINS ELF binaries (analyze with reverse engineering tools)"
            echo "[MEDIUM] $VULN_BINS ELF binaries to analyze" > "$OUTPUT_DIR/binary_findings.txt"
        fi
        
        # Check for web interface
        print_task "Checking for web interface"
        if find "$OUTPUT_DIR/extracted" -name "*.html" -o -name "*.php" -o -name "*.cgi" | grep -q .; then
            print_info "Web interface detected"
            
            # Check for default credentials in web files
            WEB_CREDS=$(grep -rEn "(admin:admin|root:root|admin:password)" "$OUTPUT_DIR/extracted" 2>/dev/null | wc -l)
            if [ $WEB_CREDS -gt 0 ]; then
                print_critical "Default credentials found in web interface"
                echo "[CRITICAL] Default credentials in web interface" > "$OUTPUT_DIR/web_findings.txt"
            fi
        fi
        
        # Check for update mechanisms
        print_task "Analyzing update mechanisms"
        if grep -rEn "(update|upgrade|firmware)" "$OUTPUT_DIR/extracted" --include="*.sh" --include="*.conf" 2>/dev/null | grep -q .; then
            print_info "Update mechanism found"
            
            # Check if updates use HTTPS
            if grep -rEn "http://" "$OUTPUT_DIR/extracted" --include="*.sh" --include="*.conf" 2>/dev/null | grep -q "update"; then
                print_warning "Updates may use insecure HTTP"
                echo "[HIGH] Insecure update mechanism" > "$OUTPUT_DIR/update_findings.txt"
            fi
        fi
    fi
fi

# ============================================================================
# DEVICE ANALYSIS (Network-based)
# ============================================================================
if [ "$MODE" = "device" ]; then
    print_phase_header "1" "🔍 DEVICE DISCOVERY"
    print_task "Scanning for IoT devices"
    
    # Nmap scan for common IoT ports
    sudo nmap -sV -p 23,80,443,8080,8443,1883,5683 "$TARGET" -oN "$OUTPUT_DIR/nmap.txt" > /dev/null 2>&1
    
    OPEN_PORTS=$(grep -c "open" "$OUTPUT_DIR/nmap.txt" 2>/dev/null || echo "0")
    print_success "Found $OPEN_PORTS open ports"
    
    # Check for common IoT protocols
    print_phase_header "2" "📡 PROTOCOL ANALYSIS"
    
    # MQTT
    if grep -q "1883" "$OUTPUT_DIR/nmap.txt"; then
        print_info "MQTT port open (1883)"
        echo "[INFO] MQTT service detected" > "$OUTPUT_DIR/protocol_findings.txt"
        
        # Try anonymous access
        MQTT_TEST=$(echo -e "CONNECT\nPING\nDISCONNECT" | nc -w 3 "$TARGET" 1883 2>/dev/null)
        if [ -n "$MQTT_TEST" ]; then
            print_warning "MQTT allows anonymous access"
            echo "[HIGH] MQTT anonymous access" >> "$OUTPUT_DIR/protocol_findings.txt"
        fi
    fi
    
    # Telnet
    if grep -q "23" "$OUTPUT_DIR/nmap.txt"; then
        print_critical "Telnet port open (23) - insecure protocol"
        echo "[CRITICAL] Telnet enabled" > "$OUTPUT_DIR/telnet_findings.txt"
    fi
    
    # Check for default credentials
    print_phase_header "3" "🔐 DEFAULT CREDENTIALS"
    print_task "Testing common default credentials"
    
    > "$OUTPUT_DIR/default_creds.txt"
    
    # Common IoT default credentials
    declare -A CREDENTIALS=(
        ["admin:admin"]="admin:admin"
        ["root:root"]="root:root"
        ["admin:password"]="admin:password"
        ["admin:1234"]="admin:1234"
        ["user:user"]="user:user"
    )
    
    for cred in "${!CREDENTIALS[@]}"; do
        user=$(echo "$cred" | cut -d: -f1)
        pass=$(echo "$cred" | cut -d: -f2)
        
        # Try via HTTP
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$user:$pass" "http://$TARGET" 2>/dev/null)
        if [ "$HTTP_CODE" = "200" ]; then
            print_critical "Default credentials work: $user:$pass"
            echo "[CRITICAL] Default credentials: $user:$pass" >> "$OUTPUT_DIR/default_creds.txt"
        fi
    done
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 🔌 IoT Security Report

**Target:** $TARGET  
**Mode:** $MODE  
**Date:** $(date)

## 📊 Summary

$(find "$OUTPUT_DIR" -name "*_findings.txt" -exec cat {} \; 2>/dev/null | sort)

## 🔍 Findings

### Credentials
\`\`\`
$(head -20 "$OUTPUT_DIR/credentials.txt" 2>/dev/null || echo "None found")
\`\`\`

### API Keys
\`\`\`
$(head -20 "$OUTPUT_DIR/api_keys.txt" 2>/dev/null || echo "None found")
\`\`\`

## 🛡️ Recommendations

- Remove all hardcoded credentials
- Use secure protocols (HTTPS, MQTT with TLS)
- Implement proper authentication
- Secure update mechanisms
- Disable unnecessary services (Telnet)
- Regular firmware updates
- Network segmentation for IoT devices
- Monitor IoT device behavior
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
