# Instructor notes — regression-hello-world

## Point of the lab

Establish the baseline. Students often meet regressions for the first time when
one is *failing* and they are under pressure to fix it. This lab deliberately
starts from an all-green suite so they learn the dashboard, the summary fraction,
and the shape of a directed test with nothing broken — then break it themselves
in §4 under controlled conditions.

## Answers

- **§1.** Six tests, six pass, zero fail.
- **§2.** `add_carry` is 15 + 1 = 16; the sum needs 5 bits because two 4-bit
  operands can carry out. A good moment to reconnect to the width lesson from the
  WaveCrux/NetCrux intro packs.
- **§3.** `sub_zero`: 0 − 0 = 0, `op = 2'd1`. Passes. It exists to cover the
  boundary where subtraction could underflow — a case worth having even though it
  looks trivial.
- **§4.** Replacing subtract with add makes `sub_basic` (9 − 4, expects 5, now
  gets 13) and `sub_zero` (0 − 0, expects 0, still 0 — this one **stays green**)
  behave differently. Ask students to predict which sub tests fail before they
  run: `sub_basic` fails, `sub_zero` passes by coincidence because 0+0 = 0−0.
  That coincidence is a real lesson — a passing test does not prove correctness,
  it only fails to disprove it.

## Common misconceptions

- *"All green means the design is correct."* No — it means the design passes the
  tests you wrote. §4's `sub_zero` staying green under a broken subtract is the
  concrete counterexample. Coverage, not a green bar, is what bounds confidence.
- *"A regression is a special SimCrux thing."* It is just running a testbench
  suite and collecting results. SimCrux manages and dashboards them at scale; the
  loop is the same one they would run by hand.

## Note on the fixture

`fixtures/results.json` is produced by `build.sh` from a real Icarus run. The
contract asserts the six outcomes; CI reruns the suite, so if the RTL or a test
changes the dashboard the pack advertises changes with it.
