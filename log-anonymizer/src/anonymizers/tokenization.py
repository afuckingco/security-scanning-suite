import uuid
import pandas as pd
from typing import List

_token_map = {}

def _get_token(value: str) -> str:
    if value not in _token_map:
        _token_map[value] = str(uuid.uuid4())
    return _token_map[value]

def tokenize_text(text: str) -> str:
    # Very naive tokenization: replace each word with a uuid token.
    return ' '.join(_get_token(tok) for tok in text.split())

def tokenize_columns(df: pd.DataFrame, columns: List[str]) -> pd.DataFrame:
    for col in columns:
        if col in df.columns:
            df[col] = df[col].astype(str).apply(_get_token)
    return df
