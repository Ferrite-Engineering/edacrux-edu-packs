# Reading a design as structure — a tiny ALU

**Tool:** NetCrux · **Time:** ~45 minutes · **Files:** `src/alu.v`, `src/adder4.v`

You have written Verilog. This lab is about *seeing* it: how the code you wrote
becomes a diagram of blocks and wires, and how to move around that diagram.

## Setup

Build the netlist and open it in NetCrux:

```
./build.sh
netcrux fixtures/netlist.json     # or File → Open in the app
```

## 1. The top module

NetCrux opens on the top module, **`alu`**. Look at its border: the ports.

- How many inputs does `alu` have? What is each one's width?
- `y` is the output. How wide is it, and why is it one bit wider than `a`?

> The RTL is in `src/alu.v`. Read the port list there and confirm it matches
> what NetCrux draws.

## 2. The output multiplexer

Find the block driving `y`. It is a **2:1 multiplexer** — a selector that picks
one of two inputs based on a control line.

- What is the control line, and where does it come from?
- Look at `assign y = op ? sum : {1'b0, a};` in the RTL. Which arm of the `?:`
  is which input of the mux?

This is the central idea of the lab: a conditional assignment in RTL is a
multiplexer in structure. They are the same thing seen two ways.

## 3. Pushing into the adder

`sum` comes from a block named **`u_add`** — an instance of the `adder4`
module. In NetCrux, **push into it** (double-click, or the push-in control).

- Inside `adder4`, what single cell does the addition?
- Pop back out. Confirm you are looking at `alu` again.

Pushing in and popping out is how you navigate a real design: the top level is a
few blocks, and detail lives inside them.

## 4. Check yourself

- If `op` is 0, what appears on `y`? Trace the path through the mux by eye.
- Which of the two `alu` blocks is combinational arithmetic, and which is
  selection?

## What you should be able to do now

Open any netlist, find the top module, read its ports, recognise a mux behind a
conditional, and navigate hierarchy by pushing into submodules. Every larger
NetCrux lab builds on exactly these moves.
