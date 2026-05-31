# uart-lab — student handout

A UART transmitter sends bytes over a single wire, one bit at a time,
framed by a *start* bit (a single low pulse) and a *stop* bit (a single
high pulse). Between bytes the line idles high.

This lab's transmitter runs at **115_200 baud** with 8 data bits, no
parity, and 1 stop bit ("8-N-1"). With a 50 MHz clock and 434 clock
cycles per bit, the effective bit period is 434 × 20 ns =
**8.68 µs**, and the actual baud rate is 50_000_000 / 434 ≈
**115_207 Hz** — well inside any conforming UART receiver's tolerance.

Four bytes are transmitted: `0x55, 0xAA, 0x55, 0xAA`.

## Setup

1. Launch WaveCrux, **File → Open Session…** select
   `fixtures/reference.wavecrux`. (If it is the placeholder, open
   `fixtures/reference.vcd` and add `tx`, `tx_busy`, `state`, and
   `tx_data` to the lane panel.)

## Part 1 — manual framing

The `tx` line is the only signal that physically travels over a UART
cable. Everything else is internal to the transmitter.

1. Move the cursor to **t = 50 ns**. `tx` is high — the line is idle.
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

## Part 2 — apply the UART decoder

1. Right-click (or long-press) on the `tx` row and choose **Add Decoder
   → UART**.
2. WaveCrux loads the binding from `decoders/uart_binding.json`. The
   parameters are pre-populated: 115_200 baud, 8 data bits, 1 stop bit,
   no parity.
3. Click **Apply**. A new lane appears under `tx` showing decoded
   frame brackets and byte values.
4. Open the **Transaction Table** (View menu or **Ctrl+T**).

> **A:** The transaction table should list four BYTE entries:
> 0x__, 0x__, 0x__, 0x__

## Part 3 — measure the bit period

1. Focus the `tx` row and press **Home** to return to t = 0.
2. Press **E** to step to the start-bit edge (t = 80 ns). Place marker
   `a`.
3. Press **E** to step to the next edge (the rising edge after the
   start bit at t ≈ 8760 ns). Place marker `b`.
4. The status bar shows the delta `a → b`.

> **A:** Measured bit period = ______ ns
>
> Implied baud rate = 1 / bit_period = ______ Hz
>
> Tolerance vs nominal 115_200: (measured − 115_200) / 115_200 = ___ %

## Part 4 — exercises

### Exercise 1 — map ASCII "Hi"

The ASCII letters `H` and `i` are:

- `H` = 0x48 = `0100_1000` (MSB first)
- `i` = 0x69 = `0110_1001` (MSB first)

A UART sends bits **LSB first** on the wire.

> **Q:** Write out the on-the-wire sequence (including start and stop
> bits) for `H` followed by `i`. Use `0` for the start bit and `1` for
> the stop bit. (Total: 20 bits across two frames.)
>
> ___________________________________________________________________

### Exercise 2 — what does the FSM state do during idle?

Add `state` to the lane panel and observe its values across the trace.

> **Q:** What `state` value(s) appear between bytes? Why? What about
> at the very beginning of the simulation while `rst_n = 0`?
>
> ___________________________________________________________________

### Exercise 3 — wrong baud rate

If a receiver assumes 9600 baud but the transmitter is at 115_200 baud,
how does the misinterpretation manifest? *(You don't need to test this
in WaveCrux — answer conceptually.)*

> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The `tx` lane with the UART decoder applied.
- The transaction table with four BYTE entries.
- Markers `a` and `b` on the first bit period.

Plus your answers to Parts 1, 2, 3, and the three exercises.
