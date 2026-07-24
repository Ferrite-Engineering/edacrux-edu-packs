# Triaging a lint report

**Tool:** LintCrux · **Time:** ~60 minutes · **Files:** `src/sync_fifo.v`

A linter will happily hand you fifty findings. The skill that matters is not
running it — it is *triage*: reading the report, telling the real problems from
the noise, and deciding what to fix, waive, or ignore. This lab is that skill on
a small, honest example.

## Setup

```
./build.sh                    # lint the FIFO, produce the report
lintcrux fixtures/lint.json   # open the unified report
```

The design is a small synchronous FIFO (`src/sync_fifo.v`). It works — but it is
not clean.

## 1. Read the whole report

Look at the violation table. How many findings are there? What rules fired?

- Open the **by-rule breakdown**. Which rule accounts for the most findings?

## 2. The unused signals

Two findings are `UNUSEDSIGNAL`:

- `debug_count` — a register declared and never touched. Leftover scaffolding.
- `almost` — a flag that is computed and then never read.

Both are *cosmetic*: they do not change what the FIFO does. But they are noise,
and noise is where real bugs hide. In the RTL, find both and decide: delete, or
keep and waive?

## 3. The finding that is actually a bug

One finding is different in kind: a `WIDTHEXPAND` (width mismatch). A 4-bit value
is compared against a 3-bit constant.

- Find it in `src/sync_fifo.v`. Why is a width mismatch a *latent bug* and not
  just style? Think about what happens at the boundary values.
- This is the whole point of triage: the width mismatch matters more than the two
  unused signals combined, even though it is one finding against two.

## 4. Filter like you would on a real project

- Filter the table to **just `UNUSEDSIGNAL`**. Confirm the two you found.
- Filter to **just `WIDTHEXPAND`**. Confirm the one.
- On a real design with hundreds of findings, this filtering is how you carve a
  wall of warnings into a to-do list.

## 5. Make the calls

Write down, for each of the three findings: fix / waive / ignore, and one line
of why. There is no single right answer — triage is judgement — but a defensible
call is: fix the width mismatch, delete or waive the two unused signals.

## What you should be able to do now

Open a lint report, read and count the by-rule view, filter by rule and severity,
and — the real skill — separate findings that are latent bugs from findings that
are only noise.
