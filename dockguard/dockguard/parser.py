"""Dockerfile parser — extracts structured instructions from raw Dockerfile text."""
from dataclasses import dataclass
from typing import List, Optional


@dataclass
class Instruction:
    cmd: str              # e.g., "FROM", "RUN", "COPY"
    value: str            # full value (rest of line after CMD)
    line_number: int      # 1-indexed
    raw: str              # raw line as it appears


@dataclass
class Dockerfile:
    instructions: List[Instruction]
    stages: List[str]     # base-image references per FROM line
    source: str           # raw source for debugging


class ParseError(Exception):
    pass


def parse(source: str) -> Dockerfile:
    """Parse a Dockerfile string into structured instructions.

    Supports:
    - Multi-line continuation (\\) and heredocs (<<EOF)
    - Comments (#) at line start
    - Multiple FROM stages (multi-stage builds)
    - Parser directives (#syntax=...) — skipped
    - Empty lines
    """
    instructions = []
    stages = []

    # Normalize line endings
    lines = source.replace("\r\n", "\n").replace("\r", "\n").split("\n")

    i = 0
    while i < len(lines):
        raw_line = lines[i]
        stripped = raw_line.strip()

        # Skip empty lines
        if not stripped:
            i += 1
            continue

        # Skip comments (full-line) and parser directives
        if stripped.startswith("#"):
            i += 1
            continue

        # Continuation handling: line ends with \
        joined = raw_line
        while joined.rstrip().endswith("\\") and i + 1 < len(lines):
            joined = joined.rstrip()[:-1] + " " + lines[i + 1].strip()
            i += 1

        # Split CMD from rest
        # Use first whitespace as separator
        parts = joined.split(None, 1)
        cmd = parts[0].upper() if parts else ""
        value = parts[1] if len(parts) > 1 else ""

        # Heredoc handling for RUN/COPY/ADD with <<EOF
        # If value contains <<TAG but not the closing TAG, consume lines
        if "<<" in value and cmd in ("RUN", "COPY", "ADD"):
            heredoc_tag = extract_heredoc_tag(value)
            if heredoc_tag and heredoc_tag not in value.split(heredoc_tag, 1)[1]:
                # Need to consume until we find the closing tag
                i += 1
                while i < len(lines):
                    if lines[i].strip() == heredoc_tag:
                        break
                    value += "\n" + lines[i]
                    i += 1

        instr = Instruction(cmd=cmd, value=value.strip(), line_number=i + 1, raw=raw_line)
        instructions.append(instr)

        if cmd == "FROM":
            # Extract base image (strip "AS alias" if present)
            base = value.split()[0] if value else ""
            stages.append(base)

        i += 1

    return Dockerfile(instructions=instructions, stages=stages, source=source)


def extract_heredoc_tag(value: str) -> Optional[str]:
    """Extract heredoc tag from '<<TAG' or '<<-TAG' patterns."""
    for marker in ("<<-", "<<"):
        idx = value.find(marker)
        if idx >= 0:
            rest = value[idx + len(marker):].lstrip()
            tag = rest.split()[0] if rest else ""
            return tag if tag else None
    return None


def get_instructions_by_cmd(dockerfile: Dockerfile, cmd: str) -> List[Instruction]:
    """Helper: filter instructions by command (case-insensitive)."""
    cmd_upper = cmd.upper()
    return [i for i in dockerfile.instructions if i.cmd == cmd_upper]