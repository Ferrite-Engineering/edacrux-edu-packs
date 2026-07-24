# From a lint finding to the structure — a memory controller

**Tools:** LintCrux + NetCrux · **Time:** ~90 minutes
**Files:** `src/mem_ctrl.v`, `src/regfile.v`, `src/addr_decoder.v`

A lint report tells you *that* something is wrong. The structure tells you *what
it means*. This lab is about moving between the two — the thing a single tool
cannot do and the reason the suite exists.

The design is a small register-mapped memory controller: an address decoder
selects one of four registers.

## Setup

```
./build.sh
lintcrux fixtures/lint.json      # the lint report
netcrux  fixtures/netlist.json   # the structure
```

## 1. Read the lint report (LintCrux)

Two findings, both `UNUSEDSIGNAL`:

- `shadow` — a register in the register file.
- `addr` — some bits of the address input.

From the report alone, you cannot yet tell whether either matters. That is the
point: triage needs context.

## 2. The `shadow` register — cross to the structure

`shadow` is flagged unused. Is it harmless, or a wiring mistake that left a
register stranded?

- In NetCrux, open the **`regfile`** module. Count the flip-flop banks
  (`$adffe` cells). How many?
- There are **three** — `ctrl`, `data0`, `data1`. **`shadow` is not there at
  all.** Synthesis saw it drives nothing and dropped it before the netlist even
  existed.

That is the whole lesson in one finding: the linter sees `shadow` in the
*source*; the structure shows it was *already eliminated*. So the finding is
real but harmless — the right fix is to delete the dead declaration and quiet the
warning, not to chase a bug that synthesis already removed.

> This is the cross-probe the suite is built for: on a full LintCrux install you
> would click the `shadow` finding and land on this exact module in NetCrux. In
> this pack you make the jump by hand — same insight, two windows.

## 3. The unused address bits — a different kind of finding

`addr` has unused bits. Cross to the structure again:

- Open **`addr_decoder`**. Which bits of `addr` does it actually use?
- It decodes only the **top nibble** (`addr[7:4]`). The low bits are unused *by
  design* — the register map is nibble-aligned.

So this finding is **intent, not a bug.** The right response is a waiver with a
comment, not a code change. Telling "dead code" (`shadow`) from "deliberate"
(`addr[3:0]`) is exactly the judgement the pair of tools lets you make quickly.

## 4. Make the calls

For each finding, write: fix / waive / delete, and one line of why, *citing what
the structure showed you*.

- `shadow`: delete the dead declaration (structure confirms it is already gone).
- `addr[3:0]`: waive with a comment (structure confirms the nibble-aligned map is
  intended).

## What you should be able to do now

Take a lint finding, cross-probe to the structure that explains it, and let the
two views together tell you whether a finding is dead code, a real bug, or
deliberate design — then make a defensible call for each.
