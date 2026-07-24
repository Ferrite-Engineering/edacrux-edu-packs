# stage-showcase-basys3

A minimal Basys 3 design — 4-switch-to-LED passthrough plus a 4-bit
button counter driving a 7-segment digit — that *looks great* when
bound to the WaveCrux **Stage** panel's Basys 3 board widget. Students
open the Stage panel, instantiate the board widget, bind their
design's I/O to the board's pins, and watch the LEDs and 7-segment
animate live as they scrub the cursor.

- **Difficulty:** intermediate
- **Estimated time:** 75 minutes
- **Prerequisites:** traffic-light-fsm
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough.
The Stage panel layout lives in
[`stage/basys3_layout.json`](stage/basys3_layout.json).

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
