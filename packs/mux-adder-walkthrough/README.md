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
