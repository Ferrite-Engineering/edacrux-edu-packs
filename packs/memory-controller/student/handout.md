# memory-controller: student handout

Wishbone is an open-source SoC bus standard widely used in the
RISC-V / OpenCores / LiteX ecosystem. This lab uses the **B4 classic**
variant: a single-cycle handshake with one transaction in flight at a
time.

The five-signal core (master view):

- `wb_adr`: address.
- `wb_dat_o`: data from master to slave (write data).
- `wb_dat_i`: data from slave to master (read data).
- `wb_we`: write enable. 1 = write, 0 = read.
- `wb_cyc + wb_stb`: *cycle in progress* + *strobe valid*.

Plus the slave's response:

- `wb_ack`: acknowledge. Pulses high for exactly one cycle when the
  slave has finished the transaction.

In this lab the master writes 8 known values to memory at byte
addresses `0x00, 0x04, 0x08, ..., 0x1C`, then reads them back in the
same order. Each transaction takes 3 clock cycles (set up, ack,
tear down).

## Setup

1. Launch WaveCrux and choose **File → Open File…** (**Cmd+O** on
   macOS, **Ctrl+O** elsewhere). Select `fixtures/reference.wavecrux`.
   (Or open `fixtures/reference.vcd` and add the signals listed in the
   session file.) The saved session lays out the signals but does not
   include the decoder lane, so Part 2 adds it.
2. The signals are grouped into "control" (`wb_cyc`, `wb_stb`,
   `wb_we`, `wb_ack`), "address_data" (`wb_adr`, `dat_master_to_slave`,
   `dat_slave_to_master`), and "master_state" (`last_read`, `done`).

## Part 1: observe the handshake

1. Move the cursor to **t = 35 ns**. Read `wb_cyc`, `wb_stb`, `wb_we`,
   `wb_ack`, and `wb_adr`.

> **A:** `wb_cyc = __`, `wb_stb = __`, `wb_we = __`, `wb_ack = __`,
> `wb_adr = 0x________`. The master has asserted a *write* transaction
> at address 0; the slave has not yet acknowledged.

2. Move the cursor forward 10 ns to **t = 45 ns**.

> **A:** `wb_ack = __`. The slave has acknowledged. The master will
> tear down `wb_cyc` and `wb_stb` on the next clock edge.

3. Move the cursor to **t = 55 ns**. The first transaction is fully
   complete and the master is preparing the second write.

## Part 2: apply the Wishbone decoder

1. Choose **Tools → Add Protocol Decoder** (**Cmd+Shift+D** on macOS,
   **Ctrl+Shift+D** elsewhere), open the **AMBA** group and pick
   **Wishbone**.
2. The Inspector opens on **Wishbone Configuration**. Under **Signal
   Bindings**, choose **Auto-bind signals**, or pick each pin from its
   **Select signal…** list using
   `decoders/wishbone_binding.json` as the key (`clk`, `rst`, `adr`,
   `dat_o`, `dat_i`, `we`, `sel`, `stb`, `cyc` and `ack`).
3. Under **Parameters**, leave **Revision** at **B3 (Classic +
   bursts)**: this master holds `stb` until `ack` and has no `stall`
   signal, which only **B4 (Pipelined)** uses. Leave **Address Width**
   and **Data Width** at 32.
4. Click **Add Decoder**.
5. Open the transaction table with **View → Toggle Transaction Table**
   (**Cmd+Shift+T** on macOS, **Ctrl+Shift+T** elsewhere).

> **A:** The transaction table should show:
> - 8 WRITEs to addresses 0x00 through 0x1C with data
>   0xCAFE0000–0xCAFE0007.
> - 8 READs to the same addresses with the same data.

## Part 3: verify the readback

1. Add `last_read` to the lane panel (drag from the signal tree,
   path: `tb_mem.u_master.last_read`).
2. Display in **Hexadecimal** format.
3. Press **E** with `last_read` focused. The cursor jumps to every
   readback completion.

> **A:** Confirm `last_read` takes values 0xCAFE0000, 0xCAFE0001, …,
> 0xCAFE0007 at successive ACKs in the read phase.

## Part 4: exercises

### Exercise 1: switching-activity heatmap

Add the bus signals to the lane panel, then choose **Tools → Analyze
Switching Activity** (**Cmd+Shift+A** on macOS, **Ctrl+Shift+A**
elsewhere). The **Activity** tab opens at the bottom, headed
**Switching Activity**, with a **Transitions** column per signal.

> **Q:** Which signal in the bus has the highest toggle count over the
> entire trace? Which has the lowest (among the data lines)? Why?
>
> ___________________________________________________________________

### Exercise 2: count transaction cycles

> **Q:** How many clock cycles does *one* Wishbone B4 transaction take
> in this design (from `wb_cyc` rising to the next rise)? Use the
> cursor delta on consecutive `wb_cyc` rising edges to confirm.
>
> ___________________________________________________________________

### Exercise 3: what if ack never arrives?

(*Conceptual.*) Suppose the memory slave has a bug and never asserts
`wb_ack` for some address.

> **Q:** What does the master's state machine in
> [`../src/wb_master.v`](../src/wb_master.v) do in that case? Will the
> master ever recover without a reset?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The Wishbone decoder applied with at least the first few WRITEs and
  READs visible in the transaction table.
- The `last_read` lane in hex.
- The switching-activity panel with the top-3 toggling signals
  highlighted.

Plus answers to Parts 1, 2, 3, and the three exercises.
