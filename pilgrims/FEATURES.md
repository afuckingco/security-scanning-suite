# ⚡ Features Reference

## Overview

PILGRIMS v17.0 includes **53 advanced features** organized into 6 phases. Each feature provides cutting-edge security capabilities for professional security researchers.

---

## Phase 1: Resume & Compare (5 features)

### 1. Resume Scan System
**Command:** `./pilgrims.sh --resume=<scan_id>`

**Description:** Continue interrupted scans from the last checkpoint.

**Benefits:**
- Save time on long scans
- No data loss on interruption
- Resume from any phase

**Usage:**
```bash
# List resumable scans
./pilgrims.sh --resume-list

# Resume specific scan
./pilgrims.sh --resume=web_20260622_221500
```

---

### 2. Comparative Analysis
**Command:** `./pilgrims.sh --module=<type> <target> --compare`

**Description:** Compare current scan with previous scans to track improvements.

**Benefits:**
- Track security posture over time
- Identify regressions
- Validate remediation efforts

**Usage:**
```bash
./pilgrims.sh --module=web example.com --compare
```

---

### 3. Attack Path Mapper
**Command:** `./pilgrims.sh --module=<type> <target> --attack-paths`

**Description:** Visualize attack chains and critical paths.

**Benefits:**
- Understand attack scenarios
- Identify critical vulnerabilities
- Prioritize remediation

**Usage:**
```bash
./pilgrims.sh --module=web example.com --attack-paths
```

---

### 4. MITRE ATT&CK Mapping
**Command:** `./pilgrims.sh --module=<type> <target> --mitre`

**Description:** Map findings to MITRE ATT&CK framework.

**Benefits:**
- Industry standard framework
- Better threat modeling
- Improved detection rules

**Usage:**
```bash
./pilgrims.sh --module=web example.com --mitre
```

---

### 5. Parallel Scanning
**Command:** `./pilgrims.sh --module=<type> --parallel=<file>`

**Description:** Scan multiple targets simultaneously.

**Benefits:**
- 3-5x faster scanning
- Efficient resource usage
- Combined reporting

**Usage:**
```bash
./pilgrims.sh --module=web --parallel=targets.txt
```

---

## Phase 2: Advanced Testing (4 features)

### 6. Coverage-Guided Fuzzing
**Command:** `./pilgrims.sh --fuzz=<target> <input_dir> <duration>`

**Description:** Intelligent fuzzing with coverage feedback.

**Benefits:**
- Discover unknown vulnerabilities
- Efficient test case generation
- Automated crash analysis

**Usage:**
```bash
./pilgrims.sh --fuzz=http://example.com seeds/ 60
```

---

### 7. Symbolic Execution
**Command:** `./pilgrims.sh --symbolic=<target>`

**Description:** Automated path exploration using symbolic execution.

**Benefits:**
- Deep code analysis
- Path coverage maximization
- Constraint solving

**Usage:**
```bash
./pilgrims.sh --symbolic=http://example.com
```

---

### 8. Formal Verification
**Command:** `./pilgrims.sh --formal=<target>`

**Description:** Mathematical proof of security properties.

**Benefits:**
- Prove correctness
- Verify security properties
- Detect logical flaws

**Usage:**
```bash
./pilgrims.sh --formal=http://example.com
```

---

### 9. Mutation Testing
**Command:** `./pilgrims.sh --mutation=<target> <test_suite>`

**Description:** Assess test suite quality using mutation testing.

**Benefits:**
- Improve test coverage
- Identify weak tests
- Validate test effectiveness

**Usage:**
```bash
./pilgrims.sh --mutation=http://example.com tests.txt
```

---

## Phase 3: Specialized Domains (12 features)

### Hardware Security (4 features)

#### 10. Side-Channel Attack Simulation
**Command:** `./pilgrims.sh --side-channel=<target> <type>`

**Description:** Simulate side-channel attacks (timing, cache, power).

**Usage:**
```bash
./pilgrims.sh --side-channel=http://example.com timing
```

---

#### 11. Fault Injection Testing
**Command:** `./pilgrims.sh --fault-injection=<target>`

**Description:** Test resistance to fault injection attacks.

