# When the test is wrong — a UART verification loop

**Tools:** SimCrux + WaveCrux · **Time:** ~90 minutes
**Files:** `src/uart_tx.v`, `tb/tb_uart.v`

A red test is not proof the design is broken. It is proof that the design and the
*test* disagree — and either one can be wrong. This lab is a case where the test
is wrong, and the discipline for finding that out instead of "fixing" a design
that was already correct.

## Setup

```
./build.sh
simcrux  fixtures/results.json    # the regression
wavecrux fixtures/reference.vcd   # the waveform (session: reference.wavecrux)
```

The design is a UART transmitter (8N1). The suite sends three bytes and checks
each on the receive side.

## 1. The red bar (SimCrux)

Open the dashboard. Two tests pass; **`tx_0xFF` fails**.

The reflex is "the transmitter is broken for 0xFF." Resist it. You have not
looked at what the transmitter actually did — only at a test's verdict.

## 2. Follow the failure to the waveform (WaveCrux)

This is the cross-probe the pair is built for: from the failing `tx_0xFF`, go to
the waveform of that transmission. Open the session (`reference.wavecrux`) — it
arranges `state`, `data`, `busy`, `tx` and the captured `rx`.

- Find the transmission of `0xFF`. Read the serial line **`tx`** bit by bit
  through the data phase: start bit (0), then eight data bits LSB-first, then the
  stop bit (1).
- For `0xFF`, every data bit is 1. What did the DUT actually put on the line?

It sent `0xFF` — correctly. The transmitter is fine.

## 3. So why did the test fail?

Read the check in `tb/tb_uart.v` for `tx_0xFF`. What byte did the testbench
*expect*?

- It expected **`0x00`**. That expectation is wrong — a copy-paste or a sign
  slip in the test, not the design. The DUT sent `0xFF`, the test wanted `0x00`,
  the test lost.

The waveform is what let you tell "the DUT is wrong" from "the test is wrong."
Without it you might have spent an afternoon debugging a correct transmitter.

## 4. Fix the right thing

Change the `tx_0xFF` expectation in the testbench from `0x00` to `0xFF`. Rebuild.

- The bar goes green — because you fixed the test, not the DUT. Confirm you did
  not touch `src/uart_tx.v`.

## What you should be able to do now

Treat a failing test as a question, not a verdict; cross-probe from the failure
to the waveform; decode a serial line to see what really happened; and decide —
with evidence — whether to fix the design or the test.
