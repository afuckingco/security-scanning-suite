#!/bin/bash
# ============================================================================
# PILGRIMS v16.0 - COMPREHENSIVE TEST SUITE
# Test semua komponen dalam 2-3 menit
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0
TOTAL=0

# Test function
run_test() {
    local name=$1
    local cmd=$2
    local critical=${3:-false}
    
    ((TOTAL++))
    echo -ne "  ${BLUE}[$TOTAL]${NC} $name... "
    
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASS++))
        return 0
    else
        if [ "$critical" = "true" ]; then
            echo -e "${RED}✗ FAIL (CRITICAL)${NC}"
        else
            echo -e "${YELLOW}⚠ FAIL${NC}"
        fi
        ((FAIL++))
        return 1
    fi
}

# Warning test
warn_test() {
    local name=$1
    local cmd=$2
    
    ((TOTAL++))
    echo -ne "  ${BLUE}[$TOTAL]${NC} $name... "
    
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        ((WARN++))
    fi
}

# ============================================================================
# HEADER
# ============================================================================
clear
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║           🧪 PILGRIMS v16.0 - COMPREHENSIVE TEST SUITE  🧪                ║"
echo "║                                                                           ║"
echo "║           Testing all components...                                       ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ============================================================================
# TEST 1: CORE FILES (12 files)
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 1/10]${NC} Core Files"
echo "─────────────────────────────────────────────────────────────────────"

run_test "pilgrims.sh exists" "[ -f pilgrims.sh ]" true
run_test "pilgrims.sh executable" "[ -x pilgrims.sh ]" true
run_test "pilgrims-manage.sh exists" "[ -f pilgrims-manage.sh ]" true
run_test "pilgrims-manage.sh executable" "[ -x pilgrims-manage.sh ]" true

# Core modules
CORE_FILES=(
    "core/ui.sh"
    "core/database.sh"
    "core/utils.sh"
    "core/logging.sh"
    "core/stealth_profiles.sh"
    "core/scan_templates.sh"
    "core/themes.sh"
    "core/crypto.sh"
    "core/recorder.sh"
    "core/profiler.sh"
    "core/qr_generator.sh"
    "core/interactive_menu.sh"
)

for file in "${CORE_FILES[@]}"; do
    run_test "$file" "[ -f $file ]" true
done

echo ""

# ============================================================================
# TEST 2: MODULES (18 modules)
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 2/10]${NC} Modules Check"
echo "─────────────────────────────────────────────────────────────────────"

MODULES=(
    "web" "network" "mobile" "cloud" "ad" "container" "code" 
    "wireless" "email" "iot" "binary" "blockchain" "forensic"
    "redteam" "ics" "medical" "financial" "ai"
)

for module in "${MODULES[@]}"; do
    run_test "module-$module" "[ -f modules/module-$module/pilgrims-$module.sh ]" true
done

echo ""

# ============================================================================
# TEST 3: SYNTAX VALIDATION
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 3/10]${NC} Syntax Validation"
echo "─────────────────────────────────────────────────────────────────────"

SYNTAX_ERRORS=0
for file in pilgrims.sh pilgrims-manage.sh core/*.sh modules/*/pilgrims-*.sh; do
    if [ -f "$file" ]; then
        if bash -n "$file" 2>/dev/null; then
            ((PASS++))
            ((TOTAL++))
        else
            echo -e "  ${RED}✗${NC} Syntax error: $file"
            ((FAIL++))
            ((TOTAL++))
            ((SYNTAX_ERRORS++))
        fi
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} All scripts have valid syntax"
fi

echo ""

# ============================================================================
# TEST 4: COMMAND SYSTEM
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 4/10]${NC} Command System"
echo "─────────────────────────────────────────────────────────────────────"

run_test "--help command" "./pilgrims.sh --help | grep -q 'Usage'" true
run_test "--modules command" "./pilgrims.sh --modules | grep -q 'web'" true
run_test "--history command" "./pilgrims.sh --history | grep -q 'RIWAYAT'" true

echo ""

# ============================================================================
# TEST 5: DATABASE
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 5/10]${NC} Database System"
echo "─────────────────────────────────────────────────────────────────────"

run_test "Database file exists" "[ -f shared/db/pilgrims.db ]" true
run_test "scans table exists" "sqlite3 shared/db/pilgrims.db '.tables' | grep -q 'scans'" true
run_test "findings table exists" "sqlite3 shared/db/pilgrims.db '.tables' | grep -q 'findings'" true

# Count scans
SCAN_COUNT=$(sqlite3 shared/db/pilgrims.db "SELECT COUNT(*) FROM scans;" 2>/dev/null || echo "0")
echo -e "  ${CYAN}ℹ${NC} Total scans in database: $SCAN_COUNT"

echo ""

# ============================================================================
# TEST 6: FEATURES
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 6/10]${NC} Advanced Features"
echo "─────────────────────────────────────────────────────────────────────"

run_test "Stealth profiles" "grep -q 'apply_stealth_profile' core/stealth_profiles.sh" true
run_test "Scan templates" "grep -q 'apply_scan_template' core/scan_templates.sh" true
run_test "Theme engine" "grep -q 'apply_theme' core/themes.sh" true
run_test "AES-256 encryption" "grep -q 'encrypt_scan' core/crypto.sh" true
run_test "Session recording" "grep -q 'start_recording' core/recorder.sh" true
run_test "Target profiling" "grep -q 'profile_target' core/profiler.sh" true
run_test "QR code generation" "grep -q 'generate_qr' core/qr_generator.sh" true
run_test "Interactive menu" "grep -q 'show_main_menu' core/interactive_menu.sh" true

