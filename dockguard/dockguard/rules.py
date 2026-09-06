"""dockguard rules — security & best practice checks for Dockerfiles.

Each rule is a function: (Dockerfile, Config) -> List[Finding]
Severity: ERROR (fail CI), WARNING (warn), INFO (suggestion)
"""
from dataclasses import dataclass
from typing import List, Callable, Dict, Optional
from .parser import Dockerfile, Instruction, get_instructions_by_cmd


@dataclass
class Finding:
    rule_id: str
    severity: str         # "error" | "warning" | "info"
    message: str
    line_number: int = 0
    suggestion: Optional[str] = None


@dataclass
class Config:
    enabled_rules: Optional[set] = None  # None = all
    ignored_rules: set = None
    ignore_severity: set = None           # for filtering

    def __post_init__(self):
        if self.ignored_rules is None: self.ignored_rules = set()
        if self.ignore_severity is None: self.ignore_severity = set()
        if self.enabled_rules is None: self.enabled_rules = set(RULES.keys())


# ============================================================================
# RULES
# ============================================================================

def rule_DG001_root_user(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG001: Container runs as root if no USER instruction or USER is root."""
    findings = []
    user_instrs = get_instructions_by_cmd(df, "USER")
    if not user_instrs:
        findings.append(Finding(
            rule_id="DG001",
            severity="warning",
            message="No USER instruction — container will run as root by default",
            line_number=df.instructions[-1].line_number if df.instructions else 0,
            suggestion="Add 'USER <non-root-user>' near the end of the Dockerfile",
        ))
    else:
        last_user = user_instrs[-1]
        user_value = last_user.value.strip().lower()
        if user_value in ("root", "0"):
            findings.append(Finding(
                rule_id="DG001",
                severity="warning",
                message=f"USER is set to '{user_value}' — running as root",
                line_number=last_user.line_number,
                suggestion="Switch to a non-root user (e.g., 'USER appuser' or 'USER 1001')",
            ))
    return findings


def rule_DG002_add_vs_copy(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG002: ADD used for local files (should use COPY)."""
    findings = []
    for instr in get_instructions_by_cmd(df, "ADD"):
        # ADD is fine for URLs / tar extraction, only flag for simple local copies
        first = instr.value.split()[0] if instr.value else ""
        if first.startswith("http://") or first.startswith("https://"):
            continue
        if first.endswith(".tar") or first.endswith(".tar.gz") or first.endswith(".tgz"):
            continue
        findings.append(Finding(
            rule_id="DG002",
            severity="info",
            message=f"ADD used for local files — prefer COPY for clarity",
            line_number=instr.line_number,
            suggestion="Replace 'ADD <src> <dest>' with 'COPY <src> <dest>'",
        ))
    return findings


def rule_DG003_secrets_in_env(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG003: Hardcoded secrets in ENV / ARG instructions."""
    findings = []
    secret_patterns = [
        "password", "passwd", "secret", "token", "api_key", "apikey",
        "auth_token", "private_key", "access_key",
    ]
    for instr in get_instructions_by_cmd(df, "ENV") + get_instructions_by_cmd(df, "ARG"):
        lower = instr.value.lower()
        for pat in secret_patterns:
            if pat in lower:
                # Skip if value is just an env var reference like ${DB_PASSWORD}
                if "${" in instr.value and "=" in instr.value:
                    parts = instr.value.split("=", 1)
                    if parts[1].strip().startswith("${") and parts[1].strip().endswith("}"):
                        continue
                # Skip if value references another var with no literal
                if "=" not in instr.value:
                    continue
                findings.append(Finding(
                    rule_id="DG003",
                    severity="error",
                    message=f"Possible hardcoded secret: '{pat}' in {instr.cmd}",
                    line_number=instr.line_number,
                    suggestion="Use Docker secrets, env files, or runtime injection — never bake secrets into images",
                ))
                break
    return findings


def rule_DG004_latest_tag(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG004: Using ':latest' tag (non-deterministic builds)."""
    findings = []
    for instr in get_instructions_by_cmd(df, "FROM"):
        image = instr.value.split()[0].strip()
        # Skip scratch
        if image.lower() == "scratch":
            continue
        # Check if has explicit tag
        if ":" not in image or image.endswith(":latest"):
            findings.append(Finding(
                rule_id="DG004",
                severity="warning",
                message=f"Image uses ':latest' tag: {image}",
                line_number=instr.line_number,
                suggestion=f"Pin to specific version: '{image.split(':')[0]}:<version>' or use digest",
            ))
    return findings


def rule_DG005_apt_no_clean(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG005: apt-get install without cleaning /var/lib/apt/lists."""
    findings = []
    for instr in get_instructions_by_cmd(df, "RUN"):
        if "apt-get install" not in instr.value:
            continue
        # Check if same RUN cleans up
        if "rm -rf /var/lib/apt/lists" in instr.value or "&& apt-get clean" in instr.value:
            continue
        findings.append(Finding(
            rule_id="DG005",
            severity="warning",
            message="apt-get install without cleaning apt cache (bloats image)",
            line_number=instr.line_number,
            suggestion="Add '&& rm -rf /var/lib/apt/lists/*' at end of RUN, or chain '&& apt-get clean'",
        ))
    return findings


def rule_DG006_curl_pipe_shell(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG006: Piping curl/wget output to shell (insecure)."""
    findings = []
    dangerous_patterns = [
        "curl", "wget",
    ]
    shells = ["sh", "bash", "zsh", "dash"]
    for instr in get_instructions_by_cmd(df, "RUN"):
        lower = instr.value.lower()
        for cmd in dangerous_patterns:
            if cmd not in lower:
                continue
            if "|" not in instr.value:
                continue
            parts = instr.value.split("|")
            for part in parts[1:]:
                part_strip = part.strip().split()[0] if part.strip() else ""
                if part_strip in shells:
                    findings.append(Finding(
                        rule_id="DG006",
                        severity="error",
                        message=f"Piping {cmd} output to {part_strip} — insecure (unverified code execution)",
                        line_number=instr.line_number,
                        suggestion="Download the script first, verify checksum, then execute",
                    ))
                    break
    return findings


def rule_DG007_no_healthcheck(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG007: Missing HEALTHCHECK instruction."""
    healthchecks = get_instructions_by_cmd(df, "HEALTHCHECK")
    if not healthchecks:
        return [Finding(
            rule_id="DG007",
            severity="info",
            message="No HEALTHCHECK instruction defined",
            line_number=df.instructions[-1].line_number if df.instructions else 0,
            suggestion="Add 'HEALTHCHECK CMD <cmd>' so orchestrators can detect unhealthy containers",
        )]
    return []


def rule_DG008_unpinned_packages(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG008: pip / npm install without version pinning."""
    findings = []
    for instr in get_instructions_by_cmd(df, "RUN"):
        # pip install <pkg> without == or >=
        if "pip install" in instr.value or "pip3 install" in instr.value:
            # Find package names that aren't pinned
            import re
            # Strip the pip command
            v = instr.value
            # Find package names
            for match in re.finditer(r"(?:^|\s)([a-zA-Z0-9_-]+)(?:\s|$|=|>|<|;)", v):
                pkg = match.group(1)
                if pkg in ("install", "pip", "pip3", "requirements", "upgrade", "no-cache-dir"):
                    continue
                # Check if followed by version specifier in the same line
                idx = match.end()
                rest = v[idx:idx + 30]
                if not re.match(r"\s*[=<>!]", rest):
                    findings.append(Finding(
                        rule_id="DG008",
                        severity="info",
                        message=f"pip package '{pkg}' not pinned to specific version",
                        line_number=instr.line_number,
                        suggestion=f"Pin version: pip install {pkg}==1.2.3",
                    ))
                    break  # one finding per RUN

        # npm install <pkg> without @
        if "npm install" in instr.value or "npm i " in instr.value:
            import re
            v = instr.value
            for match in re.finditer(r"(?:^|\s)([a-zA-Z0-9_@/-]+)@([\d\^~])?", v):
                pkg = match.group(1)
                if pkg in ("install", "i", "npm", "save", "save-dev", "-g", "no-save"):
                    continue
                version = match.group(2)
                if not version and not pkg.startswith("@"):
                    findings.append(Finding(
                        rule_id="DG008",
                        severity="info",
                        message=f"npm package '{pkg}' not pinned to specific version",
                        line_number=instr.line_number,
                        suggestion=f"Pin version: npm install {pkg}@1.2.3",
                    ))
                    break
    return findings


def rule_DG009_excessive_layers(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG009: Too many RUN instructions (bloats image, hard to cache)."""
    findings = []
    runs = get_instructions_by_cmd(df, "RUN")
    if len(runs) > 10:
        findings.append(Finding(
            rule_id="DG009",
            severity="info",
            message=f"{len(runs)} RUN instructions detected — consider combining with '&&'",
            line_number=df.instructions[-1].line_number if df.instructions else 0,
            suggestion="Combine related RUNs: 'RUN cmd1 && cmd2 && cmd3' (or use multi-stage builds)",
        ))
    return findings


def rule_DG010_no_multi_stage(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG010: No multi-stage build detected (suggests opportunity for size reduction)."""
    stages = df.stages
    if len(stages) < 2:
        # Only flag if there's a build-looking RUN (e.g., pip install, npm ci, gcc)
        build_indicators = ["pip install", "npm install", "npm ci", "yarn install",
                            "go build", "cargo build", "gcc", "make "]
        has_build = any(
            any(ind in instr.value for ind in build_indicators)
            for instr in get_instructions_by_cmd(df, "RUN")
        )
        if has_build:
            return [Finding(
                rule_id="DG010",
                severity="info",
                message="Build tools detected but no multi-stage build — final image may be bloated",
                line_number=df.instructions[-1].line_number if df.instructions else 0,
                suggestion="Use multi-stage build: 'FROM <builder> AS build' then 'COPY --from=build' to slim stage",
            )]
    return []


# Registry
RULES: Dict[str, Callable] = {
    "DG001": rule_DG001_root_user,
    "DG002": rule_DG002_add_vs_copy,
    "DG003": rule_DG003_secrets_in_env,
    "DG004": rule_DG004_latest_tag,
    "DG005": rule_DG005_apt_no_clean,
    "DG006": rule_DG006_curl_pipe_shell,
    "DG007": rule_DG007_no_healthcheck,
    "DG008": rule_DG008_unpinned_packages,
    "DG009": rule_DG009_excessive_layers,
    "DG010": rule_DG010_no_multi_stage,
}


def lint(df: Dockerfile, cfg: Optional[Config] = None) -> List[Finding]:
    """Run all enabled rules on a Dockerfile."""
    if cfg is None:
        cfg = Config()
    findings = []
    for rule_id, rule_fn in RULES.items():
        if rule_id not in cfg.enabled_rules:
            continue
        if rule_id in cfg.ignored_rules:
            continue
        for finding in rule_fn(df, cfg):
            if finding.severity in cfg.ignore_severity:
                continue
            findings.append(finding)
    return findings