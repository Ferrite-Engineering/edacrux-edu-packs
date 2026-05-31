#!/usr/bin/env bash
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build
iverilog -g2012 -o build/sim.vvp tb/tb_top.v src/top.v src/mux2to1.v src/adder8.v
vvp build/sim.vvp
[ -f fixtures/reference.vcd ] || { echo "reference.vcd missing"; exit 1; }
if command -v vcd2fst >/dev/null 2>&1; then
    vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null
fi
echo "Built fixtures/reference.vcd ($(wc -c < fixtures/reference.vcd) bytes)"
