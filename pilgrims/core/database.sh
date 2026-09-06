#!/bin/bash

# ============================================================================
# UNIFIED DATABASE - PILGRIMS v17.0
# ============================================================================

DB_DIR="$SCRIPT_DIR/shared/db"
DB_FILE="$DB_DIR/pilgrims.db"

init_db() {
    mkdir -p "$DB_DIR"
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS scans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    module TEXT NOT NULL,
    target TEXT NOT NULL,
    scan_date TEXT NOT NULL,
    duration_sec INTEGER,
    total_findings INTEGER,
    critical_count INTEGER,
    high_count INTEGER,
    output_dir TEXT
);

CREATE TABLE IF NOT EXISTS findings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    scan_id INTEGER,
    module TEXT,
    category TEXT,
    severity TEXT,
    description TEXT,
    FOREIGN KEY (scan_id) REFERENCES scans (id)
);
EOF
}

save_scan_to_db() {
    local module=$1
    local target=$2
    local duration=$3
    local output_dir=$4
    
    local total=$(find "$output_dir" -name "*.txt" -exec grep -lE "\[CRITICAL\]|\[HIGH\]|\[MEDIUM\]|\[LOW\]" {} + 2>/dev/null | wc -l)
    local critical=$(find "$output_dir" -name "*.txt" -exec grep -l "\[CRITICAL\]" {} + 2>/dev/null | wc -l)
    local high=$(find "$output_dir" -name "*.txt" -exec grep -l "\[HIGH\]" {} + 2>/dev/null | wc -l)
    local date_now=$(date '+%Y-%m-%d %H:%M:%S')
    
    sqlite3 "$DB_FILE" "INSERT INTO scans (module, target, scan_date, duration_sec, total_findings, critical_count, high_count, output_dir) VALUES ('$module', '$target', '$date_now', $duration, $total, $critical, $high, '$output_dir');"
    
    local scan_id=$(sqlite3 "$DB_FILE" "SELECT last_insert_rowid();")
    
    find "$output_dir" -name "*.txt" | while read -r file; do
        local category=$(basename $(dirname "$file"))
        grep -E "\[CRITICAL\]|\[HIGH\]|\[MEDIUM\]|\[LOW\]" "$file" 2>/dev/null | while read -r line; do
            local severity=$(echo "$line" | grep -oE "CRITICAL|HIGH|MEDIUM|LOW" | head -1)
            local desc=$(echo "$line" | sed 's/.*\] //' | sed "s/'/''/g")
            sqlite3 "$DB_FILE" "INSERT INTO findings (scan_id, module, category, severity, description) VALUES ($scan_id, '$module', '$category', '$severity', '$desc');"
        done
    done
    
    print_success "Scan data saved to database (ID: $scan_id)"
}

show_scan_history() {
    print_epic_banner
    echo -e "    ${CYAN}📜 RIWAYAT MISI PILGRIMS (ALL MODULES)${NC}"
    echo -e "    ${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
    printf "    %-4s | %-12s | %-25s | %-19s | %-8s | %-5s | %-5s\n" "ID" "MODULE" "TARGET" "DATE" "DURATION" "CRIT" "HIGH"
    echo -e "    ${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
    
    sqlite3 -separator '|' "$DB_FILE" "SELECT id, module, target, scan_date, duration_sec, critical_count, high_count FROM scans ORDER BY id DESC LIMIT 20;" | while IFS='|' read -r id module target date dur crit high; do
        local mins=$((dur / 60))
        local secs=$((dur % 60))
        local time_str="${mins}m ${secs}s"
        printf "    %-4s | %-12s | %-25s | %-19s | %-8s | ${RED}%-5s${NC} | ${YELLOW}%-5s${NC}\n" "$id" "$module" "$target" "$date" "$time_str" "$crit" "$high"
    done
    echo -e "    ${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    exit 0
}
