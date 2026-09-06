#!/bin/bash
# ============================================================================
# PILGRIMS v17.0 - COMPREHENSIVE FEATURE TEST
# ============================================================================

print_epic_banner() {
    echo -e "\033[1;36m"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║           🧪 PILGRIMS v17.0 - COMPREHENSIVE TEST SUITE                    ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
}

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

print_epic_banner

# ============================================================================
# TEST 1: File Existence Check
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 1/5]${NC} Checking file existence..."
echo "─────────────────────────────────────────────────────────────────────"

files_to_check=(
    "core/forensics/memory_forensics.sh"
    "core/forensics/network_forensics.sh"
    "core/forensics/filesystem_forensics.sh"
    "core/forensics/timeline_reconstruction.sh"
    "core/malware/static_analysis.sh"
    "core/malware/dynamic_analysis.sh"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
        ((PASS++))
    else
        echo -e "  ${RED}✗${NC} $file MISSING"
        ((FAIL++))
    fi
done

echo ""

# ============================================================================
# TEST 2: Permission Check
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 2/5]${NC} Checking permissions..."
echo "─────────────────────────────────────────────────────────────────────"

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "  ${GREEN}✓${NC} $file (executable)"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${NC} $file (not executable, fixing...)"
            chmod +x "$file"
            ((WARN++))
        fi
    fi
done

echo ""

# ============================================================================
# TEST 3: Syntax Check
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 3/5]${NC} Checking syntax..."
echo "─────────────────────────────────────────────────────────────────────"

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        if bash -n "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $file (syntax OK)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} $file (syntax error)"
            ((FAIL++))
        fi
    fi
done

echo ""

# ============================================================================
# TEST 4: Functional Test - Forensics
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 4/5]${NC} Testing forensics modules..."
echo "─────────────────────────────────────────────────────────────────────"

# Create test directory
TEST_DIR="/tmp/pilgrims_test_$$"
mkdir -p "$TEST_DIR"

# Test 4.1: Memory Forensics
echo -e "  ${DIM}Testing memory forensics...${NC}"
echo "test password123 secret_key api_token" > "$TEST_DIR/test_dump.bin"
echo "mimikatz.exe process running" >> "$TEST_DIR/test_dump.bin"

