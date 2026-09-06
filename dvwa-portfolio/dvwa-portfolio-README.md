# DVWA Security Research Portfolio

Complete documentation of SQL Injection exploitation techniques on DVWA (Damn Vulnerable Web Application).

## 📚 Contents

- **SQL Injection Techniques** - UNION-based, Boolean-based blind, Time-based blind
- **Network Reconnaissance** - Gateway and network discovery
- **Setup & Infrastructure** - MariaDB troubleshooting, Docker configuration
- **Automation Scripts** - Python exploitation tools with session handling
- **Performance Analysis** - Technique comparison and optimization

## 🎯 Techniques Covered

| Technique | Time | Use Case | Status |
|-----------|------|----------|--------|
| UNION-based | <1s | Direct output visible | ✅ Complete |
| Boolean-based blind | ~1-2min | True/False text signals | ✅ Complete |
| Time-based (optimized) | 8.1min | No visual signals | ✅ Complete |

## 📁 Directory Structure

```
dvwa-portfolio/
├── README.md (this file)
├── 01-setup/
│   ├── SETUP.md
│   ├── docker-compose.yml
│   ├── mariadb-fix.sh
│   └── dvwa-config.md
├── 02-reconnaissance/
│   ├── NETWORK_SCAN.md
│   ├── gateway-analysis.txt
│   └── nmap-results.xml
├── 03-sql-injection/
│   ├── UNION-BASED.md
│   ├── BOOLEAN-BASED-BLIND.md
│   ├── TIME-BASED-BLIND.md
│   ├── union_sqli.py
│   ├── boolean_sqli.py
│   ├── timebased_sqli.py
│   └── timebased_optimized.py
├── 04-analysis/
│   ├── PERFORMANCE_ANALYSIS.md
│   ├── EXTRACTION_OPTIMIZATION.md
│   └── comparison-table.csv
└── 05-resources/
    ├── REFERENCES.md
    └── TOOLS_USED.md
```

## 🚀 Quick Start

1. **Setup DVWA**
   ```bash
   cd 01-setup
   bash mariadb-fix.sh
   python3 setup-dvwa.py
   ```

2. **Run Reconnaissance**
   ```bash
   cd 02-reconnaissance
   bash scan.sh
   ```

3. **Execute SQL Injection**
   ```bash
   cd 03-sql-injection
   python3 union_sqli.py      # Fast extraction
   python3 boolean_sqli.py    # Medium speed
   python3 timebased_sqli.py  # No visual feedback
   ```

## 📊 Key Findings

- **Network**: 5 active hosts + 1 gateway (192.168.1.0/24)
- **Gateway**: lighttpd + Unbound DNS on 192.168.1.1
- **DVWA**: MariaDB login achieved, database users table extracted
- **Optimization**: Time-based extraction 3.7x faster with domain knowledge

## 🔐 Security Note

This portfolio documents exploitation of **DVWA**, a deliberately vulnerable application designed for educational purposes. All techniques are used exclusively on this isolated lab environment.

## 📝 Technologies

- Python 3 (requests, BeautifulSoup)
- nmap, curl, openssl
- MariaDB/MySQL
- DVWA (Damn Vulnerable Web Application)

## 📖 Reading Order

1. Start with `01-setup/SETUP.md`
2. Review `02-reconnaissance/NETWORK_SCAN.md`
3. Study SQL injection techniques in `03-sql-injection/`
4. Check performance analysis in `04-analysis/`

---

**Author**: Afiq  
**Date**: July 2026  
**Status**: Active Research
