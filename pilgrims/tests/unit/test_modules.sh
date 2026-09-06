#!/bin/bash
# Test: Each module can be loaded (sourced) AND has source guard + MODULE_NAME
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
source tests/unit/test_helper.sh

echo "=== Per-module smoke tests ==="

PASS=0
FAIL=0
FAILED_MODULES=()

for module in modules/*/pilgrims-*.sh; do
    name=$(basename "$module" .sh)

    # Test 1: source with timeout (must return 0 quickly)
    start=$(date +%s%N)
    output=$(timeout 3 bash -c "source \"$module\" 2>&1")
    exit_code=$?
    end=$(date +%s%N)
    elapsed_ms=$(( (end - start) / 1000000 ))

    if [ "$exit_code" = "0" ] && [ $elapsed_ms -lt 2000 ]; then
        echo -e "  PASS: $name sources cleanly (${elapsed_ms}ms)"
        PASS=$((PASS+1))
    else
        echo -e "  FAIL: $name (exit=$exit_code, ${elapsed_ms}ms)"
        FAIL=$((FAIL+1))
        FAILED_MODULES+=("$name")
    fi

    # Test 2: verify source guard pattern present in script
    if grep -qE 'BASH_SOURCE\[0\]|BASH_SOURCE' "$module"; then
        echo -e "  PASS: $name has source guard"
        PASS=$((PASS+1))
    else
        echo -e "  FAIL: $name missing source guard"
        FAIL=$((FAIL+1))
        FAILED_MODULES+=("$name:no-guard")
    fi

    # Test 3: verify MODULE_NAME defined
    if grep -qE '^MODULE_NAME=' "$module"; then
        echo -e "  PASS: $name defines MODULE_NAME"
        PASS=$((PASS+1))
    else
        echo -e "  FAIL: $name missing MODULE_NAME"
        FAIL=$((FAIL+1))
        FAILED_MODULES+=("$name:no-module-name")
    fi
done

echo ""
echo "Per-module smoke: PASS=$PASS FAIL=$FAIL"
if [ $FAIL -gt 0 ]; then
    echo "Failed: ${FAILED_MODULES[@]}"
    exit 1
fi
