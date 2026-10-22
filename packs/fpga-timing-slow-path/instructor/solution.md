# Solution: find the slow path

## 1. The verdicts

| Run | Verdict | Achieved | Constraint |
|---|---|---|---|
| `violated-1000mhz` | Violated | about 60.9 MHz | 1000 MHz |
| `met-12mhz` | Met | about 60.9 MHz | 12 MHz |

The final `Max frequency for clock` line of each log agrees: FAIL at 1000 MHz and
PASS at 12 MHz. An earlier line in the same log, about 67.4 MHz, is the
pre-routing estimate.

Same frequency, different verdict: the verdict compares the achieved frequency
with the constraint, and the constraint is the only thing that differs.

## 2. The worst path

Path 1 launches at `src_a_SB_DFF_Q_23_DFFLC` and ends at `sum_q_SB_DFF_Q_DFFLC`.
Its segments are one clock-to-q, a chain of alternating routing and logic
segments through the carry chain, and one setup. Logic segments dominate in
count (about 0.28 ns each through the chain); routing is near zero between them
except for a few jumps and the two ends. The segments sum to about 16.4 ns,
which is the period of about 60.9 MHz.

## 3. The RTL

- The start cell belongs to `src_a`, declared on line 10. (The path could equally
  start at `src_b`, line 11; which one the report lists first depends on
  placement.)
- The end cell belongs to `sum_q`, declared on line 12.
- The statement that computes it is line 16:

`src/path_adder.v` line 16
```verilog
    sum_q <= src_a + src_b;
```

`src_a` and `src_b` are shift registers: each bit is one register away from the
previous, so they add almost no logic. The add is a 24-bit carry chain between
two registers in a single clock cycle, so the whole chain's delay lands in one
path.

## 4. The lower clock

The paths are the same. Only the verdict changed. The constraint belongs to the
run, not to the design.

## 5. A fix

Pipeline the add: register the two operands (already done by `src_a`, `src_b`),
split the 24-bit add into two 12-bit halves with a registered carry between
them, and register each half. The worst path becomes about half as long, at the
cost of a cycle of latency and a few more registers. In a new run, look first at
the achieved frequency, then at path 1: it should now start and end at
different registers, and `sum_q` should no longer be the end.
