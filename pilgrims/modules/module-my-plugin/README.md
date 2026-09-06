# 🏴‍☠️ PILGRIMS v17.0 - EXAMPLE PLUGIN MODULE

**This is a working example plugin that demonstrates the plugin pattern.**

Unlike `module-custom-module` (which is a blank template for you to copy),
this module actually does real security checks so you can see how a complete
plugin looks in practice.

## What it does

The `my-plugin` module performs **3 quick security checks** against any target:

1. **HTTP Headers Analysis** — checks for missing security headers
   (X-Frame-Options, CSP, HSTS, X-Content-Type-Options)
2. **SSL/TLS Quick Check** — verifies HTTPS works and cert is valid
3. **Open Ports Hint** — basic nmap probe of common ports (80, 443, 22, 21)

It runs in under 30 seconds and produces a Markdown report.

## Usage

```bash
# Scan a target
./pilgrims.sh --module=my-plugin https://example.com --quick

# Or run directly
modules/module-my-plugin/pilgrims-my-plugin.sh https://example.com

# Output
modules/module-my-plugin/reports/my-plugin_TIMESTAMP/
├── REPORT.md
├── headers.txt
├── ssl.txt
└── ports.txt
```

## What you can learn from this

- **Argument parsing** — handling `--quick`, `--deep`, etc.
- **Multi-phase scanning** — multiple checks in sequence with phase headers
- **Output organization** — separate `.txt` files per check + final `REPORT.md`
- **Conditional logic** — `if command_exists nmap; then ...; else skip; fi`
- **Error handling** — `2>/dev/null` for non-critical failures, log to file

## Customize it

To turn this into your own working module:

1. **Rename** to your module name (e.g., `module-myapi`)
2. **Replace the check functions** with your own
3. **Update `MODULE_NAME`** and phase headers
4. **Add to MODULES.md** in the main repo
5. **Test** with `./pilgrims.sh --module=myapi target.com --quick`

For a blank template to copy, see `modules/module-custom-module/README.md`.

---

*Example by PILGRIMS v17.0*
