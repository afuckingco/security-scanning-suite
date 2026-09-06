#!/bin/bash
# Run all unit tests
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

total_pass=0
total_fail=0

for test_file in tests/unit/test_*.sh; do
    echo ""
    echo "======================================"
    echo "Running: $test_file"
    echo "======================================"
    if bash "$test_file"; then
        echo "[OK] $test_file"
    else
        echo "[FAIL] $test_file"
        total_fail=$((total_fail+1))
    fi
done

echo ""
echo "======================================"
echo "SUMMARY"
echo "======================================"
echo "Test files failed: $total_fail"
if [ $total_fail -eq 0 ]; then
    echo -e "All test files passed!"
    exit 0
else
    exit 1
fi
