#!/usr/bin/env bash
# A two-tool pack: it builds BOTH a NetCrux netlist and a LintCrux report from
# the same RTL, because the lab crosses between them. Yosys synthesises the
# structure; Verilator produces the lint findings; both are normalised into
# fixtures/ the way NetCrux and LintCrux would present them.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures

# --- NetCrux: the synthesised netlist ---
yosys -q -p "read_verilog src/addr_decoder.v src/regfile.v src/mem_ctrl.v; hierarchy -top mem_ctrl; proc; opt; write_json fixtures/netlist.json"

# --- LintCrux: the normalised lint report (same parser as lint-triage-101) ---
raw="$(verilator --lint-only -Wall src/addr_decoder.v src/regfile.v src/mem_ctrl.v 2>&1 || true)"
printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys, json, re
line_re = re.compile(r"^%(Warning|Error)-([A-Z0-9_]+):\s+([^:]+):(\d+):(\d+):\s+(.*)$")
sym_re  = re.compile(r"[\x27\x22]([A-Za-z_][A-Za-z0-9_]*)[\x27\x22]")
SIGNAL_RULES = {"UNUSEDSIGNAL","UNDRIVEN","UNOPTFLAT","UNUSEDPARAM","UNDRIVENSIGNAL"}
viols=[]
for line in sys.stdin:
    m=line_re.match(line.rstrip("\n"))
    if not m: continue
    kind,rule,f,ln,col,msg=m.groups()
    sym=None
    if rule in SIGNAL_RULES:
        found=sym_re.findall(msg); sym=found[-1] if found else None
    viols.append({"rule":rule,"severity":"error" if kind=="Error" else "warning",
                  "file":f.split("/")[-1],"line":int(ln),"symbol":sym,"message":msg.strip()})
viols.sort(key=lambda v:(v["file"],v["line"],v["rule"],v["symbol"] or ""))
json.dump({"schema_version":1,"engine":"verilator","violations":viols},open("fixtures/lint.json","w"),indent=2)
open("fixtures/lint.json","a").write("\n")
print(f"Built fixtures/lint.json ({len(viols)} violations)")
'
echo "Built fixtures/netlist.json ($(wc -c < fixtures/netlist.json) bytes)"
