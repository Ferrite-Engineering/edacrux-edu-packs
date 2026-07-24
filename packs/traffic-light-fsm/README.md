# traffic-light-fsm

A 3-state traffic-light FSM (RED → GREEN → YELLOW → RED) with a 30-cycle
dwell per state, driven at 100 MHz. Students apply a GTKWave-compatible
translate filter so the 2-bit `state` signal renders as named labels,
open the **FSM Visualizer** panel to see state transitions graphically,
and measure the FSM period by placing markers on three R → G
transitions.

- **Difficulty:** intro
- **Estimated time:** 60 minutes
- **Prerequisites:** none
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the lab walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The
translate filter lives in [`translate/fsm_states.txt`](translate/fsm_states.txt).

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
