#!/bin/bash
apply_stealth_profile() {
    local profile=$1
    case $profile in
        ghost)  STEALTH_DELAY_MIN=5;  STEALTH_DELAY_MAX=15; STEALTH_UA=1; STEALTH_HEADERS=1; STEALTH_PATH_NORM=1; ENABLE_PARALLEL=0; print_info "👻 Ghost Stealth: Ultra-quiet (5-15s delays)";;
        shadow) STEALTH_DELAY_MIN=3;  STEALTH_DELAY_MAX=8;  STEALTH_UA=1; STEALTH_HEADERS=1; STEALTH_PATH_NORM=0; ENABLE_PARALLEL=0; print_info "🌑 Shadow Stealth: High stealth (3-8s delays)";;
        phantom)STEALTH_DELAY_MIN=1;  STEALTH_DELAY_MAX=3;  STEALTH_UA=1; STEALTH_HEADERS=0; STEALTH_PATH_NORM=0; ENABLE_PARALLEL=0; print_info "👤 Phantom Stealth: Medium stealth (1-3s delays)";;
        wraith) STEALTH_DELAY_MIN=0;  STEALTH_DELAY_MAX=0;  STEALTH_UA=0; STEALTH_HEADERS=0; STEALTH_PATH_NORM=0; ENABLE_PARALLEL=1; print_info "💀 Wraith Mode: Aggressive speed (no delays, parallel)";;
    esac
}
