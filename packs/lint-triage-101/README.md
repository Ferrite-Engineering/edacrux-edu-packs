# lint-triage-101

A LintCrux introductory pack. A small sync FIFO, deliberately seeded with a
handful of real lint findings, used to learn how to *triage* a lint report:
read it, count it, filter it, and decide what actually matters.

- **Tool:** LintCrux (Open Core)
- **Difficulty:** intro · ~60 min
- **HDL:** Verilog

## Build

```
./build.sh
```

Runs Verilator over `src/sync_fifo.v` and normalises its output into
`fixtures/lint.json` — the unified report shape LintCrux presents.

## What is verified

`fixtures/expected.json` asserts the findings the lab depends on — the two
unused signals, the width mismatch, and that UNUSEDSIGNAL fires at least twice —
against the report Verilator actually produced. `tools/edacrux-pack-verify`
checks the contract against `lint.json`, and CI rebuilds the report from source
so it can never drift from the RTL.

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
