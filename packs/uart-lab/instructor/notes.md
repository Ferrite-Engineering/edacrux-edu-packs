# uart-lab — instructor notes

## Learning objectives recap

1. Identify start / data / stop framing in a raw UART waveform.
2. Apply a protocol decoder via the decoder binding.
3. Read decoded transactions from the transaction table.
4. Measure baud rate from cursor markers and compare to nominal.
5. Map between ASCII characters and wire-level UART bytes.

## Stimulus and timing summary

- 50 MHz clock, posedges at multiples of 20 ns starting at t = 20.
- Reset (`rst_n`) held until t = 45 ns. First posedge with reset
  released is t = 60.
- `tx_start` strobed for one cycle right after reset release. The
  FSM transitions IDLE → START at posedge t = 60.
- Each bit takes 434 cycles × 20 ns = 8680 ns. Per byte (10 bits)
  that's 86_800 ns ≈ 86.86 µs.
- Bytes transmitted: 0x55, 0xAA, 0x55, 0xAA.

Key timestamps machine-verified in
[`../fixtures/expected.json`](../fixtures/expected.json):

| Event | Time (ns) |
|---|---|
| IDLE before first byte | 50 |
| Start bit asserted | 80 |
| First data bit (LSB of 0x55 = 1) | ~8760 |
| First stop bit | ~78200 |
| First byte complete (IDLE) | 86880 |

## Exercise answers

**Part 1 wire order.** The first byte (0x55 = 0b01010101) is sent LSB-
first: 1, 0, 1, 0, 1, 0, 1, 0. Assembling MSB-first to read out the
byte value gives `01010101` = 0x55.

**Part 2 transaction table.** Four BYTE entries: 0x55, 0xAA, 0x55,
0xAA.

**Part 3 measurement.**
- Bit period = 8680 ns (or 8.68 µs).
- Implied baud rate = 1 / 8.68e-6 ≈ 115_207 Hz.
- Tolerance vs nominal = (115_207 − 115_200) / 115_200 ≈ 0.006 %.

**Exercise 1.** On-the-wire bit sequence for `Hi` (start + 8 data
LSB-first + stop):
- `H` = 0x48: start=0, data LSB-first = 0,0,0,1,0,0,1,0, stop=1
- `i` = 0x69: start=0, data LSB-first = 1,0,0,1,0,1,1,0, stop=1

Full bitstream: `0 0 0 0 1 0 0 1 0 1` ‖ `0 1 0 0 1 0 1 1 0 1` (20 bits).

**Exercise 2.** Between bytes, `state` stays in IDLE (value 0). During
reset (`rst_n = 0`), the always block resets `state <= IDLE`, so it
also reads 0 even though `tx_busy` is 0 too. Accept any answer that
mentions the FSM is parked in IDLE in both situations.

**Exercise 3.** If the receiver samples at 9600 baud (104.16 µs per
bit) while the transmitter sends at 115_200 baud (8.68 µs per bit),
the receiver samples roughly every 12 transmitter bits. The first
sample lands on the start bit; subsequent samples land deep inside
later bytes' frames. The decoded byte stream is garbage, framing
errors fire constantly (the stop bit slot rarely contains a 1), and
the receiver typically reports an OVERRUN or FRAMING error after one
or two bytes. Accept any answer that mentions the symptoms in terms
of *framing errors*, *garbage data*, or *sample-rate mismatch*.

## Common student mistakes

- **Reading bits MSB-first.** UART is LSB-first. The wire-level first
  bit *after* the start bit is the LSB. A common wrong answer to Part
  1 is `0xAA` (the byte read MSB-first off the wire), which is the
  *bit-reversed* form of `0x55`.
- **Confusing baud rate with bit period.** Baud rate is 1 / bit period
  (in seconds). Students will sometimes write `baud = 8680` (the bit
  period in ns) — push back.
- **Missing the negedge-clk timing in the testbench.** Students who
  read `tb/tb_uart_tx.v` may ask why the test driver uses `@(negedge
  clk)` instead of `@(posedge clk)`. Answer: the testbench drives
  inputs on the falling edge so they are stable for the rising-edge
  sample inside the DUT — a standard testbench idiom that avoids the
  edge-time race.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Decoder applied and transaction table shows 4 bytes | 3 |
| Bit period measurement within 5 % of 8680 ns | 2 |
| Implied baud rate within 5 % of 115_207 | 1 |
| Exercise 1 bit sequence correct (or off-by-1 reversal) | 2 |
| Exercise 2: IDLE reasoning | 1 |
| Exercise 3: framing-error reasoning | 1 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/uart-lab
./build.sh
```
