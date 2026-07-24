# memory-controller-review

A **Tier-B pair pack** (LintCrux + NetCrux). A register-mapped memory controller
with a couple of real lint findings, used to practise the move that makes a suite
worth more than its parts: reading a lint finding and cross-probing straight to
the structure it concerns.

- **Tools:** LintCrux + NetCrux (Open Core)
- **Difficulty:** intermediate · ~90 min · assumes `lint-triage-101`, `module-tour`
- **HDL:** Verilog

## Build

```
./build.sh
```

Builds **both** fixtures from the same RTL: `fixtures/lint.json` (Verilator,
normalised as LintCrux presents it) and `fixtures/netlist.json` (Yosys, as
NetCrux loads it).

## What is verified — and what isn't

Each tool's own findings are machine-verified against real engine output: the
lint findings against Verilator, the structure against Yosys. Proven, for
example, that the register file synthesises to exactly three flip-flop banks and
that the `shadow` register the linter flags is absent from the netlist.

The **cross-tool deep-link itself is declared but not machine-verified.**
Executing a live cross-probe needs both apps running and driven under automation,
which the suite does not yet expose for these two tools. The verifier records the
deep-link and marks it explicitly as not exercised, rather than pretending it was.

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
