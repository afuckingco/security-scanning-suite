#!/bin/bash
# PILGRIMS-WEB: Web Application Security Module

MODULE_NAME="web"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load core
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

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
