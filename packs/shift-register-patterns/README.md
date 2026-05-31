# shift-register-patterns

Two shift-register designs running side-by-side under one testbench:
an 8-bit *shift register* fed by a known serial pattern, and a 5-bit
*maximum-length LFSR* with primitive polynomial x⁵ + x³ + 1 (period 31).
Students contrast deterministic vs pseudo-random transition patterns,
count switching activity over a time range, and measure the LFSR
period.

- **Difficulty:** intro
- **Estimated time:** 60 minutes
- **Prerequisites:** none
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes.
