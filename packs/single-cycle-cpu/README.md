# single-cycle-cpu

A minimal RV32I single-cycle CPU executes a 15-instruction hand-
assembled program that exercises ADDI, ADD, SUB, LW, SW, BEQ, and
JAL. Students apply the WaveCrux RISC-V instruction decoder on the
`pc` and `instr` signals, scrub through the trace, and watch
register-file state change with each instruction. The program
contains a taken BEQ branch that skips an ADDI — visible as a single-
cycle PC jump from 0x18 directly to 0x20.

- **Difficulty:** intermediate
- **Estimated time:** 90 minutes
- **Prerequisites:** mux-and-adder, counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough,
[`src/program.s`](src/program.s) for the human-readable assembly, and
[`instructor/notes.md`](instructor/notes.md) for grading notes.

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
