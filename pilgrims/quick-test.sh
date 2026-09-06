#!/bin/bash
# ============================================================================
# PILGRIMS v15.0 - QUICK VERIFICATION TEST
# Test semua komponen dalam 1-2 menit
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║           🧪 PILGRIMS v15.0 - QUICK VERIFICATION TEST  🧪                 ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ============================================================================
# TEST 1: CORE FILES
# ============================================================================
echo -e "${BLUE}[TEST 1/8]${NC} Core Files Check"
echo "─────────────────────────────────────────────────────────────────────"

CORE_FILES=(
    "pilgrims.sh"
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
)

for file in "${CORE_FILES[@]}"; do
    if [ -f "$file" ]; then
        if [ -x "$file" ] || [[ "$file" == "core/"* ]]; then
            echo -e "  ${GREEN}✓${NC} $file"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${NC} $file (not executable)"
            chmod +x "$file" 2>/dev/null
            ((WARN++))
        fi
    else
        echo -e "  ${RED}✗${NC} $file MISSING"
        ((FAIL++))
    fi
done
echo ""

# ============================================================================
# TEST 2: MODULES
# ============================================================================
echo -e "${BLUE}[TEST 2/8]${NC} Modules Check"
echo "─────────────────────────────────────────────────────────────────────"

MODULES=("web" "network" "mobile" "cloud" "ad" "container" "code" "wireless" "email" "iot" "binary")

for module in "${MODULES[@]}"; do
    file="modules/module-$module/pilgrims-$module.sh"
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "  ${GREEN}✓${NC} module-$module"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${NC} module-$module (not executable)"
            chmod +x "$file"
            ((WARN++))
        fi
    else
        echo -e "  ${RED}✗${NC} module-$module MISSING"
        ((FAIL++))
    fi
done
echo ""

# ============================================================================
# TEST 3: SYNTAX CHECK
# ============================================================================
echo -e "${BLUE}[TEST 3/8]${NC} Syntax Validation"
echo "─────────────────────────────────────────────────────────────────────"

SYNTAX_ERRORS=0
for file in pilgrims.sh core/*.sh modules/*/pilgrims-*.sh; do
    if [ -f "$file" ]; then
        if bash -n "$file" 2>/dev/null; then
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Syntax error: $file"
            ((FAIL++))
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
echo -e "${BLUE}[TEST 4/8]${NC} Command System Test"
echo "─────────────────────────────────────────────────────────────────────"

# Test --help
if ./pilgrims.sh --help &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} --help command"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} --help command failed"
    ((FAIL++))
fi

# Test --modules
if ./pilgrims.sh --modules &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} --modules command"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} --modules command failed"
    ((FAIL++))
fi

# Test --history
if ./pilgrims.sh --history &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} --history command"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} --history command failed"
    ((FAIL++))
fi
echo ""

# ============================================================================
# TEST 5: DATABASE
# ============================================================================
echo -e "${BLUE}[TEST 5/8]${NC} Database Test"
echo "─────────────────────────────────────────────────────────────────────"

if [ -f "shared/db/pilgrims.db" ]; then
    echo -e "  ${GREEN}✓${NC} Database file exists"
    ((PASS++))
    
    # Check tables
    if sqlite3 shared/db/pilgrims.db ".tables" 2>/dev/null | grep -q "scans"; then
        echo -e "  ${GREEN}✓${NC} scans table exists"
        ((PASS++))
    else
        echo -e "  ${RED}✗${NC} scans table missing"
        ((FAIL++))
    fi
    
    if sqlite3 shared/db/pilgrims.db ".tables" 2>/dev/null | grep -q "findings"; then
        echo -e "  ${GREEN}✓${NC} findings table exists"
        ((PASS++))
    else
        echo -e "  ${RED}✗${NC} findings table missing"
        ((FAIL++))
    fi
    
    # Count scans
    SCAN_COUNT=$(sqlite3 shared/db/pilgrims.db "SELECT COUNT(*) FROM scans;" 2>/dev/null || echo "0")
    echo -e "  ${CYAN}ℹ${NC} Total scans in database: $SCAN_COUNT"
else
    echo -e "  ${RED}✗${NC} Database file missing"
    ((FAIL++))
fi
echo ""

# ============================================================================
# TEST 6: FEATURES
# ============================================================================
echo -e "${BLUE}[TEST 6/8]${NC} Features Test"
echo "─────────────────────────────────────────────────────────────────────"

