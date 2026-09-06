"""Smoke tests — secure-ops-suite (structural; bebas dependency berat torch/dll)."""
import tomllib
from pathlib import Path


def test_pyproject_metadata():
    data = tomllib.loads(Path(__file__).resolve().parents[1].joinpath("pyproject.toml").read_text())
    assert data["project"]["name"] == "secure-ops-suite"
    assert data["project"]["version"] == "0.1.0"


def test_src_layout_exists():
    root = Path(__file__).resolve().parents[1]
    assert (root / "src" / "analyzer" / "main.py").exists()
    assert (root / "docker-compose.yml").exists()