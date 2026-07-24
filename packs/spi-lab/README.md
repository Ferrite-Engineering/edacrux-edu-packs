# spi-lab

An SPI mode-0 master with internal /10 clock divider runs from a 50 MHz
system clock and shifts out **0x12, 0x34, 0x56, 0x78** at 5 MHz SCLK,
MSB-first. A simple passive slave samples MOSI on the rising edge of
SCLK and latches the captured byte into `last_byte` when CS_n returns
high. Students identify CPOL / CPHA from the raw signals, apply the
WaveCrux SPI decoder, and watch the wrong-mode failure manifest by
flipping CPOL.

- **Difficulty:** intermediate
- **Estimated time:** 75 minutes
- **Prerequisites:** uart-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The
decoder binding lives in [`decoders/spi_binding.json`](decoders/spi_binding.json).

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
