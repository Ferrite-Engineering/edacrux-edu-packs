# memory-controller — instructor notes

## Learning objectives recap

1. Identify the Wishbone B4 classic cyc / stb / ack handshake.
2. Apply the Wishbone decoder with a complete binding (10 signals).
3. Recognize WRITE vs READ transactions in the decoded stream.
4. Use the switching-activity heatmap to characterize bus utilization.

## Timing summary

- 100 MHz clock, posedges at every multiple of 10 ns from t = 10.
- Synchronous active-high reset (`rst`) held until t = 22 ns; first
  posedge with `rst = 0` is t = 30.
- The master's FSM is a tight three-cycle loop per transaction:
  - Cycle 1: drive `wb_cyc`, `wb_stb`, address, data, `wb_we` (S_WRITE
    or S_READ). Slave's `active` signal goes high on this same edge but
    `wb_ack` is still 0 (slave's non-blocking ack assignment fires
    on the *next* posedge).
  - Cycle 2: slave's `wb_ack` is high; master observes it and tears
    down `wb_cyc`, `wb_stb`, `wb_we`.
  - Cycle 3: bus is idle; master advances `idx` and prepares the next
    transaction.
- 8 writes (`wb_cyc` rising at t = 30, 60, 90, 120, 150, 180, 210, 240)
  + 8 reads (`wb_cyc` rising at t = 280, 310, 340, 370, 400, 430, 460,
  490). Total of 16 transactions in 510 ns.
- `done` asserts at t = 520 ns.

Full machine-checkable contract in [`../fixtures/expected.json`](../fixtures/expected.json).

## Exercise answers

**Part 1 readouts.** At t = 35: `wb_cyc = 1`, `wb_stb = 1`, `wb_we = 1`,
`wb_ack = 0`, `wb_adr = 0x00000000`. At t = 45: `wb_ack = 1`. At t = 55:
`wb_cyc = 0` (bus idle for one cycle before the second write).

**Part 2 transaction table.** Shows 16 transactions exactly as listed
in `decoder_expectations` in [`../fixtures/expected.json`](../fixtures/expected.json).

**Part 3 readback.** `last_read` takes the values 0xCAFE0000, …,
0xCAFE0007 at the 8 read-phase ACK pulses (t = 300, 330, 360, 390,
420, 450, 480, 510 ns).

**Exercise 1.** The `wb_adr` lane has the highest aggregate toggle
count (it changes on every transaction's setup cycle). The data lines
also toggle frequently because the write data and read-data lanes both
sweep through the same `0xCAFE000N` pattern.

A common student answer is "wb_cyc" (because it toggles many times)
— accept that as half-credit but coach them to compare *bit count*
(adr is 32 bits) not just *edge count* in the switching-activity
panel. The lowest-toggling data-line bits are the upper bits of
`0xCAFE` (those bytes never change across the trace).

**Exercise 2.** 3 clock cycles per transaction. The `wb_cyc` rising
edges are spaced 30 ns apart during a phase.

**Exercise 3.** The master sits in either `S_WRITE_ACK` or
`S_READ_ACK` waiting for `wb_ack`. Since there is no timeout and no
abort logic, the master hangs forever and will *not* recover without
a reset. This is a common entry-level Wishbone bug — real bus masters
add a timeout counter or a bus monitor.

## Common student mistakes

- **Reading `wb_we` as part of the transaction type instead of the
  decoder.** Students looking at raw signals can spot read vs write
  via `wb_we`, but should learn to rely on the decoder's READ/WRITE
  label for multi-master / pipelined Wishbone where the raw `wb_we`
  is more subtle.
- **Confusing the address with the data.** Both are 32 bits wide and
  format the same way. Coach: `wb_adr` carries the address (memory
  location); `wb_dat_*` carries the value at that location.
- **Expecting an ack at the same instant as cyc rising.** In
  classic Wishbone the slave needs one cycle to evaluate; the ack
  appears on the *next* posedge after cyc/stb are asserted. (Pipelined
  Wishbone B4 differs.)

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Part 1: all five values at t = 35 correct | 2 |
| Part 2: decoder applied with 16 transactions | 3 |
| Part 3: last_read sequence verified | 1 |
| Exercise 1: address signal identified with reasoning | 2 |
| Exercise 2: 3-cycle transaction count | 1 |
| Exercise 3: master hangs without timeout | 1 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/memory-controller
./build.sh
```
