# Open-FPGA timing: find the slow path

A debugging lab for SimCrux 1.2 and later. You open two captured runs of the
same small design through an open FPGA toolchain (Yosys for synthesis, nextpnr
for place and route, iCE40 UP5K) and answer three questions from the run
itself: did the design meet its clock, which path is the slowest, and which line
of RTL is responsible for it.

| | |
|---|---|
| Tool | SimCrux 1.2 or later (Flow Runs panel) |
| Time | about 45 minutes |
| Design | `src/path_adder.v`, a 24-bit add between registers |
| Runs | `fixtures/flow/runs/path_adder/violated-1000mhz` (1000 MHz), `fixtures/flow/runs/path_adder/met-12mhz` (12 MHz) |

## Start

1. In SimCrux, choose File > Open Config... and pick `simcrux.yaml` in this folder.
2. Choose View > Flow Runs. Both runs are listed.
3. Follow `student/handout.md`.

You do not need nextpnr or Yosys installed to do the lab: the runs are
committed. If you have them, Tools > Run Flow Entry re-runs the design into
`runs/path_adder/`, and you can compare your run with the committed one.

## What is in the folder

- `src/path_adder.v`: the design.
- `simcrux.yaml`: the SimCrux project that lists the two runs.
- `fixtures/flow/`: the two run directories, with `PROVENANCE.md` (tool
  versions, the exact commands, and where each expected value comes from).
- `fixtures/expected.json`: the checkpoints the pack is verified against.
- `student/handout.md`, `instructor/notes.md`, `instructor/solution.md`.

The checkpoints are verified by `tools/edacrux-pack-verify` in this
repository, which recomputes the verdict and the register at each end of the
worst path from the run's own report, log and netlist, never from what SimCrux
shows.

Licence: as for the rest of this repository (code Apache-2.0, content CC-BY-4.0).
The run files are the output of open tools (Yosys, nextpnr) on the design in
`src/`, which is Apache-2.0.
