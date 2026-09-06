#!/bin/bash
# SIMULATION STUB — educational scaffold only; NOT a live security scanner.
# Generates sample output files. Do NOT use for real assessments.

# ============================================================================
# PILGRIMS-BINARY - Binary Analysis & Reverse Engineering Module
# ============================================================================

MODULE_NAME="binary"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

MODE="static"
YARA_SCAN=1
STRINGS=1

for arg in "$@"; do
    case $arg in
        --static) MODE="static" ;;
        --dynamic) MODE="dynamic" ;;
        --no-yara) YARA_SCAN=0 ;;
        --no-strings) STRINGS=0 ;;
    esac
done

if [ ! -f "$TARGET" ]; then
    print_error "Binary file not found: $TARGET"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/binary_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "BINARY" "🎯 BINARY ANALYSIS & REVERSE ENGINEERING"
print_info "Target: $TARGET"
print_info "Mode: $MODE"
echo ""

# ============================================================================
# STATIC ANALYSIS
# ============================================================================
if [ "$MODE" = "static" ]; then
    
    # File information
    print_phase_header "1" "📋 FILE INFORMATION"
    print_task "Analyzing binary"
    
    file "$TARGET" > "$OUTPUT_DIR/file_info.txt"
    cat "$OUTPUT_DIR/file_info.txt"
    
    # Check if ELF
    if file "$TARGET" | grep -q "ELF"; then
        print_success "ELF binary detected"
        
        # Check architecture
        ARCH=$(file "$TARGET" | grep -oE "(32-bit|64-bit)")
        print_info "Architecture: $ARCH"
        
        # Check if stripped
        if file "$TARGET" | grep -q "stripped"; then
            print_warning "Binary is stripped (harder to analyze)"
            echo "[INFO] Binary is stripped" > "$OUTPUT_DIR/strip_findings.txt"
        fi
        
        # Check for PIE
        if readelf -h "$TARGET" 2>/dev/null | grep -q "DYN"; then
            print_success "PIE (Position Independent Executable) enabled"
        else
            print_warning "PIE not enabled (ASLR bypass possible)"
            echo "[MEDIUM] No PIE - ASLR bypass possible" > "$OUTPUT_DIR/pie_findings.txt"
        fi
        
        # Check for NX (No-eXecute)
        if readelf -l "$TARGET" 2>/dev/null | grep -q "GNU_STACK.*RWE"; then
            print_critical "NX disabled - stack is executable"
            echo "[CRITICAL] NX disabled - stack executable" > "$OUTPUT_DIR/nx_findings.txt"
        else
            print_success "NX enabled"
        fi
        
        # Check for RELRO
        if readelf -l "$TARGET" 2>/dev/null | grep -q "GNU_RELRO"; then
            if readelf -d "$TARGET" 2>/dev/null | grep -q "BIND_NOW"; then
                print_success "Full RELRO enabled"
            else
                print_warning "Partial RELRO only"
                echo "[LOW] Partial RELRO" > "$OUTPUT_DIR/relro_findings.txt"
            fi
        else
            print_warning "No RELRO"
            echo "[MEDIUM] No RELRO" > "$OUTPUT_DIR/relro_findings.txt"
        fi
        
        # Check for canary
        if nm "$TARGET" 2>/dev/null | grep -q "__stack_chk_fail"; then
            print_success "Stack canary enabled"
        else
            print_warning "No stack canary"
            echo "[MEDIUM] No stack canary" > "$OUTPUT_DIR/canary_findings.txt"
        fi
    fi
    
    # Strings analysis
    if [ $STRINGS -eq 1 ]; then
        print_phase_header "2" "🔤 STRINGS ANALYSIS"
        print_task "Extracting strings"
        
        strings "$TARGET" > "$OUTPUT_DIR/strings.txt"
        STRING_COUNT=$(wc -l < "$OUTPUT_DIR/strings.txt")
        print_success "Extracted $STRING_COUNT strings"
        
        # Search for interesting strings
        print_task "Searching for interesting patterns"
        
        # URLs
        URLS=$(grep -Eo "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[a-zA-Z0-9/._-]*" "$OUTPUT_DIR/strings.txt" | sort -u)
        URL_COUNT=$(echo "$URLS" | wc -l)
        if [ $URL_COUNT -gt 0 ]; then
            print_info "Found $URL_COUNT URLs"
            echo "$URLS" > "$OUTPUT_DIR/urls.txt"
        fi
        
        # IPs
        IPS=$(grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$OUTPUT_DIR/strings.txt" | sort -u)
        IP_COUNT=$(echo "$IPS" | wc -l)
        if [ $IP_COUNT -gt 0 ]; then
            print_info "Found $IP_COUNT IP addresses"
            echo "$IPS" > "$OUTPUT_DIR/ips.txt"
        fi
        
        # Credentials
        CREDS=$(grep -iE "(password|passwd|secret|api[_-]?key|token)" "$OUTPUT_DIR/strings.txt")
        CRED_COUNT=$(echo "$CREDS" | wc -l)
        if [ $CRED_COUNT -gt 0 ]; then
            print_warning "Found $CRED_COUNT potential credentials"
            echo "$CREDS" > "$OUTPUT_DIR/creds.txt"
            echo "[HIGH] $CRED_COUNT potential credentials in binary" > "$OUTPUT_DIR/cred_findings.txt"
        fi
        
        # Error messages
        ERRORS=$(grep -iE "(error|fail|exception|crash)" "$OUTPUT_DIR/strings.txt" | wc -l)
        print_info "Found $ERRORS error-related strings"
    fi
    
    # YARA scan
    if [ $YARA_SCAN -eq 1 ]; then
        print_phase_header "3" "🔍 YARA SCAN"
        print_task "Scanning with YARA rules"
        
        if command_exists yara; then
            # Use default YARA rules if available
            if [ -d "/usr/share/yara-rules" ]; then
                yara -r /usr/share/yara-rules/*.yar "$TARGET" > "$OUTPUT_DIR/yara.txt" 2>&1
            else
                print_warning "No YARA rules found"
                print_info "Install with: sudo apt install yara-rules"
            fi
            
            MATCHES=$(wc -l < "$OUTPUT_DIR/yara.txt" 2>/dev/null || echo "0")
            if [ $MATCHES -gt 0 ]; then
                print_warning "YARA found $MATCHES matches"
                echo "[MEDIUM] YARA: $MATCHES matches" > "$OUTPUT_DIR/yara_findings.txt"
            else
                print_success "No YARA matches"
            fi
        else
            print_warning "YARA not installed"
            print_info "Install with: sudo apt install yara"
        fi
    fi
    
    # Check for known malware signatures
    print_phase_header "4" "🦠 MALWARE ANALYSIS"
    print_task "Checking for suspicious patterns"
    
    > "$OUTPUT_DIR/suspicious.txt"
    
    # Check for packers
    if strings "$TARGET" | grep -qiE "(UPX|ASPack|PECompact|MEW)"; then
        print_warning "Binary appears to be packed"
        echo "[HIGH] Packed binary detected" >> "$OUTPUT_DIR/suspicious.txt"
    fi
    
    # Check for anti-debugging
    if strings "$TARGET" | grep -qiE "(IsDebuggerPresent|CheckRemoteDebuggerPresent|NtQueryInformationProcess)"; then
        print_warning "Anti-debugging techniques detected"
        echo "[MEDIUM] Anti-debugging techniques" >> "$OUTPUT_DIR/suspicious.txt"
    fi
    
    # Check for crypto
    if strings "$TARGET" | grep -qiE "(AES|RSA|DES|MD5|SHA)"; then
        print_info "Cryptographic functions detected"
    fi
fi

# ============================================================================
# DYNAMIC ANALYSIS
# ============================================================================
if [ "$MODE" = "dynamic" ]; then
    print_phase_header "1" "🔄 DYNAMIC ANALYSIS"
    print_warning "Dynamic analysis requires careful setup"
    print_info "Use specialized tools: GDB, Radare2, Ghidra"
    
    # Basic execution trace
    print_task "Running with strace"
    if command_exists strace; then
        timeout 10 strace -f "$TARGET" > "$OUTPUT_DIR/strace.txt" 2>&1
        print_success "Execution trace captured"
        
        # Analyze syscalls
        SYSCALLS=$(grep -oE "^[a-z_]+\(" "$OUTPUT_DIR/strace.txt" | sort | uniq -c | sort -rn | head -20)
        echo "$SYSCALLS" > "$OUTPUT_DIR/syscalls.txt"
        print_info "Top syscalls captured"
    else
        print_warning "strace not installed"
    fi
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 🎯 Binary Analysis Report

**Target:** $TARGET  
**Mode:** $MODE  
**Date:** $(date)

## 📊 Summary

$(find "$OUTPUT_DIR" -name "*_findings.txt" -exec cat {} \; 2>/dev/null | sort)

## 🔍 File Information
\`\`\`
$(cat "$OUTPUT_DIR/file_info.txt" 2>/dev/null)
\`\`\`

## 🔤 Interesting Strings

### URLs
\`\`\`
$(head -20 "$OUTPUT_DIR/urls.txt" 2>/dev/null || echo "None found")
\`\`\`

### IP Addresses
\`\`\`
$(head -20 "$OUTPUT_DIR/ips.txt" 2>/dev/null || echo "None found")
\`\`\`

### Credentials
\`\`\`
$(head -20 "$OUTPUT_DIR/creds.txt" 2>/dev/null || echo "None found")
\`\`\`

## 🛡️ Recommendations

- Enable all security mitigations (PIE, NX, RELRO, Canary)
- Remove hardcoded credentials
- Use secure cryptographic libraries
- Implement proper input validation
- Regular security audits
- Use reverse engineering tools for deeper analysis
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
