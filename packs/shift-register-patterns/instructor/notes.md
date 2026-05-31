# shift-register-patterns — instructor notes

## Learning objectives recap

1. Use Q/E to step transition-by-transition through a focused signal.
2. Read transition counts from the switching-activity panel.
3. Estimate signal frequency from a cursor delta.
4. Observe and measure an LFSR period.

## Stimulus and timing summary

- 100 MHz clock, reset held until t = 22 ns.
- The shift register receives the pattern `10110100` (MSB first) one
  bit per cycle starting at posedge t = 30. After the t = 100 ns
  posedge `q = 0xB4` and the pattern is fully loaded.
- The LFSR starts at `5'b00001` and completes one full 31-cycle
  period returning to `5'b00001` at t = 330 ns. The trace runs to
  3 µs, so roughly 9.5 LFSR periods are visible.

Key timestamps machine-verified by [`../fixtures/expected.json`](../fixtures/expected.json):

| Time (ns) | Signal | Value |
|---|---|---|
| 15 | `u_shift.q` | 8'h00 (still in reset) |
| 35 | `u_shift.q` | 8'h01 (first bit in) |
| 65 | `u_shift.q` | 8'h0B (four bits in) |
| 105 | `u_shift.q` | 8'hB4 (full pattern) |
| 25 | `u_lfsr.state` | 5'b00001 (seed) |
| 145 | `u_lfsr.state` | 5'b01111 (mid-cycle) |
| 335 | `u_lfsr.state` | 5'b00001 (period returns) |

## Exercise answers

**Part 1 question.** It takes **7 clock cycles** for the first `1` to
reach `q[7]`. The bit enters at `q[0]` at posedge t = 30, then shifts
into `q[1]` at t = 40, …, `q[7]` at t = 100. That is 70 ns total =
7 cycles.

**Part 2 question.** `sout` toggles 4 times over the 1 µs window:
once at t = 100 ns when the first `1` reaches `q[7]`, then on every
subsequent change of `q[7]`. The deterministic pattern keeps `sout` at
0 for most of the trace, so 4 transitions is correct (accept 2–5 as
plausible if students misread the markers).

**Part 3 question.** Marker delta is 310 ns. Period is 31 cycles.
**Yes**, it matches 2⁵ − 1 = 31.

**Exercise 1.** The LFSR `state[0]` toggles roughly half the time —
≈ 16 transitions per 31-cycle period, so an average inter-transition
gap of ~20 ns over the 3 µs trace. This is much faster than `sout`
(which is at 0 for most of the trace). The pseudo-random pattern has
much higher switching activity than the deterministic pattern.

**Exercise 2.** `q[5]` at t = 75 ns. At t = 75, the pattern bits 1, 0,
1, 1, 0 (the first 5 bits) have been shifted in:
- q[4] = 1 (bit 0 of pattern, first one in, now in position 4)
- q[5] = 0 (still uninitialized — only 5 bits in so far)

Actually let me redo this — at t = 75 ns, 5 posedges have fired
(at 30, 40, 50, 60, 70). The pattern bits shifted in are 1, 0, 1, 1,
0 (in that order). After 5 cycles, q's lower 5 bits hold `01101`
(reading bits 4..0). So q[5] = 0. The correct answer is **`q[5] = 0`**.

**Exercise 3.** State `5'b00000` is not visited. If `state = 0`,
`feedback = 0 ^ 0 = 0`, and the next state is also `5'b00000` — the
LFSR latches up at zero forever. This is why maximum-length LFSRs
have *N* − 1 = 31 unique states, not *N* = 32. The seed must be
non-zero.

## Common student mistakes

- **Confusing posedge time with q-update time.** Students may report
  `q = 0x01 at t = 30`, which is correct but is also the *moment* of
  the transition. The "value at the cursor" reading shows the
  post-edge value at exactly t = 30 = 0x01.
- **Reading bits in the wrong order.** When the shift register loads
  `10110100` MSB-first, students may verify by reading `q` left-to-
  right (MSB-first) and conclude correctly — but if they read the
  pattern as the *order in which bits arrived* they will get the
  reverse order. Both readings happen to coincide here because the
  pattern is symmetric in a specific way, but coach them on the
  shift direction.
- **Missing the LFSR latch-up.** A common Exercise 3 wrong answer is
  "state 5'b11111 is the unvisited state." It is actually visited
  (mid-cycle, at t = 145 ns). Coach: only `5'b00000` is excluded.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Part 1: cycle count answer (7) | 1 |
| Part 2: transition count answer (4 ± 1) | 1 |
| Part 3: period 310 ns, 31 cycles, formula match | 3 |
| Exercise 1: comparison of switching activity | 2 |
| Exercise 2: q[5] = 0 with justification | 1 |
| Exercise 3: 5'b00000 with latch-up reasoning | 2 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/shift-register-patterns
./build.sh
```
