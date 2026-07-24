#!/usr/bin/env bash
# A WaveCrux + SimCrux pair. One testbench run produces BOTH fixtures: the VCD
# WaveCrux opens, and — parsed from the same run's RESULT lines — the SimCrux
# regression results. The point of the pair is that a failing test sends you to
# the waveform, so both must come from the identical run.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build

iverilog -g2012 -o build/sim.vvp tb/tb_uart.v src/uart_tx.v
raw="$(vvp build/sim.vvp)"
printf '%s\n' "$raw"

printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys, json, re
res = re.compile(r"^RESULT\s+(\S+)\s+(PASS|FAIL)(.*)$")
tests = []
for line in sys.stdin:
    m = res.match(line.strip())
    if not m: continue
    n, o, extra = m.groups()
    tests.append({"name": n, "outcome": "pass" if o=="PASS" else "fail",
                  "detail": extra.strip() or None})
rep = {"schema_version":1,"suite":"uart_tx_regression","tests":tests,
       "summary":{"total":len(tests),
                  "passed":sum(t["outcome"]=="pass" for t in tests),
                  "failed":sum(t["outcome"]=="fail" for t in tests)}}
json.dump(rep, open("fixtures/results.json","w"), indent=2)
open("fixtures/results.json","a").write("\n")
s=rep["summary"]; print("Built results.json (%d/%d passed)"%(s["passed"],s["total"]))
'
[ -f fixtures/reference.vcd ] || { echo "reference.vcd missing"; exit 1; }
command -v vcd2fst >/dev/null 2>&1 && vcd2fst fixtures/reference.vcd fixtures/reference.fst >/dev/null || true
echo "Built fixtures/reference.vcd + fixtures/results.json"
