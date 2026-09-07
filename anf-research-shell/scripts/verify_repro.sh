#!/usr/bin/env bash
# verify_repro.sh — verifikasi reproduksibilitas ANF Research Shell.
#
# Cakupan:
#   A. Baseline ANF (zsh -n, test_suite 25/25, smoke hash) — jika tool tersedia.
#   B. Deliverable JSI1 (mini-SOC ML detector):
#      1.  sha256 salinan script di scaffold == sha manifest §8.1 (script utuh).
#      2.  Training dijalankan di SANDBOX tmp yang meniru layout proyek
#          (code/mini-soc-enterprise-arch/ml_detector/) sehingga Path(__file__)
#          resolve benar TANPA menulis polusi ke repo ANF.
#      3.  detector_metrics.json regenerasi dibandingkan dengan manifest §8.3:
#          gate nilai ilmiah + sha256 byte-identical (determinisme kuat).
#      4.  build_artifact.py dijalankan terhadap metrik regenerasi; CSV/JSON
#          dibandingkan hash manifest §8.2; PNG dicek keberadaan (bytes dapat
#          berbeda antar versi matplotlib — cek warn, bukan gate).
#
# Penggunaan: bash scripts/verify_repro.sh   (atau `make verify`)
# Exit: 0 jika semua gate lulus; 1 jika ada FAIL.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXP="$ROOT/research/outputs/exp_mini_soc_detector_20260907_144056"
MANIFEST="$ROOT/research/outputs/reproducibility_manifest.md"

