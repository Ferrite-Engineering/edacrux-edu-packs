#!/usr/bin/env bash
# Run the saturating-adder regression across a fixed seed set and classify each
# test. A test that passes on some seeds and fails on others is FLAKY — the exact
# thing this pack is about. iverilog's $random follows the Verilog LRM, so the
# per-seed outcomes are deterministic and identical on any compliant simulator.
#
# All parsing is in Python (no sed): BSD sed on macOS and GNU sed on the CI
# runner disagree on \| alternation and \t, and this must build identically on
# both.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures build

iverilog -g2012 -o build/sim.vvp tb/tb_sat.v src/sat_add.v

: > build/runs.txt
for s in 1 2 3 4 5 6 7 8; do
  # Prefix each line with its seed so Python can attribute outcomes.
  vvp build/sim.vvp +seed="$s" 2>/dev/null | while IFS= read -r line; do
    printf 'SEED %s %s\n' "$s" "$line"
  done >> build/runs.txt
done

/usr/bin/env python3 - <<'PY'
import json, re, collections
line_re = re.compile(r"^SEED (\d+) RESULT (\S+) (PASS|FAIL)")
passed = collections.defaultdict(list)
failed = collections.defaultdict(list)
order, seeds = [], set()
for line in open("build/runs.txt"):
    m = line_re.match(line)
    if not m:
        continue
    s, name, res = int(m.group(1)), m.group(2), m.group(3)
    seeds.add(s)
    if name not in order:
        order.append(name)
    (passed if res == "PASS" else failed)[name].append(s)

tests = []
for name in order:
    p, f = sorted(passed[name]), sorted(failed[name])
    outcome = "pass" if not f else "fail" if not p else "flaky"
    tests.append({"name": name, "outcome": outcome, "pass_seeds": p, "fail_seeds": f})

report = {"schema_version": 1, "suite": "sat_add_regression",
          "seeds": sorted(seeds), "tests": tests,
          "summary": {"total": len(tests),
                      "flaky": sum(t["outcome"] == "flaky" for t in tests)}}
json.dump(report, open("fixtures/results.json", "w"), indent=2)
open("fixtures/results.json", "a").write("\n")
for t in tests:
    print(f"  {t['name']:20s} {t['outcome']:6s} pass={t['pass_seeds']} fail={t['fail_seeds']}")
print(f"Built fixtures/results.json ({report['summary']['flaky']} flaky of {len(tests)})")
PY
