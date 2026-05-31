# cocotb-driven-testbench

A small UART receiver design with two artifacts: a `reference.vcd`
produced by a pure-Verilog testbench, and a `cocotb_run.log` file
that documents the *equivalent* cocotb test run with time-stamped
log messages. Students load both into WaveCrux and use the cocotb-
log-correlation feature to scrub between log lines and waveform
events.

> **Note on dependencies.** This pack does NOT require cocotb to be
> installed to build. The companion `tb/test_uart_rx.py` documents
> the cocotb test (and is runnable independently), but the build
> pipeline uses the pure-Verilog `tb/tb_uart_rx.v` to produce the
> VCD.

- **Difficulty:** advanced
- **Estimated time:** 90 minutes
- **Prerequisites:** uart-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough.
