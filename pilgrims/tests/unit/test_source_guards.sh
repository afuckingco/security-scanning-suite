#!/bin/bash
# Test: All modules have source guards that prevent auto-execution when sourced
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
source tests/unit/test_helper.sh

echo "=== Module source guards ==="

PASS=0
FAIL=0
FAILED_TESTS=()

for module in modules/*/pilgrims-*.sh; do
    name=$(basename "$module" .sh)
    
    # Time the source operation
    start=$(date +%s%N)
# shellcheck disable=SC1090  # dynamic source path
    source "$module" 2>&1
    exit_code=$?
    end=$(date +%s%N)
    elapsed_ms=$(( (end - start) / 1000000 ))
    
    # Should return 0 immediately
    if [ "$exit_code" = "0" ]; then
        echo -e "  PASS: $name returns 0"
        PASS=$((PASS+1))
    else
        echo -e "  FAIL: $name returned $exit_code"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name:source-exit")
    fi
    
    # Should be fast (< 2s)
    if [ $elapsed_ms -lt 2000 ]; then
        echo -e "  PASS: $name fast (${elapsed_ms}ms)"
        PASS=$((PASS+1))
    else
        echo -e "  FAIL: $name slow (${elapsed_ms}ms)"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name:slow")
    fi
done

echo ""
echo "Source guards: PASS=$PASS FAIL=$FAIL"
if [ $FAIL -gt 0 ]; then
    echo "Failed: ${FAILED_TESTS[@]}"
    exit 1
fi
