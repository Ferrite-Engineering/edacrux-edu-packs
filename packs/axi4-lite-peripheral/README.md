# axi4-lite-peripheral

A minimal AXI4-Lite master drives an 8-register peripheral through the
full 5-channel handshake (AW / W / B / AR / R). The master executes a
fixed sequence — two successful writes, one write to an unmapped
address, one successful read, and one read of an unmapped address —
so students see both happy-path OKAY responses *and* SLVERR
responses in the same trace.

- **Difficulty:** advanced
- **Estimated time:** 90 minutes
- **Prerequisites:** memory-controller
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
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
