#!/bin/bash
# Test: Core helper functions work correctly
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
source tests/unit/test_helper.sh

echo "=== Core helpers ==="

PASS=0
FAIL=0

# Source core files
source core/utils.sh

# Test get_timestamp (format: YYYYMMDD_HHMMSS)
result=$(get_timestamp)
if echo "$result" | grep -qE "^[0-9]{8}_[0-9]{6}$"; then
    echo -e "  PASS: get_timestamp returns YYYYMMDD_HHMMSS ($result)"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: get_timestamp = $result"
    FAIL=$((FAIL+1))
fi

# Test command_exists
if command_exists bash; then
    echo -e "  PASS: command_exists bash = true"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: command_exists bash = false"
    FAIL=$((FAIL+1))
fi

if ! command_exists nonexistentcommand_xyz123; then
    echo -e "  PASS: command_exists nonexistent = false"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: command_exists nonexistent = true"
    FAIL=$((FAIL+1))
fi

echo ""
echo "Helpers: PASS=$PASS FAIL=$FAIL"
if [ $FAIL -gt 0 ]; then exit 1; fi
