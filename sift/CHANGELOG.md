# Changelog — sift

## v1.0.0 — 2026-09-06
Rilis publik pertama (go1.21+, murni stdlib).

### Fitur
- Deteksi secret hardcoded: 5 pola default + 2 custom rule (termasuk `sk-proj-*`)
- Analisis entropi Shannon untuk secret tak dikenal/obfuscated
- Mode git-aware (`--git-diff`) — hanya file berubah
- Worker-pool file scanning (konkuren)
- Keluaran pretty/JSON, tanpa telemetri (zero network)

### Teknis
- Static Linux/macOS/Windows binary (<2.5MB), zero dependency runtime.
