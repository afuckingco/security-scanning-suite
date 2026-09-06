# 🏴‍☠️ PILGRIMS v17.0 - CUSTOM MODULE TEMPLATE

**Use this template to create your own security module.**

## Quick Start

1. **Copy this folder** to a new name:
   ```bash
   cp -r modules/module-custom-module modules/module-myscan
   ```

2. **Rename the script** inside:
   ```bash
   mv modules/module-myscan/pilgrims-custom-module.sh modules/module-myscan/pilgrims-myscan.sh
   ```

3. **Edit the script** — change `MODULE_NAME`, add your scanning logic:
   ```bash
   sed -i 's/custom-module/myscan/g' modules/module-myscan/pilgrims-myscan.sh
   ```

4. **Test it:**
   ```bash
   ./pilgrims.sh --module=myscan target.com --quick
   ```

5. **Commit & push** to share with the community!

## Template Structure

```
modules/module-myscan/
├── pilgrims-myscan.sh      # main module script (REQUIRED)
├── README.md               # this file
├── plugins/                # optional: individual check scripts
│   └── 01_example_check.sh
├── reports/                # scan output (gitignored)
└── logs/                   # runtime logs (gitignored)
```

## Required Script Template

```bash
#!/bin/bash
# Source guard — prevents auto-execution when sourced
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Run as script" >&2; return 0 2>/dev/null || exit 0; }

MODULE_NAME="myscan"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"

source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"

TARGET="$1"
shift

# Parse arguments (optional)
PROFILE="quick"
for arg in "$@"; do
    case $arg in
        --quick) PROFILE="quick" ;;
        --deep) PROFILE="deep" ;;
    esac
done

# Output directory
OUTPUT_DIR="$MODULE_DIR/reports/${MODULE_NAME}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "$MODULE_NAME" "🔧 YOUR MODULE TITLE"
print_info "Target: $TARGET"
print_info "Profile: $PROFILE"
echo ""

# === YOUR SCANNING LOGIC HERE ===
# Example: simple HTTP header check
print_task "Checking HTTP headers"
HEADERS=$(curl -k -s -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" > "$OUTPUT_DIR/headers.txt"

if echo "$HEADERS" | grep -qi "X-Frame-Options"; then
    print_success "X-Frame-Options header present"
else
    print_critical "Missing X-Frame-Options header (clickjacking risk)"
fi
# === END YOUR LOGIC ===

# Generate report
cat > "$OUTPUT_DIR/REPORT.md" << REOF
# $MODULE_NAME Security Report
**Target:** $TARGET
**Date:** $(date)

## Findings
$(cat "$OUTPUT_DIR"/*.txt 2>/dev/null | head -50)
REOF

print_success "Report saved: $OUTPUT_DIR/REPORT.md"
```

## Available Helpers (from core/ui.sh)

| Function | Purpose |
|----------|---------|
| `print_phase_header "NUM" "TITLE"` | Print section banner |
| `print_task "TASK"` | Print task in progress |
| `print_success "MSG"` | Green ✓ success |
| `print_error "MSG"` | Red ✗ error |
| `print_critical "MSG"` | Red ⚠ critical finding |
| `print_warning "MSG"` | Yellow ⚠ warning |
| `print_info "MSG"` | Blue ℹ info |
| `print_vuln "SEV" "MSG"` | Print vulnerability finding |
| `print_mission_complete "TYPE" "TARGET" "DIR" "DURATION"` | End-of-scan banner |

## Available Helpers (from core/utils.sh)

| Function | Purpose |
|----------|---------|
| `get_timestamp` | Current epoch seconds |
| `get_iso_timestamp` | ISO 8601 formatted date |
| `command_exists "CMD"` | Check if command in PATH |
| `is_valid_url "URL"` | URL format check |

## Plugin Pattern

For complex modules with many checks, split into plugins:

`plugins/01_header_check.sh`:
```bash
#!/bin/bash
# Plugin: HTTP Header Check
# Called by parent module with: TARGET and OUTPUT_DIR exported

header_check() {
    print_task "Header security check"
    local headers=$(curl -k -s -I --max-time 10 "$TARGET" 2>/dev/null)
    echo "$headers" > "$OUTPUT_DIR/headers.txt"
    # ... analysis logic ...
}
header_check
```

Then in main script:
```bash
for plugin in "$MODULE_DIR"/plugins/*.sh; do
    source "$plugin"
done
```

## Best Practices

1. **Always use the source guard** at the top — prevents accidental auto-execution
2. **Use `set -u`** (already in top-level scripts) to catch typos
3. **Quote variables** — `"$TARGET"` not `$TARGET`
4. **Use `timeout`** on network calls — never let a scan hang forever
5. **Generate Markdown reports** — humans + tooling both can read
6. **Add findings to `$OUTPUT_DIR/*.txt`** — easy to grep/parse later
7. **Use existing helpers** (print_*) for consistent output
8. **Test against authorized targets** — never scan without permission

## Examples to Study

Look at how other modules work:
- `modules/module-web/pilgrims-web.sh` (comprehensive, 400+ lines)
- `modules/module-network/pilgrims-network.sh` (mid-complexity)
- `modules/module-iot/pilgrims-iot.sh` (focused, IoT-specific)

## Submitting Back

If your custom module is useful for the community:

1. Add it to your fork
2. Document in `MODULES.md` (PR)
3. Add tests to `test-all-features.sh`
4. Open a PR — describe what your module does and why it's valuable

---

*Template by PILGRIMS v17.0 — see [README](../../README.md) and [CONTRIBUTING](../../CONTRIBUTING.md)*
