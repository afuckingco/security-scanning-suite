# 📘 User Guide

> **⚠ Implementation Note:** This guide documents the framework as designed. Some features (advanced forensics, compliance automation, advanced crypto) are **not yet implemented** in the Bash codebase — see MODULES.md for real-vs-stub status. The tool is **Bash + SQLite + standard CLI tools only**; no Go, Python, or Postgres components.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Interactive Mode](#interactive-mode)
3. [Command Line Mode](#command-line-mode)
4. [Module Usage](#module-usage)
5. [Advanced Features](#advanced-features)
6. [Report Analysis](#report-analysis)
7. [Best Practices](#best-practices)

---

## Getting Started

### First Run

```bash
# Start PILGRIMS
cd ~/pilgrims-v17
./pilgrims.sh
```

You'll see the epic banner and interactive menu:

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║        🏴‍☠️  PILGRIMS v17.0 - ULTIMATE SECURITY FRAMEWORK                  ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

    🎯 PILGRIMS v17.0 - INTERACTIVE MODE

    Pilih kategori scanning:

    ━━━ 🌐 WEB & NETWORK ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ 1] 🌐 Web Application Security
    [ 2] 🌐 Network Security Assessment
    [ 3] 📡 Wireless Security
    [ 4] 📧 Email Security
    ...
```

---

## Interactive Mode

### Navigation

1. **Select Category:** Enter number (1-84) or letter (H/I/S/T/Q)
2. **Provide Input:** Follow prompts for target, options, etc.
3. **View Results:** Reports saved in `reports/` directory

### Menu Categories

#### Web & Network (1-4)
- `[1]` Web Application Security
- `[2]` Network Security Assessment
- `[3]` Wireless Security
- `[4]` Email Security

#### Cloud & Infrastructure (5-7)
- `[5]` Cloud Security (AWS/Azure/GCP)
- `[6]` Active Directory Security
- `[7]` Container & Kubernetes

#### Mobile & Code (8-11)
- `[8]` Mobile App Security (Android/iOS)
- `[9]` Source Code Review (SAST)
- `[10]` IoT/Firmware Security
- `[11]` Binary Analysis & Reverse Engineering

#### Specialized Industries (12-17)
- `[12]` Blockchain & Web3 Security
- `[13]` ICS/SCADA Security
- `[14]` Medical Device Security
- `[15]` Financial Systems Security
- `[16]` Automotive Security
- `[17]` 5G/Telecom Security

#### Advanced Techniques (18-23)
- `[18]` Red Team Automation
- `[19]` Purple Team Integration
- `[20]` Digital Forensics
- `[21]` Malware Analysis
- `[22]` AI/ML Model Security
- `[23]` Gaming Security

#### Enterprise Features (24-27)
- `[24]` Threat Intelligence
- `[25]` CI/CD Pipeline Integration
- `[26]` Multi-User Team Mode
- `[27]` Custom Plugin Manager

#### Phase 1-6 Features (28-84)
- `[28-32]` Resume & Compare
- `[33-36]` Advanced Testing
- `[37-48]` Hardware, AI/ML, Supply Chain
- `[49-60]` Cloud-Native, Protocol, DevSecOps
- `[61-72]` Compliance, Crypto, Threat Intel
- `[73-84]` Digital Forensics, Malware Analysis

#### Utilities
- `[H]` Help & Documentation
- `[I]` Scan History
- `[S]` System Status
- `[T]` Change Theme
- `[Q]` Quit

---

## Command Line Mode

### Basic Syntax

```bash
./pilgrims.sh [options] <target>
```

### Common Commands

#### List Modules
```bash
./pilgrims.sh --modules
```

#### Show Help
```bash
./pilgrims.sh --help
```

#### View History
```bash
./pilgrims.sh --history
```

### Module Scanning

#### Web Application
```bash
# Quick scan
./pilgrims.sh --module=web example.com --quick

# Deep scan
./pilgrims.sh --module=web example.com --deep

# Bug bounty mode
./pilgrims.sh --module=web example.com --bug-bounty

# Red team mode
./pilgrims.sh --module=web example.com --red-team
```

#### Network Security
```bash
# Quick scan
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick

# Deep scan
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep
```

#### Cloud Security
```bash
# AWS
./pilgrims.sh --module=cloud --aws

# Azure
./pilgrims.sh --module=cloud --azure

# GCP
./pilgrims.sh --module=cloud --gcp
```

### Advanced Features

#### Resume Scan
```bash
# List resumable scans
./pilgrims.sh --resume-list

# Resume specific scan
./pilgrims.sh --resume=web_20260622_221500
```

#### Compare Scans
```bash
./pilgrims.sh --module=web example.com --compare
```

#### Attack Path Mapping
```bash
./pilgrims.sh --module=web example.com --attack-paths
```

#### MITRE ATT&CK Mapping
```bash
./pilgrims.sh --module=web example.com --mitre
```

#### Parallel Scanning
```bash
# Create targets file
echo "example.com" > targets.txt
echo "test.com" >> targets.txt

# Scan in parallel
./pilgrims.sh --module=web --parallel=targets.txt
```

### Digital Forensics

#### Memory Forensics
```bash
./pilgrims.sh --memory-forensics=dump.bin
```

#### Network Forensics
```bash
./pilgrims.sh --network-forensics=capture.pcap
```

#### Filesystem Forensics
```bash
./pilgrims.sh --filesystem-forensics=disk.img
```

#### Timeline Reconstruction
```bash
./pilgrims.sh --timeline=evidence_dir/
```

### Malware Analysis

#### Static Analysis
```bash
./pilgrims.sh --static-analysis=malware.exe
```

#### Dynamic Analysis
```bash
./pilgrims.sh --dynamic-analysis=suspicious.exe 60
```

#### YARA Rule Generation
```bash
./pilgrims.sh --yara=sample.bin
```

#### IOC Extraction
```bash
./pilgrims.sh --ioc=evidence_dir/
```

### Compliance

#### SOC2
```bash
./pilgrims.sh --soc2=organization
```

#### ISO27001
```bash
./pilgrims.sh --iso27001=organization
```

#### HIPAA
```bash
./pilgrims.sh --hipaa=healthcare_org
```

#### PCI-DSS
```bash
./pilgrims.sh --pcidss=payment_system
```

### Cryptography

#### Zero-Knowledge Proof
```bash
./pilgrims.sh --zkp=blockchain_protocol
```

#### Post-Quantum
```bash
./pilgrims.sh --pqc=system
```

#### Multi-Party Computation
```bash
./pilgrims.sh --mpc=protocol
```

#### Homomorphic Encryption
```bash
./pilgrims.sh --fhe=implementation
```

### Threat Intelligence

#### MITRE Navigator
```bash
./pilgrims.sh --mitre-nav=target
```

#### STIX/TAXII
```bash
./pilgrims.sh --stix=target
```

#### SOAR Integration
```bash
./pilgrims.sh --soar=target
```

#### Incident Response
```bash
./pilgrims.sh --ir=incident
```

---

## Module Usage

### Web Application Security

#### Quick Scan
```bash
./pilgrims.sh --module=web example.com --quick
```

**What it does:**
- Basic reconnaissance
- Common vulnerability checks
- Security headers analysis
- Quick port scan

**Duration:** 5-10 minutes

#### Deep Scan
```bash
./pilgrims.sh --module=web example.com --deep
```

**What it does:**
- Full vulnerability assessment
- All web security checks
- Comprehensive testing
- Detailed reporting

**Duration:** 30-60 minutes

#### Bug Bounty Mode
```bash
./pilgrims.sh --module=web example.com --bug-bounty
```

**What it does:**
- Focus on high-impact vulnerabilities
- Bug bounty specific checks
- Priority on critical findings

**Duration:** 20-40 minutes

### Network Security

#### Quick Scan
```bash
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick
```

**What it does:**
- Host discovery
- Basic port scan
- Service detection

**Duration:** 5-15 minutes

#### Deep Scan
```bash
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep
```

**What it does:**
- Full port scan
- OS detection
- Vulnerability scanning
- Service enumeration

**Duration:** 30-60 minutes

### Mobile Security

#### Android APK
```bash
./pilgrims.sh --module=mobile app.apk --android
```

**What it does:**
- APK decompilation
- Manifest analysis
- Permission check
- Hardcoded secrets detection

#### iOS IPA
```bash
./pilgrims.sh --module=mobile app.ipa --ios
```

**What it does:**
- IPA extraction
- Info.plist analysis
- Security check

### Cloud Security

#### AWS
```bash
./pilgrims.sh --module=cloud --aws
```

**What it does:**
- IAM analysis
- S3 bucket check
- EC2 security groups
- Configuration audit

#### Azure
```bash
./pilgrims.sh --module=cloud --azure
```

**What it does:**
- Azure AD analysis
- Storage accounts
- VM security
- Configuration audit

#### GCP
```bash
./pilgrims.sh --module=cloud --gcp
```

**What it does:**
- GCP IAM analysis
- Storage buckets
- Compute instances
- Configuration audit

---

## Advanced Features

### Resume Scan System

**Use case:** Continue interrupted scan

```bash
# List resumable scans
./pilgrims.sh --resume-list

# Resume specific scan
./pilgrims.sh --resume=web_20260622_221500
```

**Benefits:**
- Save time on long scans
- Resume from last checkpoint
- No data loss

### Comparative Analysis

**Use case:** Compare scans over time

```bash
# First scan
./pilgrims.sh --module=web example.com --quick

# Fix vulnerabilities...

# Second scan with comparison
./pilgrims.sh --module=web example.com --quick --compare
```

**Output:**
- Vulnerability comparison
- Improvement tracking
- Regression detection

### Attack Path Mapper

**Use case:** Visualize attack chains

```bash
./pilgrims.sh --module=web example.com --attack-paths
```

**Output:**
- Attack chain visualization
- Critical path identification
- Risk assessment

### MITRE ATT&CK Mapping

**Use case:** Map findings to ATT&CK framework

```bash
./pilgrims.sh --module=web example.com --mitre
```

**Output:**
- ATT&CK technique mapping
- Navigator layer generation
- Coverage analysis

### Parallel Scanning

**Use case:** Scan multiple targets simultaneously

```bash
# Create targets file
cat > targets.txt << EOF
example.com
test.com
demo.com
EOF

# Scan in parallel
./pilgrims.sh --module=web --parallel=targets.txt
```

**Benefits:**
- 3-5x faster scanning
- Efficient resource usage
- Combined reporting

---

## Report Analysis

### Report Locations

All reports are saved in:
```
~/pilgrims-v17/modules/module-<name>/reports/<scan_timestamp>/
```

### Report Types

#### Markdown Reports
```bash
cat reports/web_20260622_221500/reports/WEB_SECURITY_REPORT.md
```

**Contains:**
- Executive summary
- Detailed findings
- Recommendations
- Technical details

#### JSON Reports
```bash
cat reports/web_20260622_221500/reports/findings.json | jq .
```

**Contains:**
- Structured data
- Machine-readable format
- Easy integration

#### STIX Bundles
```bash
cat reports/ioc_test/stix/bundle.json | jq .
```

**Contains:**
- Threat intelligence
- IOC data
- Standard format

### Analyzing Results

#### View Findings
```bash
# List all reports
find reports/ -name "*.md" -type f

# View specific report
cat reports/web_*/reports/*.md | less
```

#### Extract IOCs
```bash
# Extract IPs
grep -r "IP:" reports/ | cut -d: -f3

# Extract domains
grep -r "Domain:" reports/ | cut -d: -f3

# Extract URLs
grep -r "URL:" reports/ | cut -d: -f3
```

#### Generate Summary
```bash
# Count findings
find reports/ -name "*.md" -exec grep -c "CRITICAL\|HIGH" {} \; | awk '{sum+=$1} END {print sum}'
```

---

## Best Practices

### 1. Always Get Authorization

**Before scanning:**
- Obtain written permission
- Define scope clearly
- Document rules of engagement
- Set time windows

### 2. Use Appropriate Scan Type

**Quick Scan:**
- Initial assessment
- Time-constrained
- Large scope

**Deep Scan:**
- Comprehensive assessment
- Detailed analysis
- Critical systems

**Red Team:**
- Adversary simulation
- Stealth required
- Advanced techniques

### 3. Manage Resources

**For large scans:**
```bash
# Limit parallel threads
./pilgrims.sh --module=web --parallel=targets.txt --threads=4

# Schedule during off-hours
echo "0 2 * * * /path/to/pilgrims.sh --module=web target.com" | crontab -
```

### 4. Review Reports Thoroughly

**After each scan:**
1. Read executive summary
2. Review critical findings
3. Validate false positives
4. Prioritize remediation
5. Document lessons learned

### 5. Maintain Evidence

**For forensics:**
```bash
# Create forensic copy
dd if=/dev/sda of=evidence.img bs=4M

# Calculate hashes
sha256sum evidence.img > evidence.img.sha256

# Analyze copy
./pilgrims.sh --memory-forensics=evidence.img
```

### 6. Stay Updated

**Regular updates:**
```bash
# Check for updates
git pull

# Update dependencies
sudo apt update && sudo apt upgrade -y

# Test after update
./test-simple.sh 2>/dev/null || echo "Note: test-simple.sh is an optional test script (may not exist in all distributions)"
```

### 7. Use Stealth When Needed

**For production systems:**
```bash
# Use stealth mode
./pilgrims.sh --module=web example.com --deep --stealth

# Use ghost profile
./pilgrims.sh --module=web example.com --ghost
```

### 8. Document Everything

**Maintain logs:**
```bash
# Enable verbose logging
export PILGRIMS_LOG_LEVEL=DEBUG

# Review logs
tail -f logs/pilgrims.log
```

---

## Tips & Tricks

### Tip 1: Use Aliases

```bash
# Add to ~/.bashrc
alias pgr='./pilgrims.sh'
alias pgr-web='./pilgrims.sh --module=web'
alias pgr-forensics='./pilgrims.sh --memory-forensics'

# Usage
pgr-web example.com --quick
```

### Tip 2: Batch Processing

```bash
# Scan multiple targets
for target in $(cat targets.txt); do
    ./pilgrims.sh --module=web "$target" --quick
done
```

### Tip 3: Custom Reports

```bash
# Generate custom report
./pilgrims.sh --module=web example.com --deep
cat reports/web_*/reports/*.md > custom_report.md
```

### Tip 4: Integration with Other Tools

```bash
# Export to JSON for SIEM
./pilgrims.sh --module=web example.com --json

# Import to Metasploit
./pilgrims.sh --integrate=metasploit --import=report.json
```

### Tip 5: Automation

```bash
# Daily scan
echo "0 2 * * * /path/to/pilgrims.sh --module=web target.com --quick" | crontab -

# Weekly deep scan
echo "0 3 * * 0 /path/to/pilgrims.sh --module=web target.com --deep" | crontab -
```

---

## Common Workflows

### Workflow 1: Bug Bounty Hunt

```bash
# 1. Reconnaissance
./pilgrims.sh --module=web target.com --quick

# 2. Deep analysis
./pilgrims.sh --module=web target.com --bug-bounty

# 3. Review findings
cat reports/web_*/reports/*.md | less

# 4. Validate findings
# Manual verification of critical issues

# 5. Submit report
# Write detailed report for bug bounty platform
```

### Workflow 2: Incident Response

```bash
# 1. Collect evidence
dd if=/dev/mem of=memory.dump bs=1M

# 2. Memory forensics
./pilgrims.sh --memory-forensics=memory.dump

# 3. Network forensics
./pilgrims.sh --network-forensics=capture.pcap

# 4. Timeline reconstruction
./pilgrims.sh --timeline=evidence_dir/

# 5. Malware analysis
./pilgrims.sh --static-analysis=suspicious.exe
./pilgrims.sh --dynamic-analysis=suspicious.exe

# 6. IOC extraction
./pilgrims.sh --ioc=evidence_dir/

# 7. Generate report
cat reports/*/reports/*.md > ir_report.md
```

### Workflow 3: Compliance Audit

```bash
# 1. SOC2 assessment
./pilgrims.sh --soc2=organization

# 2. ISO27001 assessment
./pilgrims.sh --iso27001=organization

# 3. PCI-DSS scan
./pilgrims.sh --pcidss=payment_system

# 4. Review findings
cat reports/soc2_*/reports/*.md | less

# 5. Remediate issues
# Fix identified vulnerabilities

# 6. Re-scan
./pilgrims.sh --soc2=organization --compare
```

### Workflow 4: Red Team Operation

```bash
# 1. Reconnaissance
./pilgrims.sh --module=web target.com --quick
./pilgrims.sh --module=network 192.168.1.0/24 --quick

# 2. Deep analysis
./pilgrims.sh --module=web target.com --red-team

# 3. Attack path mapping
./pilgrims.sh --module=web target.com --attack-paths

# 4. MITRE mapping
./pilgrims.sh --module=web target.com --mitre

# 5. Generate report
cat reports/web_*/reports/*.md > red_team_report.md
```

---

## Next Steps

After mastering the basics:

1. Explore [Modules Reference](MODULES.md)
2. Try [Examples](EXAMPLES.md)
3. Check [Commands Reference](COMMANDS.md)
4. Read [Troubleshooting](TROUBLESHOOTING.md)

---

**🏴‍☠️ Happy Hunting, Captain!**