**Usage:**
```bash
./pilgrims.sh --fault-injection=device
```

---

#### 12. HSM Security Testing
**Command:** `./pilgrims.sh --hsm=<target>`

**Description:** Hardware Security Module security assessment.

**Usage:**
```bash
./pilgrims.sh --hsm=hsm_device
```

---

#### 13. TPM/Secure Enclave Testing
**Command:** `./pilgrims.sh --tpm=<target>`

**Description:** Trusted Platform Module security testing.

**Usage:**
```bash
./pilgrims.sh --tpm=tpm_device
```

---

### AI/ML Security (4 features)

#### 14. LLM Security Testing
**Command:** `./pilgrims.sh --llm=<target>`

**Description:** Large Language Model security assessment.

**Features:**
- Prompt injection testing
- Jailbreak detection
- Data extraction testing

**Usage:**
```bash
./pilgrims.sh --llm=https://api.openai.com
```

---

#### 15. Federated Learning Security
**Command:** `./pilgrims.sh --federated=<target>`

**Description:** Federated learning system security assessment.

**Usage:**
```bash
./pilgrims.sh --federated=federated_server
```

---

#### 16. Backdoor Detection
**Command:** `./pilgrims.sh --backdoor=<target>`

**Description:** Neural network backdoor detection.

**Usage:**
```bash
./pilgrims.sh --backdoor=model.h5
```

---

#### 17. Model Stealing Detection
**Command:** `./pilgrims.sh --model-stealing=<target>`

**Description:** Detect model extraction attacks.

**Usage:**
```bash
./pilgrims.sh --model-stealing=https://api.example.com
```

---

### Supply Chain Security (4 features)

#### 18. SBOM Generation & Analysis
**Command:** `./pilgrims.sh --sbom=<target>`

**Description:** Software Bill of Materials generation and analysis.

**Usage:**
```bash
./pilgrims.sh --sbom=/path/to/project
```

---

#### 19. Dependency Confusion Detection
**Command:** `./pilgrims.sh --dep-confusion=<target>`

**Description:** Detect dependency confusion vulnerabilities.

**Usage:**
```bash
./pilgrims.sh --dep-confusion=/path/to/project
```

---

#### 20. Code Signing Verification
**Command:** `./pilgrims.sh --code-signing=<target>`

**Description:** Verify code signatures and certificates.

**Usage:**
```bash
./pilgrims.sh --code-signing=/path/to/binaries
```

---

#### 21. Container Provenance Verification
**Command:** `./pilgrims.sh --container-provenance=<target>`

**Description:** Verify container image provenance.

**Usage:**
```bash
./pilgrims.sh --container-provenance=docker.io/library/nginx
```

---

## Phase 4: Cloud-Native & Protocol (12 features)

### Cloud-Native Security (4 features)

#### 22. eBPF Security Analysis
**Command:** `./pilgrims.sh --ebpf=<target>`

**Description:** eBPF program security analysis.

**Usage:**
```bash
./pilgrims.sh --ebpf=target
```

---

#### 23. WebAssembly (WASM) Security
**Command:** `./pilgrims.sh --wasm=<target>`

**Description:** WebAssembly module security testing.

**Usage:**
```bash
./pilgrims.sh --wasm=module.wasm
```

---

#### 24. Service Mesh Security
**Command:** `./pilgrims.sh --service-mesh=<target> <type>`

**Description:** Service mesh security assessment (Istio, Linkerd, Consul).

**Usage:**
```bash
./pilgrims.sh --service-mesh=k8s-cluster istio
```

---

#### 25. Kubernetes Admission Controllers
**Command:** `./pilgrims.sh --k8s-admission=<target>`

**Description:** Kubernetes admission controller security testing.

**Usage:**
```bash
./pilgrims.sh --k8s-admission=k8s-cluster
```

---

### Protocol Security (4 features)

#### 26. gRPC Security Testing
**Command:** `./pilgrims.sh --grpc=<target>`

**Description:** gRPC service security assessment.

**Usage:**
```bash
./pilgrims.sh --grpc=grpc.example.com:50051
```

---

