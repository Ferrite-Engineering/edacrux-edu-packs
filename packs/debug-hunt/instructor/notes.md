# debug-hunt — instructor notes

## Learning objectives recap

1. Load two VCDs side-by-side as a comparison source.
2. Configure WaveCrux's waveform-diff feature and jump between
   differences.
3. Reason from a symptom in the waveform to a root cause in source.
4. Express the fix concisely as a one-line code change.

## The bug

`src/counter_buggy.v` line 22:

```verilog
else if (~enable)  count <= count + 8'd1;   // <-- BUG
```

The bitwise-not `~enable` should be plain `enable`. The buggy
counter increments when enable is *low* and freezes when enable is
*high* — the exact inverse of the intended behavior.

## Timing summary

Stimulus is identical in both VCDs:

- 100 MHz clock, posedges at multiples of 10 ns from t = 10.
- Reset (`rst_n`) held until t = 22; first valid posedge t = 30.
- enable schedule:
  - t = 22 → 200 ns: `enable = 1`
  - t = 200 → 300 ns: `enable = 0`
  - t = 300 → 500 ns: `enable = 1`

Resulting counts:

| Time | enable | golden `count` | buggy `count` |
|---|---|---|---|
| 30 | 1 | 0x01 | 0x00 |
| 100 | 1 | 0x08 | 0x00 |
| 195 | 1 | 0x11 | 0x00 |
| 205 | 0 | 0x11 (held) | 0x01 |
| 250 | 0 | 0x11 (held) | 0x06 |
| 295 | 0 | 0x11 (held) | 0x0A |
| 350 | 1 | 0x16 | 0x0A (held) |
| 495 | 1 | 0x24 | 0x0A (held) |

The full machine-checkable contract for the *buggy* VCD (which is
also copied to `reference.vcd`) is in
[`../fixtures/expected.json`](../fixtures/expected.json).

## Exercise answers

**Part 1 — first divergence.** At t = 30 ns: buggy = 0x00, golden =
0x01. The golden counter incremented on the first valid posedge with
`enable = 1`; the buggy one did not.

**Part 2 — when the buggy counter increments.** The buggy counter
increments when `enable = 0` (between t = 200 and t = 300). Outside
that window it stays put.

**Part 3 — the fix.** Change `~enable` to `enable`. Corrected line:

```verilog
else if (enable)  count <= count + 8'd1;
```

**Exercise 1.** Yes, the two waveforms are momentarily equal: both
hold `count = 0x00` from t = 0 to t = 22 ns (during reset). They are
*never* equal again after the simulation begins.

**Exercise 2.** X-trace from `count` should surface (in order of
distance from the symptom): the right-hand-side of the assignment
(`count + 1`), the `enable` predicate, the `~enable` bitwise-not gate,
and finally the `enable` input port. The bitwise-not is the suspect —
this should be the "aha" moment.

**Exercise 3.** The cognitive trap is that `~enable` *reads correctly
in English*: "not enable." A code reviewer scanning the file for
patterns rather than logic might accept "else if (not enable) then
increment" without noticing it's the *inverse* of what makes sense
for an enable-gated counter. The lesson: the natural-language
reading of code can be misleading.

## Common student mistakes

- **Not loading both VCDs at once.** Without the comparison, the
  buggy waveform looks plausible at a glance (count *does* go up,
  just at the wrong times). The diff view is what makes the bug
  obvious.
- **Misidentifying the root cause.** Some students will report
  "enable is wrong" or "the clock is wrong." Push back: the *bug*
  is on the increment-test line in `counter_buggy.v`, not in the
  testbench's `enable` schedule.
- **Confusing `~enable` with `!enable`.** Both are wrong here, but
  for an EDU pack they are functionally equivalent (single-bit
  bitwise-not = single-bit logical-not). Accept either correction
  to `enable`.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Both VCDs loaded with diff configured | 2 |
| First divergence located at t = 30, ±10 ns | 2 |
| Part 2: correct identification ("buggy increments when enable=0") | 2 |
| Part 3: corrected line is `else if (enable) count <= count + 1` | 3 |
| Exercise 3: coherent cognitive-trap discussion | 1 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/debug-hunt
./build.sh
```

The script produces three VCDs:
- `fixtures/golden.vcd` — reference correct counter
- `fixtures/buggy.vcd`  — counter under debug
- `fixtures/reference.vcd` — a copy of `buggy.vcd` so the standard
  `reference.vcd` discovery path picks up the buggy version

## Cross-tool upgrade (WaveCrux + NetCrux)

This pack is now a pair. The WaveCrux half is unchanged: find the off-by-one from
the golden/buggy waveform diff. The NetCrux half closes the loop — the bug
(`~enable`) shows in the structure as an inversion on the register's enable, so
students go from "which signal is wrong" (waveform) to "why" (structure).

The NetCrux structural facts are machine-verified against the synthesised netlist
(the enabled register and the increment adder are present). The cross-probe
*deep-link* itself — clicking `count` in WaveCrux and landing on its driver in
NetCrux — is declared but not machine-verified; verifying a live cross-probe
needs both apps driven under automation, which the suite does not yet expose. In
this pack the jump is made by hand, and the structure it lands on is real.
