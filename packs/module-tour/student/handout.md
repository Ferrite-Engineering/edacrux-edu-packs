# Touring a design — hierarchy, fan-out and fan-in

**Tool:** NetCrux · **Time:** ~60 minutes · **Files:** `src/core.v`

`mux-adder-walkthrough` taught you to open a netlist and read one module. This
lab is about *moving through* a design with more than one level, and about the
two relationships that structure every netlist: **fan-out** (one signal driving
several places) and **fan-in** (several signals converging on one).

## Setup

```
./build.sh
netcrux fixtures/netlist.json
```

The top module is **`core`** — a tiny clocked datapath.

## 1. The lay of the land

Look at `core` before pushing anywhere. It contains three instances:

- Two **register slots**, `u_ra` and `u_rb`.
- One **ALU**, `u_alu`.

Both register slots are instances of the *same* module, `regslot`. This is the
first idea: **one design, reused.** You wrote `regslot` once; the datapath uses
it twice. NetCrux draws two blocks, but pushing into either lands you in the
same module definition.

- Confirm in `src/core.v`: find the two `regslot` instantiations and the one
  `alu8`.

## 2. Fan-out — follow `din`

`din` is the data input. Trace it forward (fan-out): which blocks does it reach?

- `din` drives `u_ra`'s data input. Does it reach `u_rb`? Look carefully — the
  second slot's data comes from somewhere else.
- A single net reaching several sinks is fan-out. Here `din` fans out to… how
  many loads?

## 3. Fan-in — what drives `u_alu`?

Now trace backward (fan-in) from the ALU. The ALU has two data inputs, `a` and
`b`. Where does each come from?

- `a` comes from `u_ra`'s output.
- `b` comes from `u_rb`'s output.

Two register outputs converging on one block is fan-in. The ALU's `a`/`b` inputs
are the fan-in point of the datapath.

## 4. The feedback path

Here is the subtle one. Where does `u_rb`'s *input* come from?

- Not from `din`. It comes from `alu_y` — the ALU's **output**.
- So: ALU output → `u_rb` input → (next cycle) `u_rb` output → ALU `b` input.
  The result feeds back into the computation. Trace that loop by eye in NetCrux.

Feedback is what makes this a datapath and not just combinational logic. Being
able to *see* the loop in the structure is the point of the lab.

## 5. Into the blocks

- Push into `u_alu`. What three cells implement "A+B or A&B, choose with `op`"?
- Pop out. Push into `u_ra`. What single cell holds the register value?
- Pop out. You are back at `core`.

## What you should be able to do now

Move fluently up and down a hierarchy, tell reuse from distinct blocks, and
trace both fan-out and fan-in — including a feedback loop — by following nets
through the schematic. Every structural-debug lab from here uses these moves.
