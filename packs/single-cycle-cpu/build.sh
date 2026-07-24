#!/usr/bin/env bash
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build
iverilog -g2012 -o build/sim.vvp tb/tb_rv32_cpu.v src/rv32_cpu.v src/regfile.v src/imem.v
vvp build/sim.vvp
[ -f fixtures/reference.vcd ] || { echo "reference.vcd missing"; exit 1; }
if command -v vcd2fst >/dev/null 2>&1; then
    vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null
fi

# NetCrux half of the pair: synthesise the CPU so students can cross-probe from a
# register value in the waveform to the datapath structure — the instruction
# memory and the register file the top module is assembled from. Run from the
# pack dir so imem.v's $readmemh finds src/program.hex.
yosys -q -p "read_verilog src/rv32_cpu.v src/regfile.v src/imem.v; hierarchy -top rv32_cpu; proc; opt; write_json fixtures/netlist.json"

echo "Built fixtures/reference.vcd + fixtures/netlist.json"
