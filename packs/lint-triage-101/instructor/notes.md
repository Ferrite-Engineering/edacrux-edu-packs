# Instructor notes — lint-triage-101

## Point of the lab

Triage, not linting. Students can run a linter in one command; what they cannot
yet do is look at a report and know what to care about. The design is seeded so
the report contains exactly one finding that is a real (latent) bug and two that
are pure noise, of the same superficial "warning" severity — so the lesson is
that **severity label ≠ importance**, and judgement is required.

## The seeded findings

| Rule | Where | Kind | Right call |
|------|-------|------|-----------|
| `UNUSEDSIGNAL` (`debug_count`) | reg declared, never used | cosmetic | delete or waive |
| `UNUSEDSIGNAL` (`almost`) | computed, never read | cosmetic | delete or waive |
| `WIDTHEXPAND` | `level > 3'd2`, 4-bit vs 3-bit | latent bug | fix |

## Answers

- **§1.** Three findings; `UNUSEDSIGNAL` is the most common (two of three).
- **§2.** `debug_count` (line ~22) and `almost` (line ~33). Neither affects
  behaviour.
- **§3.** The `WIDTHEXPAND` on `level > 3'd2`. `level` is 4 bits (`wptr - rptr`),
  the constant is 3 bits. Verilator zero-extends the constant, so it happens to
  behave here — but the moment someone widens `level` or changes the constant,
  the comparison silently misbehaves. That "works today, breaks on the next
  edit" quality is exactly what makes it a latent bug worth fixing now.
- **§5.** Defensible triage: fix the width mismatch (make both sides the same
  width explicitly); delete the two unused signals, or waive them with a comment
  if they are placeholders for planned features.

## Common misconceptions

- *"They are all warnings, so they are all equally minor."* The whole lab is the
  counter to this. Severity is the linter's guess at importance; triage is the
  engineer's judgement, and the two diverge constantly.
- *"Unused signals are bugs."* Usually not — they are noise. The danger is that
  a hundred of them bury the one finding that is a bug. Cleaning noise is about
  making real bugs findable, not about the noise itself.

## Note on the fixture

`fixtures/lint.json` is produced by `build.sh` from real Verilator output. Newer
Verilator versions may add findings; the pack's contract uses "at least" counts
and presence checks, not exact totals, so it stays green across engine versions
rather than breaking every time the linter improves.
