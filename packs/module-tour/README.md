# module-tour

A NetCrux navigation pack. A small datapath `core` — two register slots and an
ALU, with the ALU's result feeding back into the second slot — used to practise
moving through a hierarchy and tracing fan-in and fan-out.

- **Tool:** NetCrux (Open Core)
- **Difficulty:** intermediate · ~60 min · assumes `mux-adder-walkthrough`
- **HDL:** Verilog

## Build

```
./build.sh
```

Runs Yosys over `src/core.v` and writes `fixtures/netlist.json` — the JSON
netlist NetCrux opens.

## What is verified

`fixtures/expected.json` pins the structure the lab depends on: the top module
and its ports, that there are exactly two `regslot` instances and one `alu8`,
and the internals of each block. `tools/edacrux-pack-verify` checks those
against the netlist Yosys produced.

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
