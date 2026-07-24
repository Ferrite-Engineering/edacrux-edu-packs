# debug-hunt

Find the bug. The pack ships two designs — a *golden* 8-bit counter
and a *buggy* version that looks almost identical but contains a
single-character bug — plus two VCDs and matching stimuli. Students
load both VCDs side-by-side, configure the waveform-diff feature,
jump between differences, and propose a fix.

**Do not** open [`../src/counter_golden.v`](src/counter_golden.v)
before completing the lab. The instructor solution lives in
[`instructor/solution.md`](instructor/solution.md).

- **Difficulty:** intermediate
- **Estimated time:** 90 minutes
- **Prerequisites:** counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough.

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
