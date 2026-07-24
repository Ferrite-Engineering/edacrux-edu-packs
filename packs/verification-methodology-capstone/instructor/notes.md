# Instructor notes — verification-methodology-capstone

## What this assesses

Whether a student can run a *complete* verification pass, not perform isolated
moves. The design is deliberately small so the effort goes into methodology and
argument, not into understanding a large RTL. The grade is the report; the tools
are how evidence is gathered.

## Suggested rubric (100 pts)

- **Structural description (15).** Correct blocks and dataflow; the address map
  explained. Full marks require it to read as a map a test plan could use.
- **Lint triage (20).** Every finding addressed with a fix/waive/delete and a
  reason. Full marks require citing the *structure* to justify at least the
  `spare` (dead) vs `addr[3:0]`/`ctrl[7:2]` (intent) distinction.
- **Coverage extension (30).** New tests that argue coverage, each with a stated
  purpose. Reward tests that would catch a *wrong connection* (e.g. operands
  swapped, opcode misdecoded), not just more arithmetic. Penalise volume without
  intent.
- **Waveform justification (15).** Two tests shown to exercise what they claim.
- **The report (20).** Ties the four views into one argument, and — importantly —
  is honest about remaining gaps. An accurate "here is what I did not cover" beats
  a false "fully verified."

## The baseline (what CI checks)

- Structure: `alu_periph` integrates `decoder`, three `reg4`, one `alu8`.
- Lint: findings present, including the dead `spare` register.
- Regression: the four directed tests pass (green baseline).
- Waveform: result bus idle (0) at reset.

These are verified so the starting point can never silently rot. The student
deliverables are yours to assess — the verifier does not grade the project.

## On the cross-tool step

The one declared deep-link (coverage gap in SimCrux → the ALU/operand structure in
NetCrux) is not machine-verified, consistent with the other cross-tool packs:
verifying a live cross-probe needs the apps under automation the suite does not yet
expose. Each tool's baseline facts ARE verified against its real engine output.

## Scaling the project

To make it harder: inject a real bug (swap two register selects, or misdecode one
opcode) so a rigorous coverage suite is *required* to catch it, and grade partly on
whether the student's suite would have found it. The fixtures rebuild from source,
so any RTL change reflows every tool's baseline.
