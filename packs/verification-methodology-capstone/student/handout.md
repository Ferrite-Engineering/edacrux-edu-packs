# Capstone: a full verification-methodology pass

**Tools:** all four · **Format:** project (~2-4 weeks)
**Design:** `src/alu_periph.v` and its submodules

The labs taught individual moves. This project is the whole game: take a real
(if small) integrated unit from "here is some RTL" to "here is a defensible
argument that it is correct," using every tool for what it is best at. Your
deliverable is not a green bar — it is a **verification report**.

The design is a register-mapped ALU peripheral: write two operands and an opcode
to registers, read back the result.

## Setup

```
./build.sh
netcrux  fixtures/netlist.json    # structure
lintcrux fixtures/lint.json       # lint baseline
simcrux  fixtures/results.json    # directed regression (green baseline)
wavecrux fixtures/reference.vcd   # waveform
```

## Deliverable 1 — Document the structure (NetCrux)

Produce a one-page structural description of the unit under verification: the
blocks (`decoder`, three `reg4` slots, `alu8`), how an address selects a register,
and how the operands reach the ALU. This is the map your test plan will reference.

## Deliverable 2 — Triage the lint baseline (LintCrux)

The starting design is not clean. For **every** finding, decide fix / waive /
delete and justify it — citing the structure where relevant (as in
`memory-controller-review`). Deliver the decisions as a short table. At least one
finding (`spare`) is genuinely dead; at least one is deliberate. Tell them apart.

## Deliverable 3 — Extend the regression to coverage (SimCrux)

Four directed tests pass today: `add`, `sub`, `and`, `or`. That is not coverage —
it is one point per opcode. Extend the suite to argue the datapath actually works:

- Boundary operands (0, max, carry/borrow cases).
- Each opcode against operands that would expose a wrong connection.
- A back-to-back sequence that proves the registers hold independently.

State, for each new test, *what it would catch that the baseline would not*.

## Deliverable 4 — Justify from the waveform (WaveCrux)

For two of your new tests, use the waveform to show the design did what the test
claims — the right operands arrived, the right opcode was applied, the result
appeared when expected. A test you cannot justify in the waveform is a test you
do not yet trust.

## Deliverable 5 — The report

Tie it together: the structure (what the unit is), the lint decisions (what you
cleaned and why), the coverage argument (what your suite proves and what it still
does not), and the waveform evidence. The grade is the *argument*, not the green
bar — a suite that passes but proves little is worth less than an honest account
of a real coverage gap.

## What this capstone certifies

That you can take an unfamiliar unit and produce a complete, evidence-backed
verification story across structure, static analysis, simulation and waveform —
which is the actual job.
