#!/bin/bash
# SIMULATION STUB — educational scaffold only; NOT a live security scanner.
# Generates sample output files. Do NOT use for real assessments.
generate_qr() {
    local data=$1 out=$2
    if command -v qrencode &>/dev/null; then
        echo "$data" | qrencode -t ANSIUTF8 -o "$out.png" -s 8 2>/dev/null
        [ -f "$out.png" ] && print_success "QR saved: $out.png"
    else
        print_warning "qrencode not installed. Install with: sudo apt install qrencode"
    fi
}
