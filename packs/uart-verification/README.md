# uart-verification

A **Tier-B pair pack** (SimCrux + WaveCrux). A UART transmitter regression where
one test fails — but the waveform shows the DUT transmitted the byte correctly.
The bug is a wrong expectation in the *testbench*, not the design. The whole
point is the loop: a red test sends you to the waveform, and the waveform tells
you what the failure actually means.

- **Tools:** SimCrux + WaveCrux (Open Core)
- **Difficulty:** intermediate · ~90 min · assumes `regression-hello-world`, `counter-lab`
- **HDL:** Verilog

## Build

```
./build.sh
```

One testbench run produces both fixtures: `fixtures/results.json` (the SimCrux
dashboard) and `fixtures/reference.vcd` (the WaveCrux waveform), so the failing
test and the waveform you debug it in come from the identical run.

## What is verified — and what isn't

Each tool's own facts are machine-verified against the real run: the regression
outcomes (two pass, `tx_0xFF` fails) against the simulator, and the serial line's
idle state against the waveform. The cross-tool **deep-link** — clicking the
failing test in SimCrux and landing on its transmission in WaveCrux — is declared
but not machine-verified, as with the other pair packs.

## Using this in a course

Give students the `student/` material (or the student-only archive) via your LMS,
not a link to this repo — it is the pack minus `instructor/` and the answer
contract. The instructor material is public on purpose: self-learners and TAs
rely on it, and the graded outcome here is whether a student can tell a design
bug from a wrong test, not a secret number. Fork the pack for a private
assessment; CC-BY-4.0 is built for it.
