import pytest
from log_anonymizer.anonymizers import tokenization

def test_tokenize_text():
    txt = "alice bob alice"
    tok = tokenization.tokenize_text(txt)
    parts = tok.split()
    # first and last token should be same UUID, middle different
    assert parts[0] == parts[2]
    assert parts[0] != parts[1]
    # tokens length should be typical UUID length
    assert len(parts[0]) == 36
