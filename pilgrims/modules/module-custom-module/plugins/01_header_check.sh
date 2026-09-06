#!/bin/bash
# Example plugin: HTTP Header Security Check
# This file is sourced by parent module, so $TARGET and $OUTPUT_DIR are inherited

header_check() {
    print_task "HTTP header security check"
    local headers=$(curl -k -s -I --max-time 10 "$TARGET" 2>/dev/null)

    if [ -z "$headers" ]; then
        print_error "Could not retrieve headers from $TARGET"
        return 1
    fi

    echo "$headers" > "$OUTPUT_DIR/headers.txt"
    print_success "Headers captured"

    # Check missing security headers
    local missing=()
    echo "$headers" | grep -qi "X-Frame-Options" || missing+=("X-Frame-Options")
    echo "$headers" | grep -qi "Content-Security-Policy" || missing+=("Content-Security-Policy")
    echo "$headers" | grep -qi "Strict-Transport-Security" || missing+=("Strict-Transport-Security")

    if [ ${#missing[@]} -gt 0 ]; then
        for h in "${missing[@]}"; do
            print_warning "Missing: $h"
        done
    else
        print_success "All key security headers present"
    fi
}
header_check