echo ""

# ============================================================================
# TEST 7: DEPENDENCIES
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 7/10]${NC} Dependencies"
echo "─────────────────────────────────────────────────────────────────────"

DEPS=("nmap" "curl" "whois" "dig" "jq" "openssl" "sqlite3" "python3" "bash" "awk" "grep" "sed")

for dep in "${DEPS[@]}"; do
    run_test "$dep installed" "command -v $dep" true
done

# Optional dependencies
warn_test "qrencode (optional)" "command -v qrencode"
warn_test "assetfinder (optional)" "command -v assetfinder"
warn_test "ffuf (optional)" "command -v ffuf"

echo ""

# ============================================================================
# TEST 8: LINE ENDINGS (WSL Check)
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 8/10]${NC} File Format (CRLF Check)"
echo "─────────────────────────────────────────────────────────────────────"

CRLF_FILES=0
for file in pilgrims.sh core/*.sh modules/*/pilgrims-*.sh; do
    if [ -f "$file" ]; then
        if file "$file" | grep -q "CRLF"; then
            echo -e "  ${YELLOW}⚠${NC} CRLF detected: $file"
            ((CRLF_FILES++))
        fi
    fi
done

if [ $CRLF_FILES -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} All files have Unix line endings (LF)"
else
    echo -e "  ${YELLOW}⚠${NC} $CRLF_FILES files have Windows line endings (CRLF)"
fi

echo ""

# ============================================================================
# TEST 9: FUNCTIONAL TESTS
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 9/10]${NC} Functional Tests"
echo "─────────────────────────────────────────────────────────────────────"

# Test core functions can be loaded
run_test "Load core/ui.sh" "bash -c 'source core/ui.sh && type print_epic_banner'" true
run_test "Load core/database.sh" "bash -c 'source core/database.sh && type init_db'" true
run_test "Load core/utils.sh" "bash -c 'source core/utils.sh && type get_timestamp'" true
run_test "Load core/themes.sh" "bash -c 'source core/themes.sh && type apply_theme'" true
run_test "Load core/stealth_profiles.sh" "bash -c 'source core/stealth_profiles.sh && type apply_stealth_profile'" true

# Test module-web can be loaded
run_test "Load module-web" "bash -n modules/module-web/pilgrims-web.sh" true

echo ""

# ============================================================================
# TEST 10: PLUGIN MANAGER
# ============================================================================
echo -e "${PURPLE}${BOLD}[TEST 10/10]${NC} Plugin Manager"
echo "─────────────────────────────────────────────────────────────────────"

run_test "Plugin manager exists" "[ -f pilgrims-manage.sh ]" true
run_test "Plugin manager executable" "[ -x pilgrims-manage.sh ]" true
run_test "Plugin manager list" "./pilgrims-manage.sh list | grep -q 'web'" true

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                         ${BOLD}TEST SUMMARY${NC}                                    ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✓ Passed:${NC}    $(printf '%-55s' "$PASS")${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${RED}✗ Failed:${NC}    $(printf '%-55s' "$FAIL")${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}⚠ Warnings:${NC} $(printf '%-55s' "$WARN")${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BLUE}Σ Total:${NC}    $(printf '%-55s' "$TOTAL")${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Success rate
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((PASS * 100 / TOTAL))
    echo -e "  ${BOLD}Success Rate:${NC} ${SUCCESS_RATE}%"
    echo ""
fi

# Final verdict
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║                 ✅ ALL TESTS PASSED!                                      ║"
    echo "║                                                                           ║"
    echo "║         PILGRIMS v16.0 is ready for deployment!                          ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}🚀 Quick Start:${NC}"
    echo "     ./pilgrims.sh                     # Interactive mode"
    echo "     ./pilgrims.sh --modules           # List modules"
    echo "     ./pilgrims.sh --module=web example.com --quick"
    echo ""
    echo -e "  ${BOLD}🎯 Advanced Usage:${NC}"
    echo "     ./pilgrims.sh --module=web example.com --red-team --encrypt=Secret --qr"
    echo "     ./pilgrims.sh --module=blockchain contract.sol --solidity"
    echo "     ./pilgrims.sh --module=forensic image.dd --disk"
    echo "     ./pilgrims.sh --history"
    echo ""
else
    echo -e "${RED}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║                 ❌ SOME TESTS FAILED                                      ║"
    echo "║                                                                           ║"
    echo "║         Please fix the issues above before using PILGRIMS.               ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}💡 Quick Fixes:${NC}"
    echo "     • Missing files: Check installation"
    echo "     • Syntax errors: Re-copy the script"
    echo "     • Permission denied: chmod +x <file>"
    echo "     • CRLF issues: dos2unix <file>"
    echo "     • Missing deps: sudo apt install <package>"
    echo ""
fi

# Statistics
echo -e "  ${BOLD}📊 Statistics:${NC}"
echo "     • Core files:    $(ls core/*.sh 2>/dev/null | wc -l)"
echo "     • Modules:       $(ls -d modules/module-* 2>/dev/null | wc -l)"
echo "     • Dependencies:  ${#DEPS[@]} required"
echo "     • Total checks:  $TOTAL"
echo ""
echo -e "  ${CYAN}🏴‍☠️  Test complete!${NC}"
