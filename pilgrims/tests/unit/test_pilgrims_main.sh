#!/bin/bash
# Test: pilgrims.sh basic invocation
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
source tests/unit/test_helper.sh

echo "=== pilgrims.sh smoke ==="

PASS=0
FAIL=0

# --help works
output=$(./pilgrims.sh --help 2>&1)
if echo "$output" | grep -q "PILGRIMS v17"; then
    echo -e "  PASS: --help shows PILGRIMS banner"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: --help missing banner"
    FAIL=$((FAIL+1))
fi

if echo "$output" | grep -q "Usage:"; then
    echo -e "  PASS: --help shows Usage"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: --help missing Usage"
    FAIL=$((FAIL+1))
fi

# --modules works
output=$(./pilgrims.sh --modules 2>&1)
if echo "$output" | grep -q "web"; then
    echo -e "  PASS: --modules lists web"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: --modules missing web"
    FAIL=$((FAIL+1))
fi

if echo "$output" | grep -q "network"; then
    echo -e "  PASS: --modules lists network"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: --modules missing network"
    FAIL=$((FAIL+1))
fi

# Test --version flag
output=$(./pilgrims.sh --version 2>&1)
if echo "$output" | grep -q "PILGRIMS v17"; then
    echo -e "  PASS: --version shows PILGRIMS v17 banner"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: --version missing v17 banner"
    FAIL=$((FAIL+1))
fi

# Test -V short flag
output=$(./pilgrims.sh -V 2>&1)
if echo "$output" | grep -q "License: MIT"; then
    echo -e "  PASS: -V shows license info"
    PASS=$((PASS+1))
else
    echo -e "  FAIL: -V missing license info"
    FAIL=$((FAIL+1))
fi

echo ""
echo "pilgrims.sh: PASS=$PASS FAIL=$FAIL"
if [ $FAIL -gt 0 ]; then exit 1; fi
