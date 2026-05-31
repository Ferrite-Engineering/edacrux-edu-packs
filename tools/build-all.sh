#!/usr/bin/env bash
# Regenerate fixtures for every pack in this catalog.
#
# Each pack's `build.sh` is responsible for producing
# `fixtures/reference.vcd` (and, when `vcd2fst` is available, a sibling
# `reference.fst`). This top-level script just iterates over the packs.
#
# Requirements: iverilog + vvp on PATH. vcd2fst is optional.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

shopt -s nullglob
for pack in "$ROOT"/packs/*/; do
    name="$(basename "$pack")"
    if [ -x "$pack/build.sh" ]; then
        echo "=== $name ==="
        if ! ( cd "$pack" && ./build.sh ); then
            echo "FAILED: $name" >&2
            FAIL=1
        fi
    elif [ -f "$pack/build.sh" ]; then
        echo "=== $name (non-executable build.sh, running with bash) ==="
        if ! ( cd "$pack" && bash build.sh ); then
            echo "FAILED: $name" >&2
            FAIL=1
        fi
    else
        echo "SKIP: $name (no build.sh)"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo
    echo "One or more packs failed to build." >&2
    exit 1
fi

echo
echo "All packs built."
