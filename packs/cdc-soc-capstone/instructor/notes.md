# Instructor notes — cdc-soc-capstone

## What this assesses

Whether a student can find a CDC bug *without* a CDC linter — from structure and
waveform reasoning — and articulate why the usual green signals (passing sim,
clean lint) do not rule it out. This is deliberately the hardest pack: the tools
that normally catch CDC are absent, which is both a real constraint of the free
toolchain and the pedagogical point.

## The design

- `req` (1 bit) crosses `clk_a`→`clk_b` through `sync2`, a correct two-flop
  synchronizer. **Safe.**
- `data` (8 bits) crosses `clk_a`→`clk_b` with **no synchronizer** — captured
  directly by the consumer on `clk_b`. **Unsafe:** a multi-bit bus sampled
  asynchronously can latch a mix of old and new bits, a value never actually
  present. Intermittent by nature.

The regression checks only the request path, and Verilator has no CDC analysis, so
the design is green and clean while broken — exactly the trap.

## Suggested rubric (100 pts)

- **Domain map (20).** Both domains identified; every crossing found. Full marks
  require finding the `data` crossing, not just the obvious `req` one.
- **The hazard explained (30).** Correct mechanism (multi-bit async capture during
  transition) AND why it is intermittent. Reward students who explain why more
  simulation would not reliably catch it.
- **Why sim/lint miss it (20).** The regression checks the wrong thing; lint has no
  CDC check. Both stated accurately.
- **The fix (30).** A synchronization strategy appropriate to a multi-bit bus
  (handshake, gray code, capture-when-stable), with an argument for why it closes
  the hazard. Reject "add a two-flop sync to each data bit" — that does not fix a
  multi-bit bus and is the classic wrong answer to reward catching.

## What CI verifies vs. what it can't

Verified against the real build: two domains + a two-flop synchronizer in the
structure, the safe-path regression, and the reset state. **Not** verified: the
CDC hazard itself and the deep-link — no free engine detects CDC, and the pack
says so rather than faking a finding. If your institution has a commercial CDC
tool, running it on this design is an excellent extension and will flag the `data`
crossing.

## Common misconceptions

- *"It passes simulation, so CDC is fine."* Async CDC failures are probabilistic;
  a finite simulation can miss them indefinitely. This pack is the counterexample.
- *"Two-flop synchronize every bit of the bus."* Independent per-bit synchronizers
  do not keep the bits coherent — you can still latch a mixed value. Multi-bit
  crossings need a coherent scheme (handshake or gray code). Catching this in a
  student's fix is a key discriminator.
