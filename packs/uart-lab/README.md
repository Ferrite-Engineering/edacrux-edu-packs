# uart-lab

A UART transmitter at 115_200 baud (50 MHz clock,
`CYCLES_PER_BIT = 434`), 8-N-1, transmitting `0x55, 0xAA, 0x55, 0xAA`
over ~350 microseconds. Students identify the start bit, the eight LSB-
first data bits, and the stop bit by eye first; then apply the WaveCrux
UART decoder and read the decoded bytes from the transaction table;
then measure the actual bit period with cursor markers.

- **Difficulty:** intermediate
- **Estimated time:** 75 minutes
- **Prerequisites:** counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The
decoder binding lives in [`decoders/uart_binding.json`](decoders/uart_binding.json).
