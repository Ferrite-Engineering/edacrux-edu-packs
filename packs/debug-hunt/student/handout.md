# debug-hunt — student handout

You are handed two VCDs from what should be the *same* design:

- **`fixtures/buggy.vcd`** — captured from a counter that
  someone wrote that *almost* works.
- **`fixtures/golden.vcd`** — captured from a known-good
  reference implementation of the same counter.

Stimulus is identical in both runs: 100 MHz clock, reset held until
t=22 ns, then `enable` is high for ~180 ns, then low for 100 ns, then
high again for the remainder of the 500 ns simulation.

**Your job:** find the bug in the buggy counter without looking at the
golden source. Propose a one-line fix.

⚠️ **Do NOT open [`../src/counter_golden.v`](../src/counter_golden.v)
or your instructor's solution before finishing.** You can read
[`../src/counter_buggy.v`](../src/counter_buggy.v) freely — that
*is* the design under debug.

## Setup

1. Launch WaveCrux.
2. **File → Open…** open `fixtures/buggy.vcd`. This becomes the
   *primary* tab.
3. **View → Compare With File…** select `fixtures/golden.vcd`. This
   loads the golden trace as a reference.
4. WaveCrux maps signal names by full path between the two. Confirm
   the signal-mapping dialog matches:
   - `tb_counter_buggy.dut.count` ↔ `tb_counter_golden.dut.count`
   - `tb_counter_buggy.dut.enable` ↔ `tb_counter_golden.dut.enable`
   - `tb_counter_buggy.dut.rst_n` ↔ `tb_counter_golden.dut.rst_n`
5. Click **Configure Diff**. A new visual style highlights the regions
   where the two `count` traces disagree.

## Part 1 — locate the first divergence

1. Press **Home** then **Ctrl + ]** (jump to next diff).
2. The cursor lands on the first cycle where buggy `count` ≠ golden
   `count`.

> **A:** First divergence at t = ____ ns. At that time:
>
> - buggy count = 0x__
> - golden count = 0x__

## Part 2 — locate the second-most-suspicious moment

Press **Ctrl + ]** to step to the next diff. Repeat until you have
observed at least three divergence regions.

> **Q:** Describe in plain language *when* the buggy counter
> increments. (Hint: focus the `enable` lane and the `count` lane in
> the buggy trace.)
>
> ___________________________________________________________________

## Part 3 — propose a fix

Read [`../src/counter_buggy.v`](../src/counter_buggy.v).

> **Q:** What single character (or short token) is wrong? What is the
> correct value? Write the corrected line of code.
>
> Buggy line: ________________________________________________
>
> Corrected line: ________________________________________________

## Part 4 — exercises

### Exercise 1 — what makes the buggy counter look so similar?

Cross-correlate the buggy `count` with the golden `count` over the
whole 500 ns window.

> **Q:** Are the two waveforms ever *equal* at the same time other
> than at t = 0? When?
>
> ___________________________________________________________________

### Exercise 2 — X-trace from the symptom

WaveCrux's **X-trace** feature walks backward from a signal of
interest through its fan-in cone. Right-click on `count` in the
buggy trace and choose **X-trace from here**.

> **Q:** What signals does X-trace identify as upstream of `count`?
> Does that list match what you'd expect from reading the source?
>
> ___________________________________________________________________

### Exercise 3 — why the bug is subtle

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
