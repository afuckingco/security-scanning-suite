# pilgrims.sh Architecture

`pilgrims.sh` is the main entry point — 786 lines, structured as a sequence
of phases. This document explains its internal layout for maintainers.

## File Structure

```
pilgrims.sh (786 lines)
├── Header (1-10)             # shebang, version, set -u, comment block
├── Core loading (11-25)      # source all core/*.sh modules
├── Interactive check (28-34) # no-arg → launch interactive_menu.sh
├── Argument parser (37-220)  # main case statement for all flags
├── Utility handlers (108-168) # --help, --modules, --history
├── Advanced config (172-220) # --stealth, --templates, --theme
├── Validation (178-220)      # arg sanity checks
├── Module execution (222-244) # dispatch to modules/module-X/pilgrims-X.sh
├── Export (245-256)           # QR, encryption based on flags
└── Phase commands (257-786)   # --resume, --compare, --attack-paths,
                               # Phase 3 (hardware/AI/supply chain),
                               # Phase 4 (cloud-native/protocol/devsecops),
                               # Phase 5 (compliance/crypto/threat-intel),
                               # Phase 6 (forensics/malware/blockchain)
```

## Execution Flow

```
./pilgrims.sh [args]
       │
       ▼
   source core/*.sh (11 modules)
       │
       ▼
   init_db; init_logging
       │
       ▼
   if $# == 0 → interactive_mode (exit)
       │
       ▼
   Parse args → set globals:
     SCAN_TYPE, TARGET, PROFILE, STEALTH_PROFILE,
     SCAN_TEMPLATE, EXPORT_*, ENCRYPT_PASS, THEME,
     SHOW_HISTORY, LIST_MODULES, SHOW_HELP, MODULE_ARGS
       │
       ▼
   Handle utility flags (--help, --modules, --history)
   (each has exit 0)
       │
       ▼
   Apply advanced config (stealth, template, theme)
       │
       ▼
   Validate (target required for module scan)
       │
       ▼
   Execute module:
     MODULE_SCRIPT=modules/module-$SCAN_TYPE/pilgrims-$SCAN_TYPE.sh
     "$MODULE_SCRIPT" "$TARGET" $MODULE_ARGS
       │
       ▼
   Post-processing:
     generate_qr (if flag)
     encrypt_scan (if flag)
     save_scan_to_db
     log_scan_end
     print_mission_complete
       │
       ▼
   exit $EXIT_CODE
```

## Phase Commands Pattern

The "phase commands" sections (lines 257+) follow a uniform pattern:

```bash
# Load new core modules
source "$SCRIPT_DIR/core/<group>/<feature>.sh" 2>/dev/null

# Handle new commands in argument parser
for arg in "$@"; do
    case $arg in
        --<feature>=*)
            TARGET="${arg#*=}"
            output_dir="reports/<feature>_$(date +%Y%m%d_%H%M%S)"
            <feature>_function "$TARGET" "$output_dir"
            exit 0
            ;;
    esac
done
```

Each phase (3-6) repeats this pattern for 8-12 features.

## Architectural Improvement Ideas

To reduce coupling and improve maintainability:

### Short-term (low risk)
1. **Extract banner/version to `core/version.sh`** — version constants
   + `pilgrims_show_version()` function (already drafted in Batch 4)
2. **Add section markers** — make the case statement blocks more navigable
3. **Document each phase** — comment headers explaining phase purpose

### Medium-term (medium risk)
1. **Extract phase commands to `core/phase3_commands.sh`**, etc. — Each
   phase becomes a sourced file with its own commands.
2. **Single dispatch function** — `dispatch_command "$@"` instead of
   scattered case statements.

### Long-term (high risk, big payoff)
1. **Replace phase case statements with associative arrays** — Bash 4+
   supports `declare -A`. More maintainable but requires testing.
2. **Move to Python entry point** — bash is fine for orchestration but
   argument parsing in Python is much cleaner.

## Why Not Refactored Yet

The 786-line file is functional and tested (100% pass). Each refactor
risk breaking 117 passing test assertions. The current structure
follows a clear, documented pattern even if verbose. Maintainers
can find what they need via section markers.

For now, prefer:
- Adding comments for clarity
- Extracting helpers (version, paths)
- Adding tests for new behavior

Over restructuring existing tested code.

## Related Files

- `core/interactive_menu.sh` — interactive mode handler
- `core/ui.sh` — print_* helpers, banner functions
- `core/database.sh` — SQLite init + scan history
- `core/utils.sh` — utility helpers (timestamps, validators)
- `core/logging.sh` — runtime logging
- `core/stealth_profiles.sh`, `core/scan_templates.sh` — config presets

---

*Last updated: 2026-06-23*
