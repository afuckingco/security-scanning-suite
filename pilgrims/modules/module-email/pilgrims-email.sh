#!/bin/bash

# ============================================================================
# PILGRIMS-EMAIL - Email Security Module
# ============================================================================

MODULE_NAME="email"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"

source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="${1:-}"
shift 2>/dev/null || true

if [ -z "$TARGET" ]; then
    print_error "Target domain not specified" >&2
    echo "Usage: $0 <domain> [args]" >&2
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/email_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "EMAIL" "📧 EMAIL SECURITY ASSESSMENT"
print_info "Domain: $TARGET"
echo ""

# ============================================================================
# SPF/DKIM/DMARC ANALYSIS
# ============================================================================
print_phase_header "1" "🔐 EMAIL AUTHENTICATION"

# SPF Record
print_task "Checking SPF record"
SPF=$(dig TXT "$TARGET" +short | grep "v=spf1")

if [ -n "$SPF" ]; then
    print_success "SPF record found"
    echo "$SPF" > "$OUTPUT_DIR/spf.txt"
    
    # Check for permissive SPF
    if echo "$SPF" | grep -q "+all"; then
        print_critical "SPF allows all senders (+all)"
        echo "[CRITICAL] SPF allows all senders" > "$OUTPUT_DIR/spf_findings.txt"
    elif echo "$SPF" | grep -q "~all"; then
        print_warning "SPF uses softfail (~all)"
        echo "[MEDIUM] SPF uses softfail (~all)" > "$OUTPUT_DIR/spf_findings.txt"
    fi
else
    print_critical "No SPF record found"
    echo "[CRITICAL] No SPF record" > "$OUTPUT_DIR/spf_findings.txt"
fi

# DKIM Record
print_task "Checking DKIM record"
DKIM_SELECTORS=("default" "google" "mail" "dkim" "selector1" "selector2" "k1" "s1" "s20151201")
DKIM_FOUND=0

for selector in "${DKIM_SELECTORS[@]}"; do
    DKIM=$(dig TXT "${selector}._domainkey.$TARGET" +short)
    if [ -n "$DKIM" ]; then
        print_success "DKIM found: $selector"
        echo "$DKIM" > "$OUTPUT_DIR/dkim_$selector.txt"
        DKIM_FOUND=1
    fi
done

if [ $DKIM_FOUND -eq 0 ]; then
    print_critical "No DKIM record found"
    echo "[CRITICAL] No DKIM record" > "$OUTPUT_DIR/dkim_findings.txt"
fi

# DMARC Record
print_task "Checking DMARC record"
DMARC=$(dig TXT "_dmarc.$TARGET" +short | grep "v=DMARC1")

if [ -n "$DMARC" ]; then
    print_success "DMARC record found"
    echo "$DMARC" > "$OUTPUT_DIR/dmarc.txt"
    
    # Check policy
    if echo "$DMARC" | grep -q "p=none"; then
        print_warning "DMARC policy is 'none' (monitoring only)"
        echo "[MEDIUM] DMARC policy is 'none'" > "$OUTPUT_DIR/dmarc_findings.txt"
    elif echo "$DMARC" | grep -q "p=quarantine"; then
        print_success "DMARC policy is 'quarantine'"
    elif echo "$DMARC" | grep -q "p=reject"; then
        print_success "DMARC policy is 'reject' (strongest)"
    fi
    
    # Check for rua/ruf
    if ! echo "$DMARC" | grep -q "rua="; then
        print_warning "No DMARC aggregate reporting (rua)"
        echo "[LOW] No DMARC aggregate reporting" >> "$OUTPUT_DIR/dmarc_findings.txt"
    fi
else
    print_critical "No DMARC record found"
    echo "[CRITICAL] No DMARC record" > "$OUTPUT_DIR/dmarc_findings.txt"
fi

# ============================================================================
# MX RECORD ANALYSIS
# ============================================================================
print_phase_header "2" "📬 MX RECORD ANALYSIS"
print_task "Enumerating mail servers"

MX_RECORDS=$(dig MX "$TARGET" +short)
echo "$MX_RECORDS" > "$OUTPUT_DIR/mx_records.txt"

MX_COUNT=$(echo "$MX_RECORDS" | wc -l)
print_success "Found $MX_COUNT mail servers"

