# Runbook — Security Lab Workflow

Contoh alur end-to-end memakai dua tool inti (`sift` + `dockguard`). Semua output
di bawah adalah hasil eksekusi nyata (2026-09-06; sift v1.0.0, dockguard v1.0.0).

## 0. Siapkan

```bash
# bangun sift (Go stdlib, tanpa dependency)
cd sift
go build -ldflags="-s -w" -o sift .
./sift --version        # → Sift v1.0.0

# dockguard cukup dengan Python stdlib
cd ../dockguard
python3 -m dockguard --version
```

## 1. Contoh kode yang bermasalah

```python
# app.py
def handler():
    api_key = "sk-proj-abcdef1234567890ABCDEF1234567890"   # secret hardcoded!
    print("ok")
```

```dockerfile
# Dockerfile
FROM node:20-alpine
CMD ["node", "server.js"]       # tidak ada USER / HEALTHCHECK
```

## 2. Scan secret dengan sift

```bash
./sift /tmp/demo
```

Output nyata:

```
🔍 Sift v1.0.0: Smart & Extensible Security Scanner

✅ Loaded 5 default rules + 2 custom rules.

⚠️  Found 1 issues in 137.938µs:

[HIGH] Generic Secret/Token (S002)
  /tmp/demo/app.py:3
  | api_key = "sk-proj-abcdef1234567890ABCDEF1234567890"
```

## 3. Lint Dockerfile dengan dockguard

```bash
python3 -m dockguard --format json --no-color /tmp/demo/Dockerfile
```

Output nyata (ringkas):

```json
{
  "tool": "dockguard",
  "version": "1.0.0",
  "findings": [
    { "rule_id": "DG001", "severity": "warning",
      "message": "No USER instruction — container will run as root by default",
      "line": 2 },
    { "rule_id": "DG007", "severity": "info",
      "message": "No HEALTHCHECK instruction defined", "line": 2 }
  ],
  "summary": { "error": 0, "warning": 1, "info": 1 }
}
```

Mode CI-friendly (hanya exit code):

```bash
python3 -m dockguard --quiet /tmp/demo/Dockerfile
echo $?    # → 1 (ada temuan; 0 = bersih)
```

## 4. Perbaiki & verifikasi

```dockerfile
# Dockerfile (bersih)
FROM node:20-alpine
USER node
HEALTHCHECK CMD wget -q --spider http://localhost:3000 || exit 1
CMD ["node", "server.js"]
```

```bash
python3 -m dockguard --quiet Dockerfile
echo $?    # → 0 = bersih, siap lanjut ke pipeline
```

## 5. Integrasi minimal di CI

```yaml
      - name: Scan secrets
        run: ./sift .
      - name: Lint Dockerfiles
        run: |
          find . -name 'Dockerfile*' -exec python3 -m dockguard --quiet {} \;
```

## Catatan

- Exit code: dockguard 0 = bersih, 1 = ada finding, 2 = file tidak ditemukan.
- Tool lain di repo ini: `log-anonymizer`, `sec-scan-cli`,
  `secure-ci-pipeline` — lihat README masing-masing.
- Gunakan hanya untuk lingkungan *authorized* (lihat README root — Catatan Etika).