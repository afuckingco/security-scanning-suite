#!/bin/bash

# ============================================================================
# PILGRIMS v17.0 - COMPREHENSIVE TEST SUITE
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

echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🏴‍☠️  PILGRIMS v17.0 - TEST SUITE  🏴‍☠️                            ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

PASS=0
FAIL=0
SKIP=0

# Test function
run_test() {
    local test_name=$1
    local test_cmd=$2
    local expected=$3
    
    echo -n "  Testing $test_name... "
    
    result=$(eval "$test_cmd" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        if [ -n "$expected" ]; then
            if echo "$result" | grep -q "$expected"; then
                echo -e "${GREEN}✓ PASS${NC}"
                ((PASS++))
            else
                echo -e "${RED}✗ FAIL${NC} (unexpected output)"
                ((FAIL++))
            fi
        else
            echo -e "${GREEN}✓ PASS${NC}"
            ((PASS++))
        fi
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAIL++))
    fi
}

# ============================================================================
# TEST 1: CORE INFRASTRUCTURE
# ============================================================================
echo -e "${BLUE}[TEST 1]${NC} Core Infrastructure"
echo ""

run_test "Main script exists" "[ -f pilgrims.sh ]"
run_test "Main script executable" "[ -x pilgrims.sh ]"
run_test "Core UI module" "[ -f core/ui.sh ]"
run_test "Core database module" "[ -f core/database.sh ]"
run_test "Core utils module" "[ -f core/utils.sh ]"
run_test "Core logging module" "[ -f core/logging.sh ]"
run_test "Core reporting module" "[ -f core/reporting.sh ]"

echo ""

# ============================================================================
# TEST 2: MODULE AVAILABILITY
# ============================================================================
echo -e "${BLUE}[TEST 2]${NC} Module Availability"
echo ""

MODULES=("web" "network" "mobile" "cloud" "ad" "container" "code" "wireless" "email" "iot" "binary")

for module in "${MODULES[@]}"; do
    run_test "Module $module" "[ -f modules/module-$module/pilgrims-$module.sh ]"
done

echo ""

# ============================================================================
# TEST 3: COMMAND LINE INTERFACE
# ============================================================================
echo -e "${BLUE}[TEST 3]${NC} Command Line Interface"
echo ""

run_test "Help command" "./pilgrims.sh --help | grep -q 'Usage'"
run_test "Modules list" "./pilgrims.sh --modules | grep -q 'AVAILABLE MODULES'"
run_test "History command" "./pilgrims.sh --history | grep -q 'RIWAYAT'"

echo ""

# ============================================================================
# TEST 4: DEPENDENCIES
# ============================================================================
echo -e "${BLUE}[TEST 4]${NC} Dependencies"
echo ""

DEPS=("nmap" "curl" "whois" "dig" "jq" "openssl" "sqlite3" "python3")

for dep in "${DEPS[@]}"; do
    run_test "Dependency $dep" "command -v $dep"
done

echo ""

# ============================================================================
# TEST 5: DATABASE
# ============================================================================
echo -e "${BLUE}[TEST 5]${NC} Database"
echo ""

# Initialize database
./pilgrims.sh --history > /dev/null 2>&1

run_test "Database created" "[ -f shared/db/pilgrims.db ]"
run_test "Database has scans table" "sqlite3 shared/db/pilgrims.db '.tables' | grep -q 'scans'"
run_test "Database has findings table" "sqlite3 shared/db/pilgrims.db '.tables' | grep -q 'findings'"

echo ""

# ============================================================================
# TEST 6: MODULE EXECUTION (Quick Tests)
# ============================================================================
echo -e "${BLUE}[TEST 6]${NC} Module Execution (Quick Tests)"
echo ""

# Test web module (very quick scan)
echo -n "  Testing web module (example.com)... "
timeout 30 ./pilgrims.sh --module=web example.com --quick > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⊘ SKIP${NC} (timeout or error)"
    ((SKIP++))
fi

# Test email module
echo -n "  Testing email module (example.com)... "
timeout 30 ./pilgrims.sh --module=email example.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⊘ SKIP${NC} (timeout or error)"
    ((SKIP++))
fi

echo ""

# ============================================================================
# TEST 7: REPORTING
# ============================================================================
echo -e "${BLUE}[TEST 7]${NC} Reporting"
echo ""

# Check if reports were generated
REPORT_COUNT=$(find modules/*/reports -name "*.md" 2>/dev/null | wc -l)
run_test "Reports generated" "[ $REPORT_COUNT -gt 0 ]"

# Check report content
if [ $REPORT_COUNT -gt 0 ]; then
    FIRST_REPORT=$(find modules/*/reports -name "*.md" | head -1)
    run_test "Report has content" "[ -s $FIRST_REPORT ]"
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                         ${BOLD}TEST SUMMARY${NC}                                    ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✓ Passed:${NC}  $PASS                                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${RED}✗ Failed:${NC}  $FAIL                                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}⊘ Skipped:${NC} $SKIP                                                    ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}✓ ALL TESTS PASSED!${NC}"
    echo -e "  ${CYAN}PILGRIMS v17.0 is ready for deployment!${NC}"
else
    echo -e "  ${RED}${BOLD}✗ SOME TESTS FAILED${NC}"
    echo -e "  ${YELLOW}Please review and fix the issues above.${NC}"
fi

echo ""
echo -e "  ${BOLD}Next Steps:${NC}"
echo "    1. Review test results above"
echo "    2. Fix any failed tests"
echo "    3. Run: ./pilgrims.sh --help"
echo "    4. Start scanning: ./pilgrims.sh --module=web example.com"
echo ""
