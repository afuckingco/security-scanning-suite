"""Output formatters for dockguard findings."""
import json
import sys
from typing import List
from .rules import Finding, Config


SEVERITY_COLORS = {
    "error": "\033[1;31m",     # bold red
    "warning": "\033[1;33m",   # bold yellow
    "info": "\033[1;36m",      # bold cyan
}
SEVERITY_ICONS = {
    "error": "✗",
    "warning": "⚠",
    "info": "ℹ",
}
RESET = "\033[0m"


def colorize(text: str, color: str, enabled: bool = True) -> str:
    if not enabled:
        return text
    code = SEVERITY_COLORS.get(color, "")
    return f"{code}{text}{RESET}" if code else text


def report_pretty(findings: List[Finding], file_path: str = "Dockerfile", color: bool = True) -> str:
    """Human-readable terminal output."""
    lines = []
    lines.append("")
    lines.append(f"  dockguard scan: {file_path}")
    lines.append("  " + "─" * 60)

    if not findings:
        lines.append(colorize("  ✓ No issues found.", "info", color))
        lines.append("")
        return "\n".join(lines)

    # Group by severity
    by_severity = {"error": [], "warning": [], "info": []}
    for f in findings:
        by_severity.setdefault(f.severity, []).append(f)

    for severity in ("error", "warning", "info"):
        items = by_severity.get(severity, [])
        if not items:
            continue
        label = colorize(f"{SEVERITY_ICONS[severity]} {severity.upper()} ({len(items)})", severity, color)
        lines.append(f"\n  {label}")
        for f in items:
            loc = f"line {f.line_number}" if f.line_number else "general"
            lines.append(f"    [{f.rule_id}] {f.message}")
            lines.append(f"      @ {loc}")
            if f.suggestion:
                lines.append(f"      → {f.suggestion}")

    # Summary
    n_err = len(by_severity.get("error", []))
    n_warn = len(by_severity.get("warning", []))
    n_info = len(by_severity.get("info", []))
    lines.append("")
    lines.append("  " + "─" * 60)
    summary_parts = []
    if n_err: summary_parts.append(colorize(f"{n_err} error(s)", "error", color))
    if n_warn: summary_parts.append(colorize(f"{n_warn} warning(s)", "warning", color))
    if n_info: summary_parts.append(colorize(f"{n_info} info", "info", color))
    lines.append(f"  Total: {', '.join(summary_parts)}")
    lines.append("")
    return "\n".join(lines)


def report_json(findings: List[Finding], file_path: str = "Dockerfile") -> str:
    """Machine-readable JSON output."""
    return json.dumps({
        "tool": "dockguard",
        "version": "1.0.0",
        "file": file_path,
        "findings": [
            {
                "rule_id": f.rule_id,
                "severity": f.severity,
                "message": f.message,
                "line": f.line_number,
                "suggestion": f.suggestion,
            }
            for f in findings
        ],
        "summary": {
            "error": sum(1 for f in findings if f.severity == "error"),
            "warning": sum(1 for f in findings if f.severity == "warning"),
            "info": sum(1 for f in findings if f.severity == "info"),
        },
    }, indent=2)


def report_github(findings: List[Finding], file_path: str = "Dockerfile") -> str:
    """GitHub Actions annotation format."""
    lines = []
    for f in findings:
        # ::error file=Dockerfile,line=10::DG001: message
        sev = f.severity if f.severity in ("error", "warning") else "notice"
        loc = f"file={file_path},line={f.line_number}" if f.line_number else f"file={file_path}"
        lines.append(f"::{sev} {loc}::{f.rule_id}: {f.message}")
    return "\n".join(lines)


FORMATS = {
    "pretty": report_pretty,
    "json": report_json,
    "github": report_github,
}