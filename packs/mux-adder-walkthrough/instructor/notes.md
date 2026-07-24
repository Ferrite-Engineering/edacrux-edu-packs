# Instructor notes — mux-adder-walkthrough

## Point of the lab

The single idea worth landing: **a conditional assignment is a multiplexer**.
Students who have only written RTL often do not connect `op ? sum : a` with a
piece of hardware. Seeing the `$mux` cell NetCrux draws for that exact line is
the moment it clicks. Everything else (ports, widths, hierarchy) is supporting
navigation practice.

## Answers

- **§1 ports.** `a`, `b` are 4-bit inputs; `op` is a 1-bit input; `y` is a
  5-bit output. `y` is 5 bits because a 4-bit + 4-bit sum needs a carry bit —
  a good place to ask why addition grows the width by one.
- **§2 mux.** Control line is `op`. The `1` arm (`op` true) is `sum`; the `0`
  arm is `{1'b0, a}`, i.e. `a` zero-extended to 5 bits. Verilog's `?:` puts the
  true value first, which is the opposite order from how a mux is often drawn —
  worth flagging.
- **§3 adder.** Inside `adder4`, a single `$add` cell. After popping out they
  should be back at `alu`.
- **§4.** With `op = 0`, `y = {1'b0, a}`. The adder still computes `sum`, but the
  mux does not select it — a useful lead-in to "unused logic still exists in the
  structure".

## Common misconceptions

- *"The adder disappears when op is 0."* It does not — synthesis does not remove
  it, and NetCrux shows it regardless of the control value. Structure is static;
  selection is dynamic.
- *"$mux and $add are NetCrux inventions."* They are Yosys cell types — the
  generic internal cells synthesis emits before any technology mapping. Point
  students at `fixtures/netlist.json` if they are curious.

## If you want to extend it

Add a subtract path (`op` becomes 2 bits, the mux becomes 3:1) and have students
predict the structural change before rebuilding. The verifier's
`cell_types_present` contract makes it easy to confirm the new mux width.
