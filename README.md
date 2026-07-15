# Security Scanning Suite
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  [![CI](https://github.com/afuckingco/security-scanning-suite/actions/workflows/ci.yml/badge.svg)](https://github.com/afuckingco/security-scanning-suite/actions)


Consolidated collection of security scanning/CI tools, each in its own subdirectory with independent history preserved via git subtree.

## Projects

- **secure-ops-suite/** — Unified security operations: anomaly-detection logs + secure npm/PyPI proxy
- **sec-scan-cli/** — CLI tool running npm audit, pip-audit, Gitleaks, Suricata in one interface
- **secure-ci-pipeline/** — Automated CI/CD security scanning pipeline for multi-stack projects
- **log-anonymizer/** — Privacy-preserving log anonymization toolkit (CLI, FastAPI, Docker)

Each subdirectory retains its own README, LICENSE, and CI configuration.