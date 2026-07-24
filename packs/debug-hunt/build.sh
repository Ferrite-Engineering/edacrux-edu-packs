#!/usr/bin/env bash
# Builds *two* VCDs: golden.vcd from the correct counter, and
# buggy.vcd from the version with the off-by-one bug. The buggy VCD
# is also copied to reference.vcd so students load it by default.

set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build

iverilog -g2012 -o build/golden.vvp tb/tb_counter_golden.v src/counter_golden.v
vvp build/golden.vvp

iverilog -g2012 -o build/buggy.vvp tb/tb_counter_buggy.v src/counter_buggy.v
vvp build/buggy.vvp

[ -f fixtures/golden.vcd ] || { echo "golden.vcd missing"; exit 1; }
[ -f fixtures/buggy.vcd ]  || { echo "buggy.vcd missing";  exit 1; }

cp fixtures/buggy.vcd fixtures/reference.vcd

if command -v vcd2fst >/dev/null 2>&1; then
    vcd2fst fixtures/golden.vcd    fixtures/golden.fst    >/dev/null
    vcd2fst fixtures/buggy.vcd     fixtures/buggy.fst     >/dev/null
    vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null
fi

# NetCrux half of the pair: synthesise the BUGGY counter so students can cross-
# probe from the misbehaving `count` in the waveform to the structure that drives
# it — the enabled register and its increment adder.
yosys -q -p "read_verilog src/counter_buggy.v; hierarchy -top counter; proc; opt; write_json fixtures/netlist.json"

echo "Built golden.vcd / buggy.vcd / reference.vcd / netlist.json"