# Test each MX server
> "$OUTPUT_DIR/mx_findings.txt"
while read -r mx; do
    MAIL_SERVER=$(echo "$mx" | awk '{print $2}' | sed 's/\.$//')
    
    if [ -n "$MAIL_SERVER" ]; then
        print_info "Testing: $MAIL_SERVER"
        
        # Check for open relay
        OPEN_RELAY=$(echo -e "EHLO test.com\nMAIL FROM:<test@test.com>\nRCPT TO:<test@evil.com>\nQUIT" | nc -w 5 "$MAIL_SERVER" 25 2>/dev/null)
        
        if echo "$OPEN_RELAY" | grep -q "250.*OK"; then
            print_critical "Open relay detected: $MAIL_SERVER"
            echo "[CRITICAL] Open relay: $MAIL_SERVER" >> "$OUTPUT_DIR/mx_findings.txt"
        fi
        
        # Check for STARTTLS
        STARTTLS=$(echo -e "EHLO test.com\nSTARTTLS\nQUIT" | nc -w 5 "$MAIL_SERVER" 25 2>/dev/null)
        if ! echo "$STARTTLS" | grep -q "220"; then
            print_warning "STARTTLS not supported: $MAIL_SERVER"
            echo "[HIGH] No STARTTLS: $MAIL_SERVER" >> "$OUTPUT_DIR/mx_findings.txt"
        fi
        
        # Banner grab
        BANNER=$(echo "QUIT" | nc -w 3 "$MAIL_SERVER" 25 2>/dev/null | head -1)
        echo "[$MAIL_SERVER] $BANNER" >> "$OUTPUT_DIR/banners.txt"
    fi
done <<< "$MX_RECORDS"

# ============================================================================
# EMAIL HEADER ANALYSIS
# ============================================================================
print_phase_header "3" "📋 EMAIL HEADER ANALYSIS"
print_info "To test email headers, send a test email and analyze headers"
print_info "Sample headers saved to: $OUTPUT_DIR/sample_headers.txt"

cat > "$OUTPUT_DIR/sample_headers.txt" << EOF
Sample Email Headers to Check:
- Received: (check for internal IP leakage)
- Return-Path: (should match From)
- SPF: (should be pass)
- DKIM: (should be pass)
- DMARC: (should be pass)
- X-Mailer: (can reveal email client)
- Message-ID: (should be unique)
EOF

# ============================================================================
# PHISHING SIMULATION PREP
# ============================================================================
print_phase_header "4" "🎣 PHISHING SIMULATION PREP"
print_info "Setting up phishing simulation framework"

cat > "$OUTPUT_DIR/phishing_checklist.md" << EOF
# 🎣 Phishing Simulation Checklist

## Pre-Assessment
- [ ] Get written authorization
- [ ] Define scope and targets
- [ ] Set up tracking infrastructure
- [ ] Prepare landing pages
- [ ] Create email templates

## Execution
- [ ] Send phishing emails
- [ ] Monitor click rates
- [ ] Track credential submissions
- [ ] Document results

## Post-Assessment
- [ ] Analyze results
- [ ] Identify vulnerable users
- [ ] Provide security training
- [ ] Generate report
EOF

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 📧 Email Security Report

**Domain:** $TARGET  
**Date:** $(date)

## 📊 Summary

$(find "$OUTPUT_DIR" -name "*_findings.txt" -exec cat {} \; 2>/dev/null | sort)

## 🔐 Email Authentication

### SPF
\`\`\`
$(cat "$OUTPUT_DIR/spf.txt" 2>/dev/null || echo "Not found")
\`\`\`

### DKIM
\`\`\`
$(cat "$OUTPUT_DIR/dkim_"*.txt 2>/dev/null | head -5 || echo "Not found")
\`\`\`

### DMARC
\`\`\`
$(cat "$OUTPUT_DIR/dmarc.txt" 2>/dev/null || echo "Not found")
\`\`\`

## 📬 Mail Servers
\`\`\`
$(cat "$OUTPUT_DIR/mx_records.txt" 2>/dev/null)
\`\`\`

## 🛡️ Recommendations

- Implement SPF with -all (hard fail)
- Configure DKIM for all mail streams
- Set DMARC policy to quarantine or reject
- Enable DMARC reporting (rua/ruf)
- Disable open relay on all mail servers
- Enable STARTTLS on all mail servers
- Regular email security awareness training
- Implement phishing simulation program
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
