#!/usr/bin/env bash
# Capstone scaffolding: build every tool's fixture from the one integrated design
# so a full-methodology pass (structure, lint, simulation, waveform) has a real
# starting point in each of the four products.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"; cd "$PACK_DIR"; mkdir -p fixtures build
SRCS="src/reg4.v src/alu8.v src/decoder.v src/alu_periph.v"

yosys -q -p "read_verilog $SRCS; hierarchy -top alu_periph; proc; opt; write_json fixtures/netlist.json"

raw="$(verilator --lint-only -Wall $SRCS 2>&1 || true)"
printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys,json,re
lr=re.compile(r"^%(Warning|Error)-([A-Z0-9_]+):\s+([^:]+):(\d+):(\d+):\s+(.*)$")
sr=re.compile(r"[\x27\x22]([A-Za-z_][A-Za-z0-9_]*)[\x27\x22]"); SIG={"UNUSEDSIGNAL","UNDRIVEN"}
v=[]
for line in sys.stdin:
    m=lr.match(line.rstrip("\n"))
    if not m: continue
    k,rule,f,ln,c,msg=m.groups(); sym=None
    if rule in SIG:
        fo=sr.findall(msg); sym=fo[-1] if fo else None
    v.append({"rule":rule,"severity":"error" if k=="Error" else "warning","file":f.split("/")[-1],"line":int(ln),"symbol":sym,"message":msg.strip()})
v.sort(key=lambda x:(x["file"],x["line"],x["rule"],x["symbol"] or ""))
json.dump({"schema_version":1,"engine":"verilator","violations":v},open("fixtures/lint.json","w"),indent=2); open("fixtures/lint.json","a").write("\n")
print("lint.json: %d findings"%len(v))
'
iverilog -g2012 -o build/sim.vvp tb/tb_alu_periph.v $SRCS
raw2="$(vvp build/sim.vvp)"; printf '%s\n' "$raw2"
printf '%s\n' "$raw2" | /usr/bin/env python3 -c '
import sys,json,re
r=re.compile(r"^RESULT\s+(\S+)\s+(PASS|FAIL)(.*)$"); t=[]
for line in sys.stdin:
    m=r.match(line.strip())
    if not m: continue
    n,o,e=m.groups(); t.append({"name":n,"outcome":"pass" if o=="PASS" else "fail","detail":e.strip() or None})
rep={"schema_version":1,"suite":"alu_periph_regression","tests":t,"summary":{"total":len(t),"passed":sum(x["outcome"]=="pass" for x in t),"failed":sum(x["outcome"]=="fail" for x in t)}}
json.dump(rep,open("fixtures/results.json","w"),indent=2); open("fixtures/results.json","a").write("\n")
print("results.json: %d/%d passed"%(rep["summary"]["passed"],rep["summary"]["total"]))
'
command -v vcd2fst >/dev/null 2>&1 && vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null || true
echo "Built netlist.json + lint.json + results.json + reference.vcd"
