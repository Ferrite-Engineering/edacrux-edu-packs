# counter-lab — student handout

In this lab you will inspect the waveform of an 8-bit synchronous
counter to learn the cursor, value column, and transition-navigation
fundamentals of WaveCrux.

The design under test is in [`../src/counter.v`](../src/counter.v). It is
an 8-bit up-counter with active-low reset, clock enable, and an overflow
strobe that pulses high for one cycle each time the counter is parked at
`0xFF` (i.e. about to wrap to zero). The clock is 100 MHz (10 ns
period).

## Setup

1. Launch WaveCrux.
2. **File → Open Session…** and select `fixtures/reference.wavecrux`.
   Your instructor may have replaced the placeholder with a saved
   session; if so, the signals will already be loaded and the cursor
   will be sitting near the reset release. Otherwise, **File → Open…**
   and select `fixtures/reference.vcd` directly, then expand the signal
   tree on the left and add `clk`, `rst_n`, `enable`, `count`, and
   `overflow` to the lane panel by double-clicking or by drag-and-drop.

## Part 1 — read the cursor

1. Click anywhere on the waveform canvas to place the primary cursor.
2. The value column on the right shows what each signal reads at the
   cursor time. Move the cursor to **t = 10 ns**: confirm `count = 00`,
   `overflow = 0`, and `rst_n = 0`. The counter is held in reset.
3. Move the cursor to **t = 25 ns**: reset has just released (at t=22),
   but the next posedge that will actually increment the counter
   doesn't fire until t=30. So `count` is still `0x00` here.
4. Move the cursor to **t = 35 ns**: the counter has now incremented
   once. Confirm `count = 01`.

## Part 2 — change display format

By default `count` displays in hexadecimal. Right-click (or long-press
on touch) the `count` row and switch the format to **Decimal**, then
**Binary**, then back to **Hexadecimal**.

> **Q:** When `count = 0x80`, what is its decimal value? What is its
> binary representation? *Answer in the box below.*
>
> ___________________________________________________________________

## Part 3 — navigate transitions

The keyboard shortcuts **Q** and **E** jump the primary cursor to the
*previous* and *next* transition of the currently-focused signal.

1. Click on the `count` row to focus it.
2. Press **E** repeatedly. The cursor lands on every count update — one
   click per 10 ns.
3. Click on the `overflow` row to focus it instead, then press **E**.
   This time the cursor jumps a much larger distance, because `overflow`
   only transitions twice in the whole simulation.

## Part 4 — exercises

### Exercise 1 — locate the rollover

The counter eventually rolls over from `0xFF` back to `0x00`. Find that
moment.

- Click on the `overflow` row, then press **Home** to return the cursor
  to t = 0.
- Press **E** until the cursor lands on the rising edge of `overflow`.
- Place a named marker by pressing **M** and naming it `rollover`.

> **Q:** At what time does `overflow` go high? At what time does it go
> low again? *(Both should be ±10 ns of clean values.)*
>
> ___________________________________________________________________

### Exercise 2 — count clock cycles

How many clock cycles elapse between reset release and the moment
`count` first reaches `0x80` (128 decimal)?

- Place marker `a` at the time `count` first equals `0x01`.
- Place marker `b` at the time `count` first equals `0x80`.
- The status bar shows the delta between markers. Divide by the clock
  period (10 ns) to get the cycle count.

> **A:** Cycles from `count = 1` to `count = 128`: __________

### Exercise 3 — explain the overflow design

Read [`../src/counter.v`](../src/counter.v). The `overflow` signal is
combinational:

```verilog
assign overflow = enable && (count == 8'hFF);
```

> **Q:** Why does `overflow` go *low* at t = 2580 ns even though `count`
> is still about to roll over at that moment? *(Hint: think about
> exactly when `count` updates.)*
>
> ___________________________________________________________________

## What to turn in

A screenshot of the WaveCrux window with the `rollover` marker placed
and the `a` / `b` markers from Exercise 2 visible in the marker strip.
Include your answers to Exercises 1, 2, and 3 in the body of your
submission.
