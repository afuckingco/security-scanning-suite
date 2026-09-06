"""dockguard CLI entry point."""
import argparse
import os
import sys
from typing import List

from . import __version__
from .parser import parse, ParseError
from .rules import lint, Config, Finding
from .reporter import FORMATS


def load_config(path: str) -> Config:
    """Load .dockguard.yml config (minimal parser — just ignore-rules and ignore-severity)."""
    if not path or not os.path.exists(path):
        return Config()

    # Minimal YAML-like parser (avoids PyYAML dependency)
    ignored_rules = set()
    ignore_severity = set()
    enabled_rules = set()

    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                # Parse key: value
                if ":" not in line:
                    continue
                key, value = line.split(":", 1)
                key = key.strip()
                value = value.strip()
                # Strip quotes
                value = value.strip("\"'")

                if key == "ignore-rules":
                    for rule in value.split(","):
                        ignored_rules.add(rule.strip())
                elif key == "ignore-severity":
                    for sev in value.split(","):
                        ignore_severity.add(sev.strip().lower())
                elif key == "enabled-rules":
                    if value.lower() in ("all", ""):
                        enabled_rules = None
                    else:
                        enabled_rules = {r.strip() for r in value.split(",")}
    except Exception:
        pass

    return Config(
        ignored_rules=ignored_rules,
        ignore_severity=ignore_severity,
        enabled_rules=enabled_rules if enabled_rules else None,
    )


def exit_code_for(findings: List[Finding]) -> int:
    """Map findings to exit code: 0=clean, 1=warnings, 2=errors."""
    if any(f.severity == "error" for f in findings):
        return 2
    if any(f.severity == "warning" for f in findings):
        return 1
    return 0


def main(argv: List[str] = None) -> int:
    parser = argparse.ArgumentParser(
        prog="dockguard",
        description="Dockerfile security linter & analyzer",
        epilog="Examples:\n"
               "  dockguard Dockerfile\n"
               "  dockguard --format json Dockerfile > report.json\n"
               "  dockguard --ignore DG001,DL3008 Dockerfile\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("path", nargs="?", default="Dockerfile",
                        help="Path to Dockerfile (default: ./Dockerfile)")
    parser.add_argument("--format", "-f", choices=list(FORMATS.keys()), default="pretty",
                        help="Output format (default: pretty)")
    parser.add_argument("--no-color", action="store_true",
                        help="Disable ANSI color codes")
    parser.add_argument("--config", "-c", default=".dockguard.yml",
                        help="Path to config file (default: .dockguard.yml in cwd)")
    parser.add_argument("--ignore", help="Comma-separated rule IDs to ignore")
    parser.add_argument("--ignore-severity", help="Comma-separated severities to ignore")
    parser.add_argument("--version", action="version", version=f"dockguard {__version__}")
    parser.add_argument("--quiet", "-q", action="store_true",
                        help="Suppress output, only exit code")

    args = parser.parse_args(argv)

    # Read Dockerfile
    if not os.path.exists(args.path):
        print(f"Error: file not found: {args.path}", file=sys.stderr)
        return 2

    try:
        with open(args.path, encoding="utf-8") as f:
            source = f.read()
    except UnicodeDecodeError:
        print(f"Error: file is not valid UTF-8: {args.path}", file=sys.stderr)
        return 2

    # Parse
    try:
        df = parse(source)
    except ParseError as e:
        print(f"Parse error: {e}", file=sys.stderr)
        return 2

    # Load config
    cfg = load_config(args.config)
    # CLI overrides
    if args.ignore:
        for rid in args.ignore.split(","):
            cfg.ignored_rules.add(rid.strip())
    if args.ignore_severity:
        for sev in args.ignore_severity.split(","):
            cfg.ignore_severity.add(sev.strip().lower())

    # Lint
    findings = lint(df, cfg)

    # Output
    if not args.quiet:
        if args.format == "pretty":
            print(FORMATS[args.format](findings, args.path, color=not args.no_color))
        else:
            print(FORMATS[args.format](findings, args.path))

    return exit_code_for(findings)


if __name__ == "__main__":
    sys.exit(main())