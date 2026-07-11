import pandas as pd
from typing import List

def apply_k_anonymity(df: pd.DataFrame, quasi_identifiers: List[str], k: int = 5) -> pd.DataFrame:
    """Simple k‑anonymity: grupkan baris berdasarkan quasi‑identifiers dan ganti nilai dengan '*'.
    Jika grup memiliki ukuran < k, semua nilai dalam grup diganti '*'.
    """
    if not quasi_identifiers:
        return df
    # Count group sizes
    group_sizes = df.groupby(quasi_identifiers).size().reset_index(name='size')
    # Merge size back
    df = df.merge(group_sizes, on=quasi_identifiers, how='left')
    # Replace values in quasi_identifiers where size < k
    mask = df['size'] < k
    for col in quasi_identifiers:
        df.loc[mask, col] = '*'
    df = df.drop(columns=['size'])
    return df
