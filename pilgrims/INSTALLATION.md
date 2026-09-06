# 📦 Installation Guide

## System Requirements

### Minimum Requirements
- **OS:** Linux (Ubuntu 20.04+, Debian 11+, Kali Linux) or WSL2
- **RAM:** 4GB (8GB recommended)
- **Storage:** 2GB free space
- **Network:** Internet connection (optional, for online features)

### Recommended Specifications
- **OS:** Kali Linux 2024.1+ or Ubuntu 22.04 LTS
- **RAM:** 16GB
- **Storage:** 10GB free space
- **CPU:** 4+ cores
- **Network:** Stable internet connection

---

## Installation Methods

### Method 1: Manual Installation (Recommended)

#### Step 1: Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install core dependencies (Bash + SQLite + standard CLI tools only)
sudo apt install -y \
    nmap \
    curl \
    whois \
    dnsutils \
    jq \
    openssl \
    sqlite3 \
    qrencode \
    netcat-openbsd \
    bc \
    file \
    binutils \
    strings \
    xxd \
    uuid-runtime \
    dig
```

#### Step 2: Download PILGRIMS

```bash
# Create directory
mkdir -p ~/pilgrims-v17
cd ~/pilgrims-v17

# Download or copy files
# (if from repository)
git clone https://github.com/your-repo/pilgrims-v17.git .

# Or copy manually
cp -r /path/to/pilgrims-v17/* ~/pilgrims-v17/
```

#### Step 3: Set Permissions

```bash
# Set execute permissions
chmod +x pilgrims.sh
chmod +x pilgrims-manage.sh
chmod +x core/*.sh
chmod +x modules/*/pilgrims-*.sh

# Set directory permissions
find . -type d -exec chmod 755 {} \;
find . -type f -name "*.sh" -exec chmod 755 {} \;
```

#### Step 4: Verify Installation

```bash
# Check structure
ls -la

# Expected layout (version 17.0):
# .
# ├── pilgrims.sh              # main entry point (Bash)
# ├── pilgrims-manage.sh       # module manager
# ├── core/                    # Bash library: ui.sh database.sh utils.sh logging.sh
# │                           #   stealth_profiles.sh scan_templates.sh themes.sh
# │                           #   crypto.sh recorder.sh profiler.sh qr_generator.sh resume.sh
# ├── modules/                 # Each module: module-<name>/pilgrims-<name>.sh
# └── tests/  docs/  packaging/

# Test installation
./pilgrims.sh --help
```

#### Step 5: Run Test Suite

```bash
# Run comprehensive test
./test-all-features.sh

# Or simple test
./test-simple.sh

# Expected output:
# ✅ ALL TESTS PASSED!
# Success Rate: 100%
```

---

### Method 2: Docker Installation

```bash
# Build Docker image
docker build -t pilgrims-v17 .

# Run container
docker run -it --rm \
    -v ~/pilgrims-reports:/reports \
    pilgrims-v17

# Inside container
./pilgrims.sh --help
```

---

### Method 3: WSL2 Installation (Windows)

#### Step 1: Install WSL2

```powershell
# PowerShell (Admin)
wsl --install -d Ubuntu-22.04
```

#### Step 2: Setup WSL Environment

```bash
# Update WSL
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y nmap curl whois dnsutils jq openssl sqlite3

# Install PILGRIMS
mkdir -p ~/pilgrims-v17
cd ~/pilgrims-v17
# ... (follow manual installation steps)
```

---

## Post-Installation Configuration

### 1. Configure Database

```bash
# Initialize database (auto-created on first run)
./pilgrims.sh --history

# Verify database (auto-created at shared/db/pilgrims.db)
sqlite3 shared/db/pilgrims.db ".tables"
```

**Note:** The `shared/` directory is created automatically by the first run. No manual setup required.

### 2. Configure Logging

```bash
# Create log directory (optional; auto-created at logs/)
mkdir -p logs

# Set log level (optional)
export PILGRIMS_LOG_LEVEL=INFO
```

### 3. Configure Themes (Optional)

```bash
# Available themes: default, matrix, blood, ocean, mono
export PILGRIMS_THEME=matrix

# Add to ~/.bashrc for persistence
echo 'export PILGRIMS_THEME=matrix' >> ~/.bashrc
```

### 4. Configure Aliases (Optional)

```bash
# Add to ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# PILGRIMS aliases
alias pgr='./pilgrims.sh'
alias pgr-web='./pilgrims.sh --module=web'
alias pgr-net='sudo ./pilgrims.sh --module=network'
alias pgr-forensics='./pilgrims.sh --memory-forensics'
alias pgr-malware='./pilgrims.sh --static-analysis'

EOF

source ~/.bashrc
```

---

## Verification Checklist

After installation, verify:

- [ ] All files are present
- [ ] All files have execute permissions
- [ ] Dependencies are installed
- [ ] Database is initialized
- [ ] Test suite passes
- [ ] Interactive menu works
- [ ] At least one module can be executed

---

## Troubleshooting Installation

### Issue: Permission Denied

```bash
# Fix permissions
chmod +x pilgrims.sh
chmod +x core/*.sh
chmod +x modules/*/pilgrims-*.sh
```

### Issue: Command Not Found

```bash
# Check PATH
echo $PATH

# Add to PATH if needed
export PATH=$PATH:~/pilgrims-v17
```

### Issue: Missing Dependencies

```bash
# Install missing dependencies
sudo apt install -y nmap curl whois jq sqlite3
```

### Issue: CRLF Line Endings (WSL)

```bash
# Install dos2unix
sudo apt install dos2unix

# Convert files
find . -type f -name "*.sh" -exec dos2unix {} \;
```

---

## Update Instructions

### Update to Latest Version

```bash
# Backup current installation
cp -r ~/pilgrims-v17 ~/pilgrims-v17-backup-$(date +%Y%m%d)

# Download new version
cd ~/pilgrims-v17
git pull

# Or copy new files
cp -r /path/to/new-version/* .

# Set permissions
chmod +x pilgrims.sh
chmod +x core/*.sh
chmod +x modules/*/pilgrims-*.sh

# Test
./test-simple.sh
```

---

## Uninstallation

```bash
# Remove installation
rm -rf ~/pilgrims-v17

# Remove dependencies (optional)
sudo apt remove -y nmap curl whois dnsutils jq openssl sqlite3
```

---

## Next Steps

After successful installation:

1. Read [User Guide](USER_GUIDE.md)
2. Try [Examples](EXAMPLES.md)
3. Explore [Modules](MODULES.md)
4. Check [Commands](COMMANDS.md)

---

**🏴‍☠️ Installation Complete! Ready to sail!**
