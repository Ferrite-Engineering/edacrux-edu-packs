#!/usr/bin/env bash
# Synthesize the datapath core with Yosys → the JSON netlist NetCrux loads.
# Generic synthesis (proc; opt), no vendor library, so the schematic reads as
# the design rather than a gate-mapped soup.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures
yosys -q -p "read_verilog src/core.v; hierarchy -top core; proc; opt; write_json fixtures/netlist.json"
echo "Built fixtures/netlist.json ($(wc -c < fixtures/netlist.json) bytes)"
