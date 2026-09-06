#!/bin/bash
# ============================================================================
# PILGRIMS - STRICT MODE GUARD
# Source this FIRST in any executable entry script.
# Enables: errexit, nounset, pipefail, and a fail-fast trap.
# Modules that are sourced (not executed) do NOT need this.
# ============================================================================

# Abort on error, undefined var, and failed pipeline.
set -euo pipefail

# Exit codes
readonly E_GENERAL=1
readonly E_USAGE=2
readonly E_DEP=3

# Print message to stderr and exit with code.
die() {
    local code=${2:-$E_GENERAL}
    printf '[PILGRIMS][FATAL] %s\n' "$1" >&2
    exit "$code"
}

# Trap: report failing command + line on unexpected exit.
__pilgrims_err_trap() {
    local code=$?
    local line=${BASH_LINENO[0]}
    local cmd=${BASH_COMMAND:-<unknown>}
    printf '[PILGRIMS][ERROR] command failed (exit %d) at line %d: %s\n' \
        "$code" "$line" "$cmd" >&2
}
trap '__pilgrims_err_trap' ERR

# Catch CTRL-C / termination cleanly.
__pilgrims_int_trap() {
    printf '\n[PILGRIMS][WARN] interrupted by user\n' >&2
    exit 130
}
trap '__pilgrims_int_trap' INT TERM
