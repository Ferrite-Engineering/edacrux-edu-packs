# Instructor notes — module-tour

## Point of the lab

Two ideas, in order of difficulty:

1. **Reuse.** Two `regslot` blocks are one module instantiated twice. Students
   who think "two blocks = two designs" need this corrected early — it is the
   basis of every register file, FIFO and datapath they will ever read.
2. **Fan-out / fan-in / feedback.** The datapath is deliberately arranged so
   each is visible: `din` fans out, the ALU inputs are a fan-in, and `alu_y →
   u_rb → alu.b` is a feedback loop. The loop is the hard part and the payoff.

## Answers

- **§1.** Two `regslot` instances (`u_ra`, `u_rb`), one `alu8` (`u_alu`).
- **§2 fan-out.** `din` drives only `u_ra`. It reaches **one** load — a good
  place to note that "input port" does not imply "fans out everywhere". `u_rb`'s
  data is `alu_y`, not `din`.
- **§3 fan-in.** ALU `a` ← `u_ra.q`; ALU `b` ← `u_rb.q`. Two sources, one block.
- **§4 feedback.** `u_rb.d = alu_y`. The loop is ALU → u_rb (register) → ALU.b.
  Ask students to state what value `u_rb` holds one cycle after a compute — it is
  the previous ALU result.
- **§5.** `u_alu`: `$add`, `$and`, `$mux`. `u_ra`/`u_rb`: one `$adffe` each
  (enabled, async-reset D flip-flop).

## Common misconceptions

- *"The two register slots are different because they have different names."*
  Names are instance labels; the module is identical. Push into both and show
  the same internals.
- *"Feedback means a combinational loop / it will hang."* No — the feedback
  passes through a register, so it advances one cycle at a time. Distinguish
  registered feedback (fine, and everywhere) from combinational loops (a bug).

## Prerequisite

Assumes `mux-adder-walkthrough` — students should already know how to open a
netlist, read ports, and push into one module. This lab adds multi-level
navigation and net tracing on top.

## Extending it

Add a third register slot and a second ALU op and have students predict the new
instance counts before rebuilding; the verifier's `instance_counts` contract
confirms them.
