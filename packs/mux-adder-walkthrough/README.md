# mux-adder-walkthrough

A NetCrux introductory pack. A small ALU — one `adder4` submodule feeding a 2:1
output multiplexer — used to learn how RTL becomes structure: the top module,
its ports, the cells inside it, and the hierarchy you push into and pop out of.

- **Tool:** NetCrux (Open Core)
- **Difficulty:** intro · ~45 min
- **HDL:** Verilog

## Build

```
./build.sh
```

Runs Yosys over `src/` and writes `fixtures/netlist.json` — the JSON netlist
NetCrux opens. The synthesis is deliberately generic (`proc; opt`, no vendor
library), so the schematic reads as the design you wrote.

## What is verified

`fixtures/expected.json` states the structure the netlist must have — the top
module and its ports, the `$mux` on the output, the `adder4` submodule, and the
`$add` inside it. `tools/edacrux-pack-verify` checks those against the netlist
Yosys actually produced, so the handout can never describe a schematic the
synthesis does not.

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
