from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import pandas as pd

from .anonymizers import hashing, tokenization, k_anonymity, diff_privacy

app = FastAPI(title='Log Anonymizer API')

class AnonymizeRequest(BaseModel):
    log: str                       # raw log data (plain text or CSV string)
    method: str                    # hash|tokenize|k_anonymity|diff_privacy
    columns: List[str] = []        # for CSV: column names to process
    k: int = 5                     # k‑anonymity
    epsilon: float = 1.0            # diff‑privacy

class AnonymizeResponse(BaseModel):
    anonymized: str

def _detect_csv(text: str) -> bool:
    # simple heuristic: check for commas & header line
    return ',' in text and '\n' in text

@app.post('/anonymize', response_model=AnonymizeResponse)
def anonymize(req: AnonymizeRequest):
    if _detect_csv(req.log):
        # treat as CSV, load into pandas DataFrame
        from io import StringIO
        df = pd.read_csv(StringIO(req.log))
        if req.method == 'hash':
            df = hashing.hash_columns(df, req.columns)
        elif req.method == 'tokenize':
            df = tokenization.tokenize_columns(df, req.columns)
        elif req.method == 'k_anonymity':
            df = k_anonymity.apply_k_anonymity(df, req.columns, req.k)
        elif req.method == 'diff_privacy':
            df = diff_privacy.add_laplace_noise(df, req.columns, req.epsilon)
        else:
            raise HTTPException(status_code=400, detail='Unsupported method')
        out = df.to_csv(index=False)
    else:
        # plain‑text log
        if req.method == 'hash':
            out = hashing.hash_text(req.log)
        elif req.method == 'tokenize':
            out = tokenization.tokenize_text(req.log)
        else:
            raise HTTPException(status_code=400, detail='Method not supported for plain‑text logs')
    return AnonymizeResponse(anonymized=out)
