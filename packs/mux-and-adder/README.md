# mux-and-adder

A hierarchical combinational design — an 8-bit 2:1 multiplexer feeds an
8-bit adder, both instantiated under a `top` wrapper. Students practice
the signal-tree browser, the signal-search dialog, direction filtering,
and showing the same signal in multiple formats across multiple lanes.

- **Difficulty:** intro
- **Estimated time:** 45 minutes
- **Prerequisites:** none
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the lab walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The full
manifest is in [`pack.yaml`](pack.yaml).

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