#### 27. QUIC/HTTP3 Security
**Command:** `./pilgrims.sh --quic=<target>`

**Description:** QUIC/HTTP3 protocol security testing.

**Usage:**
```bash
./pilgrims.sh --quic=https://example.com
```

---

#### 28. Advanced WebSocket Attacks
**Command:** `./pilgrims.sh --websocket-adv=<target>`

**Description:** Advanced WebSocket security testing.

**Usage:**
```bash
./pilgrims.sh --websocket-adv=wss://example.com/ws
```

---

#### 29. API Gateway Security
**Command:** `./pilgrims.sh --api-gateway=<target> <type>`

**Description:** API gateway security assessment (Kong, Apigee, Envoy).

**Usage:**
```bash
./pilgrims.sh --api-gateway=gateway.example.com kong
```

---

### DevSecOps Integration (4 features)

#### 30. Git Hooks Security
**Command:** `./pilgrims.sh --git-hooks=<target>`

**Description:** Git hooks security validation.

**Usage:**
```bash
./pilgrims.sh --git-hooks=/path/to/repo
```

---

#### 31. Infrastructure as Code (IaC)
**Command:** `./pilgrims.sh --iac=<target> <type>`

**Description:** IaC security scanning (Terraform, CloudFormation).

**Usage:**
```bash
./pilgrims.sh --iac=/path/to/terraform terraform
```

---

#### 32. Serverless Security
**Command:** `./pilgrims.sh --serverless=<target> <provider>`

**Description:** Serverless function security testing (AWS, GCP, Azure).

**Usage:**
```bash
./pilgrims.sh --serverless=lambda_function aws
```

---

#### 33. Chaos Engineering Security
**Command:** `./pilgrims.sh --chaos=<target>`

**Description:** Chaos engineering security validation.

**Usage:**
```bash
./pilgrims.sh --chaos=production-cluster
```

---

## Phase 5: Compliance & Crypto (12 features)

### Compliance Automation (4 features)

#### 34. SOC2 Compliance Checker
**Command:** `./pilgrims.sh --soc2=<target>`

**Description:** SOC2 compliance assessment.

**Usage:**
```bash
./pilgrims.sh --soc2=organization
```

---

#### 35. ISO27001/27002 Assessment
**Command:** `./pilgrims.sh --iso27001=<target>`

**Description:** ISO27001/27002 compliance assessment.

**Usage:**
```bash
./pilgrims.sh --iso27001=organization
```

---

#### 36. HIPAA Security Rule Audit
**Command:** `./pilgrims.sh --hipaa=<target>`

**Description:** HIPAA compliance assessment.

**Usage:**
```bash
./pilgrims.sh --hipaa=healthcare_org
```

---

#### 37. PCI-DSS Compliance Scanner
**Command:** `./pilgrims.sh --pcidss=<target>`

**Description:** PCI-DSS compliance assessment.

**Usage:**
```bash
./pilgrims.sh --pcidss=payment_system
```

---

### Advanced Cryptography (4 features)

#### 38. Zero-Knowledge Proof Auditing
**Command:** `./pilgrims.sh --zkp=<target>`

**Description:** Zero-Knowledge Proof implementation audit.

**Usage:**
```bash
./pilgrims.sh --zkp=blockchain_protocol
```

---

#### 39. Post-Quantum Cryptography Testing
**Command:** `./pilgrims.sh --pqc=<target>`

**Description:** Post-quantum cryptography readiness testing.

**Usage:**
```bash
./pilgrims.sh --pqc=system
```

---

#### 40. Multi-Party Computation Security
**Command:** `./pilgrims.sh --mpc=<target>`

**Description:** Multi-Party Computation protocol audit.

**Usage:**
```bash
./pilgrims.sh --mpc=protocol
```

---

#### 41. Homomorphic Encryption Audit
**Command:** `./pilgrims.sh --fhe=<target>`

**Description:** Fully Homomorphic Encryption implementation audit.

**Usage:**
```bash
./pilgrims.sh --fhe=implementation
```

---

### Threat Intelligence & SOAR (4 features)

#### 42. MITRE ATT&CK Navigator
**Command:** `./pilgrims.sh --mitre-nav=<target>`

