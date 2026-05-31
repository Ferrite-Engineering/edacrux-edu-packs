# cocotb-driven-testbench — student handout

[Cocotb](https://www.cocotb.org/) is a Python-based testbench
framework. Instead of writing testbenches in Verilog or VHDL,
verification engineers describe stimulus and checks in Python while
the device-under-test runs in their favourite simulator (Icarus,
Verilator, VCS, Questa, …).

Cocotb tests usually emit *structured log messages* through Python's
standard `logging` module. WaveCrux can load this log alongside the
VCD and overlay the log lines on the waveform canvas — clicking a
log line jumps the cursor to the timestamp in the log entry.

This lab's design under test is a UART receiver. The cocotb test
(documented in [`../tb/test_uart_rx.py`](../tb/test_uart_rx.py))
sends four bytes — 0x55, 0xAA, 0x55, 0xAA — into the receiver and
asserts each one is received correctly. The log it produced is in
`fixtures/cocotb_run.log`.

## Setup

1. Launch WaveCrux, **File → Open…** select
   `fixtures/reference.vcd`. The lane panel should show `rx`,
   `state`, `rx_data`, `rx_valid`, `clk`, `rst_n`.
2. **File → Open Cocotb Log…** and select
   `fixtures/cocotb_run.log`. WaveCrux parses the file and opens a
   *Cocotb Log* panel below the waveform.

## Part 1 — observe the overlay

Each log line in the Cocotb Log panel shows:

- A simulation-time prefix (e.g. `82620.00ns`).
- A severity (INFO, DEBUG, etc.).
- A logger name (e.g. `UartRxTest`).
- The message body.

Scroll through the log panel. The lines are color-coded by severity.

Look at the waveform canvas: every log line is rendered as a tick mark
on a "log overlay" rail above the waveform lanes. Hover over a tick
to see its message.

## Part 2 — click to jump

1. Find the log line:
   ```
    82620.00ns INFO     UartRxTest                         Received byte 0x55 (expected 0x55)
   ```
2. **Click on that line** in the Cocotb Log panel.
3. The cursor on the waveform canvas jumps to t = 82620 ns.
4. Observe the value column: `rx_valid = 1`, `rx_data = 0x55`. The
   log entry matches the simulator state at that exact tick.

## Part 3 — filter by severity

1. At the top of the Cocotb Log panel, find the severity filter
   chip group (INFO, DEBUG, WARNING, ERROR).
2. **Disable DEBUG.** The log shrinks to just the INFO and higher
   lines — the high-level test narrative.
3. Re-enable DEBUG. Now the per-bit driving messages reappear.

## Part 4 — filter by keyword

1. In the search box at the top of the Cocotb Log panel, type
   `Received`.
2. Only the four "Received byte" lines remain.
3. Click each in turn and watch the cursor visit the four byte-
   completion events.

## Part 5 — exercises

### Exercise 1 — first stop bit

> **Q:** The cocotb log says the *first* stop bit is driven at
> `78265.00ns`. Click that line. What time does the cursor land on?
> What value does `rx` hold at that moment, and what is the receiver
> FSM state?
>
> ___________________________________________________________________

### Exercise 2 — the inter-byte gap

> **Q:** The log line `83620.00ns INFO     UartRxTest   Sending
> byte 0xAA` corresponds to the moment the testbench begins driving
> the second byte. How many nanoseconds *after* the first byte's
> `Received byte 0x55` line (at 82620 ns) does this occur? Does
> that match the `await Timer(1000, units="ns")` line in
> [`../tb/test_uart_rx.py`](../tb/test_uart_rx.py)?
>
> ___________________________________________________________________

### Exercise 3 — what would a FAIL log look like?

The current log ends with:

```
347020.00ns INFO     UartRxTest                         All four bytes received correctly. Test PASSED.
```

> **Q:** Suppose the receiver had a bug that mis-decoded the second
> byte as 0xCC instead of 0xAA. What single log line would you
> expect to see, and where would it appear in the log (relative to
> the byte that failed)?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The Cocotb Log panel below the waveform, with the DEBUG severity
  filter toggled off.
- The cursor positioned exactly on the `Received byte 0xAA` log line
  for the fourth byte (t = 346020 ns).

Plus answers to Exercises 1, 2, and 3.