PASS=0; FAIL=0; SKIP=0
ok()  { echo "  PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip(){ echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

# hash 16-hex pertama yang dicantumkan manifest untuk sebuah artefak
man_hash() { grep -m1 -oP "$1" "$MANIFEST" 2>/dev/null | head -1; }
sha16()    { sha256sum "$1" 2>/dev/null | cut -c1-16; }

M_SRC_SHA=$(man_hash 'sha256 `\K[0-9a-f]{16}')
M_METRICS_SHA=$(man_hash 'detector_metrics\.json` `\K[0-9a-f]{16}')
M_CSV_SHA=$(man_hash 'mini_soc_detector_metrics\.csv` \| `\K[0-9a-f]{16}')
M_JSON_SHA=$(man_hash 'mini_soc_detector_metrics\.json` \| `\K[0-9a-f]{16}')

echo "== ANF Research Shell — verifikasi reproduksibilitas =="
echo "repo : $ROOT"
echo

# ---- A. Baseline ANF -------------------------------------------------------
echo "-- A. Baseline ANF --"
if command -v zsh >/dev/null 2>&1; then
    zsh -n "$ROOT/code/anf_research_shell.zsh" && ok "zsh -n syntax" || bad "zsh -n syntax"
else
    skip "zsh tidak ada — baseline syntax dilewati"
fi
if command -v python3 >/dev/null 2>&1; then
    if out=$(python3 "$ROOT/code/test_suite.py" 2>&1) && echo "$out" | grep -qE '25/25 passed'; then
        ok "test_suite 25/25"
    else
        bad "test_suite (output: $(echo "$out" | tail -1 | tr -d '\e\[[0-9;]*m'))"
    fi
else
    skip "python3 tidak ada — test_suite dilewati"
fi
if command -v "$ROOT/bin/anf" >/dev/null 2>&1 || [ -x "$ROOT/bin/anf" ]; then
    md5=$(cd "$ROOT" && bin/anf hash abc 2>/dev/null | grep -oE '[0-9a-f]{32}' | head -1)
    [ "${md5:0:8}" = "90015098" ] && ok "smoke hash (MD5 abc)" || bad "smoke hash (got $md5)"
else
    skip "launcher bin/anf tidak bisa dijalankan"
fi

# ---- B. Deliverable JSI1 ----------------------------------------------------
echo
echo "-- B. Deliverable JSI1 (mini-SOC ML detector) --"

# B.1 sha salinan scaffold == manifest
src_sha=$(sha16 "$EXP/train_detector_real.py")
if [ -n "$M_SRC_SHA" ] && [ "$src_sha" = "$M_SRC_SHA" ]; then
    ok "source script sha == manifest ($src_sha)"
else
    bad "source script sha ($src_sha) != manifest ($M_SRC_SHA)"
fi

# B.2 interpretor runtime (numpy+xgboost+psutil+scapy)
resolve_py() {
    local c
    for c in "${PYTHON:-}" \
        "$ROOT/.venv/bin/python" \
        "$HOME/venv/bin/python" \
        python3; do
        [ -n "$c" ] || continue
        if "$c" -c "import numpy, xgboost, psutil, scapy" >/dev/null 2>&1; then
            echo "$c"; return 0
        fi
    done
    return 1
}
PY="$(resolve_py)" || { echo "  FAIL: tidak ada interpreter dengan numpy+xgboost+psutil+scapy — buat venv lalu: pip install -r $EXP/requirements.txt"; FAIL=1; }
if [ "$FAIL" = 0 ]; then
    ok "interpreter runtime ($PY)"
    # B.3 training di sandbox tmp
    TMP="$(mktemp -d /tmp/hermes-verify-minisoc-XXXXXX)"
    trap 'rm -rf "$TMP"' EXIT
    mkdir -p "$TMP/code/mini-soc-enterprise-arch/ml_detector"
    cp "$EXP/train_detector_real.py" "$TMP/code/mini-soc-enterprise-arch/ml_detector/"
    ( cd "$TMP" && "$PY" code/mini-soc-enterprise-arch/ml_detector/train_detector_real.py > run.log 2>&1 )
    if [ $? -ne 0 ] || [ ! -f "$TMP/code/mini-soc-enterprise-arch/ml_detector/detector_metrics.json" ]; then
        bad "training gagal (lihat $TMP/run.log)"
    else
        REGEN="$TMP/code/mini-soc-enterprise-arch/ml_detector/detector_metrics.json"
        # B.4 gate nilai ilmiah (determinisme logis)
        "$PY" - "$REGEN" <<'PYEOF'
import json, sys
m = json.load(open(sys.argv[1]))
exp = {"accuracy": 0.9970833333333333, "precision": 0.999163179916318,
       "recall": 0.995, "auc": 0.9994583333333333, "n_trees": 200}
ok = all(abs(float(m[k]) - v) < 1e-9 for k, v in exp.items())
print("OK" if ok else f"DIFF {json.dumps({k: m.get(k) for k in exp})}")
sys.exit(0 if ok else 1)
PYEOF
        if [ $? -eq 0 ]; then
            ok "nilai ilmiah regenerasi == manuskrip (acc 0.9971 prec 0.9992 rec 0.9950 auc 0.9995)"
        else
            bad "nilai ilmiah regenerasi berbeda"
        fi
        # B.5 gate byte-identical (determinisme kuat) — hanya jika hash manifest tersedia
        if [ -n "$M_METRICS_SHA" ]; then
            if [ "$(sha16 "$REGEN")" = "$M_METRICS_SHA" ]; then
                ok "detector_metrics.json sha == manifest ($M_METRICS_SHA)"
            else
                bad "detector_metrics.json sha ($(sha16 "$REGEN")) != manifest ($M_METRICS_SHA) — kemungkinan versi xgboost berbeda; nilai ilmiah sudah dicek di atas"
            fi
        else
            skip "hash manifest tidak terbaca — lewati gate byte"
        fi

        # B.6 artefak CSV/JSON/PNG (interpreter dengan matplotlib)
        MPY=""
        for c in "${PYTHON:-}" "$HOME/venv/bin/python" python3; do
            [ -n "$c" ] || continue
            if "$c" -c "import matplotlib" >/dev/null 2>&1; then MPY="$c"; break; fi
        done
        if [ -z "$MPY" ]; then
            bad "tidak ada interpreter dengan matplotlib — pip install -r $EXP/requirements.txt"
        else
            "$MPY" "$EXP/build_artifact.py" "$REGEN" >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                bad "build_artifact.py gagal"
            else
                csv_sha=$(sha16 "$ROOT/research/outputs/mini_soc_detector_metrics.csv")
                json_sha=$(sha16 "$ROOT/research/outputs/mini_soc_detector_metrics.json")
                [ "$csv_sha" = "$M_CSV_SHA" ] && ok "CSV sha == manifest ($csv_sha)" || bad "CSV sha ($csv_sha) != manifest ($M_CSV_SHA)"
                [ "$json_sha" = "$M_JSON_SHA" ] && ok "JSON sha == manifest ($json_sha)" || bad "JSON sha ($json_sha) != manifest ($M_JSON_SHA)"
                if [ -s "$ROOT/research/outputs/mini_soc_detector_metrics.png" ]; then
                    ok "PNG dihasilkan"
                    png_sha=$(sha16 "$ROOT/research/outputs/mini_soc_detector_metrics.png")
                    m_png=$(man_hash 'mini_soc_detector_metrics\.png` \| `\K[0-9a-f]{16}')
                    [ "$png_sha" = "$m_png" ] && ok "PNG sha == manifest (byte-deterministik)" || echo "  WARN: PNG sha ($png_sha) != manifest ($m_png) — wajar bila versi matplotlib berbeda (bukan gate)"
                else
                    bad "PNG tidak dihasilkan"
                fi
            fi
        fi
    fi
fi

# ---- C. Deliverable JSI2 (VAE validation — komponen numerik SLR) -----------
echo
echo "-- C. Deliverable JSI2 (VAE validation, SLR) --"

M_JSI2_SRC_SHA=$(man_hash 'run_vae_experiment\.py` \| `\K[0-9a-f]{16}')
M_JSI2_EXP_SHA=$(man_hash 'jsi2_vae_exp\.json` \| `\K[0-9a-f]{16}')
M_JSI2_CSV_SHA=$(man_hash 'jsi2_vae_metrics\.csv` \| `\K[0-9a-f]{16}')
M_JSI2_PNG_SHA=$(man_hash 'jsi2_vae_loss\.png` \| `\K[0-9a-f]{16}')

EXP2="$ROOT/research/outputs/exp_jsi2_vae_20260907_152636"

# C.1 sha salinan scaffold == manifest
src2=$(sha16 "$EXP2/run_vae_experiment.py")
if [ -n "$M_JSI2_SRC_SHA" ] && [ "$src2" = "$M_JSI2_SRC_SHA" ]; then
    ok "jsi2 source script sha == manifest ($src2)"
else
    bad "jsi2 source script sha ($src2) != manifest ($M_JSI2_SRC_SHA)"
fi

# C.2 interpreter runtime (torch+numpy+matplotlib)
resolve_py2() {
    local c
    for c in "${PYTHON:-}" \
        "$ROOT/.venv/bin/python" \
        "$HOME/venv/bin/python" \
        python3; do
        [ -n "$c" ] || continue
        if "$c" -c "import torch, numpy, matplotlib" >/dev/null 2>&1; then
            echo "$c"; return 0
        fi
    done
    return 1
}
PY2="$(resolve_py2)"
if [ -z "$PY2" ]; then
    bad "jsi2: tidak ada interpreter dengan torch+numpy+matplotlib — pip install -r $EXP2/requirements.txt"
else
    ok "jsi2 interpreter runtime ($PY2)"
    # C.3 sandbox run (script menulis relatif-cwd → jalankan dengan cwd=sandbox)
    TMP2="$(mktemp -d /tmp/hermes-verify-jsi2vae-XXXXXX)"
    trap 'rm -rf "$TMP" "$TMP2"' EXIT
    mkdir -p "$TMP2/research/outputs" "$TMP2/submissions/jsi2/figures"
    ( cd "$TMP2" && "$PY2" "$EXP2/run_vae_experiment.py" > exp.log 2>&1 )
    if [ $? -ne 0 ] || [ ! -f "$TMP2/research/outputs/jsi2_vae_exp.json" ]; then
        bad "jsi2 training gagal (lihat $TMP2/exp.log)"
    else
        REGEN2="$TMP2/research/outputs/jsi2_vae_exp.json"
        # C.4 gate nilai ilmiah == manuskrip (abstract: 10,11 -> 2,75; recon 0,355; W2 0,100)
        # Toleransi 1e-3: bit terakhir float torch CPU dapat berbeda lintas mesin
        # (thread/BLAS) meski versi sama — runner CI membuktikan 2-4e-4 (2026-09-07).
        "$PY2" - "$REGEN2" <<'PYEOF'
import json, sys
m = json.load(open(sys.argv[1]))
exp = {"elbo_final": 2.7489, "recon_mse_final": 0.3546,
       "kl_final": 2.008, "wasserstein2_approx": 0.0999}
ok = all(abs(float(m[k]) - v) < 1e-3 for k, v in exp.items())
print("OK" if ok else f"DIFF {json.dumps({k: m.get(k) for k in exp})}")
sys.exit(0 if ok else 1)
PYEOF
        if [ $? -eq 0 ]; then
            ok "jsi2 nilai ilmiah regenerasi == manuskrip (elbo 2.7489, recon 0.3546, kl 2.008, w2 0.0999)"
        else
            bad "jsi2 nilai ilmiah regenerasi berbeda"
        fi
        # C.5 byte-stability (json memuat float 4-desimal → boleh berbeda bit
        # terakhir lintas mesin; sha beda = WARN, bukan FAIL)
        if [ -n "$M_JSI2_EXP_SHA" ]; then
            if [ "$(sha16 "$REGEN2")" = "$M_JSI2_EXP_SHA" ]; then
                ok "jsi2_vae_exp.json sha == manifest ($M_JSI2_EXP_SHA)"
            else
                echo "  WARN: jsi2_vae_exp.json sha ($(sha16 "$REGEN2")) != manifest ($M_JSI2_EXP_SHA) — float bit lintas mesin; nilai ilmiah sudah dicek di atas"
            fi
        else
            skip "jsi2 hash manifest tidak terbaca"
        fi
        # C.6 CSV artefak: nilai ilmiah STRICT (toleransi), sha WARN
        if [ -n "$M_JSI2_CSV_SHA" ]; then
            "$PY2" "$EXP2/build_artifact.py" "$REGEN2" >/dev/null 2>&1
            csv2p="$ROOT/research/outputs/jsi2_vae_metrics.csv"
            "$PY2" - "$csv2p" <<'PYEOF'
import csv, sys
exp = {"elbo_final": 2.7489, "recon_mse_final": 0.3546,
       "kl_final": 2.008, "wasserstein2_approx": 0.0999}
rows = {r["metric"]: float(r["value"]) for r in csv.DictReader(open(sys.argv[1]))}
ok = all(abs(rows.get(k, -1) - v) < 1e-3 for k, v in exp.items())
print("OK" if ok else "DIFF")
sys.exit(0 if ok else 1)
PYEOF
            [ $? -eq 0 ] && ok "jsi2 CSV nilai ilmiah == manifest" || bad "jsi2 CSV nilai ilmiah berbeda"
            csv2=$(sha16 "$csv2p")
            [ "$csv2" = "$M_JSI2_CSV_SHA" ] && ok "jsi2 CSV sha == manifest ($csv2)" || echo "  WARN: jsi2 CSV sha ($csv2) != manifest ($M_JSI2_CSV_SHA) — float bit lintas mesin"
        fi
        # C.7 PNG — cek file hasil SANDBOX (research/outputs/jsi2_vae_loss.png
        # di repo TIDAK di-track; D.7 analog untuk dca)
        PNG2="$TMP2/submissions/jsi2/figures/fig2_vae_loss.png"
        if [ -f "$PNG2" ] && [ -s "$PNG2" ]; then
            ok "jsi2 PNG dihasilkan"
            png2=$(sha16 "$PNG2")
            [ "$png2" = "$M_JSI2_PNG_SHA" ] && ok "jsi2 PNG sha == manifest (byte-deterministik)" || echo "  WARN: jsi2 PNG sha ($png2) != manifest ($M_JSI2_PNG_SHA)"
        else
            bad "jsi2 PNG tidak dihasilkan"
        fi
    fi
fi

# ---- D. Deliverable JSI3 (DCA sweep — bukti H5) -----------------------------
echo
echo "-- D. Deliverable JSI3 (DCA sweep α, bukti H5) --"

M_DCA_SRC_SHA=$(man_hash 'dca_sweep_demo\.py` \(scaffold\) \| `\K[0-9a-f]{16}')
M_DCA_JSON_SHA=$(man_hash 'dca_sweep_mc\.json` \| `\K[0-9a-f]{16}')
M_DCA_CSV_SHA=$(man_hash 'dca_sweep_mc\.csv` \| `\K[0-9a-f]{16}')
M_DCA_PNG_SHA=$(man_hash 'dca_sweep_mc\.png` \| `\K[0-9a-f]{16}')

EXP3="$ROOT/research/outputs/exp_dca_sweep_alpha_m_20260907_005822"

# D.1 sha salinan scaffold == manifest
src3=$(sha16 "$EXP3/dca_sweep_demo.py")
if [ -n "$M_DCA_SRC_SHA" ] && [ "$src3" = "$M_DCA_SRC_SHA" ]; then
    ok "dca source script sha == manifest ($src3)"
else
    bad "dca source script sha ($src3) != manifest ($M_DCA_SRC_SHA)"
fi

# D.2 interpreter runtime (numpy+scipy+matplotlib)
resolve_py3() {
    local c
    for c in "${PYTHON:-}" \
        "$ROOT/.venv/bin/python" \
        "$HOME/venv/bin/python" \
        python3; do
        [ -n "$c" ] || continue
        if "$c" -c "import numpy, scipy, matplotlib" >/dev/null 2>&1; then
            echo "$c"; return 0
        fi
    done
    return 1
}
PY3="$(resolve_py3)"
if [ -z "$PY3" ]; then
    bad "dca: tidak ada interpreter dengan numpy+scipy+matplotlib — pip install numpy scipy matplotlib"
else
    ok "dca interpreter runtime ($PY3)"
    # D.3 sandbox run (script menulis relatif-cwd → jalankan dengan cwd=sandbox)
    TMP3="$(mktemp -d /tmp/hermes-verify-dca-XXXXXX)"
    trap 'rm -rf "$TMP" "$TMP2" "$TMP3"' EXIT
    mkdir -p "$TMP3/research/outputs"
    ( cd "$TMP3" && "$PY3" "$EXP3/dca_sweep_demo.py" > exp.log 2>&1 )
    if [ $? -ne 0 ] || [ ! -f "$TMP3/research/outputs/dca_sweep_mc.json" ]; then
        bad "dca run gagal (lihat $TMP3/exp.log)"
    else
        REGEN3="$TMP3/research/outputs/dca_sweep_mc.json"
        # D.4 gate nilai ilmiah (naive_1d_w1 / two_state_w1 / qgap) == manifest §7.3
        "$PY3" - "$REGEN3" <<'PYEOF'
import json, sys
d = json.load(open(sys.argv[1]))
exp = {
    0.0: (0.009713105571432276, 0.00971310557142957, [-0.434, -1.134, -6.292]),
    0.5: (0.019210658767807674, 0.01007313208316714, [-0.573, -1.468, -8.064]),
    1.0: (0.025722138295161536, 0.009715594475907639, [-0.721, -1.688, -9.062]),
}
ok = True
for r in d["results"]:
    a = r["alpha"]
    if a not in exp:
        ok = False; continue
    nw, tw, qg = exp[a]
    if abs(r["naive_1d_w1"] - nw) > 5e-5 or abs(r["two_state_w1"] - tw) > 5e-5:
        ok = False
    if any(abs(r["two_state_qgap"][i] - qg[i]) > 2e-3 for i in range(3)):
        ok = False
print("OK" if ok else "DIFF")
sys.exit(0 if ok else 1)
PYEOF
        if [ $? -eq 0 ]; then
            ok "dca nilai ilmiah regenerasi == manifest §7.3 (W1 naif/2-state + qgap per α)"
        else
            bad "dca nilai ilmiah regenerasi berbeda"
        fi
        # D.5 JSON sha — WARN kalau beda (kolom *_cost_s timing non-deterministik by design)
        if [ -n "$M_DCA_JSON_SHA" ]; then
            j3=$(sha16 "$REGEN3")
            if [ "$j3" = "$M_DCA_JSON_SHA" ]; then
                ok "dca_sweep_mc.json sha == manifest ($j3)"
            else
                echo "  WARN: dca json sha ($j3) != manifest ($M_DCA_JSON_SHA) — kolom timing (*_cost_s) berubah antar run; nilai ilmiah sudah dicek di atas"
            fi
        fi
        # D.6 CSV: bangun + gate kolom ilmiah; sha WARN (kolom timing)
        if [ -n "$M_DCA_CSV_SHA" ]; then
            "$PY3" "$EXP3/build_artifact.py" "$REGEN3" >/dev/null 2>&1
            csv3="$ROOT/research/outputs/dca_sweep_mc.csv"
            "$PY3" - "$csv3" <<'PYEOF'
import csv, sys
# Perbandingan NUMERIK toleran (bukan string eksak): bit terakhir float W1
# dapat berbeda lintas mesin (BLAS/CPU) meski versi lib sama — lihat §10.3.
exp = {
    0.0: (0.009713105571432276, 0.00971310557142957, [-0.434, -1.134, -6.292]),
    0.5: (0.019210658767807674, 0.01007313208316714, [-0.573, -1.468, -8.064]),
    1.0: (0.025722138295161536, 0.009715594475907639, [-0.721, -1.688, -9.062]),
}
rows = list(csv.DictReader(open(sys.argv[1])))
ok = len(rows) == 3
for r in rows:
    a = float(r["alpha"])
    if a not in exp: ok = False; continue
    nw, tw, qg = exp[a]
    if abs(float(r["naive_1d_w1"]) - nw) > 5e-5 or abs(float(r["two_state_w1"]) - tw) > 5e-5:
        ok = False
    if any(abs(float(r[k]) - v) > 2e-3 for k, v in zip(("q10_gap", "q50_gap", "q90_gap"), qg)):
        ok = False
print("OK" if ok else "DIFF")
sys.exit(0 if ok else 1)
PYEOF
            [ $? -eq 0 ] && ok "dca CSV kolom ilmiah == manifest §7.3" || bad "dca CSV kolom ilmiah berbeda"
            c3=$(sha16 "$csv3")
            if [ "$c3" = "$M_DCA_CSV_SHA" ]; then
                ok "dca_sweep_mc.csv sha == manifest ($c3)"
            else
                echo "  WARN: dca csv sha ($c3) != manifest ($M_DCA_CSV_SHA) — kolom timing berubah antar run"
            fi
        fi
        # D.7 PNG — byte-deterministik di env sama; WARN kalau beda (versi matplotlib)
        if [ -f "$TMP3/research/outputs/dca_sweep_mc.png" ] && [ -s "$TMP3/research/outputs/dca_sweep_mc.png" ]; then
            ok "dca PNG dihasilkan"
            p3=$(sha16 "$TMP3/research/outputs/dca_sweep_mc.png")
            if [ "$p3" = "$M_DCA_PNG_SHA" ]; then
                ok "dca PNG sha == manifest (byte-deterministik)"
            else
                echo "  WARN: dca PNG sha ($p3) != manifest ($M_DCA_PNG_SHA) — wajar bila versi matplotlib berbeda"
            fi
        else
            bad "dca PNG tidak dihasilkan"
        fi
    fi
fi

echo
echo "== hasil: PASS $PASS | FAIL $FAIL | SKIP $SKIP =="
[ "$FAIL" = 0 ]