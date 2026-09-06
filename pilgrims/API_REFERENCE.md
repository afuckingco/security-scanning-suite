# 🔌 API Reference

## Overview

This document provides technical reference for PILGRIMS v17.0 internal APIs, functions, and data structures.

---

## Core Functions

### print_epic_banner()

**Description:** Display the PILGRIMS ASCII art banner.

**Usage:**
```bash
source core/ui.sh
print_epic_banner
```

---

### print_module_info()

**Description:** Display module information.

**Parameters:**
- `$1` - Module name
- `$2` - Version
- `$3` - Description

**Usage:**
```bash
print_module_info "web" "1.0" "Web Application Security"
```

---

### print_phase_header()

**Description:** Display phase header.

**Parameters:**
- `$1` - Phase number
- `$2` - Phase title

**Usage:**
```bash
print_phase_header "1" "Reconnaissance"
```

---

### print_success()

**Description:** Print success message.

**Parameters:**
- `$1` - Message

**Usage:**
```bash
print_success "Scan completed"
```

---

### print_error()

**Description:** Print error message.

**Parameters:**
- `$1` - Message

**Usage:**
```bash
print_error "File not found"
```

---

### print_warning()

**Description:** Print warning message.

**Parameters:**
- `$1` - Message

**Usage:**
```bash
print_warning "Timeout occurred"
```

---

### print_info()

**Description:** Print info message.

**Parameters:**
- `$1` - Message

**Usage:**
```bash
print_info "Processing..."
```

---

### print_vuln()

**Description:** Print vulnerability finding.

**Parameters:**
- `$1` - Severity (CRITICAL, HIGH, MEDIUM, LOW)
- `$2` - Description

**Usage:**
```bash
print_vuln "CRITICAL" "SQL Injection found"
```

---

### print_mission_complete()

**Description:** Display mission complete banner.

**Parameters:**
- `$1` - Module name
- `$2` - Target
- `$3` - Output directory
- `$4` - Duration

**Usage:**
```bash
print_mission_complete "web" "example.com" "/path/to/reports" "120"
```

---

## Database Functions

### init_db()

**Description:** Initialize the SQLite database.

**Usage:**
```bash
source core/database.sh
init_db
```

---

### save_scan_to_db()

**Description:** Save scan results to database.

**Parameters:**
- `$1` - Module name
- `$2` - Target
- `$3` - Duration
- `$4` - Output directory

**Usage:**
```bash
save_scan_to_db "web" "example.com" "120" "/path/to/reports"
```

---

### show_scan_history()

**Description:** Display scan history from database.

**Usage:**
```bash
show_scan_history
```

---

## Utility Functions

### get_timestamp()

**Description:** Get current timestamp.

**Returns:** Timestamp string (YYYYMMDD_HHMMSS)

**Usage:**
```bash
timestamp=$(get_timestamp)
```

---

### get_iso_timestamp()

**Description:** Get ISO 8601 timestamp.

**Returns:** ISO timestamp string

**Usage:**
```bash
iso_timestamp=$(get_iso_timestamp)
```

---

### calculate_duration()

**Description:** Calculate duration between two timestamps.

**Parameters:**
- `$1` - Start timestamp

**Returns:** Duration in seconds

**Usage:**
```bash
duration=$(calculate_duration $start_time)
```

---

### format_duration()

**Description:** Format duration in human-readable format.

**Parameters:**
- `$1` - Duration in seconds

**Returns:** Formatted string (e.g., "2h 15m 30s")

**Usage:**
```bash
formatted=$(format_duration 8130)
# Returns: "2h 15m 30s"
```

---

### count_findings()

**Description:** Count findings by severity.

**Parameters:**
- `$1` - Output directory
- `$2` - Severity (CRITICAL, HIGH, MEDIUM, LOW)

**Returns:** Count

**Usage:**
```bash
critical_count=$(count_findings "/path/to/reports" "CRITICAL")
```

---

### get_total_findings()

**Description:** Get total number of findings.

**Parameters:**
- `$1` - Output directory

**Returns:** Total count

**Usage:**
```bash
total=$(get_total_findings "/path/to/reports")
```

---

### extract_domain()

**Description:** Extract domain from URL.

**Parameters:**
- `$1` - URL

**Returns:** Domain name

