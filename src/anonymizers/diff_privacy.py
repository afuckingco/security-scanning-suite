import numpy as np
import pandas as pd
from typing import List

def add_laplace_noise(df: pd.DataFrame, columns: List[str], epsilon: float = 1.0) -> pd.DataFrame:
    """Tambahkan noise Laplace pada kolom numerik yang dipilih.
    epsilon kecil → noise besar (privasi tinggi).
    """
    scale = 1.0 / epsilon
    for col in columns:
        if col in df.columns and np.issubdtype(df[col].dtype, np.number):
            noise = np.random.laplace(0, scale, size=df.shape[0])
            df[col] = df[col] + noise
    return df
