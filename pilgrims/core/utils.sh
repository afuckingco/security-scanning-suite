#!/bin/bash

# ============================================================================
# SHARED UTILITIES - PILGRIMS v17.0
# ============================================================================

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check multiple dependencies
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${missing[*]}"
        print_info "Install with: sudo apt install ${missing[*]}"
        return 1
    fi
    return 0
}

# URL validation
is_valid_url() {
    local url=$1
    if [[ $url =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        return 0
    fi
    return 1
}

# IP/CIDR validation
is_valid_network() {
    local network=$1
    if [[ $network =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
        return 0
    fi
    return 1
}

# File validation
is_valid_file() {
    local file=$1
    if [ -f "$file" ]; then
        return 0
    fi
    return 1
}

# Get timestamp
get_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Get ISO timestamp
get_iso_timestamp() {
    date -Iseconds
}

# Calculate duration
calculate_duration() {
    local start=$1
    local end=$(date +%s)
    echo $((end - start))
}

# Format duration
format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

# Count findings by severity
count_findings() {
    local output_dir=$1
    local severity=$2
    
    find "$output_dir" -name "*.txt" -exec grep -l "\[$severity\]" {} + 2>/dev/null | wc -l
}

# Get total findings
get_total_findings() {
    local output_dir=$1
    find "$output_dir" -name "*.txt" -exec grep -lE "\[CRITICAL\]|\[HIGH\]|\[MEDIUM\]|\[LOW\]" {} + 2>/dev/null | wc -l
}

# Extract domain from URL
extract_domain() {
    local url=$1
    echo "$url" | sed 's|https\?://||' | cut -d'/' -f1
}

# Sanitize filename
sanitize_filename() {
    local name=$1
    echo "$name" | sed 's/[^a-zA-Z0-9.-]/_/g'
}

# Create backup
create_backup() {
    local file=$1
    if [ -f "$file" ]; then
        cp "$file" "$file.backup.$(get_timestamp)"
    fi
}

# Cleanup temp files
cleanup_temp() {
    local pattern=${1:-"/tmp/pilgrims_*"}
    rm -rf $pattern 2>/dev/null
}

# Check root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Some features require root privileges"
        return 1
    fi
    return 0
}

# Get system info
get_system_info() {
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Arch: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
}

# Calculate risk score
calculate_risk_score() {
    local output_dir=$1
    local critical=$(count_findings "$output_dir" "CRITICAL")
    local high=$(count_findings "$output_dir" "HIGH")
    local medium=$(count_findings "$output_dir" "MEDIUM")
    local low=$(count_findings "$output_dir" "LOW")
    
    local score=$((critical * 40 + high * 25 + medium * 10 + low * 3))
    [ $score -gt 100 ] && score=100
    
    echo $score
}

# Get risk level
get_risk_level() {
    local score=$1
    
    if [ $score -ge 75 ]; then
        echo "CRITICAL"
    elif [ $score -ge 50 ]; then
        echo "HIGH"
    elif [ $score -ge 25 ]; then
        echo "MEDIUM"
    else
        echo "LOW"
    fi
}
