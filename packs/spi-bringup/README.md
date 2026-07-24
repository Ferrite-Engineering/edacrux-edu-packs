# spi-bringup

A **Tier-B triple pack** (SimCrux + WaveCrux + NetCrux). An SPI mode-0 master
whose loopback link is *alive but wrong*: every byte comes back shifted by one
bit. Bringing it up means crossing all three views of the same event — the
regression that fails, the waveform that shows the mis-timed sample, and the
structure where the fix lives.

- **Tools:** SimCrux + WaveCrux + NetCrux (Open Core)
- **Difficulty:** advanced · ~2 hours · assumes `uart-verification`, `module-tour`
- **HDL:** Verilog

## Build

```
./build.sh
```

One design and one testbench run produce all three fixtures: the Yosys netlist,
the WaveCrux VCD, and the SimCrux results — so the failure, the waveform and the
structure are the same bring-up seen three ways.

## What is verified — and what isn't

Each tool's facts are machine-verified against the real build: the three failing
transfers (SimCrux) against the run, chip-select idle (WaveCrux) against the VCD,
and the two shift registers (NetCrux) against the netlist. The two cross-tool
**deep-links** — failing test → waveform → receive shift register — are declared
but not machine-verified, as with the other pair packs.

## Using this in a course

Give students the `student/` material (or the student-only archive) via your LMS.
The `instructor/` folder — including the root cause and fix — is yours, and public
for self-learners. Fork for a private assessment; CC-BY-4.0 is built for it.
