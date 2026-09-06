#!/bin/bash
# SIMULATION STUB — educational scaffold only; NOT a live security scanner.
# Generates sample output files. Do NOT use for real assessments.

# Encrypt a scan directory. Password flows via stdin — invisible in `ps aux`.
# Usage: encrypt_scan /path/to/dir "mypassword"
encrypt_scan() {
    local dir=$1 pass=$2 out="${dir}.enc" tarball="${dir}.tar.gz"
    tar czf "$tarball" -C "$(dirname "$dir")" "$(basename "$dir")" 2>/dev/null || return 1
    # Pipe password to stdin — does NOT appear in process table
    printf '%s' "$pass" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
        -in "$tarball" -out "$out" -pass stdin 2>/dev/null
    rm -f "$tarball"
    [ -f "$out" ] && print_success "Encrypted: $out" || print_error "Encryption failed"
}

# Decrypt a scan archive. Password flows via stdin — invisible in `ps aux`.
# Usage: decrypt_scan /path/to/dir.enc "mypassword"
decrypt_scan() {
    local file=$1 pass=$2 tarball="${file%.enc}.tar.gz" restored_dir="${file%.enc}"
    printf '%s' "$pass" | openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
        -in "$file" -out "$tarball" -pass stdin 2>/dev/null
    # Extract to parent dir; tar stdin is closed, so no conflict
    tar xzf "$tarball" -C "$(dirname "$file")" 2>/dev/null && rm -f "$tarball"
    [ -d "$restored_dir" ] && print_success "Decrypted: $restored_dir" \
        || print_error "Decryption failed (wrong password?)"
}
