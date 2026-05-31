# spi-lab — instructor notes

## Learning objectives recap

1. Identify CPOL and CPHA from a raw SPI waveform.
2. Apply the SPI protocol decoder with the right mode.
3. Reason about the role of CS_n in framing transfers.
4. Diagnose mode-mismatch failures.

## Stimulus and timing summary

- 50 MHz `clk`, posedges at multiples of 20 ns starting at t = 20.
- Reset (`rst_n`) held until t = 45 ns; first valid posedge at t = 60.
- Master FSM walks IDLE → SETUP → BIT_LO → BIT_HI → … pattern.
  - Each SCLK half-period is 5 system cycles = 100 ns.
  - Full SCLK period = 200 ns → 5 MHz SCLK.
  - Each byte takes 1620 ns of SCLK plus a 60 ns CS-setup time
    (CS_n drops at t=60 of each byte, SCLK starts at +120, lasts
    1600 ns).
- Inter-byte gap: 400 ns with CS_n high.
- Bytes complete (CS_n rises) at t = 1680, 3720, 5760, 7800 ns.

The slave samples MOSI on rising SCLK edges, shifts into rx_shift, and
latches the byte into `last_byte` at every CS_n rising edge.

Full machine-checkable contract in [`../fixtures/expected.json`](../fixtures/expected.json).

## Exercise answers

**Part 1 — CPOL.** CPOL = 0 because SCLK idles low. (If SCLK idled
high, that would be CPOL = 1.)

**Part 1 — CPHA.** At t = 180 ns (the first rising edge of SCLK), MOSI
= 0 — which is the MSB of 0x12. So the slave samples MOSI on the
*rising* edge of SCLK, and the master changed MOSI before the rising
edge (in fact at the *previous* falling edge, but the first falling
edge happens at CS_n drop). That means CPHA = 0 (sample on first
SCLK edge after CS_n drops).

**Part 2 — decoded transactions.** 0x12, 0x34, 0x56, 0x78.

**Part 3 — slave's last_byte.** 0x12 → 0x34 → 0x56 → 0x78 at CS_n
rising edges t = 1680, 3720, 5760, 7800 ns. Exactly matches the
decoder transaction table.

**Exercise 1 — wrong CPOL.** With CPOL = 1, the decoder treats the
*falling* edge as the sampling edge. Since the data line transitions
right after the SCLK edge it samples on, the decoder reads either
the next bit or hold-time-violation undefined bits. The transaction
table either shows garbage or reports protocol-violation markers
(depending on decoder build).

Accept any answer that mentions: "decoder reads the wrong bit
because it samples on the wrong edge" or "protocol violation /
framing error."

**Exercise 2.** SCLK period = 200 ns. Frequency = 1 / 200e-9 = 5 MHz.

**Exercise 3.** LSB-first bit-reversal:
- 0x12 = 0b00010010 → 0b01001000 = 0x48
- 0x34 = 0b00110100 → 0b00101100 = 0x2C
- 0x56 = 0b01010110 → 0b01101010 = 0x6A
- 0x78 = 0b01111000 → 0b00011110 = 0x1E

So LSB-first interpretation: 0x48, 0x2C, 0x6A, 0x1E.

## Common student mistakes

- **Confusing CPHA with which edge the master *outputs* on.** CPHA
  is conventionally described by which edge the slave *samples* on.
  In mode 0 (CPHA=0), the slave samples on the *first* SCLK edge
  after CS_n drops (the rising edge in this case). Coach: focus on
  the sampling edge.
- **Looking at the wrong byte for the first transfer.** The very
  first MOSI bit is presented when CS_n drops at t = 60, *before*
  any SCLK edge. So a student who places the cursor at t = 60 and
  reads MOSI = 0 is reading the MSB correctly, but might think the
  decoder should also report a bit at t = 60. The decoder waits for
  the first sample edge (t = 180) before reporting.
- **Mode 0 vs mode 2 confusion.** CPOL=0/CPHA=0 (mode 0) vs CPOL=1/
  CPHA=0 (mode 2) differ in idle SCLK but both sample on the *first*
  SCLK edge after CS_n drops. Mode 0 / mode 3 share sampling on
  rising / falling first-edge but differ in idle SCLK. The four
  modes table is in any SPI textbook — surface it if students get
  tangled.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| CPOL identified correctly (Part 1) | 1 |
| CPHA identified correctly (Part 1) | 1 |
| Decoder applied with 4 correct bytes (Part 2) | 3 |
| Slave last_byte matches decoder (Part 3) | 1 |
| Exercise 1: wrong-mode reasoning | 1 |
| Exercise 2: 200 ns / 5 MHz | 1 |
| Exercise 3: bit-reversed bytes correct | 2 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/spi-lab
./build.sh
```
