"""Smoke tests — sec-scan-cli (importable + CLI runs)."""
import subprocess
import sys


def test_module_importable():
    import sec_scan  # noqa: F401
    assert hasattr(sec_scan, "__file__")


def test_cli_help_exits_zero():
    r = subprocess.run([sys.executable, "-m", "sec_scan.cli", "--help"],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stderr