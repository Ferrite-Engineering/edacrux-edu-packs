#!/usr/bin/env bash
# Lint the FIFO with Verilator and normalise its output into fixtures/lint.json
# — the unified report shape LintCrux presents after aggregating an engine.
#
# Verilator has no native machine-readable lint format, so we parse its text
# output. The point of committing the normalised JSON (rather than raw text) is
# that it is the artifact the lab and the verifier both read, exactly as a
# LintCrux report would be.
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PACK_DIR"
mkdir -p fixtures

# --lint-only never exits 0 when it finds warnings; capture and continue.
raw="$(verilator --lint-only -Wall src/sync_fifo.v 2>&1 || true)"

printf '%s\n' "$raw" | /usr/bin/env python3 -c '
import sys, json, re

line_re = re.compile(r"^%(Warning|Error)-([A-Z0-9_]+):\s+([^:]+):(\d+):(\d+):\s+(.*)$")
sym_re  = re.compile(r"[\x27\x22]([A-Za-z_][A-Za-z0-9_]*)[\x27\x22]")   # a quoted identifier

# Only these rules name a signal in their message; for others the quoted token
# is often part of a sized literal (e.g. 3\x27h2), so extracting it is noise.
SIGNAL_RULES = {"UNUSEDSIGNAL", "UNDRIVEN", "UNOPTFLAT", "UNUSEDPARAM", "UNDRIVENSIGNAL"}

viols = []
for line in sys.stdin:
    m = line_re.match(line.rstrip("\n"))
    if not m:
        continue
    kind, rule, f, ln, col, msg = m.groups()
    symbol = None
    if rule in SIGNAL_RULES:
        # the signal is the LAST quoted identifier in the message
        found = sym_re.findall(msg)
        symbol = found[-1] if found else None
    viols.append({
        "rule": rule,
        "severity": "error" if kind == "Error" else "warning",
        "file": f.split("/")[-1],
        "line": int(ln),
        "symbol": symbol,
        "message": msg.strip(),
    })

# Stable ordering so the committed fixture is reproducible run-to-run.
viols.sort(key=lambda v: (v["file"], v["line"], v["rule"], v["symbol"] or ""))
report = {"schema_version": 1, "engine": "verilator", "violations": viols}
json.dump(report, open("fixtures/lint.json", "w"), indent=2)
open("fixtures/lint.json", "a").write("\n")
print(f"Built fixtures/lint.json ({len(viols)} violations)")
'
