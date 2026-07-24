# Instructor notes — memory-controller-review

## Point of the lab

The single move worth teaching: **a lint finding is a question, and the structure
is often the answer.** Students who only lint learn to silence warnings; students
who can cross-probe learn to *resolve* them. The two findings are chosen to give
opposite answers — one is dead code, one is intent — so the lesson is that lint
severity alone cannot tell them apart.

## The two findings

| Finding | What the structure shows | Right call |
|---|---|---|
| `UNUSEDSIGNAL` on `shadow` | not in the netlist at all — synthesis dropped it | delete the dead declaration |
| `UNUSEDSIGNAL` on `addr[3:0]` | decoder uses only `addr[7:4]` — nibble-aligned map | waive with a comment (intent) |

## Answers

- **§2.** `regfile` has three `$adffe` banks (`ctrl`, `data0`, `data1`). `shadow`
  is absent — it drives nothing, so `opt` eliminated it. The finding is real (the
  declaration is dead source) but not a bug; deleting the line is the fix.
- **§3.** `addr_decoder` compares only `addr[7:4]`. The low nibble is unused on
  purpose. This is a waiver case, not a code change.
- **§4.** Delete `shadow`; waive `addr[3:0]` with a comment. The grading point is
  whether the student *cited the structure* to justify each call, not the calls
  themselves.

## On the cross-tool step

The deep-link (click the `shadow` finding in LintCrux → land on `regfile` in
NetCrux) is described in the handout but performed manually here, because the two
tools do not yet expose the automation needed to verify a live cross-probe
end-to-end. Each tool's own findings ARE machine-verified against real engine
output — the lint against Verilator, the structure against Yosys. If you have both
apps installed, the live cross-probe works; the pack just cannot prove it in CI
yet, and says so rather than implying otherwise.

## Common misconceptions

- *"Unused means delete it."* Not always — `addr[3:0]` is unused and correct.
  Deleting or renaming it to force the warning quiet would obscure a deliberate,
  documented address map.
- *"If synthesis removed it, why does lint still complain?"* Because lint reads
  the source, before synthesis. The warning is about the code you maintain, not
  the gates you ship — and dead source is still worth removing for the next
  reader.