**Description:** Generate MITRE ATT&CK Navigator layers.

**Usage:**
```bash
./pilgrims.sh --mitre-nav=target
```

---

#### 43. STIX/TAXII Feed Integration
**Command:** `./pilgrims.sh --stix=<target>`

**Description:** STIX/TAXII threat intelligence integration.

**Usage:**
```bash
./pilgrims.sh --stix=target
```

---

#### 44. SOAR Playbook Integration
**Command:** `./pilgrims.sh --soar=<target>`

**Description:** SOAR playbook generation and integration.

**Usage:**
```bash
./pilgrims.sh --soar=target
```

---

#### 45. Incident Response Automation
**Command:** `./pilgrims.sh --ir=<target>`

**Description:** Automated incident response workflows.

**Usage:**
```bash
./pilgrims.sh --ir=incident
```

---

## Phase 6: Forensics & Malware (8 features)

### Digital Forensics (4 features)

#### 46. Memory Forensics Analysis
**Command:** `./pilgrims.sh --memory-forensics=<file>`

**Description:** RAM dump analysis and artifact extraction.

**Usage:**
```bash
./pilgrims.sh --memory-forensics=dump.bin
```

---

#### 47. Network Forensics (PCAP)
**Command:** `./pilgrims.sh --network-forensics=<file>`

**Description:** Network traffic analysis and reconstruction.

**Usage:**
```bash
./pilgrims.sh --network-forensics=capture.pcap
```

---

#### 48. File System Forensics
**Command:** `./pilgrims.sh --filesystem-forensics=<file>`

**Description:** File system analysis and deleted file recovery.

**Usage:**
```bash
./pilgrims.sh --filesystem-forensics=disk.img
```

---

#### 49. Timeline Reconstruction
**Command:** `./pilgrims.sh --timeline=<directory>`

**Description:** Event correlation and timeline reconstruction.

**Usage:**
```bash
./pilgrims.sh --timeline=evidence_dir/
```

---

### Malware Analysis (4 features)

#### 50. Static Reverse Engineering
**Command:** `./pilgrims.sh --static-analysis=<file>`

**Description:** Binary static analysis and reverse engineering.

**Usage:**
```bash
./pilgrims.sh --static-analysis=malware.exe
```

---

#### 51. Dynamic Analysis Sandbox
**Command:** `./pilgrims.sh --dynamic-analysis=<file> [duration]`

**Description:** Behavioral analysis in sandbox environment.

**Usage:**
```bash
./pilgrims.sh --dynamic-analysis=suspicious.exe 60
```

---

#### 52. YARA Rule Generation
**Command:** `./pilgrims.sh --yara=<file>`

**Description:** Automated YARA rule generation.

**Usage:**
```bash
./pilgrims.sh --yara=sample.bin
```

---

#### 53. IOC Extraction & Correlation
**Command:** `./pilgrims.sh --ioc=<target>`

**Description:** Indicator of Compromise extraction and correlation.

**Usage:**
```bash
./pilgrims.sh --ioc=evidence_dir/
```

---

## Feature Statistics

| Phase | Features | Category |
|-------|----------|----------|
| Phase 1 | 5 | Resume & Compare |
| Phase 2 | 4 | Advanced Testing |
| Phase 3 | 12 | Specialized Domains |
| Phase 4 | 12 | Cloud-Native & Protocol |
| Phase 5 | 12 | Compliance & Crypto |
| Phase 6 | 8 | Forensics & Malware |
| **Total** | **53** | **All Features** |

---

## Feature Integration

All features integrate with:
- **Interactive Menu** - Access via menu options 28-84
- **Command Line** - Direct command execution
- **Reporting** - Consistent report formats
- **Database** - Unified data storage
- **Logging** - Centralized logging

---

## Coming Soon

### Phase 7: Futuristic & Emerging Technologies
- Quantum Computing Security
- Space/Satellite Security
- Nuclear Facility Security
- Defense/Military Systems
- Autonomous Vehicle Security
- Metaverse Security
- Brain-Computer Interface
- Swarm Robotics

---

**🏴‍☠️ Master all features, Captain!**
