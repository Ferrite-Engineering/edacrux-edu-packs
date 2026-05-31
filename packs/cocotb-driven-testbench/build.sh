#!/usr/bin/env bash
# Builds fixtures/reference.vcd from the pure-Verilog testbench. The
# cocotb test in tb/test_uart_rx.py is documentation only and is NOT
# required for this script to run.

set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build
iverilog -g2012 -o build/sim.vvp tb/tb_uart_rx.v src/uart_rx.v
vvp build/sim.vvp
[ -f fixtures/reference.vcd ] || { echo "reference.vcd missing"; exit 1; }
if command -v vcd2fst >/dev/null 2>&1; then
    vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null
fi
echo "Built fixtures/reference.vcd ($(wc -c < fixtures/reference.vcd) bytes)"
