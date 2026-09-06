#!/bin/bash
# SIMULATION STUB — educational scaffold only; NOT a live security scanner.
# Generates sample output files. Do NOT use for real assessments.

# ============================================================================
# PILGRIMS-MOBILE - Mobile Application Security Module
# ============================================================================

MODULE_NAME="mobile"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

PLATFORM=""
STATIC=1
DYNAMIC=0
API=1

for arg in "$@"; do
    case $arg in
        --android) PLATFORM="android" ;;
        --ios) PLATFORM="ios" ;;
        --no-static) STATIC=0 ;;
        --dynamic) DYNAMIC=1 ;;
        --no-api) API=0 ;;
    esac
done

# Auto-detect platform
if [ -z "$PLATFORM" ]; then
    if [[ "$TARGET" == *.apk ]]; then
        PLATFORM="android"
    elif [[ "$TARGET" == *.ipa ]]; then
        PLATFORM="ios"
    else
        print_error "Cannot detect platform. Use --android or --ios"
        exit 1
    fi
fi

if [ ! -f "$TARGET" ]; then
    print_error "File not found: $TARGET"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/mobile_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "MOBILE" "📱 MOBILE APPLICATION SECURITY"
print_info "Target: $TARGET"
print_info "Platform: $PLATFORM"
echo ""

# ============================================================================
# ANDROID ANALYSIS
# ============================================================================
if [ "$PLATFORM" = "android" ]; then
    
    # Static Analysis
    if [ $STATIC -eq 1 ]; then
        print_phase_header "1" "🔍 STATIC ANALYSIS"
        
        # Decompile APK
        print_task "Decompiling APK"
        if command_exists apktool; then
            apktool d "$TARGET" -o "$OUTPUT_DIR/decompiled" -f > /dev/null 2>&1
            print_success "APK decompiled"
        else
            print_warning "apktool not installed"
            print_info "Install with: sudo apt install apktool"
        fi
        
        # Check AndroidManifest.xml
        print_task "Analyzing AndroidManifest.xml"
        if [ -f "$OUTPUT_DIR/decompiled/AndroidManifest.xml" ]; then
            # Check permissions
            PERMISSIONS=$(grep -c "android.permission" "$OUTPUT_DIR/decompiled/AndroidManifest.xml" 2>/dev/null || echo "0")
            print_info "Declared permissions: $PERMISSIONS"
            
            # Check for dangerous permissions
            DANGEROUS=$(grep -E "(READ_CONTACTS|SEND_SMS|CALL_PHONE|CAMERA|RECORD_AUDIO|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE)" "$OUTPUT_DIR/decompiled/AndroidManifest.xml" | wc -l)
            if [ $DANGEROUS -gt 0 ]; then
                print_warning "Found $DANGEROUS dangerous permissions"
                echo "[MEDIUM] $DANGEROUS dangerous permissions declared" > "$OUTPUT_DIR/permission_findings.txt"
            fi
            
            # Check exported components
            EXPORTED=$(grep -c "android:exported=\"true\"" "$OUTPUT_DIR/decompiled/AndroidManifest.xml" 2>/dev/null || echo "0")
            if [ $EXPORTED -gt 0 ]; then
                print_warning "Found $EXPORTED exported components"
                echo "[HIGH] $EXPORTED exported components (potential attack surface)" > "$OUTPUT_DIR/export_findings.txt"
            fi
            
            # Check for debuggable
            if grep -q "android:debuggable=\"true\"" "$OUTPUT_DIR/decompiled/AndroidManifest.xml"; then
                print_critical "App is debuggable!"
                echo "[CRITICAL] App is debuggable in production" > "$OUTPUT_DIR/debug_findings.txt"
            fi
            
            # Check for backup allowed
            if grep -q "android:allowBackup=\"true\"" "$OUTPUT_DIR/decompiled/AndroidManifest.xml"; then
                print_warning "Backup is allowed"
                echo "[MEDIUM] Backup allowed - data can be extracted" > "$OUTPUT_DIR/backup_findings.txt"
            fi
        fi
        
        # Search for hardcoded secrets
        print_task "Searching for hardcoded secrets"
        > "$OUTPUT_DIR/secrets.txt"
        
        if [ -d "$OUTPUT_DIR/decompiled" ]; then
            grep -rEn "(api[_-]?key|apikey|secret[_-]?key|password|passwd|token|AWS_|firebase)" \
                "$OUTPUT_DIR/decompiled" --include="*.smali" --include="*.xml" --include="*.json" \
                2>/dev/null | head -50 > "$OUTPUT_DIR/secrets.txt"
            
            SECRETS=$(wc -l < "$OUTPUT_DIR/secrets.txt")
            if [ $SECRETS -gt 0 ]; then
                print_critical "Found $SECRETS potential secrets"
                echo "[CRITICAL] $SECRETS hardcoded secrets in APK" > "$OUTPUT_DIR/secret_findings.txt"
            fi
        fi
        
        # Check for SSL/TLS issues
        print_task "Checking SSL/TLS implementation"
        if [ -d "$OUTPUT_DIR/decompiled" ]; then
            # Check for trust-all certificates
            TRUST_ALL=$(grep -rEn "(TrustAllCertificates|AllowAllHostnames|X509TrustManager)" "$OUTPUT_DIR/decompiled" 2>/dev/null | wc -l)
            if [ $TRUST_ALL -gt 0 ]; then
                print_critical "SSL certificate validation disabled!"
                echo "[CRITICAL] SSL certificate validation disabled" > "$OUTPUT_DIR/ssl_findings.txt"
            fi
        fi
    fi
    
    # API Analysis
    if [ $API -eq 1 ]; then
        print_phase_header "2" "🔌 API ANALYSIS"
        print_task "Extracting API endpoints"
        
        > "$OUTPUT_DIR/api_endpoints.txt"
        
        if [ -d "$OUTPUT_DIR/decompiled" ]; then
            # Search for URLs
            grep -rEoh "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[a-zA-Z0-9/._-]*" \
                "$OUTPUT_DIR/decompiled" --include="*.smali" --include="*.xml" \
                2>/dev/null | sort -u > "$OUTPUT_DIR/api_endpoints.txt"
            
            ENDPOINTS=$(wc -l < "$OUTPUT_DIR/api_endpoints.txt")
            print_success "Found $ENDPOINTS API endpoints"
            
            # Check for HTTP (insecure)
            HTTP_COUNT=$(grep -c "^http://" "$OUTPUT_DIR/api_endpoints.txt" 2>/dev/null || echo "0")
            if [ $HTTP_COUNT -gt 0 ]; then
                print_warning "Found $HTTP_COUNT insecure HTTP endpoints"
                echo "[HIGH] $HTTP_COUNT insecure HTTP endpoints" > "$OUTPUT_DIR/http_findings.txt"
            fi
        fi
    fi
