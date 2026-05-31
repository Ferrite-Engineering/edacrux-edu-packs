# counter-lab — instructor notes

## Learning objectives recap

After completing this lab a student should be able to:

1. Open a VCD file in WaveCrux and add signals to the lane panel.
2. Read signal values from the value column at a given cursor time.
3. Change display format per signal (hex / decimal / binary).
4. Use **Q** / **E** to step through transitions of the focused signal.
5. Place named markers and read inter-marker deltas from the status bar.
6. Reason about how a combinational signal (`overflow`) relates to the
   register it depends on (`count`).

The two hardest concepts in this lab — the only ones graders should be
prepared to coach on — are the cycle-vs-time distinction (Part 1, Step 3)
and the overflow strobe falling edge (Exercise 3).

## Timing summary

- Clock: 100 MHz, posedges at every multiple of 10 ns starting at t=10.
- Reset (`rst_n`) is held low from t=0 to t=22, released at t=22.
- Enable is asserted at t=22 alongside the reset release.
- The first posedge that increments the counter is t=30, so:
  - `count = 0x01` from t=30 to just before t=40
  - `count = 0x80` from t=1300 to just before t=1310
  - `count = 0xFF` from t=2570 to just before t=2580
  - `count = 0x00` from t=2580 (the rollover)
- The overflow strobe is high from t=2570 (when `count` reaches `0xFF`)
  to t=2580 (when `count` resets to `0x00`).

The full machine-checkable contract is in
[`../fixtures/expected.json`](../fixtures/expected.json).

## Common student mistakes

### "Why is count still 0 at t=25 if reset released at t=22?"

This is the most common conceptual hiccup. The cursor at t=25 sits
between two clock posedges (t=20 and t=30). The posedge at t=20 still
saw `rst_n = 0` (released at t=22). The very next posedge — at t=30 —
is the first to see `rst_n = 1` with `enable = 1`, and *that* is the
posedge that drives `count` to `0x01`.

Coach students to think about register updates as happening only on
clock edges, not continuously. The value column showing `0x00`
between t=22 and t=30 is the correct, expected behavior.

### "Why does overflow go low at t=2580 if the counter rolls over there?"

`overflow` is combinational: `enable && (count == 8'hFF)`. The instant
`count` transitions to `0x00` (at the t=2580 posedge), the equality
test fails and `overflow` returns to 0. So `overflow = 1` for exactly
the cycle during which `count = 0xFF`, and falls *with* the rollover,
not *after* it. This is the intended pedagogical hook for Exercise 3.

A common wrong answer is "overflow goes high *after* the rollover."
Push back: the strobe goes high one cycle *before* the rollover,
during the `0xFF` cycle.

### Off-by-one on cycle counts (Exercise 2)

Students will often answer **127** for cycles from `count = 1` to
`count = 128` (subtracting 1 from 128). The correct answer is **127
cycles**: from `count = 1` (at t=30) to `count = 128` (at t=1300), the
elapsed time is 1270 ns = 127 cycles at 10 ns each. So in this case
their off-by-one is actually correct — but ask them to justify the
arithmetic, not just write down a number.

## Exercise answers

**Exercise 1.** `overflow` rises at t = 2570 ns and falls at t = 2580 ns.

**Exercise 2.** 127 cycles (1270 ns / 10 ns per cycle).

**Exercise 3.** `overflow` is combinational on `count`. When the t=2580
posedge updates `count` from `0xFF` to `0x00`, the equality test
`count == 8'hFF` becomes false in the same simulation timestep, and
the combinational output `overflow` falls to 0. So the strobe goes
high *during* the `0xFF` cycle (the cycle *before* the rollover), and
falls coincident with the rollover edge.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Screenshot shows `rollover` marker at t ≈ 2570 ns | 2 |
| Markers `a` and `b` at `count = 1` and `count = 128` | 2 |
| Correct answer to Exercise 1 (both edges within ±10 ns) | 2 |
| Correct cycle count in Exercise 2 (127) | 2 |
| Coherent answer to Exercise 3 explaining combinational fall | 2 |
| **Total** | **10** |

## Re-running the build

If you need to regenerate `fixtures/reference.vcd` (for example after
modifying the design in `src/counter.v` for a custom homework
variant):

```bash
cd packs/counter-lab
./build.sh
```

Requirements: `iverilog` + `vvp` on `$PATH`. A sibling `reference.fst`
is produced automatically if GTKWave's `vcd2fst` is available.
