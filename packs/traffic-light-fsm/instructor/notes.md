# traffic-light-fsm — instructor notes

## Learning objectives recap

1. Identify FSM states from a multi-bit `state` signal.
2. Apply a GTKWave-compatible translate filter so a state signal
   renders as named labels.
3. Open the FSM Visualizer and observe state transitions.
4. Place named markers and read inter-marker deltas.

## Timing summary

| Time (ns) | State | Notes |
|---|---|---|
| 0 – 320   | RED    | 22 ns reset hold + 30 cycles in RED |
| 320 – 620 | GREEN  | 30 cycles |
| 620 – 920 | YELLOW | 30 cycles |
| 920 – 1220 | RED    | second cycle |
| 1220 – 1520 | GREEN | |
| 1520 – 1820 | YELLOW | |
| 1820 – 2120 | RED | third cycle |
| 2120 – 2420 | GREEN | |
| 2420 – 2720 | YELLOW | |
| 2720 – 3000 | RED | partial fourth cycle |

So the three R → G transitions students mark in Exercise 1 are at
t = 320, t = 1220, and t = 2120 ns. The period is 900 ns = 90 clock
cycles.

The full machine-checkable contract is in
[`../fixtures/expected.json`](../fixtures/expected.json).

## Exercise answers

**Exercise 1.** Delta `a → b` = 900 ns; delta `b → c` = 900 ns; period
= 900 ns = 90 cycles. Accept ±1 cycle as a marker-placement tolerance.

**Exercise 2.** *Neither binary, nor Gray, nor one-hot.* It is a
**binary encoding** restricted to three values (00, 01, 10) — the
fourth code (11) is unused. RED → GREEN flips one bit; GREEN → YELLOW
flips two bits; YELLOW → RED flips two bits. A Gray code would flip
exactly one bit on *every* transition. One-hot would use one register
bit per state (so three bits, not two). Common wrong answers:

- "It's Gray code." — Half-credit if the student notes the RED → GREEN
  transition does flip only one bit but does not check the other two.
- "It's one-hot." — Zero credit; one-hot needs N bits for N states.
- "It's binary." — Full credit; the student saw the contiguous binary
  values 00, 01, 10.

**Exercise 3.** *Back to RED.* The reset is asynchronous (`negedge
rst_n` in the sensitivity list), so the moment `rst_n` goes low the
register forces `state <= RED` and `dwell <= 0`. One cycle after
`rst_n` returns high, `state` is still RED (because dwell is 0 — not
near 29 — so the FSM has not transitioned out of RED yet). Students
who answer just "RED" with reference to the async reset receive full
credit.

## Common student mistakes

- **Pressing E on the wrong signal.** If the student focuses `clk`
  instead of `state`, E will step through every clock edge — 270 of
  them in 3 µs. Always re-focus `state` before navigating.
- **Misinterpreting the dwell counter.** Some students will look at
  `dwell` and conclude the FSM "transitions every 29 cycles" because
  the equality test is `dwell == 29`. The actual cycle count is 30:
  dwell goes 0, 1, 2, …, 29 (that is 30 values), and the transition
  fires at the posedge after dwell reaches 29.
- **Missing the second/third R → G in Exercise 1.** Students who
  press **E** too many times will land on a YELLOW → RED transition
  instead. Coach them to read the value column after each E press.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Translate filter visibly applied (state renders as RED/GREEN/YELLOW) | 2 |
| FSM Visualizer open with a non-RED state highlighted | 2 |
| Three R → G markers in the right places (±1 cycle) | 2 |
| Correct period in Exercise 1 (900 ns, 90 cycles) | 1 |
| Correct encoding identification in Exercise 2 | 1 |
| Correct reset-behavior answer in Exercise 3 | 2 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/traffic-light-fsm
./build.sh
```
