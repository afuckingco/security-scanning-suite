#!/usr/bin/env python3
"""Aggregate security scan outputs into a single Markdown report.
Outputs:
  - security_report.md (human‑readable)
  - security_report.json (machine‑readable, optional)
"""
import json, pathlib, sys

BASE = pathlib.Path(__file__).resolve().parents[1]  # repo root

def load_json(rel_path: str):
    p = BASE / rel_path
    if p.is_file():
        try:
            return json.loads(p.read_text())
        except Exception as e:
            print(f"[WARN] Failed to parse {rel_path}: {e}", file=sys.stderr)
    return None

reports = {
    "npm_audit": load_json("scripts/npm_audit.json"),
    "pip_audit": load_json("scripts/pip_audit.json"),
    "gitleaks": load_json("scripts/gitleaks.json"),
    "suricata": load_json("scripts/suricata/log/evts.json"),
}

lines = ["# Security Scan Report", ""]
for name, data in reports.items():
    lines.append(f"## {name}")
    if not data:
        lines.append("*No data / scan not executed*\n")
        continue
    # count findings (common keys)
    if isinstance(data, dict):
        count = len(data.get("results", []))
    elif isinstance(data, list):
        count = len(data)
    else:
        count = 0
    lines.append(f"*Findings:* **{count}**")
    # embed a truncated JSON snippet for quick glance
    snippet = json.dumps(data, indent=2)[:1000]
    lines.append("```json")
    lines.append(snippet)
    lines.append("```")
    lines.append("")

md_path = BASE / "security_report.md"
md_path.write_text("\n".join(lines), encoding="utf-8")
print(f"Report written to {md_path}")
