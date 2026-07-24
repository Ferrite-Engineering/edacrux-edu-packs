# Instructor notes — spi-bringup

## Point of the lab

The capstone skill of the Tier-B pairs, made explicit: **no single view is
enough.** SimCrux says *what* is wrong (every byte left-shifted), WaveCrux says
*when* (the sample lands one SCLK too late), NetCrux says *where* (the receive
shift register's enable). A student who tries to fix this from any one view alone
will flail; the lab rewards triangulation.

## The bug

The receive shift register begins clocking one SCLK edge later than it should, so
it misses the first (MSB) MOSI bit and clocks in one extra bit before the transfer
ends. The result is a consistent `received = (sent << 1) & 0xFF` — which is
exactly the table students see (0x3C→0x78, 0xA5→0x4A, 0xFF→0xFE).

Root cause is the sample-enable timing on `u_rx`: the `rise` strobe that shifts
the receive register is not aligned to the first valid MOSI bit. A correct fix
presents the first bit before, or samples from, the first rising edge — options
include priming the receive register on chip-select assertion, or shifting the
enable one SCLK earlier. There is more than one defensible fix; grade the
*reasoning across the three views*, not a single expected diff.

## Answers

- **§1.** The pattern is a left-shift by one bit; one timing bug, not three.
- **§2.** The first rising-edge sample lands before the first MOSI bit is valid,
  so the MSB is missed and a trailing bit is gained.
- **§3.** `u_rx` (the MISO shift register); its `shift`/`rise` enable timing.
- **§4.** Any answer that names the receive sample timing as the cause and
  proposes aligning it earlier is correct. Reject answers that blame the slave,
  the MOSI path, or "noise" — the waveform rules those out.

## On the cross-tool steps

Each tool's own facts are machine-verified: the three failing transfers against
the simulator, chip-select idle against the VCD, the two shift registers against
the netlist. The two deep-links (failing test → waveform, waveform → receive
register) are declared but not machine-verified — a live cross-probe needs the
apps driven under automation, which the suite does not yet expose. All three
fixtures come from one build, so the failure, waveform and structure are
guaranteed to be the same bring-up.

## Common misconceptions

- *"Three failures means three bugs."* The consistent transform is the tell —
  one root cause. Teaching students to look for the pattern before diving in is
  half the lab.
- *"The clock is running and data is moving, so timing is fine."* Alive is not
  correct. Mode-0 SPI is unforgiving about *which* edge samples; a link can be
  fully active and still off by one edge.
