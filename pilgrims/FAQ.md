# Frequently Asked Questions

## General

### What is PILGRIMS?

PILGRIMS is a **privacy-first web security framework** that bundles multiple security tools and modules into a single CLI. It's designed for authorized penetration testing, bug bounty hunting, CTF competitions, and security research.

### Is it free?

Yes. MIT licensed. Use it commercially, modify it, redistribute — as long as you keep the copyright notice.

### What's the difference between this and the original `pilgrims` repo?

There are two repos:

| Repo                                       | Status     | Audience                                |
|--------------------------------------------|------------|-----------------------------------------|
| `afiqandico13/pilgrims` (v13.0)            | legacy     | flat structure, 66 plugins, simpler    |
| `afiqandico13/pilgrims-v17` (v17.0)        | active     | 20 modules, 53 features, modular arch   |

`pilgrims-v17` is the modern, restructured version. `pilgrims` is preserved for historical reference.

---

## Installation

### Which platforms are supported?

- **Linux** (Ubuntu 20.04+, Debian 11+, Kali, Arch)
- **WSL2** on Windows 10/11
- **macOS** (with limitations — some tools are Linux-only)
- **Docker** (recommended for isolated runs)

### What are the minimum dependencies?

Required:
- `bash` 4+
- `coreutils`, `grep`, `sed`, `awk`, `find`
- `curl`, `wget`
- `nmap` (network scans)
- `jq` (JSON parsing)
- `openssl`
- `python3`

Optional (for specific modules):
- `whois`, `dig`, `nslookup` (DNS recon)
- `assetfinder`, `subfinder` (subdomain enum)
- `ffuf`, `gobuster` (directory brute)
- `sqlmap` (SQLi testing)
- `hydra` (brute force)
- `metasploit` (exploit framework integration)

### How do I install?

```bash
git clone https://github.com/afiqandico13/pilgrims-v17.git
cd pilgrims-v17
chmod +x pilgrims.sh
./pilgrims.sh --help
```

Or with Docker:

```bash
docker pull ghcr.io/afiqandico13/pilgrims-v17:latest
docker run --rm pilgrims-v17 --help
```

### How do I update?

```bash
cd pilgrims-v17
git pull origin main
```

That's it. The framework is self-contained — no package manager, no daemon, no DB schema to migrate.

---

## Usage

### What's the basic command structure?

```bash
./pilgrims.sh [options] <target>
```

Where `<target>` is a URL, IP, domain, or file (depending on the module).

### What modules are available?

```bash
./pilgrims.sh --modules
```

20 modules: web, network, mobile, cloud, ad, container, code, wireless, email, iot, binary, blockchain, ics, medical, financial, forensic, ai, redteam, custom-module, my-plugin.

### What profiles are available?

- `--quick` (default): fast scan, top findings
- `--deep`: comprehensive scan
- `--vuln`: vulnerability-focused
- `--bug-bounty`: optimized for bug bounty programs
- `--red-team`: adversary simulation mode
- `--stealth`: low-noise scan

### How long does a scan take?

| Profile | Time     | Use case                  |
|---------|----------|---------------------------|
| `--quick` | 1-5 min   | First pass, triage        |
| `--deep`  | 15-60 min | Full assessment           |
| `--vuln`  | 30-90 min | Vuln-focused              |
| `--stealth` | 30+ min  | Avoid detection           |

These depend heavily on target size, network latency, and which plugins are enabled.

### Where do scan results go?

By default: `modules/<module>/reports/<module>_<timestamp>/`

Or specify: `--output-dir=/path/to/dir`

Reports are in Markdown. You can also export to JSON, CSV, HTML, or QR code with `--format=` flag.

---

## Customization

### How do I add a custom module?

Create `modules/module-mything/pilgrims-mything.sh`:

```bash
#!/bin/bash
# Source guard — prevents auto-execution when sourced
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Run as script" >&2; return 0 2>/dev/null || exit 0; }

MODULE_NAME="mything"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"

TARGET="$1"
shift

# Your scanning logic here
echo "Scanning $TARGET..."
```

