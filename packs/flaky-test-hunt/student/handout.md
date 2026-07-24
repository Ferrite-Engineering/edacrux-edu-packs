# Hunting a flaky test

**Tool:** SimCrux · **Time:** ~60 minutes · **Files:** `src/sat_add.v`, `tb/tb_sat.v`

A **flaky** test is one that passes sometimes and fails sometimes on the *same
code*. It is the worst kind of failure because "run it again" makes it go away —
which is exactly why it must never be ignored. This lab is a flaky test with a
real cause, and the discipline for dealing with it.

## Setup

```
./build.sh                       # run the suite across 8 seeds
simcrux fixtures/results.json    # open the seed grid
```

The design is an 8-bit signed **saturating adder** (`src/sat_add.v`): results
that overflow should clamp to +127 or −128.

## 1. Read the seed grid

The suite ran three tests across eight seeds. On the dashboard:

- Which tests passed on **every** seed?
- Which test passed on some seeds and failed on others?

A test with a mixed row is **flaky**. Here it is `random_stress`.

## 2. Flaky is a symptom, not a diagnosis

A flaky test has one of two causes, and telling them apart is the whole skill:

- **A bad testbench** — a race, an uninitialised value, a timing assumption.
  The design is fine; the test lies.
- **A real design bug** that only some inputs trigger. The test is fine; the
  design is broken, and the flakiness is just the bug being rare.

Which is it here? Look at `tb/tb_sat.v`: `random_stress` draws random operands and
checks them against a reference model. The testbench is deterministic given a
seed. So the flakiness comes from the *design* meeting inputs only some seeds
generate. **This is cause two: a real bug.**

## 3. Reproduce it

A flaky failure you cannot reproduce, you cannot fix. Pin a failing seed:

- From the grid, note a seed where `random_stress` failed.
- Run `./build.sh` — or `vvp build/sim.vvp +seed=<N>` — and confirm the failure
  is there every time for that seed. Deterministic reproduction is the difference
  between "flaky, ignore it" and "found it."

## 4. Find the bug

Read `src/sat_add.v`. Positive overflow clamps to +127 correctly. Look hard at
the **negative** overflow case.

- What value should a large-magnitude negative overflow clamp to?
- What does this design clamp it to?
- That single wrong constant is the entire bug. It only shows up when two
  operands sum below −128 — inputs some seeds produce and others do not.

## 5. Fix vs. quarantine

You could *quarantine* `random_stress` — tell SimCrux to stop failing the suite
on it — and the dashboard goes green. **That is not a fix.** The bug still ships;
you have only hidden the one test that found it. Quarantine buys time to fix, it
is not a substitute. Fix the constant, rebuild, and watch every seed go green for
the right reason.

## What you should be able to do now

Read a seed grid, classify a test as flaky, reason about whether the cause is the
test or the design, reproduce a flaky failure by pinning its seed, and resist the
temptation to make a red bar green without fixing what turned it red.