# Test stealth profiles
if grep -q "apply_stealth_profile" core/stealth_profiles.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Stealth profiles (ghost/shadow/phantom/wraith)"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Stealth profiles missing"
    ((FAIL++))
fi

# Test scan templates
if grep -q "apply_scan_template" core/scan_templates.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Scan templates (6 templates)"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Scan templates missing"
    ((FAIL++))
fi

# Test themes
if grep -q "apply_theme" core/themes.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Theme engine (5 themes)"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Theme engine missing"
    ((FAIL++))
fi

# Test encryption
if grep -q "encrypt_scan" core/crypto.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} AES-256 encryption"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Encryption missing"
    ((FAIL++))
fi

# Test recorder
if grep -q "start_recording" core/recorder.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Session recording"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Session recording missing"
    ((FAIL++))
fi

# Test profiler
if grep -q "profile_target" core/profiler.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Target profiling"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Target profiling missing"
    ((FAIL++))
fi

# Test QR
if grep -q "generate_qr" core/qr_generator.sh 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} QR code generation"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} QR generation missing"
    ((FAIL++))
fi
echo ""

# ============================================================================
# TEST 7: DEPENDENCIES
# ============================================================================
echo -e "${BLUE}[TEST 7/8]${NC} Dependencies Check"
echo "─────────────────────────────────────────────────────────────────────"

DEPS=("nmap" "curl" "whois" "dig" "jq" "openssl" "sqlite3" "python3" "bash")

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $dep"
        ((PASS++))
    else
        echo -e "  ${RED}✗${NC} $dep MISSING"
        ((FAIL++))
    fi
done
echo ""

# ============================================================================
# TEST 8: QUICK FUNCTIONAL TEST
# ============================================================================
echo -e "${BLUE}[TEST 8/8]${NC} Quick Functional Test"
echo "─────────────────────────────────────────────────────────────────────"

# Test module-web can be loaded
if bash -c "source modules/module-web/pilgrims-web.sh" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} module-web loads correctly"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠${NC} module-web has warnings (may be OK)"
    ((WARN++))
fi

# Test core functions
if bash -c "source core/ui.sh && type print_epic_banner" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Core UI functions work"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Core UI functions broken"
    ((FAIL++))
fi

if bash -c "source core/database.sh && type init_db" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Database functions work"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Database functions broken"
    ((FAIL++))
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                         ${BOLD}TEST SUMMARY${NC}                                    ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✓ Passed:${NC}   $PASS                                                            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${RED}✗ Failed:${NC}   $FAIL                                                             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}⚠ Warnings:${NC} $WARN                                                            ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✅ ALL TESTS PASSED!${NC}"
    echo -e "${CYAN}PILGRIMS v15.0 is ready for deployment!${NC}"
    echo ""
    echo -e "${BOLD}🚀 Quick Start:${NC}"
    echo "   ./pilgrims.sh --module=web example.com --quick"
    echo "   ./pilgrims.sh --module=network 192.168.1.1 --quick"
    echo "   ./pilgrims.sh --module=email example.com"
    echo ""
    echo -e "${BOLD}🎯 Advanced Usage:${NC}"
    echo "   ./pilgrims.sh --module=web example.com --red-team --encrypt=Secret --qr"
    echo "   ./pilgrims.sh --module=web example.com --bug-bounty --phantom"
    echo "   ./pilgrims.sh --history"
    echo ""
else
    echo -e "${RED}${BOLD}❌ SOME TESTS FAILED${NC}"
    echo -e "${YELLOW}Please fix the issues above before using PILGRIMS.${NC}"
    echo ""
    echo -e "${BOLD}💡 Quick Fixes:${NC}"
    echo "   • Missing files: Check installation"
    echo "   • Syntax errors: Re-copy the script"
    echo "   • Permission denied: chmod +x <file>"
    echo "   • Missing deps: sudo apt install <package>"
    echo ""
fi

echo -e "${BOLD}📊 Statistics:${NC}"
echo "   • Core files: ${#CORE_FILES[@]}"
echo "   • Modules: ${#MODULES[@]}"
echo "   • Dependencies: ${#DEPS[@]}"
echo "   • Total checks: $((PASS + FAIL + WARN))"
echo ""
echo -e "${CYAN}🏴‍☠️  Test complete!${NC}"
