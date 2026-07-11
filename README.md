# Log Anonymizer

**Toolkit privasi‑preserving untuk anonimisasi data log**. Menyediakan:

- **CLI** (Click) dengan sub‑command `hash`, `tokenize`, `k_anonymity`, `diff_privacy`.
- **FastAPI** endpoint `/anonymize` (POST) untuk anonimisasi via HTTP.
- **Docker** image yang dapat dijalankan sebagai service mandiri.
- **Unit tests** (pytest) untuk tiap metode.

## Fitur utama
| Metode | Deskripsi |
|--------|-----------|
| `hash` | SHA‑256 hashing (opsional salt). |
| `tokenize` | Deterministic UUID token replacement. |
| `k_anonymity` | Generalisasi quasi‑identifier dengan parameter `k`. |
| `diff_privacy` | Tambah noise Laplace pada kolom numerik (parameter `epsilon`). |

## Instalasi
```bash
# Clone repo
git clone https://github.com/afuckingco/log-anonymizer.git
cd log-anonymizer
# Virtual env (optional)
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

## Penggunaan CLI
```bash
# Hash seluruh file teks
python -m log_anonymizer.cli run input.log output_hashed.log --algorithm hash

# Tokenisasi CSV (kolom ip,userid)
python -m log_anonymizer.cli run data.csv data_tok.csv --algorithm tokenize --columns ip userid

# k‑anonymity pada CSV (quasi‑identifiers timestamp,userid)
python -m log_anonymizer.cli run data.csv data_kanon.csv --algorithm k_anonymity --columns timestamp userid --k 5

# Differential privacy (Laplace noise)
python -m log_anonymizer.cli run data.csv data_dp.csv --algorithm diff_privacy --columns amount price --epsilon 0.8
```

## FastAPI (Remote)
```bash
# Jalankan server
uvicorn src.api:app --host 0.0.0.0 --port 8000
# atau via Docker
docker compose up --build -d
```

### Contoh request (curl)
```bash
curl -X POST http://localhost:8000/anonymize \
  -H "Content-Type: application/json" \
  -d '{"log":"user=alice ip=10.0.0.5 action=login","method":"hash"}'
```

## Docker
```bash
# Build dan jalankan semua layanan
docker compose up --build -d
# API tersedia di http://localhost:8000, proxy di http://localhost:8080
```

## Testing
```bash
pytest -n auto   # paralel semua tes di src/tests/
```

## Roadmap
- **v0.2.0** – dukungan streaming log (Kafka/Fluentd).
- **v0.3.0** – policy engine (YAML) untuk konfigurasi per‑field.
- **v0.4.0** – metrik Prometheus + Grafana dashboard.
- **v1.0.0** – dokumentasi lengkap, contoh CI/CD pipeline.

## Lisensi
MIT – lihat file `LICENSE`.
