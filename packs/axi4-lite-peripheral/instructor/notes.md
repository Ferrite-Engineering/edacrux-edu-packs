# axi4-lite-peripheral — instructor notes

## Learning objectives recap

1. Recognize the five AXI4-Lite channels and their VALID/READY
   handshakes.
2. Apply the AXI4-Lite decoder with a complete 19-signal binding.
3. Read decoded WRITE / READ transactions including response codes.
4. Identify protocol-violation (SLVERR) markers on the B and R
   channels.

## Timing summary

- 100 MHz `aclk`, posedges at multiples of 10 ns starting at t = 10.
- Active-low `aresetn` released at t = 22; first valid posedge t = 30.
- Per-channel handshake characteristics in this design:
  - AWREADY and WREADY are tied high — slave accepts AW + W in 1 cycle.
  - BVALID asserts the cycle *after* a write commits and is held
    until BREADY pulses (the master holds BREADY high during
    `S_*_RESP`).
  - ARREADY = !RVALID — slave only accepts a new read while no
    prior R is pending.
  - RVALID asserts the cycle after AR is accepted.

Per-transaction timing (machine-verified in
[`../fixtures/expected.json`](../fixtures/expected.json)):

| # | Op | Addr   | Data       | AW@ | B@  | Resp  |
|---|----|--------|------------|-----|-----|-------|
| 1 | W  | 0x00   | 0xA0A00000 | 30  | 40  | OKAY  |
| 2 | W  | 0x04   | 0xB1B11111 | 60  | 70  | OKAY  |
| 3 | W  | 0xFC   | 0xDEADC0DE | 90  | 100 | SLVERR |
| 4 | R  | 0x00   | (=0xA0A00000) | AR@120 | R@130 | OKAY |
| 5 | R  | 0x80   | (sentinel) | AR@150 | R@160 | SLVERR |

`done` asserts at t = 180.

## Exercise answers

**Part 1 (t = 35 ns).** `awvalid=1`, `awready=1`, `wvalid=1`,
`wready=1`, `awaddr=0x00000000`, `wdata=0xA0A00000`. The address and
data channels fire simultaneously.

**Part 1 (t = 45 ns).** `bvalid=1`, `bresp=2'b00` (OKAY).

**Part 2 transaction table.** Exactly as listed in
`decoder_expectations` in [`../fixtures/expected.json`](../fixtures/expected.json):

1. WRITE 0x00 ← 0xA0A00000 OKAY
2. WRITE 0x04 ← 0xB1B11111 OKAY
3. WRITE 0xFC ← 0xDEADC0DE SLVERR
4. READ  0x00 → 0xA0A00000 OKAY
5. READ  0x80 → 0xDEADBEEF SLVERR

**Part 3.** SLVERR write at t = 100 ns on the **B** channel.
SLVERR read at t = 160 ns on the **R** channel.

**Exercise 1.** At t = 200: `last_bresp = 2'b10`, `last_rresp = 2'b10`,
`last_rdata = 0xDEADBEEF`. These reflect the *most recent* response
the master saw — which happened to be SLVERR for both. The master
did not propagate any errors back to a higher-level controller; in a
real system this is the kind of latent failure that a fabric monitor
or HW Watchdog should catch.

**Exercise 2.** Returning **zero** for an unmapped read makes
unmapped accesses indistinguishable from accessing a register
holding the value 0 — a stealthy correctness bug. Returning
`0xDEADBEEF` is a *sentinel*: software that sees `0xDEADBEEF` knows
it likely just hit an unmapped address. The risk is that some valid
register *could* legitimately hold `0xDEADBEEF` after software
writes that value, creating a small ambiguity. The best practice
(beyond this lab) is to **always** check `RRESP` and treat any
non-OKAY response as an error, rather than relying on the data
sentinel.

**Exercise 3.** Yes — AXI explicitly allows interleaving across
channels. AR could fire while B is still in flight (or vice-versa).
A naive single-thread master like this one would need state-machine
changes to support that; the decoder, however, can handle it because
it tracks per-channel valid/ready events independently. In real
systems, multiple outstanding reads & writes are common for
performance.

## Common student mistakes

- **Reporting the BRESP channel as "the response channel."** It *is*
  one of the two response channels (the other is R). Coach: B
  carries write responses; R carries read data *and* the read
  response in one combined channel.
- **Looking at the wrong cycle for the SLVERR.** A common mis-reading
  is to point to the AW or W channel at the time the unmapped write
  is issued. The error is reported on the *response* (B/R), not on
  the *request*.
- **Confusing AWVALID with AWREADY.** Use the producer / consumer
  framing: the master *produces* (drives AWVALID); the slave
  *consumes* (drives AWREADY).

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| Part 1 (t=35 + t=45) handshake readout correct | 2 |
| Part 2 decoder transaction table complete (5 rows) | 3 |
| Part 3 both SLVERR markers placed correctly | 2 |
| Exercise 1: last_* interpretation | 1 |
| Exercise 2: zero vs sentinel discussion | 1 |
| Exercise 3: channel-independence answer | 1 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/axi4-lite-peripheral
./build.sh
```
