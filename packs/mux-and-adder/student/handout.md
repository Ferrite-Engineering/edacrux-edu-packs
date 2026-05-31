# mux-and-adder — student handout

This lab introduces hierarchical design navigation in WaveCrux. The
design is a `top` module that wires an 8-bit 2:1 multiplexer
(`u_mux`) into an 8-bit adder (`u_add`):

```
            ┌────────┐    mux_out    ┌────────┐
   a_in  ──▶│   2:1  │──────────────▶│  adder │──▶ result
   b_in  ──▶│  mux   │               │   8    │──▶ cout
            └───▲────┘               └───▲────┘
                │ sel              c_in/cin
```

Open the [`src/`](../src/) directory and skim `mux2to1.v`, `adder8.v`,
and `top.v` before starting.

## Setup

1. Launch WaveCrux and **File → Open Session…** select
   `fixtures/reference.wavecrux`. (If it is the placeholder version,
   open `fixtures/reference.vcd` directly and add the signals listed
   below.)
2. The signal tree on the left should show:
   - `tb_top` (the testbench scope)
     - `dut` (the `top` module instance)
       - `u_mux` (the multiplexer instance)
       - `u_add` (the adder instance)

## Part 1 — browse the hierarchy

1. Expand `tb_top.dut` in the signal tree.
2. Expand `u_mux`. Notice that the mux's `y` port is the wire feeding
   the adder.
3. Expand `u_add`. Add `u_add.a`, `u_add.b`, `u_add.sum`, and
   `u_add.cout` to the lane panel.

> **Q:** Within `u_add`, the input named `a` is *not* `tb_top.a_in`.
> What signal in the parent module is it bound to? *(Hint: read
> `top.v`.)*
>
> ___________________________________________________________________

## Part 2 — signal search

1. Press **Ctrl + F** (or **Cmd + F** on macOS) to open the
   signal-search dialog.
2. Type `*_in` to glob-match the top-level input ports. You should see
   `a_in`, `b_in`, and `c_in`.
3. Click each result to add it to the lane panel.

## Part 3 — direction filter

1. In the signal-tree pane, click the **direction filter** chip.
2. Cycle through `inputs`, `outputs`, and `all`. Notice how the listed
   variables narrow to just the matching direction.
3. Return to `all` before continuing.

## Part 4 — multiple formats on multiple lanes

1. Right-click (or long-press) `a_in` and **Duplicate Lane**. Set one
   lane to **Hexadecimal** and the duplicate to **Decimal**.
2. Move the cursor to **t = 175 ns**. The hex lane reads `FF`; the
   decimal lane reads `255`.
3. Move the cursor to **t = 225 ns** and confirm `result` reads `00`
   while `cout` reads `1` — the adder overflow case.

## Part 5 — exercises

### Exercise 1 — find the first cout edge

Click on `cout` to focus it, press **Home** to return the cursor to
t = 0, then press **E** to step to the next transition.

> **Q:** At what time does `cout` first go high? Why does it stay high
> for the rest of the simulation? *(Hint: look at the input
> combinations at t = 150 ns and t = 200 ns.)*
>
> ___________________________________________________________________

### Exercise 2 — predict result at t = 125 ns

Without looking at the value column, predict `result` and `cout` at
t = 125 ns. Then move the cursor there and verify.

> **A:** Predicted result = ______, predicted cout = ______. Actual?

### Exercise 3 — combinational vs sequential

The `clk` lane shows a continuous 100 MHz toggle, but the outputs only
change at four discrete points (t = 50, 100, 150, 200 ns) — *not* on
every clock edge.

> **Q:** Why? What does this tell you about whether this design is
> combinational or sequential?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing the signal tree expanded into `u_mux` and `u_add`,
with at least `a_in`, `b_in`, `c_in`, `u_mux.y`, `result`, and `cout`
on the lane panel. Include your answers to Exercises 1, 2, and 3.
