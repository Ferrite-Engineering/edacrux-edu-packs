# Instructor notes — flaky-test-hunt

## Point of the lab

Two things students must internalise about flaky tests:

1. **Flaky ≠ ignore.** The instinct is "re-run it, it passed, move on." This lab
   makes the flaky test a real, shippable bug so that instinct is visibly wrong.
2. **Flaky has two causes** — a bad testbench or a rare real bug — and the
   engineer's job is to tell them apart before touching anything. Here it is a
   real bug; a good follow-up is to show them a flaky *testbench* (uninitialised
   reg) so they see the other case.

## The bug

`src/sat_add.v` clamps negative overflow to `8'sd127` instead of `-8'sd128`:

```
(sum < -9'sd128) ? 8'sd127 :   // should be -8'sd128
```

It only fires when `a + b < -128`, i.e. two sufficiently negative operands —
roughly one random pair in eight. `random_stress` draws three pairs per run, so
each seed hits the bug with probability ~1 − (7/8)^3 ≈ 33%. Across eight seeds
you get a mix: most pass, a couple fail. That mix *is* the flakiness.

## Answers

- **§1.** `add_small` and `pos_overflow_sat` pass on every seed; `random_stress`
  is mixed → flaky.
- **§2.** A real design bug. The testbench is deterministic per seed and checks
  against a correct reference model, so it is not lying; the design is.
- **§3.** Any seed in the failing set reproduces every time — `$random` is
  seed-deterministic per the LRM.
- **§4.** Negative-overflow saturation constant is wrong (`+127` instead of
  `−128`).
- **§5.** Fixing the constant turns every seed green. Quarantine would also turn
  the bar green, but by suppressing the only test that caught a real bug — the
  teachable trap.

## Why "at least" in the contract

The pack's checkpoints assert `random_stress` passes on ≥1 seed and fails on ≥1
seed, not the exact split. The split is reproducible (LRM `$random`), but pinning
it exactly would make the pack brittle for no pedagogical gain; "genuinely mixed"
is the fact that matters.

## Common misconceptions

- *"Flaky tests are always bad tests."* No — often, as here, the test is doing
  its job and catching a rare real bug. Deleting or quarantining it ships the bug.
- *"If it passes most of the time it is basically fine."* A bug that fails one run
  in three is not a third of a bug; in a nightly regression it fails constantly at
  scale. Rarity is not severity.
