# Bringing up an SPI link — three tools, one bug

**Tools:** SimCrux + WaveCrux + NetCrux · **Time:** ~2 hours
**Files:** `src/spi_master.v`, `tb/tb_spi.v`

Bring-up is the moment a design first meets reality and reality wins. The link
here *works* — clock toggles, data moves, the slave answers — and yet every byte
comes back wrong. That gap, between "alive" and "correct", is where real hardware
debugging lives, and no single tool closes it. You will use all three.

## Setup

```
./build.sh
simcrux  fixtures/results.json    # the regression
wavecrux fixtures/reference.vcd   # the waveform (session: reference.wavecrux)
netcrux  fixtures/netlist.json    # the structure
```

The design is an SPI **mode-0** master (sample on rising SCLK, shift on falling)
with a loopback slave, so a correct master receives exactly what it sent.

## 1. The symptom (SimCrux)

All three loopback transfers **fail**. Look at what came back:

| sent | received |
|------|----------|
| 0x3C | 0x78 |
| 0xA5 | 0x4A |
| 0xFF | 0xFE |

Do not treat these as three separate failures. Find the *pattern*: in each row,
what is the received value, in binary, relative to the sent value? It is the sent
byte **shifted left by one bit**. One consistent transformation, not three bugs —
that is a strong clue it is a single timing error, not random corruption.

## 2. The timing (WaveCrux)

A one-bit shift in a serial link is almost always a *sampling-edge* problem. Open
the session and find one transfer.

- Chip-select (`cs_n`) drops, then SCLK runs for eight cycles.
- In mode 0 the master should **sample MISO on each rising SCLK edge.** Line up
  the MISO transitions against the SCLK rising edges.
- Count: at the first rising edge, is a valid data bit present yet, or does the
  first sample land before the first bit — so the receiver misses the MSB and
  clocks in one extra bit at the end? A byte that loses its MSB and gains a
  trailing bit is exactly a left-shift by one.

The waveform tells you *when* the sampling is wrong. Now find *where*.

## 3. The structure (NetCrux)

```
netcrux fixtures/netlist.json
```

- `spi_master` is built from **two shift registers** — one drives MOSI, one
  captures MISO. Identify the **receive** one.
- Its shift enable is what decides *which* SCLK edges clock a bit in. Trace that
  enable. The one-SCLK-late sampling you saw in the waveform is a property of
  when this register is told to shift.

## 4. Form the fix

You now have three facts about one bug: a consistent left-shift (SimCrux), a
sample that lands one edge too late (WaveCrux), and the receive shift register's
enable timing (NetCrux). Write, in two sentences: what is the root cause, and
what one change fixes it? (You do not have to land the fix perfectly — forming a
*grounded* hypothesis from all three views is the skill.)

## What you should be able to do now

Read a bring-up failure as a pattern, not noise; use a waveform to place a timing
error against clock edges; localise it to a specific block in the structure; and
synthesise the three into a single, defensible root-cause hypothesis.