Then `./pilgrims.sh --module=mything target.com` works automatically.

### How do I add a custom plugin?

Plugins live inside a module: `modules/module-web/plugins/99_myplugin.sh`. Each plugin is a self-contained check that gets sourced by the parent module.

### How do I change the theme?

```bash
./pilgrims.sh --theme=matrix    # green on black
./pilgrims.sh --theme=blood     # red
./pilgrims.sh --theme=ocean     # blue
./pilgrims.sh --theme=mono      # no color
```

Set permanently: `export PILGRIMS_THEME=matrix` in `~/.bashrc`.

---

## Troubleshooting

### I get "command not found" errors

Some optional tools aren't installed. Run `./diagnose.sh` to see which tools are missing.

For missing tools:
```bash
# Debian/Ubuntu
sudo apt install nmap whois dnsutils jq ffuf

# macOS
brew install nmap jq

# Arch
sudo pacman -S nmap whois dnsutils jq ffuf
```

### Scan is stuck/hanging

- Network timeout? Try `--quick` or `--stealth` profile.
- Target blocking you? Try different IP or VPN.
- DNS issues? Check `/etc/resolv.conf`.
- Press `Ctrl+C` to abort cleanly. PILGRIMS saves state on interrupt.

### shellcheck warnings

PILGRIMS includes a `.shellcheckrc` that suppresses known-safe patterns. If you add new code, run `shellcheck path/to/file.sh` and address new warnings.

### Tests fail after my changes

```bash
./test-simple.sh       # quick sanity check
./test-all-features.sh # comprehensive
./full-test.sh         # full suite (118 checks)
```

Run `shellcheck -f gcc modules/<your_module>/pilgrims-<module>.sh` before committing.

### How do I report a bug?

See [SECURITY.md](SECURITY.md) for the disclosure policy.

For non-security bugs: open a GitHub Issue.

---

## Legal & Ethics

### Is this legal?

The tool itself is legal. **Using it against systems you don't own or have explicit permission to test is illegal** in most jurisdictions (CFAA, UU ITE, Computer Misuse Act, etc.).

### What if I accidentally scan the wrong target?

Stop immediately (`Ctrl+C`). Disclose the incident to the target's owner if any data was collected. Don't try to cover it up — good faith errors are usually treated more leniently than deliberate violations.

### Can I use this for bug bounty?

Yes — for programs where the scope explicitly includes the target. Always:
1. Read the program's policy
2. Stay in scope
3. Don't access user data
4. Report findings through the program's channel
5. Don't publicly disclose until the program allows

### What about penetration testing engagements?

Yes. PILGRIMS is suitable for authorized pentests. Always:
1. Have a signed SOW (scope of work) and RoE (rules of engagement)
2. Use isolated networks when possible
3. Clean up artifacts after engagement
4. Report through agreed channels

---

## Contributing

### How do I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md).

Quick start:
1. Fork the repo
2. Create feature branch (`git checkout -b feat/awesome-thing`)
3. Make changes, run tests + shellcheck
4. Update docs (MODULES.md, FEATURES.md, etc.)
5. Submit PR

### Can I add a new module to the core framework?

Yes, but:
- Must follow the source guard pattern
- Must pass shellcheck + bash -n
- Must include at least one functional test
- Update MODULES.md with description
- PR will be reviewed for security/ethics implications

---

## More questions?

- 📖 Read the [README](README.md) and [USER_GUIDE](USER_GUIDE.md)
- 💬 Open a [GitHub Discussion](https://github.com/afiqandico13/pilgrims-v17/discussions)
- 🐛 Report bugs via [GitHub Issues](https://github.com/afiqandico13/pilgrims-v17/issues)
- 📧 Email: afiqandico13@gmail.com (security: see [SECURITY.md](SECURITY.md))

---

*Last updated: June 23, 2026*
