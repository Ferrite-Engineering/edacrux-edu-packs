#!/usr/bin/env bash
# A three-tool pack: NetCrux structure, WaveCrux waveform, SimCrux results — all
# from one design and one testbench run, because a bring-up debug crosses all
# three views of the same event.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build

# NetCrux: the datapath structure.
yosys -q -p "read_verilog src/spi_master.v; hierarchy -top spi_master; proc; opt; write_json fixtures/netlist.json"

# WaveCrux + SimCrux: the waveform and the regression results, from one run.
iverilog -g2012 -o build/sim.vvp tb/tb_spi.v src/spi_master.v
raw="$(vvp build/sim.vvp)"
printf '%s\n' "$raw"
printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys, json, re
res=re.compile(r"^RESULT\s+(\S+)\s+(PASS|FAIL)(.*)$"); tests=[]
for line in sys.stdin:
    m=res.match(line.strip())
    if not m: continue
    n,o,ex=m.groups()
    tests.append({"name":n,"outcome":"pass" if o=="PASS" else "fail","detail":ex.strip() or None})
rep={"schema_version":1,"suite":"spi_loopback","tests":tests,
     "summary":{"total":len(tests),"passed":sum(t["outcome"]=="pass" for t in tests),
                "failed":sum(t["outcome"]=="fail" for t in tests)}}
json.dump(rep,open("fixtures/results.json","w"),indent=2); open("fixtures/results.json","a").write("\n")
print("Built results.json (%d/%d passed)"%(rep["summary"]["passed"],rep["summary"]["total"]))
'
command -v vcd2fst >/dev/null 2>&1 && vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null || true
echo "Built netlist.json + reference.vcd + results.json"
