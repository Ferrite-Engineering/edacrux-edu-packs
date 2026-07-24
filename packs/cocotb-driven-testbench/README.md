# cocotb-driven-testbench

A small UART receiver design with two artifacts: a `reference.vcd`
produced by a pure-Verilog testbench, and a `cocotb_run.log` file
that documents the *equivalent* cocotb test run with time-stamped
log messages. Students load both into WaveCrux and use the cocotb-
log-correlation feature to scrub between log lines and waveform
events.

> **Note on dependencies.** This pack does NOT require cocotb to be
> installed to build. The companion `tb/test_uart_rx.py` documents
> the cocotb test (and is runnable independently), but the build
> pipeline uses the pure-Verilog `tb/tb_uart_rx.v` to produce the
> VCD.

- **Difficulty:** advanced
- **Estimated time:** 90 minutes
- **Prerequisites:** uart-lab
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
