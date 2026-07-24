# flaky-test-hunt

A SimCrux pack about the most frustrating thing in verification: a test that
sometimes passes and sometimes fails. Here the flakiness is a *real bug* in a
saturating adder, surfacing only on inputs that some random seeds generate.

- **Tool:** SimCrux (Open Core)
- **Difficulty:** intermediate · ~60 min · assumes `regression-hello-world`
- **HDL:** Verilog

## Build

```
./build.sh
```

Runs the regression across eight seeds with Icarus Verilog and classifies each
test — stable, failing, or flaky — into `fixtures/results.json`.

## What is verified

`fixtures/expected.json` asserts the two directed tests pass on every seed and
that `random_stress` is flaky (passes on at least one seed, fails on at least
one). Seed floors, not exact splits, keep the pack robust while still proving the
flakiness is real. `iverilog`'s `$random` follows the Verilog LRM, so the
per-seed outcomes are reproducible.

## Using this in a course

Everything here is CC-BY-4.0 — adapt, renumber and rebrand it for your course.
Two practical notes on how to hand it out:

- **Give students the `student/` material via your LMS** (Canvas, Moodle,
  Blackboard), not a link to this repository. The `student-…` archive on the
  catalog page is exactly that subset: the handout, the design and testbench,
  and the waveform or netlist to open — with `instructor/` and
  `fixtures/expected.json` (the answer contract) left out.
- **The `instructor/` folder is for you** — the rubric, the common
  misconceptions, and where relevant the worked solution. It is public because
  self-learners and TAs benefit from it, and because these are tool-skill labs
  where the graded outcome is *can the student drive the tool*, not a secret
  number. If you need a private, high-stakes assessment, fork the pack and change
  the exercise — the licence is built for exactly that.
