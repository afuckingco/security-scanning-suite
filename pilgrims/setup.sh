#!/bin/bash
# Strict mode guard (errexit + nounset + pipefail)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/strict.sh"

# ============================================================================
# PILGRIMS v17.0 - AUTOMATED SETUP SCRIPT
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
║           🏴‍☠️  PILGRIMS v17.0 - ULTIMATE SECURITY FRAMEWORK SETUP  🏴‍☠️                     ║
║                                                                           ║
║           "Navigating the Digital Seas of Cybersecurity"                  ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# ============================================================================
# CHECK PREREQUISITES
# ============================================================================
echo -e "${BLUE}[1/6]${NC} Checking prerequisites..."

# Check if running as root for some installations
if [ "$EUID" -ne 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} Some features require root privileges"
    echo -e "  ${DIM}You may need to run: sudo $0${NC}"
    echo ""
fi

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================
echo -e "${BLUE}[2/6]${NC} Installing dependencies..."

# Core dependencies
CORE_DEPS=(
    "nmap"
    "curl"
    "whois"
    "dnsutils"
    "jq"
    "openssl"
    "python3"
    "python3-pip"
    "sqlite3"
    "qrencode"
    "netcat"
    "bc"
    "file"
    "binutils"
)

echo "  Installing core dependencies..."
sudo apt update -qq
for dep in "${CORE_DEPS[@]}"; do
    if ! command -v $dep &> /dev/null; then
        echo -e "  ${YELLOW}→${NC} Installing $dep..."
        sudo apt install -y -qq $dep > /dev/null 2>&1
    else
        echo -e "  ${GREEN}✓${NC} $dep already installed"
    fi
done

# Security tools
SECURITY_DEPS=(
    "assetfinder"
    "ffuf"
    "whatweb"
    "wafw00f"
    "dirb"
    "apktool"
    "hashcat"
    "john"
    "trivy"
    "yara"
    "binwalk"
)

echo ""
echo "  Installing security tools..."
for dep in "${SECURITY_DEPS[@]}"; do
    if ! command -v $dep &> /dev/null; then
        echo -e "  ${YELLOW}→${NC} Installing $dep..."
        sudo apt install -y -qq $dep > /dev/null 2>&1 || echo -e "  ${YELLOW}⚠${NC} $dep not available in repos"
    else
        echo -e "  ${GREEN}✓${NC} $dep already installed"
    fi
done

# Python packages
echo ""
echo "  Installing Python packages..."
pip3 install -q semgrep bandit pip-audit trufflehog 2>/dev/null || echo -e "  ${YELLOW}⚠${NC} Some Python packages failed"

# ============================================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================================
echo ""
echo -e "${BLUE}[3/6]${NC} Creating directory structure..."

DIRS=(
    "core"
    "shared/db"
    "shared/logs"
    "shared/wordlists"
    "shared/payloads"
    "reports"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "  ${GREEN}✓${NC} Created $dir"
    else
        echo -e "  ${GREEN}✓${NC} $dir exists"
    fi
done

# Create module directories
MODULES=(
    "module-web"
    "module-network"
    "module-mobile"
    "module-cloud"
    "module-ad"
    "module-container"
    "module-code"
    "module-wireless"
    "module-email"
    "module-iot"
    "module-binary"
)

for module in "${MODULES[@]}"; do
    if [ ! -d "modules/$module" ]; then
        mkdir -p "modules/$module"/{plugins,reports,logs}
        echo -e "  ${GREEN}✓${NC} Created modules/$module"
    else
        echo -e "  ${GREEN}✓${NC} modules/$module exists"
    fi
done

# ============================================================================
# SET PERMISSIONS
# ============================================================================
echo ""
echo -e "${BLUE}[4/6]${NC} Setting permissions..."

chmod +x pilgrims.sh 2>/dev/null
chmod +x pilgrims-manage.sh 2>/dev/null
chmod +x core/*.sh 2>/dev/null
chmod +x modules/*/pilgrims-*.sh 2>/dev/null

echo -e "  ${GREEN}✓${NC} Permissions set"

# ============================================================================
# VERIFY INSTALLATION
# ============================================================================
echo ""
echo -e "${BLUE}[5/6]${NC} Verifying installation..."

ERRORS=0

# Check main script
if [ -f "pilgrims.sh" ] && [ -x "pilgrims.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Main script OK"
else
    echo -e "  ${RED}✗${NC} Main script missing or not executable"
    ((ERRORS++))
fi

# Check core modules
CORE_FILES=("ui.sh" "database.sh" "utils.sh" "logging.sh" "reporting.sh")
for file in "${CORE_FILES[@]}"; do
    if [ -f "core/$file" ]; then
        echo -e "  ${GREEN}✓${NC} core/$file OK"
    else
        echo -e "  ${RED}✗${NC} core/$file missing"
        ((ERRORS++))
    fi
done

# Check modules
for module in "${MODULES[@]}"; do
    module_name=$(echo $module | sed 's/module-//')
    if [ -f "modules/$module/pilgrims-$module_name.sh" ]; then
        echo -e "  ${GREEN}✓${NC} Module $module_name OK"
    else
        echo -e "  ${YELLOW}⊘${NC} Module $module_name not found"
    fi
done

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo ""
echo -e "${BLUE}[6/6]${NC} Setup complete!"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    ✓ PILGRIMS v17.0 SETUP SUCCESSFUL!                     ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}Quick Start:${NC}"
    echo "    ./pilgrims.sh --help                    # Show help"
    echo "    ./pilgrims.sh --modules                 # List modules"
    echo "    ./pilgrims.sh --module=web example.com  # Web scan"
    echo "    ./pilgrims.sh --history                 # View history"
    echo ""
    echo -e "  ${BOLD}Module Manager:${NC}"
    echo "    ./pilgrims-manage.sh list               # List modules"
    echo "    ./pilgrims-manage.sh install <name>     # Install module"
    echo ""
else
    echo -e "${RED}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    ✗ SETUP COMPLETED WITH ERRORS                          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "  ${RED}Found $ERRORS error(s). Please fix before using PILGRIMS.${NC}"
    echo ""
fi

echo -e "  ${CYAN}🏴‍☠️  Happy hunting, Captain!${NC}"
echo ""
