#!/bin/bash
apply_scan_template() {
    local template=$1
    case $template in
        quick-audit)   PROFILE="quick"; ENABLE_SQLI=1; ENABLE_XSS=1; ENABLE_FUZZING=0; print_info "📊 Quick-Audit: Fast basic assessment (5-10m)";;
        full-pentest)  PROFILE="deep";  ENABLE_SQLI=1; ENABLE_XSS=1; ENABLE_SSRF=1; ENABLE_FUZZING=1; print_info "🎯 Full-Pentest: Comprehensive scan (30-60m)";;
        bug-bounty)    PROFILE="deep";  ENABLE_SQLI=1; ENABLE_XSS=1; ENABLE_IDOR=1; ENABLE_SUBDOMAIN=1; ENABLE_SECRETS=1; print_info "💰 Bug-Bounty: High-impact focus (20-40m)";;
        compliance)    PROFILE="deep";  ENABLE_OWASP=1; ENABLE_HEADERS=1; ENABLE_SSL=1; print_info "📋 Compliance: OWASP/PCI-DSS focused (25-45m)";;
        red-team)      PROFILE="deep";  apply_stealth_profile "ghost"; ENABLE_WAF_BYPASS=1; print_info "🎭 Red-Team: Max stealth + all attacks (45-90m)";;
        recon-only)    PROFILE="quick"; ENABLE_RECON=1; ENABLE_SUBDOMAIN=1; ENABLE_PORTSCAN=1; ENABLE_FUZZING=0; ENABLE_SQLI=0; print_info "🔍 Recon-Only: Passive info gathering (3-8m)";;
    esac
}
