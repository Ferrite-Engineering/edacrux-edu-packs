# uart-lab: student handout

A UART transmitter sends bytes over a single wire, one bit at a time,
framed by a *start* bit (a single low pulse) and a *stop* bit (a single
high pulse). Between bytes the line idles high.

This lab's transmitter runs at **115_200 baud** with 8 data bits, no
parity, and 1 stop bit ("8-N-1"). With a 50 MHz clock and 434 clock
cycles per bit, the effective bit period is 434 × 20 ns =
**8.68 µs**, and the actual baud rate is 50_000_000 / 434 ≈
**115_207 Hz**, well inside any conforming UART receiver's tolerance.

Four bytes are transmitted: `0x55, 0xAA, 0x55, 0xAA`.

## Setup

1. Launch WaveCrux and choose **File → Open File…** (**Cmd+O** on
   macOS, **Ctrl+O** elsewhere). Select `fixtures/reference.wavecrux`.
   (If the lanes are missing, open `fixtures/reference.vcd` and add
   `tx`, `tx_busy`, `state`, and `tx_data` to the lane panel.) The
   saved session does not include the decoder lane, so Part 2 adds it.

## Part 1: manual framing

The `tx` line is the only signal that physically travels over a UART
cable. Everything else is internal to the transmitter.

1. Move the cursor to **t = 50 ns**. `tx` is high: the line is idle.
2. Move the cursor to **t = 80 ns**. `tx` has just gone low. **This is
   the start bit.** Note the timestamp.
3. Press **E** (with `tx` focused) and step through every transition.
   The cursor lands every 8680 ns or so, on each bit boundary of
   byte 0.

> **Q:** Read off the 8 data bits of the first byte from left to right
> (start at the first bit *after* the start bit). Remember bits are
> sent **LSB first**.
>
> Wire order: _, _, _, _, _, _, _, _
>
> Byte value (assemble MSB-first from the table): 0x_____

If you got `0x55`, you are doing it right.

## Part 2: apply the UART decoder

1. Choose **Tools → Add Protocol Decoder** (**Cmd+Shift+D** on macOS,
   **Ctrl+Shift+D** elsewhere), open the **Serial Bus** group and pick
   **UART**.
2. The Inspector opens on **UART Configuration**. Under **Signal
   Bindings**, set the required `tx` pin to `tb_uart_tx.dut.tx` from its
   **Select signal…** list (`decoders/uart_binding.json` lists it).
3. Under **Parameters**, set **Baud Rate** to `115200` (the default is
   9600). **Data Bits** 8, **Parity** `None` and **Stop Bits** `1` are
   already the defaults. Set **Group Gap (bits)** to `0`: this
   transmitter sends the four bytes back to back, and the default of 10
   merges bytes with a gap shorter than that into one transaction.
4. Click **Add Decoder**. A new lane appears showing decoded frame
   brackets and byte values.
5. Open the transaction table with **View → Toggle Transaction Table**
   (**Cmd+Shift+T** on macOS, **Ctrl+Shift+T** elsewhere).

> **A:** The transaction table should list four BYTE entries:
> 0x__, 0x__, 0x__, 0x__

## Part 3: measure the bit period

1. Focus the `tx` row and press **Home** to return to t = 0.
2. Press **E** to step to the start-bit edge (t = 80 ns). Place marker
   `a` (press **M**, then **A**).
3. Press **E** to step to the next edge (the rising edge after the
   start bit at t ≈ 8760 ns). Place marker `b` (press **M**, then
   **B**).
4. The status bar shows the delta `a → b`.

> **A:** Measured bit period = ______ ns
>
> Implied baud rate = 1 / bit_period = ______ Hz
>
> Tolerance vs nominal 115_200: (measured − 115_200) / 115_200 = ___ %

## Part 4: exercises

### Exercise 1: map ASCII "Hi"

The ASCII letters `H` and `i` are:

- `H` = 0x48 = `0100_1000` (MSB first)
- `i` = 0x69 = `0110_1001` (MSB first)

A UART sends bits **LSB first** on the wire.

> **Q:** Write out the on-the-wire sequence (including start and stop
> bits) for `H` followed by `i`. Use `0` for the start bit and `1` for
> the stop bit. (Total: 20 bits across two frames.)
>
> ___________________________________________________________________

### Exercise 2: what does the FSM state do during idle?

Add `state` to the lane panel and observe its values across the trace.

> **Q:** What `state` value(s) appear between bytes? Why? What about
> at the very beginning of the simulation while `rst_n = 0`?
>
> ___________________________________________________________________

### Exercise 3: wrong baud rate

If a receiver assumes 9600 baud but the transmitter is at 115_200 baud,
how does the misinterpretation manifest? *(You don't need to test this
in WaveCrux, answer conceptually.)*

> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The `tx` lane with the UART decoder applied.
- The transaction table with four BYTE entries.
- Markers `a` and `b` on the first bit period.

Plus your answers to Parts 1, 2, 3, and the three exercises.
