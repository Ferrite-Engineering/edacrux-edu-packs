# cdc-soc-capstone

A **Tier-C capstone** across all four tools, on clock-domain crossing. A small
two-clock SoC has one crossing done right (a two-flop synchronizer) and one done
wrong (an unsynchronized multi-bit data bus). The design **passes simulation and
lint** — so the bug can only be found by analysing the structure and the waveform
by hand. That is the point.

- **Tools:** NetCrux + WaveCrux + SimCrux + LintCrux (Open Core)
- **Format:** term project (~2-4 weeks) · advanced
- **HDL:** Verilog

## Honest note on tooling

**The free open-source toolchain has no CDC engine.** Verilator's lint does not
flag clock-domain crossings, and this pack does not pretend otherwise — its
`lint.json` is genuinely empty of CDC findings, which is itself the lesson: a
clean lint run is not a clean CDC story. Automated CDC checking needs a dedicated
tool beyond the free baseline. Here the CDC analysis is a **manual deliverable**,
done by reading the structure (NetCrux) and the waveform (WaveCrux) — the way CDC
was found before automated checkers, and a skill worth having regardless.

## Build

```
./build.sh
```

Builds the baseline in each tool: netlist (NetCrux), lint report (LintCrux, no CDC
findings by design), a green regression on the *safe* path (SimCrux), and the
waveform (WaveCrux).

## What is verified

The structure (two domains and a two-flop synchronizer), the safe-path regression,
and the reset state are machine-verified against the real build. The CDC hazard
itself is **not** machine-verified — no free engine detects it — and neither is the
cross-tool deep-link. Both are stated plainly rather than implied.

## Using this in a course

Give students the `student/` brief via your LMS; the `instructor/` folder holds the
rubric and the full CDC analysis. Fork it to add domains or a second hazard.