**Usage:**
```bash
domain=$(extract_domain "https://example.com/path")
# Returns: "example.com"
```

---

### sanitize_filename()

**Description:** Sanitize string for use as filename.

**Parameters:**
- `$1` - String

**Returns:** Sanitized string

**Usage:**
```bash
filename=$(sanitize_filename "example.com/path")
# Returns: "example.com_path"
```

---

## Stealth Functions

### apply_stealth_profile()

**Description:** Apply stealth profile settings.

**Parameters:**
- `$1` - Profile name (ghost, shadow, phantom, wraith)

**Usage:**
```bash
source core/stealth_profiles.sh
apply_stealth_profile "ghost"
```

---

## Template Functions

### apply_scan_template()

**Description:** Apply scan template settings.

**Parameters:**
- `$1` - Template name (quick-audit, full-pentest, bug-bounty, compliance, red-team, recon-only)

**Usage:**
```bash
source core/scan_templates.sh
apply_scan_template "bug-bounty"
```

---

## Theme Functions

### apply_theme()

**Description:** Apply color theme.

**Parameters:**
- `$1` - Theme name (default, matrix, blood, ocean, mono)

**Usage:**
```bash
source core/themes.sh
apply_theme "matrix"
```

---

## Crypto Functions

### encrypt_scan()

**Description:** Encrypt scan results with AES-256.

**Parameters:**
- `$1` - Directory to encrypt
- `$2` - Password

**Usage:**
```bash
source core/crypto.sh
encrypt_scan "/path/to/reports" "SecretPassword"
```

---

### decrypt_scan()

**Description:** Decrypt encrypted scan results.

**Parameters:**
- `$1` - Encrypted file
- `$2` - Password

**Usage:**
```bash
decrypt_scan "/path/to/reports.enc" "SecretPassword"
```

---

## Recorder Functions

### start_recording()

**Description:** Start session recording.

**Parameters:**
- `$1` - Output directory

**Usage:**
```bash
source core/recorder.sh
start_recording "/path/to/output"
```

---

### stop_recording()

**Description:** Stop session recording.

**Parameters:**
- `$1` - Output directory

**Usage:**
```bash
stop_recording "/path/to/output"
```

---

## Profiler Functions

### profile_target()

**Description:** Profile target to detect technology stack.

**Parameters:**
- `$1` - Target URL

**Returns:** Technology stack string

**Usage:**
```bash
source core/profiler.sh
profile=$(profile_target "https://example.com")
# Returns: "cms:WordPress"
```

---

## QR Functions

### generate_qr()

**Description:** Generate QR code from data.

**Parameters:**
- `$1` - Data
- `$2` - Output file (without extension)

**Usage:**
```bash
source core/qr_generator.sh
generate_qr "https://example.com" "/path/to/qr_code"
```

---

## Resume Functions

### save_scan_state()

**Description:** Save scan state for resumption.

**Parameters:**
- `$1` - Module name
- `$2` - Target
- `$3` - Current phase
- `$4` - Output directory

**Usage:**
```bash
source core/resume.sh
save_scan_state "web" "example.com" "5" "/path/to/reports"
```

---

### load_scan_state()

**Description:** Load saved scan state.

**Parameters:**
- `$1` - State file path

**Returns:** State string (module|target|phase|output_dir)

**Usage:**
```bash
state=$(load_scan_state "/path/to/.state.json")
```

---

### list_resumable_scans()

**Description:** List all resumable scans.

**Usage:**
```bash
list_resumable_scans
```

---

### resume_scan()

**Description:** Resume a previous scan.

**Parameters:**
- `$1` - Scan directory

**Usage:**
```bash
resume_scan "/path/to/scan_directory"
```

---

## Compare Functions

### compare_scans()

**Description:** Compare two scans.

**Parameters:**
- `$1` - Module name
- `$2` - Target

**Usage:**
```bash
source core/compare.sh
compare_scans "web" "example.com"
```

---

## Attack Path Functions

### map_attack_paths()

**Description:** Map attack paths from scan results.

**Parameters:**
- `$1` - Output directory

**Usage:**
```bash
source core/attack_path.sh
map_attack_paths "/path/to/reports"
```

---

## MITRE Functions

### map_to_mitre()

**Description:** Map findings to MITRE ATT&CK.

