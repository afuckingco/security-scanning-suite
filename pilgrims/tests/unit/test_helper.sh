# Simple bash test helper — no external deps
# Usage: source test_helper.sh; run_test "name" "command to test" "expected_pattern"

# Colors
RED="[0;31m"
GREEN="[0;32m"
YELLOW="[1;33m"
NC="[0m"

PASS=0
FAIL=0
FAILED_TESTS=()

assert_eq() {
    local name="$1"
    local actual="$2"
    local expected="$3"
    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}â${NC} $name"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}â${NC} $name"
        echo "      expected: $expected"
        echo "      actual:   $actual"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name")
    fi
}

assert_match() {
    local name="$1"
    local actual="$2"
    local pattern="$3"
    if echo "$actual" | grep -qE "$pattern"; then
        echo -e "  ${GREEN}â${NC} $name"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}â${NC} $name"
        echo "      pattern: $pattern"
        echo "      actual:  $actual"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name")
    fi
}

assert_file_exists() {
    local name="$1"
    local path="$2"
    if [ -f "$path" ]; then
        echo -e "  ${GREEN}â${NC} $name"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}â${NC} $name (file not found: $path)"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name")
    fi
}

assert_exit_zero() {
    local name="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo -e "  ${GREEN}â${NC} $name"
        PASS=$((PASS+1))
    else
        local exit_code=$?
        echo -e "  ${RED}â${NC} $name (exit $exit_code)"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name")
    fi
}

print_test_summary() {
    local test_file="$1"
    echo ""
    echo "=== $test_file ==="
    echo "  Passed: $PASS"
    echo "  Failed: $FAIL"
    if [ $FAIL -gt 0 ]; then
        echo -e "  ${RED}Failed tests:${NC}"
        for t in "${FAILED_TESTS[@]}"; do
            echo "    - $t"
        done
        return 1
    fi
    return 0
}
