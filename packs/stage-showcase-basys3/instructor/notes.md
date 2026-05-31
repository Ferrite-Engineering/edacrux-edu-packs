# stage-showcase-basys3 — instructor notes

## Learning objectives recap

1. Open the WaveCrux Stage panel and insert a board widget.
2. Bind design signals to widget pins.
3. Scrub the cursor and observe synchronized animation.
4. Recognize Stage as *complementary* to (not a replacement for) the
   waveform view.

## Stimulus timeline

| Time (ns) | sw  | Press | count | What the Stage shows |
|---|---|---|---|---|
| 22  | 0x0 | —          | 0 | reset just released; nothing lit; digit "0" |
| 100 | 0x5 | —          | 0 | LED0, LED2 lit; digit "0" |
| 300 | 0x5 | btn[0]     | 1 | digit changes to "1" |
| 600 | 0x5 | btn[1]     | 2 | digit changes to "2" |
| 900 | 0xA | btn[2]     | 3 | LED1, LED3 lit (LED0/LED2 off); digit "3" |
| 1200 | 0xA | btn[3]    | 4 | digit "4" |
| 1500 | 0xA | btn[0]    | 5 | digit "5" |
| 2000 | 0xF | —         | 5 | all four LEDs lit |
| 2490 | 0xF | btn[0]    | 6 | digit "6" |
| 3000 | —   | —         | 6 | finish |

Note the last button press lands at t = 2490, not t = 2500 — the
inter-press intervals in the testbench compound a 10 ns offset
because each `press()` call holds for 10 ns. This is intentional and
documented in `fixtures/expected.json` (the final checkpoint is at
t = 2700, well after the count = 6 transition).

## Exercise answers

**Exercise 1.** The 7-segment first displays `3` at t = 900 ns (the
moment of the third button press).

**Exercise 2.** For digit `4`, `seg = 7'b0011001`. Reading the active-
*low* bits (those with value 0): bit 6 (`g`) = 0, bit 5 (`f`) = 0,
bit 2 (`c`) = 0, bit 1 (`b`) = 0. So segments **b, c, f, g** are lit.
That is the canonical "4" shape on a 7-segment display.

**Exercise 3.** Many possible answers. Good ones include:
- "Detecting glitches" — Stage shows steady state; the waveform shows
  the transient glitch.
- "Measuring timing" — Stage has no time axis displayed; the waveform
  has the time ruler.
- "Counting transitions" — only the waveform view has Q/E navigation
  and switching-activity panels.
- "Debugging metastability" — Stage interpolates between samples;
  the waveform shows the exact transition window.

Accept any answer that articulates "waveform = timing-axis is
explicit; Stage = signal-meaning is explicit."

## Common student mistakes

- **Binding inverted signals.** The Basys 3 7-segment is active-low,
  but the educational board widget knows that and inverts internally.
  Students who try to "fix" this by inverting the binding themselves
  end up with the wrong digit displayed. Coach: trust the widget;
  bind raw `seg[i]` to `seg[i]`.
- **Expecting the digit to scroll across all four anodes.** This
  design drives only the rightmost digit (`an = 4'b1110`). The other
  three anodes are inactive. A real Basys 3 design would
  time-multiplex all four digits; here we deliberately keep it
  simple.
- **Confusing the Stage panel with the FSM Visualizer.** Both are
  visualization panels but they serve different purposes. Stage is
  for physical I/O; FSM Visualizer is for abstract state machines.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Stage panel open with Basys 3 widget inserted | 2 |
| All LED / SW / BTN / SEG / AN bindings correct | 3 |
| Screenshot at t = 2700 with all LEDs + digit "6" | 2 |
| Exercise 1: t = 900 ns | 1 |
| Exercise 2: segments b, c, f, g lit | 1 |
| Exercise 3: coherent waveform-vs-stage distinction | 1 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/stage-showcase-basys3
./build.sh
```
