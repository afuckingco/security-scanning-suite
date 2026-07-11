import os
import subprocess
import json
import sys
from pathlib import Path
import click
from rich.console import Console
from rich.table import Table

console = Console()

SCRIPT_DIR = Path(__file__).resolve().parent.parent.parent / "scripts"

def run_script(script_name: str) -> dict:
    """Execute a shell script located in the repo's `scripts/` directory.
    Returns a dict with keys: success (bool), output (str), error (str)."""
    script_path = SCRIPT_DIR / script_name
    if not script_path.is_file():
        return {"success": False, "output": "", "error": f"Script {script_name} not found"}
    # Ensure execution permission (mostly for *nix, harmless on Windows)
    os.chmod(script_path, 0o755)
    try:
        result = subprocess.run([str(script_path)], capture_output=True, text=True, check=False)
        return {
            "success": result.returncode == 0,
            "output": result.stdout.strip(),
            "error": result.stderr.strip(),
        }
    except Exception as e:
        return {"success": False, "output": "", "error": str(e)}

def aggregate_reports() -> Path:
    """Run the aggregation script and return the path to the generated markdown report."""
    agg_path = SCRIPT_DIR.parent / "scripts" / "aggregate_report.py"
    result = subprocess.run([sys.executable, str(agg_path)], capture_output=True, text=True)
    report_path = SCRIPT_DIR.parent / "security_report.md"
    return report_path

@click.group()
def main():
    """sec-scan – single‑command wrapper for security scans.
    Use subcommands to run individual tools or the full pipeline.
    """
    pass

@main.command()
@click.option("--ci", is_flag=True, help="Run in CI mode – minimal stdout, only exit code.")
def run(ci: bool):
    """Execute the full security scan pipeline (npm, pip, gitleaks, Suricata)."""
    steps = [
        ("npm audit", "run_npm_audit.sh"),
        ("pip-audit", "run_pip_audit.sh"),
        ("gitleaks", "run_gitleaks.sh"),
        ("Suricata", "run_suricata.sh"),
    ]
    results = []
    for name, script in steps:
        res = run_script(script)
        results.append((name, res))
        if ci and not res["success"]:
            sys.exit(1)
    # Aggregate report
    report_path = aggregate_reports()
    if ci:
        # In CI we only care about exit status; output is captured by the runner.
        sys.exit(0)
    # Human‑readable output
    table = Table(title="sec‑scan results")
    table.add_column("Tool")
    table.add_column("Status", style="green")
    table.add_column("Output (truncated)")
    for name, res in results:
        status = "✅" if res["success"] else "❌"
        out = (res["output"] or res["error"]).replace("\n", " ")[:200]
        table.add_row(name, status, out)
    console.print(table)
    console.print(f"[bold]Aggregated report saved to:[/bold] {report_path}")

@main.command()
@click.argument("tool", type=click.Choice(["npm", "pip", "gitleaks", "suricata"]))
def single(tool: str):
    """Run a single scan tool.
    Example: `sec-scan single npm`
    """
    mapping = {
        "npm": "run_npm_audit.sh",
        "pip": "run_pip_audit.sh",
        "gitleaks": "run_gitleaks.sh",
        "suricata": "run_suricata.sh",
    }
    script = mapping[tool]
    res = run_script(script)
    if res["success"]:
        console.print(f"[green]✅ {tool} completed successfully[/green]")
        console.print(res["output"][:500])
    else:
        console.print(f"[red]❌ {tool} failed[/red]")
        console.print(res["error"][:500])
        sys.exit(1)

@main.command()
def version():
    """Show tool version."""
    console.print("sec-scan version 0.1.0")

if __name__ == "__main__":
    main()
