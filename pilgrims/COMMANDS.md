# 📋 Commands Reference

> **⚠ Implementation Note:** Some modules are **simulation stubs** (marked `[STUB]` in MODULES.md) — they generate sample output only, not live scans. The "Advanced Feature Commands" section documents the **full vision** for the framework; many flags (e.g. `--fuzz`, `--symbolic`, `--zkp`, `--soar`) are **not yet implemented** in the current Bash codebase and will be ignored or error if invoked. Only modules marked "Real" in MODULES.md perform actual security testing.

## Table of Contents

1. [Basic Commands](#basic-commands)
2. [Module Commands](#module-commands)
3. [Advanced Feature Commands](#advanced-feature-commands)
4. [Utility Commands](#utility-commands)
5. [Command Examples](#command-examples)

---

## Basic Commands

### Help
```bash
./pilgrims.sh --help
./pilgrims.sh -h
```
**Description:** Show help message with all available options

### Version
```bash
./pilgrims.sh --version
```
**Description:** Show PILGRIMS version information

### Modules List
```bash
./pilgrims.sh --modules
```
**Description:** List all available modules

### History
```bash
./pilgrims.sh --history
```
**Description:** Show scan history from database

---

## Module Commands

### Web Application Security
```bash
./pilgrims.sh --module=web <target> [options]
```

**Options:**
- `--quick` - Quick scan (5-10 min)
- `--deep` - Deep scan (30-60 min)
- `--bug-bounty` - Bug bounty mode
- `--red-team` - Red team mode
- `--compliance` - Compliance mode
- `--recon-only` - Reconnaissance only
- `--stealth` - Enable stealth mode
- `--ghost` - Ultra stealth mode
- `--shadow` - High stealth mode
- `--phantom` - Medium stealth mode
- `--wraith` - Aggressive mode

**Examples:**
```bash
./pilgrims.sh --module=web example.com --quick
./pilgrims.sh --module=web example.com --deep --stealth
./pilgrims.sh --module=web example.com --bug-bounty
./pilgrims.sh --module=web example.com --red-team --encrypt=Secret123
```

### Network Security
```bash
sudo ./pilgrims.sh --module=network <target> [options]
```

**Options:**
- `--quick` - Quick scan
- `--deep` - Deep scan
- `--vuln` - Vulnerability scan

**Examples:**
```bash
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep
sudo ./pilgrims.sh --module=network example.com --vuln
```

### Mobile Security
```bash
./pilgrims.sh --module=mobile <file> [options]
```

**Options:**
- `--android` - Android APK
- `--ios` - iOS IPA
- `--dynamic` - Dynamic analysis

**Examples:**
```bash
./pilgrims.sh --module=mobile app.apk --android
./pilgrims.sh --module=mobile app.ipa --ios
```

### Cloud Security
```bash
./pilgrims.sh --module=cloud [options]
```

**Options:**
- `--aws` - AWS assessment
- `--azure` - Azure assessment
- `--gcp` - GCP assessment

**Examples:**
```bash
./pilgrims.sh --module=cloud --aws
./pilgrims.sh --module=cloud --azure
./pilgrims.sh --module=cloud --gcp
```

### Active Directory
```bash
./pilgrims.sh --module=ad <dc-ip> [options]
```

**Options:**
- `--domain=<domain>` - Domain name
- `--user=<username>` - Username
- `--pass=<password>` - Password

**Examples:**
```bash
./pilgrims.sh --module=ad 192.168.1.10 --domain=corp.local --user=auditor --pass=Password123
```

### Container Security
```bash
./pilgrims.sh --module=container [options]
```

**Options:**
- `--docker` - Docker scan
- `--k8s` - Kubernetes scan
- `--images=<list>` - Specific images

**Examples:**
```bash
./pilgrims.sh --module=container --docker
./pilgrims.sh --module=container --k8s
./pilgrims.sh --module=container --docker --images=nginx,redis
```

### Source Code Review
```bash
./pilgrims.sh --module=code <path> [options]
```

**Options:**
- `--lang=<language>` - Language (python, javascript, php, java)
- `--no-secrets` - Skip secret scanning
- `--no-deps` - Skip dependency check

**Examples:**
```bash
./pilgrims.sh --module=code /path/to/source --lang=python
./pilgrims.sh --module=code /path/to/source --lang=javascript
```

### Wireless Security
```bash
sudo ./pilgrims.sh --module=wireless <interface> [options]
```

**Options:**
- `--duration=<sec>` - Scan duration
- `--crack` - Attempt cracking
- `--wordlist=<path>` - Wordlist path

**Examples:**
```bash
sudo ./pilgrims.sh --module=wireless wlan0 --duration=120
sudo ./pilgrims.sh --module=wireless wlan0 --crack
```

### Email Security
```bash
./pilgrims.sh --module=email <domain>
```

**Examples:**
```bash
./pilgrims.sh --module=email example.com
```

### IoT Security
```bash
./pilgrims.sh --module=iot <target> [options]
```

**Options:**
- `--firmware` - Firmware analysis
- `--device` - Device analysis

**Examples:**
```bash
./pilgrims.sh --module=iot firmware.bin --firmware
./pilgrims.sh --module=iot 192.168.1.100 --device
```

### Binary Analysis
```bash
./pilgrims.sh --module=binary <file> [options]
```

**Options:**
- `--static` - Static analysis
- `--dynamic` - Dynamic analysis
- `--yara` - YARA scan

**Examples:**
```bash
./pilgrims.sh --module=binary malware.exe --static
./pilgrims.sh --module=binary malware.exe --dynamic
```

### Blockchain Security
```bash
./pilgrims.sh --module=blockchain <target> [options]
```

**Options:**
- `--solidity` - Solidity contract
- `--wallet` - Wallet analysis
- `--defi` - DeFi protocol

**Examples:**
```bash
./pilgrims.sh --module=blockchain contract.sol --solidity
./pilgrims.sh --module=blockchain 0x1234... --wallet
```

### ICS/SCADA Security
```bash
./pilgrims.sh --module=ics <target>
```

**Examples:**
```bash
./pilgrims.sh --module=ics 192.168.1.100
```

### Medical Device Security
```bash
./pilgrims.sh --module=medical <target>
```

**Examples:**
```bash
./pilgrims.sh --module=medical 192.168.1.50
```

### Financial Systems Security
```bash
./pilgrims.sh --module=financial <target>
```

**Examples:**
```bash
./pilgrims.sh --module=financial payment_gateway
```

### Automotive Security
```bash
./pilgrims.sh --module=automotive <target>
```

**Examples:**
```bash
./pilgrims.sh --module=automotive can0
```

### 5G/Telecom Security
```bash
./pilgrims.sh --module=5g <target>
```

**Examples:**
```bash
./pilgrims.sh --module=5g gnb
```

### Gaming Security
```bash
./pilgrims.sh --module=gaming <target>
```

**Examples:**
```bash
./pilgrims.sh --module=gaming game.exe
```

---

## Advanced Feature Commands

### Resume Scan
```bash
./pilgrims.sh --resume-list
./pilgrims.sh --resume=<scan_id>
```

**Examples:**
```bash
./pilgrims.sh --resume-list
./pilgrims.sh --resume=web_20260622_221500
```

### Comparative Analysis
```bash
./pilgrims.sh --module=<type> <target> --compare
```

**Examples:**
```bash
./pilgrims.sh --module=web example.com --compare
```

### Attack Path Mapper
```bash
./pilgrims.sh --module=<type> <target> --attack-paths
```

**Examples:**
```bash
./pilgrims.sh --module=web example.com --attack-paths
```

### MITRE ATT&CK Mapping
```bash
./pilgrims.sh --module=<type> <target> --mitre
```

**Examples:**
```bash
./pilgrims.sh --module=web example.com --mitre
```

### Parallel Scanning
```bash
./pilgrims.sh --module=<type> --parallel=<file>
```

**Examples:**
```bash
./pilgrims.sh --module=web --parallel=targets.txt
```

### Coverage-Guided Fuzzing
```bash
./pilgrims.sh --fuzz=<target> <input_dir> <duration>
```

**Examples:**
```bash
./pilgrims.sh --fuzz=http://example.com seeds/ 60
```

### Symbolic Execution
```bash
./pilgrims.sh --symbolic=<target>
```

**Examples:**
```bash
./pilgrims.sh --symbolic=http://example.com
```

### Formal Verification
```bash
./pilgrims.sh --formal=<target>
```

**Examples:**
```bash
./pilgrims.sh --formal=http://example.com
```

### Mutation Testing
```bash
./pilgrims.sh --mutation=<target> <test_suite>
```

**Examples:**
```bash
./pilgrims.sh --mutation=http://example.com tests.txt
```

### Side-Channel Attack
```bash
./pilgrims.sh --side-channel=<target> <type>
```

**Types:** timing, cache, power

**Examples:**
```bash
./pilgrims.sh --side-channel=http://example.com timing
```

### Fault Injection
```bash
./pilgrims.sh --fault-injection=<target>
```

**Examples:**
```bash
./pilgrims.sh --fault-injection=device
```

### HSM Testing
```bash
./pilgrims.sh --hsm=<target>
```

**Examples:**
```bash
./pilgrims.sh --hsm=hsm_device
```

### TPM Testing
```bash
./pilgrims.sh --tpm=<target>
```

**Examples:**
```bash
./pilgrims.sh --tpm=tpm_device
```

### LLM Security
```bash
./pilgrims.sh --llm=<target>
```

**Examples:**
```bash
./pilgrims.sh --llm=https://api.openai.com
```

### Federated Learning
```bash
./pilgrims.sh --federated=<target>
```

**Examples:**
```bash
./pilgrims.sh --federated=federated_server
```

### Backdoor Detection
```bash
./pilgrims.sh --backdoor=<target>
```

**Examples:**
```bash
./pilgrims.sh --backdoor=model.h5
```

### Model Stealing
```bash
./pilgrims.sh --model-stealing=<target>
```

**Examples:**
```bash
./pilgrims.sh --model-stealing=https://api.example.com
```

### SBOM Analysis
```bash
./pilgrims.sh --sbom=<target>
```

**Examples:**
```bash
./pilgrims.sh --sbom=/path/to/project
```

### Dependency Confusion
```bash
./pilgrims.sh --dep-confusion=<target>
```

**Examples:**
```bash
./pilgrims.sh --dep-confusion=/path/to/project
```

### Code Signing
```bash
./pilgrims.sh --code-signing=<target>
```

**Examples:**
```bash
./pilgrims.sh --code-signing=/path/to/binaries
```

### Container Provenance
```bash
./pilgrims.sh --container-provenance=<target>
```

**Examples:**
```bash
./pilgrims.sh --container-provenance=docker.io/library/nginx
```

### eBPF Security
```bash
./pilgrims.sh --ebpf=<target>
```

**Examples:**
```bash
./pilgrims.sh --ebpf=target
```

### WASM Security
```bash
./pilgrims.sh --wasm=<target>
```

**Examples:**
```bash
./pilgrims.sh --wasm=module.wasm
```

### Service Mesh
```bash
./pilgrims.sh --service-mesh=<target> <type>
```

**Types:** istio, linkerd, consul

**Examples:**
```bash
./pilgrims.sh --service-mesh=k8s-cluster istio
```

### K8s Admission
```bash
./pilgrims.sh --k8s-admission=<target>
```

**Examples:**
```bash
./pilgrims.sh --k8s-admission=k8s-cluster
```

### gRPC Security
```bash
./pilgrims.sh --grpc=<target>
```

**Examples:**
```bash
./pilgrims.sh --grpc=grpc.example.com:50051
```

### QUIC Security
```bash
./pilgrims.sh --quic=<target>
```

**Examples:**
```bash
./pilgrims.sh --quic=https://example.com
```

### WebSocket Advanced
```bash
./pilgrims.sh --websocket-adv=<target>
```

**Examples:**
```bash
./pilgrims.sh --websocket-adv=wss://example.com/ws
```

### API Gateway
```bash
./pilgrims.sh --api-gateway=<target> <type>
```

**Types:** kong, apigee, envoy

**Examples:**
```bash
./pilgrims.sh --api-gateway=gateway.example.com kong
```

### Git Hooks
```bash
./pilgrims.sh --git-hooks=<target>
```

**Examples:**
```bash
./pilgrims.sh --git-hooks=/path/to/repo
```

### IaC Security
```bash
./pilgrims.sh --iac=<target> <type>
```

**Types:** terraform, cloudformation

**Examples:**
```bash
./pilgrims.sh --iac=/path/to/terraform terraform
```

### Serverless Security
```bash
./pilgrims.sh --serverless=<target> <provider>
```

**Providers:** aws, gcp, azure

**Examples:**
```bash
./pilgrims.sh --serverless=lambda_function aws
```

### Chaos Engineering
```bash
./pilgrims.sh --chaos=<target>
```

**Examples:**
```bash
./pilgrims.sh --chaos=production-cluster
```

### SOC2 Compliance
```bash
./pilgrims.sh --soc2=<target>
```

**Examples:**
```bash
./pilgrims.sh --soc2=organization
```

### ISO27001
```bash
./pilgrims.sh --iso27001=<target>
```

**Examples:**
```bash
./pilgrims.sh --iso27001=organization
```

### HIPAA
```bash
./pilgrims.sh --hipaa=<target>
```

**Examples:**
```bash
./pilgrims.sh --hipaa=healthcare_org
```

### PCI-DSS
```bash
./pilgrims.sh --pcidss=<target>
```

**Examples:**
```bash
./pilgrims.sh --pcidss=payment_system
```

### Zero-Knowledge Proof
```bash
./pilgrims.sh --zkp=<target>
```

**Examples:**
```bash
./pilgrims.sh --zkp=blockchain_protocol
```

### Post-Quantum Cryptography
```bash
./pilgrims.sh --pqc=<target>
```

**Examples:**
```bash
./pilgrims.sh --pqc=system
```

### Multi-Party Computation
```bash
./pilgrims.sh --mpc=<target>
```

**Examples:**
```bash
./pilgrims.sh --mpc=protocol
```

### Homomorphic Encryption
```bash
./pilgrims.sh --fhe=<target>
```

**Examples:**
```bash
./pilgrims.sh --fhe=implementation
```

### MITRE Navigator
```bash
./pilgrims.sh --mitre-nav=<target>
```

**Examples:**
```bash
./pilgrims.sh --mitre-nav=target
```

### STIX/TAXII
```bash
./pilgrims.sh --stix=<target>
```

**Examples:**
```bash
./pilgrims.sh --stix=target
```

### SOAR Integration
```bash
./pilgrims.sh --soar=<target>
```

**Examples:**
```bash
./pilgrims.sh --soar=target
```

### Incident Response
```bash
./pilgrims.sh --ir=<target>
```

**Examples:**
```bash
./pilgrims.sh --ir=incident
```

### Memory Forensics
```bash
./pilgrims.sh --memory-forensics=<file>
```

**Examples:**
```bash
./pilgrims.sh --memory-forensics=dump.bin
```

### Network Forensics
```bash
./pilgrims.sh --network-forensics=<file>
```

**Examples:**
```bash
./pilgrims.sh --network-forensics=capture.pcap
```

### Filesystem Forensics
```bash
./pilgrims.sh --filesystem-forensics=<file>
```

**Examples:**
```bash
./pilgrims.sh --filesystem-forensics=disk.img
```

### Timeline Reconstruction
```bash
./pilgrims.sh --timeline=<directory>
```

**Examples:**
```bash
./pilgrims.sh --timeline=evidence_dir/
```

### Static Analysis
```bash
./pilgrims.sh --static-analysis=<file>
```

**Examples:**
```bash
./pilgrims.sh --static-analysis=malware.exe
```

### Dynamic Analysis
```bash
./pilgrims.sh --dynamic-analysis=<file> [duration]
```

**Examples:**
```bash
./pilgrims.sh --dynamic-analysis=suspicious.exe 60
```

### YARA Rule Generation
```bash
./pilgrims.sh --yara=<file>
```

**Examples:**
```bash
./pilgrims.sh --yara=sample.bin
```

### IOC Extraction
```bash
./pilgrims.sh --ioc=<target>
```

**Examples:**
```bash
./pilgrims.sh --ioc=evidence_dir/
```

---

## Utility Commands

### Plugin Manager
```bash
./pilgrims-manage.sh list
./pilgrims-manage.sh install <name>
./pilgrims-manage.sh remove <name>
./pilgrims-manage.sh create <name>
```

### Test Suite
```bash
./test-all-features.sh
./test-simple.sh
```

---

## Command Examples

### Example 1: Complete Web Assessment
```bash
# Quick recon
./pilgrims.sh --module=web example.com --quick

# Deep scan with stealth
./pilgrims.sh --module=web example.com --deep --stealth

# Bug bounty mode
./pilgrims.sh --module=web example.com --bug-bounty

# Red team with encryption
./pilgrims.sh --module=web example.com --red-team --encrypt=Secret123

# Compare with previous scan
./pilgrims.sh --module=web example.com --compare
```

### Example 2: Incident Response
```bash
# Memory forensics
./pilgrims.sh --memory-forensics=memory.dump

# Network forensics
./pilgrims.sh --network-forensics=capture.pcap

# Timeline reconstruction
./pilgrims.sh --timeline=evidence_dir/

# Malware analysis
./pilgrims.sh --static-analysis=suspicious.exe
./pilgrims.sh --dynamic-analysis=suspicious.exe 60

# IOC extraction
./pilgrims.sh --ioc=evidence_dir/

# YARA rules
./pilgrims.sh --yara=suspicious.exe
```

### Example 3: Compliance Audit
```bash
# SOC2
./pilgrims.sh --soc2=organization

# ISO27001
./pilgrims.sh --iso27001=organization

# HIPAA
./pilgrims.sh --hipaa=healthcare_org

# PCI-DSS
./pilgrims.sh --pcidss=payment_system

# Compare results
./pilgrims.sh --soc2=organization --compare
```

### Example 4: Red Team Operation
```bash
# Reconnaissance
./pilgrims.sh --module=web target.com --quick
./pilgrims.sh --module=network 192.168.1.0/24 --quick

# Deep analysis
./pilgrims.sh --module=web target.com --red-team

# Attack path mapping
./pilgrims.sh --module=web target.com --attack-paths

# MITRE mapping
./pilgrims.sh --module=web target.com --mitre

# Generate report
cat reports/web_*/reports/*.md > red_team_report.md
```

### Example 5: Cloud Security
```bash
# AWS assessment
./pilgrims.sh --module=cloud --aws

# Azure assessment
./pilgrims.sh --module=cloud --azure

# GCP assessment
./pilgrims.sh --module=cloud --gcp

# Container security
./pilgrims.sh --module=container --docker
./pilgrims.sh --module=container --k8s
```

### Example 6: Blockchain Security
```bash
# Smart contract audit
./pilgrims.sh --module=blockchain contract.sol --solidity

# DeFi protocol
./pilgrims.sh --module=blockchain uniswap --defi

# Wallet security
./pilgrims.sh --module=blockchain 0x1234... --wallet
```

### Example 7: Advanced Cryptography
```bash
# Zero-Knowledge Proof
./pilgrims.sh --zkp=blockchain_protocol

# Post-Quantum
./pilgrims.sh --pqc=system

# Multi-Party Computation
./pilgrims.sh --mpc=protocol

# Homomorphic Encryption
./pilgrims.sh --fhe=implementation
```

### Example 8: Threat Intelligence
```bash
# MITRE Navigator
./pilgrims.sh --mitre-nav=target

# STIX/TAXII
./pilgrims.sh --stix=target

# SOAR Integration
./pilgrims.sh --soar=target

# Incident Response
./pilgrims.sh --ir=incident
```

---

## Command Cheat Sheet

### Quick Reference

```bash
# Basic
./pilgrims.sh --help              # Show help
./pilgrims.sh --modules           # List modules
./pilgrims.sh --history           # View history

# Web
./pilgrims.sh --module=web target.com --quick
./pilgrims.sh --module=web target.com --deep
./pilgrims.sh --module=web target.com --bug-bounty
./pilgrims.sh --module=web target.com --red-team

# Network
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --deep

# Cloud
./pilgrims.sh --module=cloud --aws
./pilgrims.sh --module=cloud --azure
./pilgrims.sh --module=cloud --gcp

# Forensics
./pilgrims.sh --memory-forensics=dump.bin
./pilgrims.sh --network-forensics=capture.pcap
./pilgrims.sh --filesystem-forensics=disk.img
./pilgrims.sh --timeline=evidence_dir/

# Malware
./pilgrims.sh --static-analysis=malware.exe
./pilgrims.sh --dynamic-analysis=suspicious.exe
./pilgrims.sh --yara=sample.bin
./pilgrims.sh --ioc=evidence_dir/

# Compliance
./pilgrims.sh --soc2=organization
./pilgrims.sh --iso27001=organization
./pilgrims.sh --hipaa=healthcare_org
./pilgrims.sh --pcidss=payment_system

# Advanced
./pilgrims.sh --module=web target.com --compare
./pilgrims.sh --module=web target.com --attack-paths
./pilgrims.sh --module=web target.com --mitre
./pilgrims.sh --module=web --parallel=targets.txt
```

---

**🏴‍☠️ Command like a pro, Captain!**
