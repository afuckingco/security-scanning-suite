#!/bin/bash
# ============================================================================
# PILGRIMS-MY-PLUGIN: Example Plugin Module (HTTP Headers + SSL + Ports)
# Demonstrates a working 3-check security scan in ~30 seconds
# ============================================================================

MODULE_NAME="my-plugin"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"

source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"

# Source guard — prevent auto-execution when sourced
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

# === Argument parsing ===
TARGET="$1"
shift
[[ ! "$TARGET" =~ ^https?:// ]] && TARGET="http://$TARGET"
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||' | cut -d'/' -f1)

PROFILE="quick"
STEALTH=0
for arg in "$@"; do
    case $arg in
        --quick)  PROFILE="quick" ;;
        --deep)   PROFILE="deep" ;;
        --stealth) STEALTH=1 ;;
        --help|-h)
            echo "Usage: $0 <target> [--quick|--deep|--stealth]"
            exit 0
            ;;
    esac
done

# === Output setup ===
OUTPUT_DIR="$MODULE_DIR/reports/${MODULE_NAME}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "my-plugin" "🔌 MY-PLUGIN — EXAMPLE 3-CHECK SCAN"
print_info "Target: $TARGET"
print_info "Domain: $DOMAIN"
print_info "Profile: $PROFILE"
echo ""

# === Check 1: HTTP Headers Analysis ===
print_phase_header "1" "📋 HTTP HEADERS ANALYSIS"
HEADERS=$(curl -k -s -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" > "$OUTPUT_DIR/headers.txt"

if [ -z "$HEADERS" ]; then
    print_error "Could not retrieve headers"
else
    print_success "Headers captured ($(wc -l < "$OUTPUT_DIR/headers.txt") lines)"

    # Check for missing security headers
    MISSING=()
    echo "$HEADERS" | grep -qi "X-Frame-Options"       || MISSING+=("X-Frame-Options (clickjacking)")
    echo "$HEADERS" | grep -qi "Content-Security-Policy" || MISSING+=("CSP (XSS)")
    echo "$HEADERS" | grep -qi "Strict-Transport-Security" || MISSING+=("HSTS (downgrade)")
    echo "$HEADERS" | grep -qi "X-Content-Type-Options" || MISSING+=("X-Content-Type-Options (MIME)")

    if [ ${#MISSING[@]} -gt 0 ]; then
        for h in "${MISSING[@]}"; do
            print_warning "Missing: $h"
        done
    else
        print_success "All key security headers present"
    fi
fi

# Stealth delay
[ $STEALTH -eq 1 ] && sleep $((RANDOM % 3 + 1))

# === Check 2: SSL/TLS Quick Check ===
print_phase_header "2" "🔒 SSL/TLS QUICK CHECK"
SSL_TARGET="${TARGET/https/http}"
if command_exists openssl; then
    EXPIRY=$(echo | timeout 5 openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        print_success "SSL certificate valid until: $EXPIRY"
        echo "Expiry: $EXPIRY" > "$OUTPUT_DIR/ssl.txt"
    else
        print_warning "No SSL on port 443 or cert unreadable"
        echo "No SSL" > "$OUTPUT_DIR/ssl.txt"
    fi
else
    print_warning "openssl not installed — skipping SSL check"
fi

[ $STEALTH -eq 1 ] && sleep $((RANDOM % 3 + 1))

# === Check 3: Open Ports (lightweight) ===
print_phase_header "3" "🔌 OPEN PORTS (top 4)"
if command_exists nmap; then
    PORTS=$(timeout 15 nmap -Pn --top-ports 4 -T4 "$DOMAIN" 2>/dev/null | grep "open" | awk '{print $1}' | sort -u | tr '\n' ',' | sed 's/,$//')
    echo "Open ports: $PORTS" > "$OUTPUT_DIR/ports.txt"
    if [ -n "$PORTS" ]; then
        print_success "Found open ports: $PORTS"
    else
        print_info "No open ports detected (or all filtered)"
    fi
else
    print_warning "nmap not installed — skipping port scan"
    echo "nmap not installed" > "$OUTPUT_DIR/ports.txt"
fi

# === Generate report ===
cat > "$OUTPUT_DIR/REPORT.md" << REOF
# my-plugin Example Scan Report

**Target:** $TARGET
**Domain:** $DOMAIN
**Profile:** $PROFILE
**Date:** $(date)

## 1. HTTP Headers

\`\`\`
$(cat "$OUTPUT_DIR/headers.txt" 2>/dev/null || echo "No data")
\`\`\`

## 2. SSL/TLS

$(cat "$OUTPUT_DIR/ssl.txt" 2>/dev/null || echo "No data")

## 3. Open Ports

$(cat "$OUTPUT_DIR/ports.txt" 2>/dev/null || echo "No data")

## Summary

This is a quick example scan showing how a PILGRIMS plugin works.
Real production modules have many more checks. See modules/module-web
for a comprehensive example.
REOF

print_success "Report saved: $OUTPUT_DIR/REPORT.md"
echo ""
print_info "Files generated:"
ls -1 "$OUTPUT_DIR" | sed 's/^/  /'
