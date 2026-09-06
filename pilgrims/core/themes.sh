#!/bin/bash
apply_theme() {
    case "${1:-default}" in
        matrix)  RED='\033[0;32m'; GREEN='\033[1;32m'; YELLOW='\033[0;32m'; BLUE='\033[0;32m'; CYAN='\033[0;32m'; PURPLE='\033[0;32m'; WHITE='\033[1;32m'; print_info "🟢 Matrix theme applied";;
        blood)   RED='\033[1;31m'; GREEN='\033[0;33m'; YELLOW='\033[0;33m'; BLUE='\033[0;31m'; CYAN='\033[0;31m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; print_info "🔴 Blood theme applied";;
        ocean)   RED='\033[0;36m'; GREEN='\033[0;34m'; YELLOW='\033[1;36m'; BLUE='\033[1;34m'; CYAN='\033[1;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; print_info "🌊 Ocean theme applied";;
        mono)    RED='\033[0;37m'; GREEN='\033[0;37m'; YELLOW='\033[0;37m'; BLUE='\033[0;37m'; CYAN='\033[0;37m'; PURPLE='\033[0;37m'; WHITE='\033[1;37m'; print_info "⚪ Mono theme applied";;
        *)       RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; print_info "🎨 Default theme applied";;
    esac
    NC='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
}