fi

# ============================================================================
# iOS ANALYSIS
# ============================================================================
if [ "$PLATFORM" = "ios" ]; then
    print_phase_header "1" "🔍 iOS ANALYSIS"
    print_info "iOS analysis requires macOS with Xcode"
    print_warning "Limited analysis on Linux"
    
    # Extract IPA (it's just a zip)
    print_task "Extracting IPA"
    unzip -q "$TARGET" -d "$OUTPUT_DIR/extracted" 2>/dev/null
    
    if [ -d "$OUTPUT_DIR/extracted/Payload" ]; then
        print_success "IPA extracted"
        
        # Find Info.plist
        INFO_PLIST=$(find "$OUTPUT_DIR/extracted" -name "Info.plist" | head -1)
        if [ -n "$INFO_PLIST" ]; then
            print_task "Analyzing Info.plist"
            
            # Check for ATS (App Transport Security)
            if grep -q "NSAllowsArbitraryLoads" "$INFO_PLIST"; then
                print_critical "ATS disabled - allows insecure connections"
                echo "[CRITICAL] App Transport Security disabled" > "$OUTPUT_DIR/ats_findings.txt"
            fi
            
            # Check for backup flag
            if grep -q "UIFileSharingEnabled" "$INFO_PLIST"; then
                print_warning "File sharing enabled"
                echo "[MEDIUM] File sharing enabled" > "$OUTPUT_DIR/sharing_findings.txt"
            fi
        fi
    fi
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 📱 Mobile Application Security Report

**Target:** $TARGET  
**Platform:** $PLATFORM  
**Date:** $(date)

## 📊 Summary

$(find "$OUTPUT_DIR" -name "*_findings.txt" -exec cat {} \; 2>/dev/null | sort)

## 🔍 Static Analysis

### Permissions
\`\`\`
$(grep "android.permission" "$OUTPUT_DIR/decompiled/AndroidManifest.xml" 2>/dev/null | head -20 || echo "N/A")
\`\`\`

### Secrets
\`\`\`
$(head -20 "$OUTPUT_DIR/secrets.txt" 2>/dev/null || echo "None found")
\`\`\`

### API Endpoints
\`\`\`
$(head -20 "$OUTPUT_DIR/api_endpoints.txt" 2>/dev/null || echo "N/A")
\`\`\`

## 🛡️ Recommendations

- Remove all hardcoded secrets
- Enable SSL certificate validation
- Review and minimize permissions
- Disable debuggable flag in production
- Disable backup if not needed
- Use HTTPS for all API endpoints
- Implement proper input validation
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
