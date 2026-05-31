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
