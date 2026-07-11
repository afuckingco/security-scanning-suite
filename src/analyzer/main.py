import json
from pathlib import Path
from typing import List

import pandas as pd
from sklearn.ensemble import IsolationForest
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

app = FastAPI()

LOGS_DIR = Path(__file__).resolve().parents[2] / "logs"
REPORT_MD = Path(__file__).resolve().parents[2] / "anomaly_report.md"

def load_logs() -> pd.DataFrame:
    """Load all JSON log files under LOGS_DIR and return a DataFrame.
    Expect each JSON object to be a dict with numeric values; non‑numeric columns are ignored.
    """
    rows: List[dict] = []
    for p in LOGS_DIR.rglob("*.json"):
        try:
            data = json.loads(p.read_text())
            if isinstance(data, dict):
                rows.append(data)
            elif isinstance(data, list):
                rows.extend([item for item in data if isinstance(item, dict)])
        except Exception:
            continue
    if not rows:
        return pd.DataFrame()
    df = pd.json_normalize(rows)
    # Keep only numeric columns for the model
    numeric_df = df.select_dtypes(include=["number"]).copy()
    return numeric_df

@app.get("/detect")
def detect_anomalies(threshold: float = -0.1):
    df = load_logs()
    if df.empty:
        raise HTTPException(status_code=404, detail="No log data found")
    # Train IsolationForest (default contamination)
    iso = IsolationForest(random_state=42, contamination="auto")
    iso.fit(df)
    scores = iso.decision_function(df)
    anomalies = df[scores < threshold]
    # Write markdown report
    lines = ["# Anomaly Detection Report", ""]
    if anomalies.empty:
        lines.append("No anomalies detected.")
    else:
        lines.append(f"Detected **{len(anomalies)}** anomalous rows (score < {threshold}).")
        lines.append("\n```json")
        lines.append(anomalies.head(20).to_json(orient="records", indent=2))
        lines.append("```\n")
    REPORT_MD.write_text("\n".join(lines))
    return JSONResponse(content={"anomalies": anomalies.to_dict(orient="records"), "report_path": str(REPORT_MD)})
