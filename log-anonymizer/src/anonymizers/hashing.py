import hashlib
import pandas as pd
from typing import List

def hash_text(text: str, salt: str = '') -> str:
    h = hashlib.sha256()
    h.update((salt + text).encode('utf-8'))
    return h.hexdigest()

def hash_columns(df: pd.DataFrame, columns: List[str], salt: str = '') -> pd.DataFrame:
    for col in columns:
        if col in df.columns:
            df[col] = df[col].astype(str).apply(lambda x: hash_text(x, salt))
    return df