if source core/forensics/memory_forensics.sh 2>/dev/null; then
    if memory_forensics "$TEST_DIR/test_dump.bin" "$TEST_DIR/memory_test" 2>/dev/null; then
        if [ -f "$TEST_DIR/memory_test/reports/MEMORY_FORENSICS_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Memory forensics (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Memory forensics (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Memory forensics (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Memory forensics (source failed)"
    ((FAIL++))
fi

# Test 4.2: Network Forensics
echo -e "  ${DIM}Testing network forensics...${NC}"
echo "PCAP test file with network traffic" > "$TEST_DIR/test_capture.pcap"
echo "HTTP GET /malware.exe" >> "$TEST_DIR/test_capture.pcap"
echo "DNS query evil-domain.xyz" >> "$TEST_DIR/test_capture.pcap"

if source core/forensics/network_forensics.sh 2>/dev/null; then
    if network_forensics "$TEST_DIR/test_capture.pcap" "$TEST_DIR/network_test" 2>/dev/null; then
        if [ -f "$TEST_DIR/network_test/reports/NETWORK_FORENSICS_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Network forensics (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Network forensics (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Network forensics (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Network forensics (source failed)"
    ((FAIL++))
fi

# Test 4.3: Filesystem Forensics
echo -e "  ${DIM}Testing filesystem forensics...${NC}"
dd if=/dev/zero of="$TEST_DIR/test_disk.img" bs=1M count=1 2>/dev/null
echo "password123 secret_key" >> "$TEST_DIR/test_disk.img"

if source core/forensics/filesystem_forensics.sh 2>/dev/null; then
    if filesystem_forensics "$TEST_DIR/test_disk.img" "$TEST_DIR/filesystem_test" 2>/dev/null; then
        if [ -f "$TEST_DIR/filesystem_test/reports/FILESYSTEM_FORENSICS_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Filesystem forensics (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Filesystem forensics (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Filesystem forensics (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Filesystem forensics (source failed)"
    ((FAIL++))
fi

# Test 4.4: Timeline Reconstruction
echo -e "  ${DIM}Testing timeline reconstruction...${NC}"
mkdir -p "$TEST_DIR/evidence_test"
echo "System log entry" > "$TEST_DIR/evidence_test/system.log"
echo "Network connection" > "$TEST_DIR/evidence_test/network.log"

if source core/forensics/timeline_reconstruction.sh 2>/dev/null; then
    if timeline_reconstruction "$TEST_DIR/evidence_test" "$TEST_DIR/timeline_test" 2>/dev/null; then
        if [ -f "$TEST_DIR/timeline_test/reports/TIMELINE_RECONSTRUCTION_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Timeline reconstruction (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Timeline reconstruction (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Timeline reconstruction (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Timeline reconstruction (source failed)"
    ((FAIL++))
fi

echo ""

# ============================================================================
# TEST 5: Functional Test - Malware Analysis
# ============================================================================
echo -e "${BLUE}${BOLD}[TEST 5/5]${NC} Testing malware analysis modules..."
echo "─────────────────────────────────────────────────────────────────────"

# Test 5.1: Static Analysis
echo -e "  ${DIM}Testing static analysis...${NC}"
cat > "$TEST_DIR/test_malware.bin" << 'EOF'
MZ
http://malware-c2.evil.com/beacon
192.168.1.100
password123
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
C:\Windows\System32\cmd.exe
VirtualAlloc
EOF

dd if=/dev/urandom bs=1024 count=5 >> "$TEST_DIR/test_malware.bin" 2>/dev/null

if source core/malware/static_analysis.sh 2>/dev/null; then
    if static_analysis "$TEST_DIR/test_malware.bin" "$TEST_DIR/static_test" 2>/dev/null; then
        if [ -f "$TEST_DIR/static_test/reports/STATIC_ANALYSIS_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Static analysis (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Static analysis (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Static analysis (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Static analysis (source failed)"
    ((FAIL++))
fi

# Test 5.2: Dynamic Analysis
echo -e "  ${DIM}Testing dynamic analysis (10s test)...${NC}"
cat > "$TEST_DIR/test_dynamic.bin" << 'EOF'
MZ
http://c2-server.evil.com/beacon
192.168.1.100
password123
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
VirtualAlloc
EOF

dd if=/dev/urandom bs=1024 count=3 >> "$TEST_DIR/test_dynamic.bin" 2>/dev/null

if source core/malware/dynamic_analysis.sh 2>/dev/null; then
    if dynamic_analysis "$TEST_DIR/test_dynamic.bin" "$TEST_DIR/dynamic_test" 10 2>/dev/null; then
        if [ -f "$TEST_DIR/dynamic_test/reports/DYNAMIC_ANALYSIS_REPORT.md" ]; then
            echo -e "  ${GREEN}✓${NC} Dynamic analysis (working)"
            ((PASS++))
        else
            echo -e "  ${RED}✗${NC} Dynamic analysis (no report generated)"
            ((FAIL++))
        fi
    else
        echo -e "  ${RED}✗${NC} Dynamic analysis (execution failed)"
        ((FAIL++))
    fi
else
    echo -e "  ${RED}✗${NC} Dynamic analysis (source failed)"
    ((FAIL++))
fi

echo ""

# ============================================================================
# Cleanup
# ============================================================================
rm -rf "$TEST_DIR"

# ============================================================================
# Summary
# ============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                         ${BOLD}TEST SUMMARY${NC}                                    ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✓ Passed:${NC}    $(printf '%-55s' "$PASS")${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${RED}✗ Failed:${NC}    $(printf '%-55s' "$FAIL")${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}⚠ Warnings:${NC} $(printf '%-55s' "$WARN")${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Success rate
TOTAL=$((PASS + FAIL))
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
    echo "║         All features are working correctly!                              ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}🎉 PILGRIMS v17.0 is ready to use!${NC}"
    echo ""
    echo -e "  ${BOLD}Available features:${NC}"
    echo "    • Memory Forensics Analysis"
    echo "    • Network Forensics (PCAP)"
    echo "    • File System Forensics"
    echo "    • Timeline Reconstruction"
    echo "    • Static Reverse Engineering"
    echo "    • Dynamic Analysis Sandbox"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo "    • Continue with YARA Rule Generation (Fitur 7)"
    echo "    • Continue with IOC Extraction (Fitur 8)"
    echo "    • Or test individual features manually"
    echo ""
else
    echo -e "${RED}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║                 ❌ SOME TESTS FAILED                                      ║"
    echo "║                                                                           ║"
    echo "║         Please fix the issues above.                                     ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}💡 Troubleshooting:${NC}"
    echo "    • Check if all files are created"
    echo "    • Ensure all files have execute permission"
    echo "    • Verify bash syntax is correct"
    echo "    • Check if dependencies are installed"
    echo ""
fi
