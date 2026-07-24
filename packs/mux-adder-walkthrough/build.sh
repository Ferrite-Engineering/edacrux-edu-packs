#!/usr/bin/env bash
# Synthesize the ALU with Yosys and emit the JSON netlist NetCrux loads.
# Deliberately a light, generic synthesis (proc; opt) — enough to give real
# cells and hierarchy without mapping to any vendor's library, so the schematic
# reads as the design the student wrote rather than a gate soup.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures
yosys -q -p "read_verilog src/adder4.v src/alu.v; hierarchy -top alu; proc; opt; write_json fixtures/netlist.json"
echo "Built fixtures/netlist.json ($(wc -c < fixtures/netlist.json) bytes)"
