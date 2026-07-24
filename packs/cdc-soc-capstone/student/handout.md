# Capstone: find the CDC that the tools won't

**Tools:** all four · **Format:** project (~2-4 weeks)
**Design:** `src/soc_top.v` and its submodules

Everything green is not everything correct. This SoC **compiles, simulates, and
lints clean** — and it still has a clock-domain-crossing bug that will cause
intermittent, un-reproducible failures in silicon. Your job is to find it with
the tools that *can* show it (structure and waveform), because the tools that
usually catch CDC are not in this toolchain. Your deliverable is a **CDC analysis
report**.

## The system

Two clock domains:

- **`clk_a`** — a producer that counts, emitting a `req` pulse and an 8-bit
  `data` word.
- **`clk_b`** — a consumer that captures `data` when it sees the request.

Between them sits a synchronizer.

## Setup

```
./build.sh
netcrux  fixtures/netlist.json    # structure — start here
wavecrux fixtures/reference.vcd   # waveform  (session: reference.wavecrux)
simcrux  fixtures/results.json    # regression (green — and misleading)
lintcrux fixtures/lint.json       # lint      (clean — and misleading)
```

## Deliverable 1 — Map the domains (NetCrux)

From the structure, establish which logic is clocked by `clk_a` and which by
`clk_b`, and find **every** signal that crosses between them.

- The `req` bit crosses through a **two-flop synchronizer** (`sync2`). Confirm it
  is two flip-flops in series — the correct structure for a single-bit crossing.
- The `data` bus crosses too. Through what? Trace it from the producer to the
  consumer's capture register. Is there a synchronizer on it?

## Deliverable 2 — Show why the simulation lies (SimCrux + WaveCrux)

The regression is green. But look at what it checks: that the *synchronized
request* works, not that the *captured data* is correct. In the waveform:

- `data` changes on every `clk_a`. The consumer captures it on a `clk_b` edge.
- Because the two clocks are asynchronous, a `clk_b` capture can land while `data`
  is mid-change across several bits at once. What value gets captured then?

A single-bit crossing can only be 0-or-1 wrong; a **multi-bit** bus crossing
unsynchronized can capture a value that was *never actually on the bus* — some
bits old, some new. That is the hazard, and it is invisible to a test that only
checks the request path.

## Deliverable 3 — Explain why lint didn't catch it

Run LintCrux. It reports no CDC problem. In two sentences: why not? (The report is
empty of CDC findings for a real reason — state it. A clean lint is evidence about
the checks that ran, not proof of what they didn't check.)

## Deliverable 4 — The analysis report

Deliver a CDC analysis of the SoC:

- Every clock-domain crossing, classified **safe** or **unsafe**, with the
  structural evidence.
- For the unsafe one: the failure mechanism (multi-bit capture during transition),
  and *why it is intermittent* — why it might pass a thousand simulations and fail
  in the lab.
- A fix: what synchronization the data path needs (e.g. a request/acknowledge
  handshake, a gray-coded pointer, or capturing only when data is known stable),
  and why your fix closes the hazard the two-flop request sync does not.

## What this capstone certifies

That you can find a clock-domain-crossing bug in a design that passes every
automated check available — by reasoning from structure and timing — and explain
it well enough that someone else would trust your fix. That is the CDC skill, and
it does not go away when the automated tools are missing.