**Parameters:**
- `$1` - Output directory

**Usage:**
```bash
source core/mitre.sh
map_to_mitre "/path/to/reports"
```

---

## Parallel Functions

### parallel_scan()

**Description:** Execute parallel scans.

**Parameters:**
- `$1` - Targets file
- `$2` - Module name
- `$3` - Number of threads (default: 4)

**Usage:**
```bash
source core/parallel.sh
parallel_scan "targets.txt" "web" 4
```

---

## Module-Specific Functions

### Web Module

```bash
# Main function
plugin_web() {
    local target=$1
    local output_dir=$2
    # Implementation...
}
```

### Network Module

```bash
# Main function
plugin_network() {
    local target=$1
    local output_dir=$2
    # Implementation...
}
```

### Forensics Module

```bash
# Memory forensics
memory_forensics() {
    local target=$1
    local output_dir=$2
    # Implementation...
}

# Network forensics
network_forensics() {
    local target=$1
    local output_dir=$2
    # Implementation...
}

# Filesystem forensics
filesystem_forensics() {
    local target=$1
    local output_dir=$2
    # Implementation...
}

# Timeline reconstruction
timeline_reconstruction() {
    local target=$1
    local output_dir=$2
    # Implementation...
}
```

### Malware Module

```bash
# Static analysis
static_analysis() {
    local target=$1
    local output_dir=$2
    # Implementation...
}

# Dynamic analysis
dynamic_analysis() {
    local target=$1
    local output_dir=$2
    local duration=$3
    # Implementation...
}

# YARA generation
yara_generator() {
    local target=$1
    local output_dir=$2
    # Implementation...
}

# IOC extraction
ioc_extractor() {
    local target=$1
    local output_dir=$2
    # Implementation...
}
```

---

## Data Structures

### Scan Record

```bash
{
    "id": 1,
    "module": "web",
    "target": "example.com",
    "scan_date": "2026-06-22 18:00:00",
    "duration_sec": 120,
    "total_findings": 15,
    "critical_count": 2,
    "high_count": 5,
    "output_dir": "/path/to/reports"
}
```

### Finding Record

```bash
{
    "id": 1,
    "scan_id": 1,
    "module": "web",
    "category": "sqli",
    "severity": "CRITICAL",
    "description": "SQL Injection at /login"
}
```

### IOC Record

```bash
{
    "type": "ipv4",
    "value": "192.168.1.100",
    "classification": "SUSPICIOUS",
    "source": "malware_analysis"
}
```

---

## Environment Variables

### PILGRIMS_THEME
**Description:** Set color theme  
**Values:** default, matrix, blood, ocean, mono  
**Default:** default

```bash
export PILGRIMS_THEME=matrix
```

---

### PILGRIMS_LOG_LEVEL
**Description:** Set logging level  
**Values:** DEBUG, INFO, WARNING, ERROR, CRITICAL  
**Default:** INFO

```bash
export PILGRIMS_LOG_LEVEL=DEBUG
```

---

### PILGRIMS_TIMEOUT
**Description:** Set request timeout (seconds)  
**Default:** 10

```bash
export PILGRIMS_TIMEOUT=30
```

---

## Return Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Module not found |
| 4 | Target not accessible |
| 5 | Database error |
| 6 | Permission denied |

---

## Error Handling

All functions should check return codes:

```bash
if ! some_function; then
    print_error "Function failed"
    exit 1
fi
```

---

## Logging

Use logging functions for consistent logging:

```bash
source core/logging.sh

log_info "Starting scan"
log_warning "Timeout occurred"
log_error "Scan failed"
log_debug "Detailed information"
```

---

## Best Practices

1. **Always check parameters:**
   ```bash
   if [ -z "$1" ]; then
       print_error "Parameter required"
       return 1
   fi
   ```

2. **Use proper quoting:**
   ```bash
   echo "$variable"  # Good
   echo $variable    # Bad
   ```

3. **Handle errors gracefully:**
   ```bash
   command || {
       print_error "Command failed"
       return 1
   }
   ```

4. **Clean up resources:**
   ```bash
   trap 'rm -rf /tmp/temp_dir' EXIT
   ```

5. **Use local variables:**
   ```bash
   local variable="value"
   ```

---

**🏴‍☠️ Code like a pro, Captain!**
