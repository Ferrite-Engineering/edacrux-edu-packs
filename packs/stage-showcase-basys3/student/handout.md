# stage-showcase-basys3 — student handout

The WaveCrux **Stage** panel is an animated, signal-bound visualization
surface. Where the waveform view shows you raw signal traces over
time, the Stage shows you what the signals *mean* in their physical
context — for FPGA boards, that means LEDs lighting up, switches
flipping, and 7-segment digits changing as you scrub the cursor.

This lab's design is a minimal Basys 3 demo:

- 4 switches (`sw[3:0]`) feed directly to 4 LEDs (`led[3:0]`).
- 4 push buttons (`btn[3:0]`) increment a 4-bit counter on any rising
  edge.
- The counter value drives a single 7-segment digit (active-low
  segment encoding, active-low anode select for the rightmost digit).

You'll learn the Stage panel by binding the design's I/O to the
educational Basys 3 board widget that ships with WaveCrux Open Core.

## Setup

1. Launch WaveCrux, **File → Open…** select `fixtures/reference.vcd`.
2. The default lane panel shows your signals. Add `sw`, `btn`, `led`,
   `count`, `seg`, and `an` if not already present.

## Part 1 — open the Stage panel

1. Press **F4** (or **View → Stage**) to open the Stage panel.
2. Click **➕ Insert Widget** at the top of the Stage panel.
3. From the widget catalog, choose **Educational Boards → Digilent
   Basys 3**.
4. The widget appears on the Stage canvas with a stylized rendering
   of the board's switches, LEDs, buttons, and 7-segment display.
   None of them are yet wired to your design.

## Part 2 — bind I/O

WaveCrux's Stage binding dialog lets you map design signals to board
pins one at a time. The pre-saved binding file
[`../stage/basys3_layout.json`](../stage/basys3_layout.json) has the
complete map; if your instructor has loaded the saved session it is
applied automatically. Otherwise:

1. Right-click the Basys 3 widget and choose **Bind Signals…**.
2. For each board pin, click the pin and select the matching design
   signal from the dropdown:
   - `LED[3:0]` ← `tb_basys3.dut.led`
   - `SW[3:0]`  ← `tb_basys3.dut.sw`
   - `BTN[3:0]` ← `tb_basys3.dut.btn`
   - `SEG[a..g]` ← `tb_basys3.dut.seg[0..6]`
   - `AN[3:0]`  ← `tb_basys3.dut.an`

## Part 3 — scrub and observe

1. Press **Home** to return the cursor to t = 0.
2. Click on the waveform canvas and drag the cursor slowly to the
   right.
3. As the cursor moves past t = 100 ns, the Basys 3 widget's SW0 and
   SW2 flip to ON, and LED0 and LED2 light up in red.
4. Continue scrubbing past t = 300 ns. BTN0 flashes briefly, and the
   7-segment digit changes from "0" to "1".
5. Continue. The cursor drives the entire ~3 µs simulation
   animation:
   - t = 500 ns: digit reads "1"
   - t = 900 ns: SW1 and SW3 flip on as well; digit reads "3"
   - t = 1200 ns: digit reads "4"
   - t = 1500 ns: digit reads "5"
   - t = 2700 ns: all four switches lit; digit reads "6"

## Part 4 — exercises

### Exercise 1 — find a specific digit display

> **Q:** At what cursor time does the 7-segment first display the
> digit `3`? *(Hint: focus the `count` lane, press **E** until it
> reads 3.)*
>
> ___________________________________________________________________

### Exercise 2 — active-low segments

The Basys 3 7-segment display is **active-low**: a segment lights
when its bit is `0`. Look at the `seg` lane when `count = 4`.

> **Q:** Which segments are lit for the digit `4`? Hint: `seg` is
> ordered seg[6]=g, seg[5]=f, seg[4]=e, seg[3]=d, seg[2]=c, seg[1]=b,
> seg[0]=a. Read out which segments have `seg[i] = 0`.
>
> ___________________________________________________________________

### Exercise 3 — when does the waveform view help more than Stage?

The Stage panel shows physical-world animation. The waveform panel
shows signal timing.

> **Q:** Give one example where the *waveform* view is the better
> debugging surface — i.e. a question that Stage cannot help you
> answer.
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The Stage panel with the Basys 3 widget bound and rendering
  correctly at cursor t = 2700 ns (all four LEDs lit, digit "6"
  displayed).
- The waveform panel with `count` and `seg` visible.

Plus answers to Exercises 1, 2, 3.
