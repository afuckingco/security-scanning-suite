#!/bin/bash
# SIMULATION STUB — educational scaffold only; NOT a live security scanner.
# Generates sample output files. Do NOT use for real assessments.
start_recording() { script -q -t 2>"$1/timing" "$1/session.log" >/dev/null 2>&1 & echo $! > "$1/.recorder_pid"; }
stop_recording() { [ -f "$1/.recorder_pid" ] && kill $(cat "$1/.recorder_pid") 2>/dev/null; }
