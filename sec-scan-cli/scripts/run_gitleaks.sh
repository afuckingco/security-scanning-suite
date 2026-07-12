#!/usr/bin/env bash
set -euo pipefail

GITLEAKS_VERSION="8.21.2"

declare -A GITLEAKS_SHA256=(
  ["linux_x64"]="5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba"
  ["linux_arm64"]="654c935542c89f565aabe7bf7c6c500830f116c114f0aeb509d2460c1ac2e6da"
  ["darwin_x64"]="5b42c6e4b1fd693eaeb2b5b7faa5f17a1434299d4deb2de63d4b2efd7c753128"
  ["darwin_arm64"]="cad3de5dc9a4d5447d967a70a4d49499c557f04db028274cc324f9ff983f6502"
)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/../.cache/gitleaks"
GL="${BIN_DIR}/gitleaks"

mkdir -p "${BIN_DIR}"

if [[ ! -x "${GL}" ]]; then
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "${arch}" in
    x86_64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported arch: ${arch}" >&2; exit 1 ;;
  esac

  key="${os}_${arch}"
  expected="${GITLEAKS_SHA256[${key}]:-}"
  if [[ -z "${expected}" ]]; then
    echo "No pinned checksum for platform ${key}; add one to GITLEAKS_SHA256." >&2
    exit 1
  fi

  archive="gitleaks_${GITLEAKS_VERSION}_${os}_${arch}.tar.gz"
  url="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${archive}"

  tmp=$(mktemp -d)
  trap 'rm -rf "${tmp}"' EXIT

  curl -fsSL "${url}" -o "${tmp}/${archive}"
  echo "${expected}  ${tmp}/${archive}" | sha256sum -c -
  tar -xzf "${tmp}/${archive}" -C "${tmp}"
  install -m 0755 "${tmp}/gitleaks" "${GL}"
fi

"${GL}" detect -c "${SCRIPT_DIR}/../.gitleaks.toml" -r . -f json > "${SCRIPT_DIR}/../gitleaks.json"
