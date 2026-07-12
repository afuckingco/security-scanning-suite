import pytest
from log_anonymizer.anonymizers import hashing

def test_hash_text():
    txt = "secret"
    h1 = hashing.hash_text(txt)
    h2 = hashing.hash_text(txt)
    assert h1 == h2
    assert len(h1) == 64  # SHA256 hex length
