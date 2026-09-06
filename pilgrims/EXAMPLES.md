# 💡 Examples - Real-World Usage

## Table of Contents

1. [Bug Bounty Hunting](#bug-bounty-hunting)
2. [Penetration Testing](#penetration-testing)
3. [Incident Response](#incident-response)
4. [Compliance Audit](#compliance-audit)
5. [Red Team Operations](#red-team-operations)
6. [Malware Analysis](#malware-analysis)
7. [Cloud Security](#cloud-security)
8. [Blockchain Security](#blockchain-security)
9. [Advanced Workflows](#advanced-workflows)

---

## Bug Bounty Hunting

### Scenario: Finding Vulnerabilities in Web Application

**Target:** example.com (authorized bug bounty program)

#### Step 1: Reconnaissance
```bash
# Quick scan to identify attack surface
./pilgrims.sh --module=web example.com --quick

# Review initial findings
cat reports/web_*/reports/WEB_SECURITY_REPORT.md | less
```

#### Step 2: Deep Analysis
```bash
# Bug bounty focused scan
./pilgrims.sh --module=web example.com --bug-bounty

# Review detailed findings
cat reports/web_*/reports/WEB_SECURITY_REPORT.md | grep -A 5 "CRITICAL\|HIGH"
```

#### Step 3: Advanced Testing
```bash
# Attack path mapping
./pilgrims.sh --module=web example.com --attack-paths

# MITRE ATT&CK mapping
./pilgrims.sh --module=web example.com --mitre
```

#### Step 4: Validate Findings
```bash
# Manual verification of critical issues
# Use browser developer tools, Burp Suite, etc.
```

#### Step 5: Generate Report
```bash
# Combine all reports
cat reports/web_*/reports/*.md > bug_bounty_report.md

# Extract IOCs
./pilgrims.sh --ioc=reports/web_*/
```

**Expected Output:**
- List of vulnerabilities with severity
- Proof of concept for each finding
- Remediation recommendations
- IOCs for detection

---

## Penetration Testing

### Scenario: Full Network Penetration Test

**Target:** 192.168.1.0/24 (authorized engagement)

#### Step 1: Network Discovery
```bash
# Quick network scan
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick

# Identify live hosts and open ports
cat reports/network_*/reports/NETWORK_SECURITY_REPORT.md
```

#### Step 2: Deep Network Analysis
```bash
# Comprehensive network scan
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep

# Vulnerability scanning
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --vuln
```

#### Step 3: Web Application Testing
```bash
# Test discovered web applications
./pilgrims.sh --module=web http://192.168.1.10 --deep
./pilgrims.sh --module=web http://192.168.1.20 --deep
```

#### Step 4: Active Directory Assessment
```bash
# AD security testing
./pilgrims.sh --module=ad 192.168.1.10 --domain=corp.local --user=auditor --pass=Password123
```

#### Step 5: Container Security
```bash
# Docker security
./pilgrims.sh --module=container --docker

# Kubernetes security
./pilgrims.sh --module=container --k8s
```

#### Step 6: Generate Comprehensive Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > pentest_report.md

# Create executive summary
head -100 pentest_report.md > executive_summary.md
```

---

## Incident Response

### Scenario: Responding to Security Incident

**Evidence:** memory.dump, capture.pcap, suspicious.exe

#### Step 1: Evidence Collection
```bash
# Create evidence directory
mkdir -p /evidence/incident_20260622

# Copy evidence files
cp memory.dump capture.pcap suspicious.exe /evidence/incident_20260622/

# Calculate hashes
sha256sum /evidence/incident_20260622/* > hashes.txt
```

#### Step 2: Memory Forensics
```bash
# Analyze memory dump
./pilgrims.sh --memory-forensics=/evidence/incident_20260622/memory.dump

# Review findings
cat reports/memory_forensics_*/reports/MEMORY_FORENSICS_REPORT.md
```

#### Step 3: Network Forensics
```bash
# Analyze network capture
./pilgrims.sh --network-forensics=/evidence/incident_20260622/capture.pcap

# Review findings
cat reports/network_forensics_*/reports/NETWORK_FORENSICS_REPORT.md
```

#### Step 4: Malware Analysis
```bash
# Static analysis
./pilgrims.sh --static-analysis=/evidence/incident_20260622/suspicious.exe

# Dynamic analysis (60 seconds)
./pilgrims.sh --dynamic-analysis=/evidence/incident_20260622/suspicious.exe 60

# Generate YARA rules
./pilgrims.sh --yara=/evidence/incident_20260622/suspicious.exe
```

#### Step 5: Timeline Reconstruction
```bash
# Reconstruct incident timeline
./pilgrims.sh --timeline=/evidence/incident_20260622/

# Review timeline
cat reports/timeline_*/reports/TIMELINE_RECONSTRUCTION_REPORT.md
```

#### Step 6: IOC Extraction
```bash
# Extract all IOCs
./pilgrims.sh --ioc=/evidence/incident_20260622/

# Review IOCs
cat reports/ioc_*/reports/IOC_EXTRACTION_REPORT.md
```

#### Step 7: Generate IR Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > incident_response_report.md

# Extract IOCs for sharing
cat reports/ioc_*/stix/bundle.json > iocs.json
```

**Expected Output:**
- Complete incident timeline
- Malware analysis results
- Extracted IOCs
- STIX bundle for sharing
- Recommendations for containment

---

## Compliance Audit

### Scenario: SOC2 Compliance Assessment

**Target:** Organization-wide assessment

#### Step 1: SOC2 Assessment
```bash
# Run SOC2 compliance check
./pilgrims.sh --soc2=organization

# Review findings
cat reports/soc2_*/reports/SOC2_REPORT.md
```

#### Step 2: ISO27001 Assessment
```bash
# Run ISO27001 assessment
./pilgrims.sh --iso27001=organization

# Review findings
cat reports/iso27001_*/reports/ISO27001_REPORT.md
```

#### Step 3: Additional Compliance Checks
```bash
# HIPAA (if healthcare)
./pilgrims.sh --hipaa=healthcare_org

# PCI-DSS (if payment processing)
./pilgrims.sh --pcidss=payment_system
```

#### Step 4: Web Application Compliance
```bash
# Scan web applications
./pilgrims.sh --module=web company.com --compliance

# Review findings
cat reports/web_*/reports/WEB_SECURITY_REPORT.md
```

#### Step 5: Network Compliance
```bash
# Scan network infrastructure
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep
```

#### Step 6: Generate Compliance Report
```bash
# Combine all compliance reports
find reports/ -name "*SOC2*" -o -name "*ISO27001*" -o -name "*HIPAA*" -o -name "*PCI*" | xargs cat > compliance_report.md

# Create gap analysis
grep -i "non-compliant\|missing\|failed" compliance_report.md > gap_analysis.md
```

#### Step 7: Remediation Tracking
```bash
# Re-scan after fixes
./pilgrims.sh --soc2=organization --compare

# Track improvements
cat reports/soc2_*/reports/SOC2_REPORT.md | grep -A 5 "improvement\|fixed"
```

---

## Red Team Operations

### Scenario: Adversary Simulation

**Target:** target.com (authorized red team engagement)

#### Step 1: Reconnaissance
```bash
# Passive reconnaissance
./pilgrims.sh --module=web target.com --recon-only

# Network reconnaissance
sudo ./pilgrims.sh --module=network target.com --quick
```

#### Step 2: Deep Analysis
```bash
# Red team mode scan
./pilgrims.sh --module=web target.com --red-team

# Stealth mode
./pilgrims.sh --module=web target.com --red-team --stealth
```

#### Step 3: Attack Path Mapping
```bash
# Map attack paths
./pilgrims.sh --module=web target.com --attack-paths

# Review attack chains
cat reports/web_*/reports/ATTACK_PATH_REPORT.md
```

#### Step 4: MITRE ATT&CK Mapping
```bash
# Map to MITRE framework
./pilgrims.sh --module=web target.com --mitre

# Generate Navigator layer
cat reports/web_*/mitre/navigator_layer.json
```

#### Step 5: Advanced Testing
```bash
# Parallel scanning
echo "target.com" > targets.txt
echo "api.target.com" >> targets.txt
echo "admin.target.com" >> targets.txt

./pilgrims.sh --module=web --parallel=targets.txt
```

#### Step 6: Generate Red Team Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > red_team_report.md

# Create executive summary
head -50 red_team_report.md > executive_summary.md

# Extract IOCs
./pilgrims.sh --ioc=reports/web_*/
```

---

## Malware Analysis

### Scenario: Analyzing Suspicious File

**Sample:** suspicious.exe

#### Step 1: Static Analysis
```bash
# Reverse engineering
./pilgrims.sh --static-analysis=suspicious.exe

# Review findings
cat reports/static_analysis_*/reports/STATIC_ANALYSIS_REPORT.md
```

#### Step 2: Dynamic Analysis
```bash
# Sandbox analysis (60 seconds)
./pilgrims.sh --dynamic-analysis=suspicious.exe 60

# Review behavioral analysis
cat reports/dynamic_analysis_*/reports/DYNAMIC_ANALYSIS_REPORT.md
```

#### Step 3: YARA Rule Generation
```bash
# Generate detection rules
./pilgrims.sh --yara=suspicious.exe

# Test rules
yara reports/yara_*/rules/generated.yar suspicious.exe
```

#### Step 4: IOC Extraction
```bash
# Extract all IOCs
./pilgrims.sh --ioc=suspicious.exe

# Review IOCs
cat reports/ioc_*/reports/IOC_EXTRACTION_REPORT.md
```

#### Step 5: Generate Analysis Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > malware_analysis_report.md

# Extract STIX bundle
cat reports/ioc_*/stix/bundle.json > iocs.json
```

---

## Cloud Security

### Scenario: AWS Security Assessment

**Target:** AWS environment

#### Step 1: AWS Assessment
```bash
# AWS security scan
./pilgrims.sh --module=cloud --aws

# Review findings
cat reports/cloud_*/reports/CLOUD_SECURITY_REPORT.md
```

#### Step 2: Container Security
```bash
# Docker security
./pilgrims.sh --module=container --docker

# Kubernetes security
./pilgrims.sh --module=container --k8s
```

#### Step 3: Infrastructure as Code
```bash
# Terraform security
./pilgrims.sh --iac=/path/to/terraform terraform

# Review findings
cat reports/iac_*/reports/IAC_SECURITY_REPORT.md
```

#### Step 4: Serverless Security
```bash
# Lambda security
./pilgrims.sh --serverless=lambda_function aws

# Review findings
cat reports/serverless_*/reports/SERVERLESS_SECURITY_REPORT.md
```

#### Step 5: Generate Cloud Security Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > cloud_security_report.md
```

---

## Blockchain Security

### Scenario: Smart Contract Audit

**Target:** Token.sol

#### Step 1: Smart Contract Audit
```bash
# Solidity contract audit
./pilgrims.sh --module=blockchain Token.sol --solidity

# Review findings
cat reports/blockchain_*/reports/SMART_CONTRACT_AUDIT_REPORT.md
```

#### Step 2: DeFi Protocol Analysis
```bash
# DeFi protocol security
./pilgrims.sh --module=blockchain uniswap --defi

# Review findings
cat reports/blockchain_*/reports/DEFI_SECURITY_REPORT.md
```

#### Step 3: Advanced Cryptography
```bash
# Zero-Knowledge Proof audit
./pilgrims.sh --zkp=blockchain_protocol

# Post-Quantum readiness
./pilgrims.sh --pqc=system
```

#### Step 4: Generate Blockchain Report
```bash
# Combine all reports
find reports/ -name "*.md" -exec cat {} \; > blockchain_security_report.md
```

---

## Advanced Workflows

### Workflow 1: Continuous Security Monitoring

```bash
#!/bin/bash
# continuous_monitoring.sh

# Daily quick scan
./pilgrims.sh --module=web target.com --quick

# Weekly deep scan
if [ $(date +%u) -eq 7 ]; then
    ./pilgrims.sh --module=web target.com --deep
fi

# Monthly compliance check
if [ $(date +%d) -eq 1 ]; then
    ./pilgrims.sh --soc2=organization
    ./pilgrims.sh --iso27001=organization
fi

# Compare with previous scan
./pilgrims.sh --module=web target.com --compare

# Generate report
find reports/ -name "*.md" -newer /last_report -exec cat {} \; > daily_report.md
```

### Workflow 2: Automated Incident Response

```bash
#!/bin/bash
# automated_ir.sh

# Detect incident
if [ -f "/var/log/suspicious.log" ]; then
    # Collect evidence
    cp /var/log/suspicious.log /evidence/
    
    # Analyze
    ./pilgrims.sh --ioc=/evidence/
    ./pilgrims.sh --static-analysis=/evidence/suspicious.exe
    
    # Extract IOCs
    ./pilgrims.sh --ioc=/evidence/
    
    # Generate STIX bundle
    cat reports/ioc_*/stix/bundle.json > iocs.json
    
    # Share with SIEM
    curl -X POST https://siem.example.com/api/iocs -d @iocs.json
    
    # Notify team
    echo "Incident detected! Report: reports/*/reports/*.md" | mail -s "Security Incident" team@example.com
fi
```

### Workflow 3: Bug Bounty Automation

```bash
#!/bin/bash
# bug_bounty_automation.sh

# Read targets from file
while read target; do
    echo "Scanning $target..."
    
    # Quick scan
    ./pilgrims.sh --module=web "$target" --quick
    
    # Bug bounty mode
    ./pilgrims.sh --module=web "$target" --bug-bounty
    
    # Extract IOCs
    ./pilgrims.sh --ioc=reports/web_*/
    
    # Check for critical findings
    if grep -q "CRITICAL" reports/web_*/reports/*.md; then
        echo "Critical findings on $target!" | mail -s "Bug Bounty Alert" hunter@example.com
    fi
done < targets.txt

# Generate summary
find reports/ -name "*.md" -exec cat {} \; > bug_bounty_summary.md
```

### Workflow 4: Red Team Campaign

```bash
#!/bin/bash
# red_team_campaign.sh

# Phase 1: Reconnaissance
echo "Phase 1: Reconnaissance"
./pilgrims.sh --module=web target.com --recon-only
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick

# Phase 2: Weaponization
echo "Phase 2: Weaponization"
./pilgrims.sh --module=web target.com --red-team

# Phase 3: Delivery
echo "Phase 3: Delivery"
./pilgrims.sh --module=web target.com --attack-paths

# Phase 4: Exploitation
echo "Phase 4: Exploitation"
./pilgrims.sh --module=web target.com --mitre

# Phase 5: Installation
echo "Phase 5: Installation"
./pilgrims.sh --static-analysis=payload.exe
./pilgrims.sh --dynamic-analysis=payload.exe

# Phase 6: Command & Control
echo "Phase 6: Command & Control"
./pilgrims.sh --ioc=reports/

# Phase 7: Actions on Objectives
echo "Phase 7: Actions on Objectives"
find reports/ -name "*.md" -exec cat {} \; > red_team_campaign_report.md
```

---

## Tips for Effective Usage

### Tip 1: Combine Multiple Scans
```bash
# Scan multiple targets
for target in $(cat targets.txt); do
    ./pilgrims.sh --module=web "$target" --quick
done
```

### Tip 2: Use Parallel Scanning
```bash
# Scan multiple targets in parallel
./pilgrims.sh --module=web --parallel=targets.txt
```

### Tip 3: Schedule Regular Scans
```bash
# Add to crontab
0 2 * * * /path/to/pilgrims.sh --module=web target.com --quick
```

### Tip 4: Compare Over Time
```bash
# First scan
./pilgrims.sh --module=web target.com --quick

# After fixes
./pilgrims.sh --module=web target.com --quick --compare
```

### Tip 5: Generate Custom Reports
```bash
# Combine specific reports
cat reports/web_*/reports/EXECUTIVE_SUMMARY.md > summary.md
cat reports/web_*/reports/TECHNICAL_DETAILS.md > technical.md
```

---

**🏴‍☠️ Ready to sail, Captain!**
