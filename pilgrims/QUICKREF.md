# 🏴‍☠️ PILGRIMS v17.0 — QUICK REFERENCE CARD

## 🚀 QUICK START

```bash
# Setup (run once after clone)
./setup.sh

# Quick test
./test-simple.sh

# Full help
./pilgrims.sh --help

# List all 20 modules
./pilgrims.sh --modules

# Interactive menu
./pilgrims-interactive.sh
```

## ⚡ COMMON COMMANDS

```bash
# Scan a target
./pilgrims.sh --module=web example.com
./pilgrims.sh --module=network 192.168.1.0/24
./pilgrims.sh --module=cloud --aws
./pilgrims.sh --module=ad domain.local

# Quick / stealth modes
./pilgrims.sh --module=web target.com --quick
./pilgrims.sh --module=web target.com --stealth
./pilgrims.sh --module=web target.com --deep

# Bug bounty / red team
./pilgrims.sh --module=web target.com --bug-bounty
./pilgrims.sh --module=web target.com --red-team

# Forensics
./pilgrims.sh --memory-forensics=dump.bin
./pilgrims.sh --network-forensics=capture.pcap
./pilgrims.sh --timeline=evidence_dir/

# Malware analysis
./pilgrims.sh --static-analysis=sample.exe
./pilgrims.sh --dynamic-analysis=sample.exe
./pilgrims.sh --yara=sample.bin
```

## 📂 STRUCTURE

```
pilgrims-v17/
├── pilgrims.sh              # main entry (v17.0)
├── pilgrims-interactive.sh  # interactive menu
├── pilgrims-manage.sh       # module manager
├── core/                    # 32 core scripts (ui, db, crypto, etc.)
├── modules/                 # 20 security modules
│   ├── module-web/          # web application (60+ checks)
│   ├── module-network/
│   ├── module-cloud/
│   ├── module-ad/
│   └── ... 17 more
├── shared/                  # runtime: db/, logs/, payloads/, wordlists/
├── upgrade-*.sh             # evolution: v14→v15, v15→v17, phases 2-6
└── test-*.sh                # test suites
```

## 🎯 20 MODULES

web · network · mobile · cloud · ad · container · code · wireless · email ·
iot · binary · blockchain · ics · medical · financial · forensic · ai ·
redteam · custom-module · my-plugin

## ⚠️ ALWAYS READ FIRST

- **[DISCLAIMER.md](DISCLAIMER.md)** — authorized use only
- **[INSTALLATION.md](INSTALLATION.md)** — setup
- **[USER_GUIDE.md](USER_GUIDE.md)** — full usage

---

*"Navigating the Digital Seas of Cybersecurity"*
