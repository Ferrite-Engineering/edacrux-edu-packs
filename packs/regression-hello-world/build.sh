#!/usr/bin/env bash
# Run the ALU regression with Icarus and normalise the results into
# fixtures/results.json — the per-test outcome list a SimCrux dashboard shows.
# The testbench prints "RESULT <name> <PASS|FAIL> ..."; we parse those.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build

iverilog -g2012 -o build/sim.vvp tb/tb_alu.v src/alu4.v
raw="$(vvp build/sim.vvp)"
printf '%s\n' "$raw"

printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys, json, re
res = re.compile(r"^RESULT\s+(\S+)\s+(PASS|FAIL)(.*)$")
tests = []
for line in sys.stdin:
    m = res.match(line.strip())
    if not m:
        continue
    name, outcome, extra = m.groups()
    tests.append({"name": name,
                  "outcome": "pass" if outcome == "PASS" else "fail",
                  "detail": extra.strip() or None})
report = {
    "schema_version": 1,
    "suite": "alu4_regression",
    "tests": tests,
    "summary": {"total": len(tests),
                "passed": sum(t["outcome"] == "pass" for t in tests),
                "failed": sum(t["outcome"] == "fail" for t in tests)},
}
json.dump(report, open("fixtures/results.json", "w"), indent=2)
open("fixtures/results.json", "a").write("\n")
s = report["summary"]
print("Built fixtures/results.json (%d/%d passed)" % (s["passed"], s["total"]))
'
