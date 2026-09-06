# 🔧 Troubleshooting Guide

## Table of Contents

1. [Common Issues](#common-issues)
2. [Installation Problems](#installation-problems)
3. [Module Errors](#module-errors)
4. [Performance Issues](#performance-issues)
5. [Report Generation](#report-generation)
6. [Database Issues](#database-issues)
7. [Network Issues](#network-issues)
8. [Debug Mode](#debug-mode)

---

## Common Issues

### Issue: Permission Denied

**Symptom:**
```
bash: ./pilgrims.sh: Permission denied
```

**Solution:**
```bash
# Set execute permissions
chmod +x pilgrims.sh
chmod +x core/*.sh
chmod +x modules/*/pilgrims-*.sh

# Verify permissions
ls -l pilgrims.sh
```

---

### Issue: Command Not Found

**Symptom:**
```
./pilgrims.sh: command not found
```

**Solution:**
```bash
# Check if file exists
ls -l pilgrims.sh

# Run with bash explicitly
bash pilgrims.sh --help

# Add to PATH
export PATH=$PATH:$(pwd)
```

---

### Issue: Module Not Found

**Symptom:**
```
❌ Module 'web' not found
```

**Solution:**
```bash
# Check if module exists
ls modules/module-web/

# Verify module script
ls modules/module-web/pilgrims-web.sh

# Check permissions
chmod +x modules/module-web/pilgrims-web.sh
```

---

### Issue: Syntax Error

**Symptom:**
```
pilgrims.sh: line 10: syntax error near unexpected token
```

**Solution:**
```bash
# Check syntax
bash -n pilgrims.sh

# Fix CRLF line endings (WSL)
sudo apt install dos2unix
find . -type f -name "*.sh" -exec dos2unix {} \;

# Re-download file if corrupted
```

---

## Installation Problems

### Issue: Missing Dependencies

**Symptom:**
```
❌ nmap not installed
❌ jq not installed
```

**Solution:**
```bash
# Install core dependencies
sudo apt update
sudo apt install -y nmap curl whois dnsutils jq openssl python3 sqlite3

# Install security tools
sudo apt install -y assetfinder ffuf whatweb wafw00f dirb

# Verify installation
which nmap jq sqlite3
```

---

### Issue: Database Initialization Failed

**Symptom:**
```
❌ Database initialization failed
```

**Solution:**
```bash
# Create database directory
mkdir -p shared/db

# Initialize database
./pilgrims.sh --history

# Check database
sqlite3 shared/db/pilgrims.db ".tables"
```

---

### Issue: WSL CRLF Issues

**Symptom:**
```
\r: command not found
```

**Solution:**
```bash
# Install dos2unix
sudo apt install dos2unix

# Convert all files
find . -type f -name "*.sh" -exec dos2unix {} \;
find . -type f -name "*.conf" -exec dos2unix {} \;

# Verify
file pilgrims.sh
# Should show: ASCII text (not CRLF)
```

---

## Module Errors

### Issue: Web Module Timeout

**Symptom:**
```
⚠️  Timeout while scanning example.com
```

**Solution:**
```bash
# Increase timeout
export PILGRIMS_TIMEOUT=30

# Check network connectivity
curl -I https://example.com

# Try with stealth mode
./pilgrims.sh --module=web example.com --quick --stealth
```

---

### Issue: Network Module Requires Root

**Symptom:**
```
❌ Network scan requires root privileges
```

**Solution:**
```bash
# Run with sudo
sudo ./pilgrims.sh --module=network 192.168.1.0/24 --quick

# Or configure sudoers
sudo visudo
# Add: username ALL=(ALL) NOPASSWD: /path/to/pilgrims.sh
```

---

### Issue: Mobile Module - APK Tool Missing

**Symptom:**
```
❌ apktool not found
```

**Solution:**
```bash
# Install apktool
sudo apt install apktool

# Or download manually
wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.7.0.jar
sudo mv apktool_2.7.0.jar /usr/local/bin/apktool.jar
```

---

### Issue: Cloud Module - AWS CLI Not Configured

**Symptom:**
```
❌ AWS credentials not found
```

**Solution:**
```bash
# Install AWS CLI
sudo apt install awscli

# Configure credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

---

## Performance Issues

### Issue: Scan Too Slow

**Symptom:**
```
Scan taking too long (> 1 hour)
```

**Solution:**
```bash
# Use quick scan instead of deep
./pilgrims.sh --module=web example.com --quick

# Limit scope
./pilgrims.sh --module=web example.com --recon-only

# Use parallel scanning
./pilgrims.sh --module=web --parallel=targets.txt

# Reduce timeout
export PILGRIMS_TIMEOUT=10
```

---

### Issue: High Memory Usage

**Symptom:**
```
System running out of memory during scan
```

**Solution:**
```bash
# Limit parallel threads
./pilgrims.sh --module=web --parallel=targets.txt --threads=2

# Scan smaller batches
split -l 10 targets.txt batch_
for batch in batch_*; do
    ./pilgrims.sh --module=web --parallel=$batch
done

# Increase swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

### Issue: Disk Space Full

**Symptom:**
```
No space left on device
```

**Solution:**
```bash
# Check disk usage
df -h

# Clean old reports
find reports/ -type d -mtime +30 -exec rm -rf {} \;

# Compress old reports
find reports/ -type d -mtime +7 -exec tar -czf {}.tar.gz {} \; -exec rm -rf {} \;

# Clean database
sqlite3 shared/db/pilgrims.db "DELETE FROM scans WHERE scan_date < date('now', '-30 days');"
```

---

## Report Generation

### Issue: Report Not Generated

**Symptom:**
```
⚠️  Report not found in reports/
```

**Solution:**
```bash
# Check if report directory exists
ls reports/

# Check permissions
chmod 755 reports/

# Run scan again with verbose output
./pilgrims.sh --module=web example.com --quick 2>&1 | tee scan.log

# Check for errors in log
grep -i "error\|fail" scan.log
```

---

### Issue: Empty Report

**Symptom:**
```
Report generated but contains no findings
```

**Solution:**
```bash
# Verify target is accessible
curl -I https://example.com

# Try deep scan
./pilgrims.sh --module=web example.com --deep

# Check if target has vulnerabilities
# Try with known vulnerable target
./pilgrims.sh --module=web http://testphp.vulnweb.com --quick
```

---

### Issue: Report Format Issues

**Symptom:**
```
Report not displaying correctly
```

**Solution:**
```bash
# Check file encoding
file reports/web_*/reports/*.md

# Convert to UTF-8 if needed
iconv -f ISO-8859-1 -t UTF-8 report.md > report_utf8.md

# View with proper encoding
less -R report.md
```

---

## Database Issues

### Issue: Database Locked

**Symptom:**
```
Error: database is locked
```

**Solution:**
```bash
# Kill any running pilgrims processes
pkill -f pilgrims

# Remove lock file
rm -f shared/db/pilgrims.db-journal

# Vacuum database
sqlite3 shared/db/pilgrims.db "VACUUM;"

# Check integrity
sqlite3 shared/db/pilgrims.db "PRAGMA integrity_check;"
```

---

### Issue: Database Corrupted

**Symptom:**
```
Error: database disk image is malformed
```

**Solution:**
```bash
# Backup current database
cp shared/db/pilgrims.db shared/db/pilgrims.db.backup

# Recreate database
rm shared/db/pilgrims.db
./pilgrims.sh --history

# Restore data if needed
sqlite3 shared/db/pilgrims.db.backup ".dump" | sqlite3 shared/db/pilgrims.db
```

---

### Issue: History Not Showing

**Symptom:**
```
./pilgrims.sh --history shows empty
```

**Solution:**
```bash
# Check database
sqlite3 shared/db/pilgrims.db "SELECT COUNT(*) FROM scans;"

# Check if scans are being saved
ls reports/

# Manually insert test record
sqlite3 shared/db/pilgrims.db "INSERT INTO scans (module, target, scan_date) VALUES ('web', 'test.com', datetime('now'));"

# Verify
./pilgrims.sh --history
```

---

## Network Issues

### Issue: Connection Timeout

**Symptom:**
```
Connection timed out
```

**Solution:**
```bash
# Check network connectivity
ping example.com

# Check DNS resolution
nslookup example.com

# Try with different DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Increase timeout
export PILGRIMS_TIMEOUT=30

# Check firewall
sudo iptables -L
```

---

### Issue: SSL Certificate Errors

**Symptom:**
```
SSL certificate problem: unable to get local issuer certificate
```

**Solution:**
```bash
# Update CA certificates
sudo apt install ca-certificates
sudo update-ca-certificates

# Or skip SSL verification (not recommended)
export CURL_SSL_NO_VERIFY=1

# Or use specific CA bundle
export CURL_CA_BUNDLE=/path/to/ca-bundle.crt
```

---

### Issue: Proxy Issues

**Symptom:**
```
Cannot connect through proxy
```

**Solution:**
```bash
# Set proxy environment variables
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080

# Or bypass proxy for local addresses
export no_proxy=localhost,127.0.0.1,192.168.0.0/16

# Test proxy
curl -I https://example.com
```

---

## Debug Mode

### Enable Debug Logging

```bash
# Set debug level
export PILGRIMS_LOG_LEVEL=DEBUG

# Run scan
./pilgrims.sh --module=web example.com --quick

# Check logs
tail -f shared/logs/pilgrims.log
```

### Verbose Output

```bash
# Run with verbose output
./pilgrims.sh --module=web example.com --quick 2>&1 | tee debug.log

# Check for errors
grep -i "error\|fail\|exception" debug.log
```

### Module-Specific Debug

```bash
# Source module directly
source core/forensics/memory_forensics.sh

# Run function with debug
set -x
memory_forensics dump.bin output_dir
set +x
```

### Network Debug

```bash
# Enable curl verbose
export CURL_VERBOSE=1

# Or use tcpdump
sudo tcpdump -i any -n -s 0 -w capture.pcap

# Analyze capture
./pilgrims.sh --network-forensics=capture.pcap
```

---

## Getting Help

### Check Documentation

```bash
# View README
cat README.md

# View user guide
cat USER_GUIDE.md

# View examples
cat EXAMPLES.md
```

### Run Test Suite

```bash
# Comprehensive test
./test-all-features.sh

# Simple test
./test-simple.sh
```

### Check System Status

```bash
# Interactive mode
./pilgrims.sh

# Select [S] System Status
```

### Contact Support

- **Documentation:** See docs/ folder
- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

---

## Quick Fix Checklist

When encountering issues, try these in order:

1. ✅ Check file permissions: `chmod +x pilgrims.sh`
2. ✅ Verify dependencies: `./test-simple.sh`
3. ✅ Fix line endings: `dos2unix *.sh`
4. ✅ Check database: `sqlite3 shared/db/pilgrims.db ".tables"`
5. ✅ Clear cache: `rm -rf reports/`
6. ✅ Update PILGRIMS: `git pull`
7. ✅ Reinstall dependencies: `sudo apt install -y nmap curl jq`
8. ✅ Check logs: `tail -f shared/logs/pilgrims.log`

---

**🏴‍☠️ Smooth sailing, Captain!**
