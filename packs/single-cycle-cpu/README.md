# single-cycle-cpu

A minimal RV32I single-cycle CPU executes a 15-instruction hand-
assembled program that exercises ADDI, ADD, SUB, LW, SW, BEQ, and
JAL. Students apply the WaveCrux RISC-V instruction decoder on the
`pc` and `instr` signals, scrub through the trace, and watch
register-file state change with each instruction. The program
contains a taken BEQ branch that skips an ADDI — visible as a single-
cycle PC jump from 0x18 directly to 0x20.

- **Difficulty:** intermediate
- **Estimated time:** 90 minutes
- **Prerequisites:** mux-and-adder, counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough,
[`src/program.s`](src/program.s) for the human-readable assembly, and
[`instructor/notes.md`](instructor/notes.md) for grading notes.
