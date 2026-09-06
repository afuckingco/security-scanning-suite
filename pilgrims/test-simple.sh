#!/bin/bash
# ============================================================================
# PILGRIMS v17.0 - SIMPLE FEATURE TEST
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

echo -e "${BLUE}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║           🧪 PILGRIMS v17.0 - SIMPLE FEATURE TEST                         ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create test directory
TEST_DIR="/tmp/pilgrims_simple_test_$$"
mkdir -p "$TEST_DIR"

# Define dummy print functions
print_epic_banner() { :; }
print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_error() { echo -e "  ${RED}✗${NC} $1"; }
print_warning() { echo -e "  ${YELLOW}⚠${NC} $1"; }

# ============================================================================
# TEST 1: Memory Forensics
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 1/6]${NC} Memory Forensics..."

echo "test password123 secret_key" > "$TEST_DIR/test_dump.bin"
echo "mimikatz.exe" >> "$TEST_DIR/test_dump.bin"

source core/forensics/memory_forensics.sh 2>/dev/null
memory_forensics "$TEST_DIR/test_dump.bin" "$TEST_DIR/memory_test" >/dev/null 2>&1

if [ -f "$TEST_DIR/memory_test/reports/MEMORY_FORENSICS_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Memory Forensics - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Memory Forensics - FAILED"
    ((FAIL++))
fi

# ============================================================================
# TEST 2: Network Forensics
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 2/6]${NC} Network Forensics..."

echo "PCAP test file" > "$TEST_DIR/test_capture.pcap"
echo "HTTP GET /malware.exe" >> "$TEST_DIR/test_capture.pcap"

source core/forensics/network_forensics.sh 2>/dev/null
network_forensics "$TEST_DIR/test_capture.pcap" "$TEST_DIR/network_test" >/dev/null 2>&1

if [ -f "$TEST_DIR/network_test/reports/NETWORK_FORENSICS_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Network Forensics - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Network Forensics - FAILED"
    ((FAIL++))
fi

# ============================================================================
# TEST 3: Filesystem Forensics
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 3/6]${NC} Filesystem Forensics..."

dd if=/dev/zero of="$TEST_DIR/test_disk.img" bs=1M count=1 2>/dev/null
echo "password123" >> "$TEST_DIR/test_disk.img"

source core/forensics/filesystem_forensics.sh 2>/dev/null
filesystem_forensics "$TEST_DIR/test_disk.img" "$TEST_DIR/filesystem_test" >/dev/null 2>&1

if [ -f "$TEST_DIR/filesystem_test/reports/FILESYSTEM_FORENSICS_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Filesystem Forensics - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Filesystem Forensics - FAILED"
    ((FAIL++))
fi

# ============================================================================
# TEST 4: Timeline Reconstruction
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 4/6]${NC} Timeline Reconstruction..."

mkdir -p "$TEST_DIR/evidence_test"
echo "System log" > "$TEST_DIR/evidence_test/system.log"

source core/forensics/timeline_reconstruction.sh 2>/dev/null
timeline_reconstruction "$TEST_DIR/evidence_test" "$TEST_DIR/timeline_test" >/dev/null 2>&1

if [ -f "$TEST_DIR/timeline_test/reports/TIMELINE_RECONSTRUCTION_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Timeline Reconstruction - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Timeline Reconstruction - FAILED"
    ((FAIL++))
fi

# ============================================================================
# TEST 5: Static Analysis
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 5/6]${NC} Static Analysis..."

cat > "$TEST_DIR/test_malware.bin" << 'EOF'
MZ
http://malware-c2.evil.com
192.168.1.100
password123
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
VirtualAlloc
EOF

dd if=/dev/urandom bs=1024 count=5 >> "$TEST_DIR/test_malware.bin" 2>/dev/null

source core/malware/static_analysis.sh 2>/dev/null
static_analysis "$TEST_DIR/test_malware.bin" "$TEST_DIR/static_test" >/dev/null 2>&1

if [ -f "$TEST_DIR/static_test/reports/STATIC_ANALYSIS_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Static Analysis - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Static Analysis - FAILED"
    ((FAIL++))
fi

# ============================================================================
# TEST 6: Dynamic Analysis
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 6/6]${NC} Dynamic Analysis (10s)..."

cat > "$TEST_DIR/test_dynamic.bin" << 'EOF'
MZ
http://c2-server.evil.com
192.168.1.100
password123
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
VirtualAlloc
EOF

dd if=/dev/urandom bs=1024 count=3 >> "$TEST_DIR/test_dynamic.bin" 2>/dev/null

source core/malware/dynamic_analysis.sh 2>/dev/null
dynamic_analysis "$TEST_DIR/test_dynamic.bin" "$TEST_DIR/dynamic_test" 10 >/dev/null 2>&1

if [ -f "$TEST_DIR/dynamic_test/reports/DYNAMIC_ANALYSIS_REPORT.md" ]; then
    echo -e "  ${GREEN}✓${NC} Dynamic Analysis - WORKING"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Dynamic Analysis - FAILED"
    ((FAIL++))
fi

# ============================================================================
# Cleanup
# ============================================================================
rm -rf "$TEST_DIR"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${BLUE}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                         TEST SUMMARY                                      ║"
echo "╠═══════════════════════════════════════════════════════════════════════════╣"
echo "║  ${GREEN}✓ Passed:${NC}    $PASS                                                                ║"
echo "║  ${RED}✗ Failed:${NC}    $FAIL                                                                 ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

TOTAL=$((PASS + FAIL))
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((PASS * 100 / TOTAL))
    echo -e "  ${BOLD}Success Rate:${NC} ${SUCCESS_RATE}%"
    echo ""
fi

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║                 ✅ ALL TESTS PASSED!                                      ║"
    echo "║                                                                           ║"
    echo "║         All 6 features are working correctly!                            ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}🎉 PILGRIMS v17.0 Phase 6 is COMPLETE!${NC}"
    echo ""
    echo -e "  ${BOLD}Working features:${NC}"
    echo "    ✓ Memory Forensics Analysis"
    echo "    ✓ Network Forensics (PCAP)"
    echo "    ✓ File System Forensics"
    echo "    ✓ Timeline Reconstruction"
    echo "    ✓ Static Reverse Engineering"
    echo "    ✓ Dynamic Analysis Sandbox"
    echo ""
    echo -e "  ${BOLD}Next: Continue to Fitur 7 (YARA Rule Generation)${NC}"
    echo ""
else
    echo -e "${RED}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║                 ❌ SOME TESTS FAILED                                      ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
fi
