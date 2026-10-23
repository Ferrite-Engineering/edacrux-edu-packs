# Solution: read your run

Values below are from the committed run; a re-run moves them by small amounts.

## 1. The verdict

**Violated.** The run log reaches the last step (`Misc.ReportManufacturability`)
and `final/metrics.json` exists, so the flow completed. The flow exited with
status 2 because a checker raised an error at the end. That status is not what
the verdict reads.

## 2. The failed step

`Checker.SetupViolations` (step 72) is Failed: its directory has `config.json`
and `state_in.json` and no `state_out.json`. The steps after it (`Checker.HoldViolations`,
the slew and capacitance checkers, `Misc.ReportManufacturability`) are
Completed. LibreLane holds a checker's error until the end of the flow so the
later checks still run.

`Yosys.Synthesis` and `OpenROAD.STAPostPNR` are Completed.

The timing numbers the checker read were produced by `OpenROAD.STAPostPNR`
(step 55): it writes one directory per corner, a `summary.rpt` and the timing
metrics.

## 3. The metrics

| Metric | Value |
|---|---|
| Worst setup slack, whole design | about -3.43 ns, in the `max_ss_100C_1v60` corner |
| Worst setup slack, `nom_tt_025C_1v80` | about -0.90 ns |
| Setup violations, whole design | 276 |
| Setup violations, `nom_tt_025C_1v80` | 20 |
| Hold violations, Routing DRC errors, Magic DRC errors, LVS errors | 0 each |
| Sequential cells | 73 |

The register count agrees with the RTL: `src_a` and `src_b` are 24 bits each and
`sum_q` is 25 bits, 24 + 24 + 25 = 73.

The failure is not caused by the worst number in the table. The setup checker
looks at corners matching `*tt*`, and three of them (nominal, min and max
typical) violate by about 0.9 ns. If it looked at every corner it would fail all
the same, with a larger number. The hold checker looks at every corner and
passes.

## 4. The worst path

Path 1 starts at `_354_` and ends at `_400_`. Slack is about -0.904 ns: data
arrives at about 2.997 ns, and the capturing clock edge (2 ns plus the clock tree
delay to the capture flip-flop) less 0.25 ns of clock uncertainty and 0.071 ns of
setup time requires it by about 2.093 ns.

The path is one clock-to-Q of about 0.38 ns, then nine logic cells in a row (an
XOR, a few AND-OR-invert and OR-AND cells, an XNOR) with almost no routing delay
between them, about 2.2 ns in all. Logic dominates.

The Mapping column reads `register src_b` for the start and `register sum_q` for
the end.

To check it by hand, in
`fixtures/flow/runs/path_adder/timing-2ns/06-yosys-synthesis/path_adder.nl.v`:

```
sky130_fd_sc_hd__dfxtp_2 _354_ ( .CLK(clk), .D(\src_b[0] ), .Q(\src_b[1] ) );
sky130_fd_sc_hd__dfxtp_2 _400_ ( .CLK(clk), .D(_017_), .Q(\sum_q[23] ) );
```

`_354_` is the flip-flop that holds bit 1 of `src_b`, and `_400_` holds bit 23 of
`sum_q`. The second path of the report also starts at `_354_`; which start bit
and which end bit come first is a consequence of placement and of the order the
timer breaks ties in, not of the RTL.

## 5. The RTL

- Start: `src_b`, declared on line 11. End: `sum_q`, declared on line 12.
- The statement that computes the end register is line 16:

`src/path_adder.v` line 16
```verilog
    sum_q <= src_a + src_b;
```

`src_a` and `src_b` are shift registers: each bit is one register away from the
previous, so they add almost no logic. The add is a 24-bit carry chain between
two registers in a single clock cycle, so the whole chain's delay lands in one
path. The middle of the path is the carry rippling from the low bits to bit 23,
one cell per stage.

## 6. What to try next

- Period estimate: the typical corner misses by about 0.9 ns at 2 ns, so about
  2.9 ns is a first guess for meeting it, and about 5.4 ns if the slow corner
  had to meet as well. Only a first guess: the tools re-place, re-route and
  re-size for a new period, so the real number moves, and the clock uncertainty
  and setup time do not scale with it.
- A fix: pipeline the add. Split the 24-bit addition into two 12-bit halves with
  a registered carry between them and register each half. The worst path is
  about half as long, at the cost of a cycle of latency and a few more
  registers.
- Read first in a new run: the verdict, then the worst setup slack in the
  typical and slow corners, then the ends of path 1. It should no longer end at
  `sum_q` from the same start, or its slack should be positive.
