# debug-hunt: student handout

You are handed two VCDs from what should be the *same* design:

- **`fixtures/buggy.vcd`**: captured from a counter that
  someone wrote that *almost* works.
- **`fixtures/golden.vcd`**: captured from a known-good
  reference implementation of the same counter.

Stimulus is identical in both runs: 100 MHz clock, reset held until
t=22 ns, then `enable` is high for ~180 ns, then low for 100 ns, then
high again for the remainder of the 500 ns simulation.

**Your job:** find the bug in the buggy counter without looking at the
golden source. Propose a one-line fix.

⚠️ **Do NOT open [`../src/counter_golden.v`](../src/counter_golden.v)
or your instructor's solution before finishing.** You can read
[`../src/counter_buggy.v`](../src/counter_buggy.v) freely, that
*is* the design under debug.

## Setup

1. Launch WaveCrux.
2. Choose **File → Open File…** (**Cmd+O** on macOS, **Ctrl+O**
   elsewhere) and open `fixtures/buggy.vcd`. Add `count`, `enable` and
   `rst_n` to the lane panel.
3. Choose **Tools → Compare Waveforms** (**Cmd+Shift+C** on macOS,
   **Ctrl+Shift+C** elsewhere) and select `fixtures/golden.vcd`. This
   loads the golden trace as the comparison file, and the **Diff** tab
   opens in the left dock.
4. WaveCrux matches signals between the two by path, ignoring the
   testbench's root name. In the **Diff** tab, under **MATCHED
   SIGNALS**, confirm these pairs match:
   - `tb_counter_buggy.dut.count` ↔ `tb_counter_golden.dut.count`
   - `tb_counter_buggy.dut.enable` ↔ `tb_counter_golden.dut.enable`
   - `tb_counter_buggy.dut.rst_n` ↔ `tb_counter_golden.dut.rst_n`
5. The toolbar reads **Comparing: golden.vcd** and the regions where
   the two `count` traces disagree are highlighted.

## Part 1: locate the first divergence

1. Press **Home** then **F7** (**Tools → Next Divergence**).
2. The cursor lands on the first cycle where buggy `count` ≠ golden
   `count`. The toolbar reads **Divergence 1 of N**.

> **A:** First divergence at t = ____ ns. At that time:
>
> - buggy count = 0x__
> - golden count = 0x__

## Part 2: locate the second-most-suspicious moment

Press **F7** to step to the next divergence (**Shift+F7** steps back).
Repeat until you have observed at least three divergence regions.

> **Q:** Describe in plain language *when* the buggy counter
> increments. (Hint: focus the `enable` lane and the `count` lane in
> the buggy trace.)
>
> ___________________________________________________________________

## Part 3: propose a fix

Read [`../src/counter_buggy.v`](../src/counter_buggy.v).

> **Q:** What single character (or short token) is wrong? What is the
> correct value? Write the corrected line of code.
>
> Buggy line: ________________________________________________
>
> Corrected line: ________________________________________________

## Part 4: exercises

### Exercise 1: what makes the buggy counter look so similar?

Cross-correlate the buggy `count` with the golden `count` over the
whole 500 ns window.

> **Q:** Are the two waveforms ever *equal* at the same time other
> than at t = 0? When?
>
> ___________________________________________________________________

### Exercise 2: work backward from the symptom

WaveCrux's **Trace X Origin** command walks backward from a signal
through its fan-in cone, but it only appears on signals that carry
unknown (`x`) values, and this trace has none. Do the same walk by hand
from `counter_buggy.v`, starting at `count`.

> **Q:** What signals and expressions sit upstream of `count`, from the
> assignment back to the input port? Is the suspect among them?
>
> ___________________________________________________________________

### Exercise 3: why the bug is subtle

A reviewer skimming `counter_buggy.v` might miss the bug entirely.
What was the *cognitive trap* that lets this kind of typo slip past
code review?

> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The waveform-diff view with the highlighted divergence regions.
- The cursor on the first divergence.
- A text annotation (in the screenshot, or in your submission) of the
  corrected line of code.

Plus answers to Parts 1, 2, 3, and the three exercises.

---

## Cross-probing to the structure (NetCrux)

You found the bug's *symptom* in the waveform: `count` advances when `enable` is
high, the opposite of what it should do. Now see the bug's *shape* in the
structure.

Open NetCrux and choose **File → Open Netlist JSON…**, then select
`fixtures/netlist.json`.

- The counter is a single **enabled register** (an `$adffe` cell) fed by an
  **increment adder** (`$add`). Find both.
- The register only updates when its **enable** is asserted. Trace the fan-in
  cone of that enable back toward the `enable` input port.
- What sits between the `enable` input and the register's enable? On a correct
  counter, nothing, the input drives the enable directly. Here, the enable is
  driven by the **inverted** input. That inversion is the entire bug, and in the
  structure it is a single gate you can point at.

> On a full install this is one click: select the misbehaving `count` in WaveCrux
> and cross-probe to its driver in NetCrux. In this pack you open the netlist by
> hand, same destination. The waveform told you *which* signal is wrong; the
> structure tells you *why*.
