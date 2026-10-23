# Open-PDK hardening: read your run

A debugging lab for SimCrux 1.2 and later. You open one captured run of a small
design through an open-PDK flow (LibreLane 3.0.16 with the open sky130A PDK:
Yosys, OpenROAD, Magic, KLayout, Netgen) and answer three questions from the run
itself: which step failed and which did not, how far the worst setup slack is
below zero, and which path is the worst and where it starts and ends in the
design.

| | |
|---|---|
| Tool | SimCrux 1.2 or later (Flow Runs panel) |
| Time | about 60 minutes |
| Design | `src/path_adder.v`, a 24-bit add between registers |
| Run | `fixtures/flow/runs/path_adder/timing-2ns` (sky130A, 2 ns clock) |

What you read are findings, not signoff: one small design on one open PDK, and
nothing in this lab says a chip built from it would work.

## Start

1. In SimCrux, choose File > Open Config... and pick `simcrux.yaml` in this folder.
2. Choose View > Flow Runs. The run is listed under the design `path_adder`.
3. Follow `student/handout.md`.

You do not need LibreLane, Nix or a PDK installed to do the lab: the run is
committed. If you have LibreLane 3.0.16 and the sky130A PDK, `config.yaml` is
the capture's configuration with the design path pointed at `src/`, and a run of
your own lands in `runs/<tag>/` beside it, never in `fixtures/`.

## What is in the folder

- `src/path_adder.v`: the design.
- `config.yaml`: the LibreLane configuration of the committed run.
- `simcrux.yaml`: the SimCrux project that lists the run.
- `fixtures/flow/`: the run directory, trimmed to under 5 MB, with
  `PROVENANCE.md` (tool versions, the exact commands, what was trimmed, and
  where each expected value was read from).
- `fixtures/expected.json`: the checkpoints the pack is verified against.
- `student/handout.md`, `instructor/notes.md`, `instructor/solution.md`.

The checkpoints are verified by `tools/edacrux-pack-verify` in this repository,
which recomputes the step statuses, the metrics and the first path of the setup
report from the run's own files, never from what SimCrux shows. That does not
establish that a given SimCrux release displays the run as the handout says.

Licence: as for the rest of this repository (code Apache-2.0, content CC-BY-4.0).
The run files are the output of open tools on the design in `src/`, which is
Apache-2.0. The sky130A PDK is Apache-2.0 (SkyWater Technology and Google); the
run holds names of its cells and layers and none of its data files.
