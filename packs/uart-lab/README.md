# uart-lab

A UART transmitter at 115_200 baud (50 MHz clock,
`CYCLES_PER_BIT = 434`), 8-N-1, transmitting `0x55, 0xAA, 0x55, 0xAA`
over ~350 microseconds. Students identify the start bit, the eight LSB-
first data bits, and the stop bit by eye first; then apply the WaveCrux
UART decoder and read the decoded bytes from the transaction table;
then measure the actual bit period with cursor markers.

- **Difficulty:** intermediate
- **Estimated time:** 75 minutes
- **Prerequisites:** counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The
decoder binding lives in [`decoders/uart_binding.json`](decoders/uart_binding.json).

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
