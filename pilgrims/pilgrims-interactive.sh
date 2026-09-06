#!/bin/bash
# Strict mode guard (errexit + nounset + pipefail)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/strict.sh"
# PILGRIMS Interactive Mode Wrapper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load core
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/interactive_menu.sh"

# Start interactive mode
interactive_mode
