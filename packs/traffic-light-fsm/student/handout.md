# traffic-light-fsm — student handout

A traffic light cycles through three states — **RED → GREEN → YELLOW
→ RED → …** — spending 30 clock cycles in each state. At 100 MHz that
is 300 ns per state and 900 ns per full RED-GREEN-YELLOW period.

The design lives in [`../src/traffic_light.v`](../src/traffic_light.v).
It uses an asynchronous active-low reset and a 5-bit dwell counter
that fires the state transition on the cycle dwell reaches 29.

## Setup

1. Launch WaveCrux.
2. **File → Open Session…** select `fixtures/reference.wavecrux`. (If
   it is still the placeholder, open `fixtures/reference.vcd`, add
   `clk`, `rst_n`, `state`, `red_light`, `green_light`, and
   `yellow_light` to the lane panel.)

## Part 1 — observe the raw state

Move the cursor to **t = 25 ns** and confirm `state = 2'b00`,
`red_light = 1`, others 0. The FSM is in RED.

Press **E** (or click on the `state` row and press **E**) to step
forward to the first state transition. The cursor should land near
t = 320 ns where `state` changes to `2'b01` (GREEN).

> **Q:** What value does the value column show for `state` at t = 325 ns?
> What does it show at t = 625 ns? At t = 925 ns?
>
> ___________________________________________________________________

## Part 2 — apply a translate filter

Reading `0b00`, `0b01`, `0b10` from the value column gets old quickly.
WaveCrux supports GTKWave-compatible *translate filters* that map raw
signal values to friendly labels.

1. The filter file is [`translate/fsm_states.txt`](../translate/fsm_states.txt).
   Open it. It maps binary values to state names:

   ```
   00 RED
   01 GREEN
   10 YELLOW
   ```

2. Right-click (or long-press) the `state` row in the lane panel and
   choose **Apply Translate Filter…**.
3. Navigate to `translate/fsm_states.txt` and confirm.
4. The lane now shows `RED`, `GREEN`, `YELLOW` segments instead of
   `00`, `01`, `10`.

Move the cursor to t = 325 ns again. The value column now reads
`GREEN`. Much better.

## Part 3 — FSM Visualizer

WaveCrux can render an FSM-state graph from a translated state signal.

1. Right-click `state` and choose **Open in FSM Visualizer**.
2. A bottom panel opens showing a node-and-edge graph: three nodes
   (RED, GREEN, YELLOW), three edges (the cyclic transitions). The
   *active* node is highlighted at the current cursor position.
3. Scrub the cursor and watch the active-node highlight follow the
   FSM through its cycle. Take a moment to convince yourself that the
   graph matches the case statement in `traffic_light.v`.

## Part 4 — exercises

### Exercise 1 — measure the FSM period with markers

Three RED → GREEN transitions are visible in the 3 µs trace.

1. Click on the `state` row to focus it.
2. Press **Home** to return to t = 0.
3. Press **E** to jump to the *first* RED → GREEN transition. Press
   **M** and name the marker `a`.
4. Press **E** twice more (next is GREEN→YELLOW, then YELLOW→RED).
   You should now be at the start of the *second* RED state. Press
   **E** again to jump to the *second* RED → GREEN transition. Press
   **M** and name the marker `b`.
5. Continue to the *third* RED → GREEN transition and name it `c`.

> **A:** The cursor delta between `a` and `b` is _______ ns.
> The delta between `b` and `c` is _______ ns. The FSM period is
> _______ ns and the period in clock cycles is _______.

### Exercise 2 — encoding type

The states use values `2'b00`, `2'b01`, `2'b10`. Only one bit changes
per transition for RED → GREEN (bit 0) and for GREEN → YELLOW (bit 1
flips, bit 0 also flips). For YELLOW → RED both bits change.

> **Q:** Is this a binary, Gray, or one-hot encoding? Why?
>
> ___________________________________________________________________

### Exercise 3 — what would happen if reset is asserted mid-cycle?

(*Conceptual — no need to modify the testbench.*)

> **Q:** Suppose `rst_n` goes low for a single cycle while the FSM is
> in GREEN. What state will the FSM be in one cycle after `rst_n`
> returns high? Justify with a one-sentence reference to the design
> code.
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The lane panel with `state` displayed as named labels (RED / GREEN /
  YELLOW).
- The FSM Visualizer open at the bottom with a non-RED state
  highlighted.
- All three markers `a`, `b`, `c` in the marker strip.

Plus your answers to Exercises 1, 2, and 3.
