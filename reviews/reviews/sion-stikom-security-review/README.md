![GitHub top language](https://img.shields.io/github/languages/top/afiqandico13/sion-stikom-security-review) ![GitHub license](https://img.shields.io/github/license/afiqandico13/sion-stikom-security-review)

# SION STIKOM Bali — Security Research

Comprehensive security research on ITB STIKOM Bali's web infrastructure. Dua report tersedia: **pentest 2026** (comprehensive) dan **static review** (preliminary).

---

## 📑 Reports

### 🎯 [pentest-2026/](./pentest-2026/) — **Comprehensive (22 Juni 2026)**
Full OWASP-aligned black-box penetration test on `*.stikom-bali.ac.id`:
- **5 findings** + 1 safe control verified
- CVSS 3.1 scoring per finding
- POC commands dengan output
- Remediation (code + config)
- Verification commands untuk IT team
- Responsible disclosure timeline
- Anonymized untuk portfolio publik

**Top finding:** Origin IP exposure & WAF bypass on `pembayaran.stikom-bali.ac.id`.

### 📄 [Report.md](./Report.md) — Static Review (18 Juni 2026)
Preliminary static analysis of `sion.stikom-bali.ac.id`:
- HTTP header posture
- 6 items, mostly defense-in-depth
- **No exploit path verified** — purely hardening recommendations
- HTML + PDF versions available

---

## ⚡ Quick Summary (pentest 2026)

| # | Finding | Severity | CVSS 3.1 |
|---|---|---|---|
| 1 | Origin IP Exposure & WAF Bypass | 🔴 CRITICAL | 7.5 |
| 2 | Missing Rate Limiting on Login | 🟠 HIGH | 7.5 |
| 3 | Debug Mode Enabled (Stack Trace) | 🟠 HIGH | 5.3 |
| 4 | Verbose Error Messages | 🟡 MEDIUM | 5.3 |
| 5 | Misconfigured Web Server | 🟡 MEDIUM | 5.3 |
| 6 | User Enumeration via Forgot Password | 🟢 SAFE | — |

**Read the full report:** [pentest-2026/README.md](./pentest-2026/README.md)

---

## 🛡️ Responsible Disclosure

Both reports follow responsible disclosure principles:
- ✅ No exploitation of findings
- ✅ Anonymized version published (sensitive data redacted)
- ✅ Email disclosure sent to IT STIKOM
- ✅ 90-day public disclosure window

Email template: [email-to-it.md](./email-to-it.md) (for the static review; pentest 2026 has its own template inside `pentest-2026/`)

---

## 🎓 Author

**afuckingco** — IT Support @ Cube Cafe Jimbaran · Mahasiswa Sistem Informasi ITB STIKOM Bali

---

## 📜 License

MIT — see [LICENSE](./LICENSE). Feel free to use as template for your own security research.
