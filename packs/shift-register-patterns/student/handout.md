# shift-register-patterns: student handout

This lab contrasts two shift-register designs:

1. **An 8-bit shift register** fed by a known serial pattern
   (`10110100`, MSB first) one bit per 100 MHz clock cycle.
2. **A 5-bit maximum-length LFSR** with taps at bits 5 and 3
   (polynomial x⁵ + x³ + 1), period 31.

Both are clocked from the same 100 MHz clock and released from a 22 ns
reset. You will learn to count transitions over a window, estimate
frequency from a cursor delta, and recognize an LFSR's period.

## Setup

1. Launch WaveCrux and choose **File → Open File…** (**Cmd+O** on
   macOS, **Ctrl+O** elsewhere). Select `fixtures/reference.wavecrux`.
   (If the lanes are missing, open `fixtures/reference.vcd` and add
   `clk`, `sin`, `u_shift.q`, `u_shift.sout`, and `u_lfsr.state` to the
   lane panel.)

## Part 1: deterministic shift

1. Move the cursor to **t = 35 ns**. The first pattern bit (`1`) has
   shifted into `q[0]`; `q = 0x01`.
2. Press **E** with `u_shift.q` focused. Step through:
   - t = 45 → `q = 0x02` (binary `00000010`: the `1` migrated to
     bit 1, and a `0` shifted into bit 0).
   - t = 55 → `q = 0x05`.
   - t = 65 → `q = 0x0B` (four bits in: `1011`).
   - t = 105 → `q = 0xB4` (full pattern `10110100` loaded).

> **Q:** How long, in clock cycles, does it take for `q[0]` to reach
> `q[7]`? *(Use the cursor delta from `q = 0x01` to when `sout`
> first goes high.)*
>
> ___________________________________________________________________

## Part 2: switching activity

WaveCrux counts the *transitions* of every signal in the lane panel
over the time range you are looking at.

1. Zoom and pan until the visible range runs from t = 30 ns to
   t = 1030 ns, as closely as you can. The analysis counts the
   transitions inside the visible range.
2. Choose **Tools → Analyze Switching Activity** (**Cmd+Shift+A** on
   macOS, **Ctrl+Shift+A** elsewhere). The **Activity** tab opens at
   the bottom, headed **Switching Activity**. Read the **Transitions**
   column on the `sout` row.

> **A:** Transition count on `sout` over [30, 1030] ns: ______

## Part 3: LFSR period

The LFSR is initialized to `5'b00001` on reset. Its state evolves on
every clock until it returns to `5'b00001` after a full period.

1. Focus the `u_lfsr.state` lane. Place marker `m` (press **M**, then
   **M**) at the first time `state = 5'b00001` after reset releases,
   this should be at t = 22 ns (still the reset value, since the next
   posedge has not fired yet).
2. Press **E** until `state` returns to `5'b00001`. Place marker `n`
   there (press **M**, then **N**).

> **A:** Marker delta `m → n` = ______ ns
>
> Period in clock cycles = ______
>
> Does this match the formula for a maximum-length LFSR of length n?
> (Hint: 2ⁿ − 1 for n = 5.) Yes / No

## Part 4: exercises

### Exercise 1: frequency estimation

The LFSR `state[0]` bit is pseudo-random. Focus it.

> **Q:** Roughly how often (in nanoseconds, averaged over the whole
> 3 µs trace) does `state[0]` toggle? Compare to the deterministic
> `sout` rate from Part 2.
>
> ___________________________________________________________________

### Exercise 2: predict q[5] at t = 75 ns

Without looking at the value column:

> **Q:** What is `q[5]` at t = 75 ns? Verify by adding `q[5]` to the
> lane panel (drag from the signal tree).

### Exercise 3: what changes if we start LFSR with 5'b00000?

The 5-bit LFSR has 32 possible states but visits only 31. Read
[`../src/lfsr5.v`](../src/lfsr5.v).

> **Q:** Which state is *not* visited, and why? What would happen if
> the LFSR ever reached that state?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing both designs side-by-side with markers `m` and
`n` on the LFSR period. Plus your answers to Parts 1, 2, 3, and the
three exercises.
