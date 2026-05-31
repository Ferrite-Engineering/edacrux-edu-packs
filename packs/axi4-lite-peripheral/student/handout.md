# axi4-lite-peripheral — student handout

AXI4-Lite is a five-channel subset of the ARM AXI4 bus. Each channel
uses a simple **VALID / READY handshake**:

- The *producer* drives VALID when it has data; the *consumer* drives
  READY when it can accept it.
- A transfer happens on every clock edge where both VALID and READY
  are high.

The five channels:

| Channel | Direction | Purpose |
|---|---|---|
| **AW** (Write Address) | master → slave | `awaddr`, `awvalid`, `awready` |
| **W**  (Write Data)    | master → slave | `wdata`, `wstrb`, `wvalid`, `wready` |
| **B**  (Write Response) | slave → master | `bresp`, `bvalid`, `bready` |
| **AR** (Read Address)  | master → slave | `araddr`, `arvalid`, `arready` |
| **R**  (Read Data + Response) | slave → master | `rdata`, `rresp`, `rvalid`, `rready` |

This lab's peripheral exposes **8 32-bit registers** at word offsets
`0x00, 0x04, …, 0x1C`. Any access outside that range is rejected
with **SLVERR** (response code `2'b10`).

The master walks through five operations:

| # | Operation | Address  | Data       | Expected resp |
|---|-----------|----------|------------|----------------|
| 1 | WRITE     | 0x00     | 0xA0A00000 | OKAY (`2'b00`) |
| 2 | WRITE     | 0x04     | 0xB1B11111 | OKAY |
| 3 | WRITE     | 0xFC     | 0xDEADC0DE | **SLVERR** (`2'b10`) — unmapped |
| 4 | READ      | 0x00     | (= 0xA0A00000) | OKAY |
| 5 | READ      | 0x80     | (sentinel 0xDEADBEEF) | **SLVERR** — unmapped |

## Setup

1. Launch WaveCrux, **File → Open Session…** select
   `fixtures/reference.wavecrux`. (Or open `fixtures/reference.vcd`
   and add the channel signals grouped under aw_channel, w_channel,
   b_channel, ar_channel, r_channel.)

## Part 1 — handshake by hand

1. Move the cursor to **t = 35 ns**. Read `awvalid`, `awready`,
   `wvalid`, `wready`, `awaddr`, `wdata`.

> **A:** `awvalid = __`, `awready = __`, `wvalid = __`, `wready = __`,
> `awaddr = 0x________`, `wdata = 0x________`.

The address phase and data phase fire simultaneously here (slave's
AWREADY and WREADY are both tied high). This is the *fastest*
possible AXI4-Lite write — one clock cycle per channel.

2. Move the cursor to **t = 45 ns**. Read `bvalid` and `bresp`.

> **A:** `bvalid = __`, `bresp = 0b__`.

The slave is acknowledging the write with `BRESP = OKAY`.

## Part 2 — apply the AXI4-Lite decoder

1. Right-click on any channel signal and choose **Add Decoder →
   AXI4-Lite**.
2. WaveCrux loads the binding from
   `decoders/axi4lite_binding.json` with all 19 channel signals.
3. Click **Apply**.
4. Open the **Transaction Table** (**Ctrl+T**).

> **A:** Five transactions appear:
> 1. WRITE 0x00 ← 0x________ ; resp=______
> 2. WRITE 0x04 ← 0x________ ; resp=______
> 3. WRITE 0xFC ← 0x________ ; resp=______
> 4. READ  0x00 → 0x________ ; resp=______
> 5. READ  0x80 → 0x________ ; resp=______

## Part 3 — locate the SLVERR

The third write (to address 0xFC) is the protocol violation. Find it
in the waveform:

1. Press **Home**. Focus the `bresp` row.
2. Press **E** until `bresp` takes the value `2'b10` (the SLVERR
   code).
3. Place marker `slverr_write` here.

> **A:** SLVERR write returned at t = ______ ns. The response channel
> that carries it is the **__** channel.

Similarly, find the SLVERR *read*:

4. Focus the `rresp` row. Press **E** until `rresp` = `2'b10`.
5. Place marker `slverr_read`.

> **A:** SLVERR read returned at t = ______ ns; channel = __.

## Part 4 — exercises

### Exercise 1 — what does the master see?

Add `last_bresp`, `last_rresp`, and `last_rdata` from
`tb_axil.u_master` to the lane panel.

> **Q:** At t = 200 ns, what are the values of `last_bresp`,
> `last_rresp`, and `last_rdata`? What do those final values tell you
> about the master's view of the sequence?
>
> ___________________________________________________________________

### Exercise 2 — why a sentinel?

The slave returns `0xDEADBEEF` for unmapped reads (instead of, say,
zero).

> **Q:** What's the downside of returning zero for an unmapped read?
> What's the downside of `0xDEADBEEF`?
>
> ___________________________________________________________________

### Exercise 3 — channel independence

AXI explicitly allows write and read channels to operate
*independently*. In this trace, every operation completes before the
next begins.

> **Q:** Could the master instead issue a read *while* a write is
> still in flight (e.g. AR fires while waiting for B)? What would
> happen?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The AXI4-Lite decoder applied with all five transactions in the
  table.
- Markers `slverr_write` and `slverr_read` on the two violation
  responses.
- The `last_bresp` / `last_rresp` / `last_rdata` lanes visible.

Plus answers to Parts 1, 2, 3, and the three exercises.
