#!/bin/bash

# ============================================================================
# PILGRIMS-CODE - Source Code Review (SAST) Module
# ============================================================================

MODULE_NAME="code"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

TARGET="$1"
shift

LANG="auto"
SCAN_SECRETS=1
SCAN_DEPS=1

for arg in "$@"; do
    case $arg in
        --lang=*) LANG="${arg#*=}" ;;
        --no-secrets) SCAN_SECRETS=0 ;;
        --no-deps) SCAN_DEPS=0 ;;
    esac
done

if [ ! -d "$TARGET" ]; then
    print_error "Target directory not found: $TARGET"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/code_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "CODE" "💻 SOURCE CODE REVIEW (SAST)"
print_info "Target: $TARGET"
print_info "Language: $LANG"
echo ""

# Detect language
if [ "$LANG" = "auto" ]; then
    print_task "Detecting programming languages"
    
    PY_COUNT=$(find "$TARGET" -name "*.py" | wc -l)
    JS_COUNT=$(find "$TARGET" -name "*.js" | wc -l)
    PHP_COUNT=$(find "$TARGET" -name "*.php" | wc -l)
    JAVA_COUNT=$(find "$TARGET" -name "*.java" | wc -l)
    
    if [ $PY_COUNT -gt 0 ]; then LANG="python"; fi
    if [ $JS_COUNT -gt 0 ]; then LANG="javascript"; fi
    if [ $PHP_COUNT -gt 0 ]; then LANG="php"; fi
    if [ $JAVA_COUNT -gt 0 ]; then LANG="java"; fi
    
    print_success "Detected language: $LANG"
fi

# ============================================================================
# SECRET SCANNING
# ============================================================================
if [ $SCAN_SECRETS -eq 1 ]; then
    print_phase_header "1" "🔑 SECRET SCANNING"
    print_task "Scanning for hardcoded secrets"
    
    > "$OUTPUT_DIR/secrets.txt"
    
    # API Keys patterns
    grep -rEn "(AKIA[0-9A-Z]{16}|api[_-]?key|apikey|secret[_-]?key|password|passwd)" "$TARGET" \
        --include="*.py" --include="*.js" --include="*.php" --include="*.java" \
        --include="*.env" --include="*.yml" --include="*.yaml" --include="*.json" \
        2>/dev/null | head -50 > "$OUTPUT_DIR/secrets.txt"
    
    SECRETS=$(wc -l < "$OUTPUT_DIR/secrets.txt")
    if [ $SECRETS -gt 0 ]; then
        print_critical "Found $SECRETS potential secrets"
        echo "[CRITICAL] $SECRETS hardcoded secrets detected" > "$OUTPUT_DIR/secret_findings.txt"
    else
        print_success "No hardcoded secrets found"
    fi
fi

# ============================================================================
# VULNERABILITY SCANNING
# ============================================================================
print_phase_header "2" "⚠️  VULNERABILITY SCANNING"

# Check for Semgrep
if command_exists semgrep; then
    print_task "Running Semgrep analysis"
    semgrep --config=p/ci "$TARGET" --json > "$OUTPUT_DIR/semgrep.json" 2>/dev/null
    
    VULNS=$(jq '.results | length' "$OUTPUT_DIR/semgrep.json" 2>/dev/null || echo "0")
    print_success "Found $VULNS potential vulnerabilities"
else
    print_warning "Semgrep not installed, using pattern-based scanning"
    
    # Pattern-based scanning
    > "$OUTPUT_DIR/vulns.txt"
    
    case "$LANG" in
        python)
            # SQL Injection
            grep -rEn "(execute|executemany).*%" "$TARGET" --include="*.py" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            # Command Injection
            grep -rEn "(os\.system|subprocess\.call|subprocess\.Popen)" "$TARGET" --include="*.py" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            # Eval
            grep -rEn "\beval\(" "$TARGET" --include="*.py" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            ;;
        javascript)
            # XSS
            grep -rEn "(innerHTML|outerHTML|document\.write)" "$TARGET" --include="*.js" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            # Eval
            grep -rEn "\beval\(" "$TARGET" --include="*.js" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            ;;
        php)
            # SQL Injection
            grep -rEn "(mysql_query|mysqli_query).*\\\$" "$TARGET" --include="*.php" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            # Command Injection
            grep -rEn "(system|exec|passthru|shell_exec)" "$TARGET" --include="*.php" >> "$OUTPUT_DIR/vulns.txt" 2>/dev/null
            ;;
    esac
    
    VULNS=$(wc -l < "$OUTPUT_DIR/vulns.txt")
    print_info "Found $VULNS potential vulnerabilities (pattern-based)"
fi

# ============================================================================
# DEPENDENCY CHECK
# ============================================================================
if [ $SCAN_DEPS -eq 1 ]; then
    print_phase_header "3" "📦 DEPENDENCY ANALYSIS"
    print_task "Checking for vulnerable dependencies"
    
    > "$OUTPUT_DIR/deps.txt"
    
    case "$LANG" in
        python)
            if [ -f "$TARGET/requirements.txt" ]; then
                if command_exists pip-audit; then
                    pip-audit -r "$TARGET/requirements.txt" > "$OUTPUT_DIR/deps.txt" 2>&1
                else
                    print_warning "pip-audit not installed"
                    print_info "Install with: pip install pip-audit"
                fi
            fi
            ;;
        javascript)
            if [ -f "$TARGET/package.json" ]; then
                cd "$TARGET" && npm audit --json > "$OUTPUT_DIR/deps.json" 2>&1
                VULN_DEPS=$(jq '.metadata.vulnerabilities.total' "$OUTPUT_DIR/deps.json" 2>/dev/null || echo "0")
                echo "Vulnerable dependencies: $VULN_DEPS" > "$OUTPUT_DIR/deps.txt"
            fi
            ;;
    esac
    
    if [ -s "$OUTPUT_DIR/deps.txt" ]; then
        print_success "Dependency analysis complete"
    else
        print_info "No dependency files found"
    fi
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# 💻 Source Code Review Report

**Target:** $TARGET  
**Language:** $LANG  
**Date:** $(date)

## 📊 Summary

- **Secrets Found:** $(wc -l < "$OUTPUT_DIR/secrets.txt" 2>/dev/null || echo "0")
- **Vulnerabilities:** $VULNS
- **Dependencies:** Analyzed

## 🔑 Secrets

\`\`\`
$(head -20 "$OUTPUT_DIR/secrets.txt" 2>/dev/null || echo "None found")
\`\`\`

## ⚠️ Vulnerabilities

\`\`\`
$(head -20 "$OUTPUT_DIR/vulns.txt" 2>/dev/null || echo "None found")
\`\`\`

## 📦 Dependencies

\`\`\`
$(cat "$OUTPUT_DIR/deps.txt" 2>/dev/null || echo "No dependency analysis")
\`\`\`

## 🛡️ Recommendations

- Remove all hardcoded secrets
- Use environment variables for configuration
- Implement parameterized queries
- Sanitize all user inputs
- Update vulnerable dependencies
- Implement code review process
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
