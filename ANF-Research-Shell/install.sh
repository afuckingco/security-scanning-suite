#!/usr/bin/env bash
# ==============================================================================
# ANF RESEARCH SHELL — Installer
# Memasang launcher ke /usr/local/bin/anf dan config dist ke ~/.config/anf/.
# Aman dijalankan berulang (idempotent). Tidak menimpa anfrc yang sudah ada.
#
# Usage: ./install.sh [--prefix /usr/local] [--skip-config]
# ==============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${1:-/usr/local}"
if [[ "$PREFIX" != /usr/local && $# -ge 1 ]]; then
  # --prefix /path bentuk
  for a in "$@"; do :; done
fi

# parse arg sederhana
SKIP_CONFIG=0
BIN_DIR="$PREFIX/bin"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix) BIN_DIR="$2/bin"; shift 2;;
    --skip-config) SKIP_CONFIG=1; shift;;
    *) echo "arg tak dikenal: $1"; exit 1;;
  esac
done

echo "==> Install launcher ke $BIN_DIR/anf"
install -Dm755 "$ROOT/bin/anf" "$BIN_DIR/anf"

echo "==> Install script inti ke ${BIN_DIR%/bin}/lib/anf/anf_research_shell.zsh"
install -Dm644 "$ROOT/code/anf_research_shell.zsh" "${BIN_DIR%/bin}/lib/anf/anf_research_shell.zsh"

if [[ "$SKIP_CONFIG" == 0 ]]; then
  CFG_DIR="$HOME/.config/anf"
  echo "==> Siapkan config dir $CFG_DIR"
  mkdir -p "$CFG_DIR"
  if [[ ! -f "$CFG_DIR/anfrc" ]]; then
    echo "==> Salin anfrc.dist -> $CFG_DIR/anfrc (editable)"
    cp "$ROOT/code/anfrc.dist" "$CFG_DIR/anfrc"
  else
    echo "==> anfrc sudah ada — biarkan (tidak menimpa)"
  fi
fi

echo
echo "✅ ANF Research Shell terpasang."
echo "   Jalankan:  anf              # shell interaktif"
echo "   Jalankan:  anf help         # daftar command"
echo "   Config:    $CFG_DIR/anfrc   (opsional)"
