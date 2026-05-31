# mux-and-adder — instructor notes

## Learning objectives recap

1. Navigate a hierarchical design in the signal-tree browser.
2. Use the signal-search dialog with substring and glob patterns.
3. Filter the signal-tree view by direction.
4. Render the same signal in multiple formats simultaneously across
   multiple lanes.
5. Recognize that an entirely-combinational design's outputs change
   only when its inputs change, not on every clock edge.

## Stimulus summary

The testbench drives four input combinations at clean 50 ns
boundaries, on top of a free-running 100 MHz clock:

| Time (ns) | sel | a_in | b_in | c_in | cin | u_mux.y | result | cout |
|---|---|---|---|---|---|---|---|---|
| 50–100   | 0 | 0x12 | 0x34 | 0x10 | 0 | 0x12 | 0x22 | 0 |
| 100–150  | 1 | 0x12 | 0x34 | 0x10 | 0 | 0x34 | 0x44 | 0 |
| 150–200  | 0 | 0xFF | 0x34 | 0x01 | 0 | 0xFF | 0x00 | 1 |
| 200–250  | 1 | 0xFF | 0x80 | 0x80 | 0 | 0x80 | 0x00 | 1 |

The full machine-checkable contract is in
[`../fixtures/expected.json`](../fixtures/expected.json).

## Exercise answers

**Exercise 1.** `cout` first goes high at t = 150 ns (the `0xFF + 0x01`
overflow). It stays high through t = 200 ns because the next
combination (`0x80 + 0x80`) also overflows.

**Exercise 2.** `result = 0x44`, `cout = 0`. (`0x34 + 0x10 = 0x44`,
no overflow.)

**Exercise 3.** The design has no registers — `mux2to1` and `adder8`
are pure combinational. Outputs settle the moment inputs change and
ignore the clock entirely. Students who answer "the clock is unused"
or "the design is combinational" both receive full credit.

## Common student mistakes

- **"`u_add.a` is the same as `tb_top.a_in`."** No: `u_add.a` is fed
  by `u_mux.y`, which selects between `a_in` and `b_in`. This is the
  whole point of a hierarchical instance — the local port name does
  not match the parent's signal name. Coach students to follow the
  wires in `top.v`.
- **Trying to use Q/E on the clock.** Students who focus `clk` and
  press **E** will land on every clock edge — useful for clock
  navigation in *other* labs, less useful here. Recommend they focus
  one of the input signals or `result` instead.
- **Direction-filter chip is hidden behind narrow window.** On
  smaller windows, the chip may collapse into an overflow menu.
  Worth pointing out before students get stuck.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Signal tree expanded into both submodules | 2 |
| At least 6 of the 9 expected signals on the lane panel | 2 |
| Correct answer to Exercise 1 (t = 150 ns, two overflow cases) | 2 |
| Correct prediction for Exercise 2 | 2 |
| Coherent answer to Exercise 3 ("combinational, clock unused") | 2 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/mux-and-adder
./build.sh
```
