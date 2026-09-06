#!/bin/bash

# ============================================================================
# CENTRALIZED LOGGING - PILGRIMS v17.0
# ============================================================================

LOG_DIR="$SCRIPT_DIR/shared/logs"
LOG_FILE="$LOG_DIR/pilgrims_$(date +%Y%m%d).log"

# Initialize logging
init_logging() {
    mkdir -p "$LOG_DIR"
}

# Log levels
LOG_DEBUG=0
LOG_INFO=1
LOG_WARNING=2
LOG_ERROR=3
LOG_CRITICAL=4

# Current log level (default: INFO)
CURRENT_LOG_LEVEL=${PILGRIMS_LOG_LEVEL:-$LOG_INFO}

# Log message
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local module=${3:-"core"}
    
    # Check if should log
    if [ $level -lt $CURRENT_LOG_LEVEL ]; then
        return
    fi
    
    # Get level name
    local level_name
    case $level in
        $LOG_DEBUG) level_name="DEBUG" ;;
        $LOG_INFO) level_name="INFO" ;;
        $LOG_WARNING) level_name="WARNING" ;;
        $LOG_ERROR) level_name="ERROR" ;;
        $LOG_CRITICAL) level_name="CRITICAL" ;;
    esac
    
    # Write to log file
    echo "[$timestamp] [$level_name] [$module] $message" >> "$LOG_FILE"
}

# Convenience functions
log_debug() { log $LOG_DEBUG "$1" "$2"; }
log_info() { log $LOG_INFO "$1" "$2"; }
log_warning() { log $LOG_WARNING "$1" "$2"; }
log_error() { log $LOG_ERROR "$1" "$2"; }
log_critical() { log $LOG_CRITICAL "$1" "$2"; }

# Log scan start
log_scan_start() {
    local module=$1
    local target=$2
    log_info "=== SCAN STARTED ===" "$module"
    log_info "Module: $module" "$module"
    log_info "Target: $target" "$module"
    log_info "Timestamp: $(get_iso_timestamp)" "$module"
}

# Log scan end
log_scan_end() {
    local module=$1
    local target=$2
    local duration=$3
    local findings=$4
    
    log_info "=== SCAN COMPLETED ===" "$module"
    log_info "Module: $module" "$module"
    log_info "Target: $target" "$module"
    log_info "Duration: ${duration}s" "$module"
    log_info "Findings: $findings" "$module"
}

# Log finding
log_finding() {
    local module=$1
    local severity=$2
    local category=$3
    local description=$4
    
    log_info "FINDING [$severity] [$category] $description" "$module"
}

# View logs
view_logs() {
    local lines=${1:-50}
    local module=$2
    
    if [ -n "$module" ]; then
        grep "\[$module\]" "$LOG_FILE" | tail -n $lines
    else
        tail -n $lines "$LOG_FILE"
    fi
}

# Clear logs
clear_logs() {
    local days=${1:-30}
    find "$LOG_DIR" -name "*.log" -mtime +$days -delete
    log_info "Cleared logs older than $days days" "core"
}

# Search logs
search_logs() {
    local keyword=$1
    grep -i "$keyword" "$LOG_FILE" | tail -n 50
}
