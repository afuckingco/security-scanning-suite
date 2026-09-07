#!/usr/bin/env python3
"""Build CSV ringkas deliverable DCA (JSI3) untuk sitasi.

Input : research/outputs/dca_sweep_mc.json (hasil dca_sweep_demo.py).
Output: research/outputs/dca_sweep_mc.csv — format 8 kolom, CRLF line endings
        (identik dengan CSV historis di manifest §7.2).
Catatan determinisme: kolom `naive_1d_cost_s` / `two_state_cost_s` adalah
wall-clock timing → BERUBAH antar run; kolom ilmiah (naive_1d_w1, two_state_w1,
q10/50/90_gap) deterministik dan menjadi gate verifikasi (make verify).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT_DIR = ROOT / "research" / "outputs"
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else OUT_DIR / "dca_sweep_mc.json"

HEADER = ["alpha", "naive_1d_w1", "two_state_w1", "q10_gap", "q50_gap",
          "q90_gap", "naive_1d_cost_s", "two_state_cost_s"]


def main() -> int:
    d = json.loads(SRC.read_text())
    lines = [",".join(HEADER)]
    for r in d["results"]:
        row = [str(r["alpha"]), repr(r["naive_1d_w1"]), repr(r["two_state_w1"])]
        row += [str(x) for x in r["two_state_qgap"]]
        row += [str(r["naive_1d_cost_s"]), str(r["two_state_cost_s"])]
        lines.append(",".join(row))
    out = OUT_DIR / "dca_sweep_mc.csv"
    out.write_text("\r\n".join(lines) + "\r\n")
    print(f"artefak: {out.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())