#!/usr/bin/env python3
"""Generate each pack's fixtures/reference.wavecrux from its placeholder spec.

Every pack shipped a `_TODO` stub listing the signals, formats and cursor the
session should contain. This turns those specs into real WaveCrux session files
(schema version 3) without needing the GUI.

The important correctness rule: a session row is identified by `path`, and on
load WaveCrux re-resolves `path` to a backend handle. A path that does not exist
in the waveform is **silently dropped** — no error, the row just vanishes. So
every path is checked against the pack's own reference.vcd before it is written.

Run from the repo root:  python3 tools/generate-sessions.py [--check]
  --check   validate and report without writing (used by CI)
"""
import json, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCHEMA_VERSION = 3

# display_format.dart enum names. Anything else silently degrades to
# hexadecimal on load, so an unknown value here is a hard error instead.
VALID_FORMATS = {
    "binary", "hexadecimal", "octal", "unsignedDecimal", "signedDecimal",
    "ascii", "ieee754Single", "ieee754Double", "fixedPointQ",
    "signedMagnitude", "grayCode", "namedEnum",
}


def vcd_paths(vcd: pathlib.Path) -> set[str]:
    """Every hierarchical signal path declared in a VCD's header.

    Walks $scope/$upscope to rebuild full dotted paths, matching how the
    waveform backend reports Variable.fullPath. Vector suffixes (`[7:0]`) are
    stripped: the session refers to the signal, not the slice.
    """
    paths, stack = set(), []
    for line in vcd.read_text(errors="replace").splitlines():
        line = line.strip()
        if line.startswith("$scope"):
            parts = line.split()
            if len(parts) >= 3:
                stack.append(parts[2])
        elif line.startswith("$upscope"):
            if stack:
                stack.pop()
        elif line.startswith("$var"):
            # $var wire 8 # count [7:0] $end
            parts = line.split()
            if len(parts) >= 5:
                name = parts[4]
                # Escaped identifier (`\regs[1]`): the backslash is a VCD
                # delimiter, not part of the signal name.
                if name.startswith("\\"):
                    name = name[1:]
                paths.add(".".join(stack + [name]))
        elif line.startswith("$enddefinitions"):
            break
    return paths


def build_session(spec: dict, vcd_name: str, present: set[str]) -> tuple[dict, list[str]]:
    fmt_by_signal = {
        e["signal"]: e["format"]
        for e in spec.get("_required_format_settings", [])
        if isinstance(e, dict) and "signal" in e and "format" in e
    }

    problems, rows = [], []
    for path in spec.get("_required_signals", []):
        if path not in present:
            problems.append(f"path not in VCD, row would be dropped: {path}")
            continue
        fmt = fmt_by_signal.get(path)
        if fmt is None:
            # Single-bit control lines read better as binary; buses default to
            # hex, matching what the placeholders specify explicitly elsewhere.
            leaf = path.rsplit(".", 1)[-1]
            fmt = "binary" if re.fullmatch(
                r"(clk|clock|rst|rst_n|reset|reset_n|en|enable|valid|ready|"
                r"ack|req|start|done|busy|error|overflow|tx|rx|sclk|cs_n|"
                r"mosi|miso|we|re|stb|cyc)", leaf) else "hexadecimal"
        if fmt not in VALID_FORMATS:
            problems.append(f"unknown display format {fmt!r} for {path}")
            continue
        rows.append({
            "kind": "signal",
            # `ref` is a volatile backend handle, overwritten from `path` on
            # load. Empty is correct for a file written outside the app.
            "ref": "",
            "path": path,
            "name": path.rsplit(".", 1)[-1],
            "format": fmt,
            "height": 30.0,
        })

    session = {
        "version": SCHEMA_VERSION,
        # Relative — resolved against the .wavecrux file's own directory, so the
        # pack stays portable no matter where a professor unzips it.
        "sourceFilePath": vcd_name,
        "signals": rows,
        "cursor": {"primary": spec.get("_initial_cursor_time_ns"), "secondary": None},
        "markers": {},
        "view": {"ticksPerPixel": 1.0, "panOffsetTicks": 0.0, "scrollOffset": 0.0},
        "panels": {
            "signalTree": True, "valueColumn": True, "transactionView": False,
            "stageView": bool(spec.get("_required_stage_panels")),
            "statisticsStrip": False, "cocotbLogPanel": False, "rtlSource": False,
        },
        "translateFilters": {},
        "stage": {"panels": []},
        "activeTheme": "wavecrux-dark",
    }
    return session, problems


def main() -> int:
    check_only = "--check" in sys.argv
    packs = sorted((ROOT / "packs").iterdir())
    total_problems, written, skipped = 0, 0, 0

    for pack in packs:
        if not pack.is_dir():
            continue
        sess = pack / "fixtures" / "reference.wavecrux"
        vcd = pack / "fixtures" / "reference.vcd"
        if not sess.exists() or not vcd.exists():
            continue

        spec = json.loads(sess.read_text())
        if "_TODO" not in spec:
            print(f"  {pack.name:28s} already generated, skipped")
            skipped += 1
            continue

        present = vcd_paths(vcd)
        session, problems = build_session(spec, vcd.name, present)

        note = ""
        # Flag capabilities the placeholder asked for that a hand-written file
        # cannot honestly provide — see the caveat in the module docstring.
        if spec.get("_required_translate_filters"):
            note = " (translate filters need the GUI — see README)"
        if spec.get("_required_decoder_bindings"):
            note += " (decoder bindings need the GUI)"

        status = "OK " if not problems else "WARN"
        print(f"  {status} {pack.name:28s} {len(session['signals'])}/"
              f"{len(spec.get('_required_signals', []))} signals"
              f"  cursor={session['cursor']['primary']}{note}")
        for p in problems:
            print(f"       ! {p}")
        total_problems += len(problems)

        if not check_only:
            sess.write_text(json.dumps(session, indent=2) + "\n")
            written += 1

    print(f"\n  {written} written, {skipped} skipped, {total_problems} problem(s)")
    return 1 if total_problems else 0


if __name__ == "__main__":
    sys.exit(main())
