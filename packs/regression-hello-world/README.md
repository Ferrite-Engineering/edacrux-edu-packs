# regression-hello-world

A SimCrux introductory pack. A small ALU with a six-test directed regression,
used to learn the loop every verification engineer lives in: run the suite, read
the dashboard, know what green means.

- **Tool:** SimCrux (Open Core)
- **Difficulty:** intro · ~45 min
- **HDL:** Verilog

## Build

```
./build.sh
```

Runs the testbench with Icarus Verilog and normalises the per-test outcomes into
`fixtures/results.json` — the results a SimCrux dashboard renders.

## What is verified

`fixtures/expected.json` asserts the suite has six tests, all passing, and that
the named directed cases each pass — checked against the results the testbench
actually produced. CI reruns the suite from source, so the dashboard can never
disagree with the RTL beside it.

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
