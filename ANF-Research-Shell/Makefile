# ANF Research Shell — Makefile verifikasi reproduksibilitas
# `make setup` : buat .venv + install requirements agregat (satu perintah onboarding).
# `make verify`: baseline ANF + deliverable JSI1 (mini-SOC) + JSI2 (VAE/SLR) + JSI3 (DCA),
#                semua di sandbox, cek hash vs manifest.
# `make test`  : alias verify (sesuai TODO reproducibility manifest §6).
.PHONY: setup verify test
setup:
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt
	@echo "venv siap. Jalankan: PYTHON=$$(pwd)/.venv/bin/python make verify"

# Interpreter default dipakai $PYTHON bila di-set; tanpa itu verify mere-resolve
# kandidat lokal sendiri. Set PYTHON ke .venv agar verifikasi memakai env pin.
verify:
	bash scripts/verify_repro.sh
test: verify