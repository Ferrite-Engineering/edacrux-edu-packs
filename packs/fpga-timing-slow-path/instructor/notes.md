# Instructor notes: find the slow path

## Purpose

Students learn to read a place-and-route result the way an FPGA engineer does:
the verdict from the report, the worst path from the report's path list, and the
register and RTL line behind it. The design is deliberately tiny so the whole
chain from verdict to line of RTL fits in one sitting.

## Before class

- SimCrux 1.2 or later. No Yosys or nextpnr install is needed: both runs are
  committed under `fixtures/flow/runs/path_adder/`.
- Have students open the pack's `simcrux.yaml` with File > Open Config... and
  then View > Flow Runs. If the panel is empty, the project did not load: look
  for a message about `simcrux.yaml` first.
- If you want students to re-run it, nextpnr and Yosys must be on the PATH
  SimCrux sees. On macOS a GUI app started from the Dock does not see a
  Homebrew PATH: start SimCrux from a terminal.

## Timing (45 minutes)

| Section | Minutes |
|---|---|
| Setup | 5 |
| 1. Read the verdict | 10 |
| 2. Find the worst path | 10 |
| 3. Map the path back to the RTL | 10 |
| 4. Same design, a lower clock | 5 |
| 5. Fix it on paper | 5 |

## Points worth stopping on

- **Violated is not failed.** The run finished. The tool is reporting a fact about
  the design. Students who read the exit status instead of the verdict will treat
  this run as a crash. nextpnr does exit non-zero on a miss, which is exactly why
  the exit status is the wrong thing to read.
- **The constraint is not in the design.** Both runs have the same achieved
  frequency (about 60.9 MHz). The 12 MHz run passes because 60.9 is above 12; the
  1000 MHz run fails because 60.9 is below 1000. Ask students what they would
  have to change in the RTL to make the 1000 MHz run pass: far more than a
  constraint edit.
- **Cell names carry register names on iCE40.** `src_a_SB_DFF_Q_23_DFFLC` is the
  flip-flop for bit 23 of `src_a`. On some other families the names are opaque
  and the mapping falls back to source spans. A mapping is evidence, not proof;
  SimCrux labels it by how precise it is (register, statement, block).
- **The carry chain.** The path is long because 24 bits of carry ripple through
  hard carry logic: many logic segments with almost no routing between them.

## Common misconceptions

- "The slow path is the one with the biggest routing delay." Here the logic
  segments dominate; routing is small except at the two ends.
- "Path 1 is the launching register's slowest bit." Path 1 is the path with the
  largest total delay the report lists; the start bit it picks (`src_a` bit 23
  here) is a consequence of placement, not of RTL.
- "A constraint of 1000 MHz is silly." It is deliberate, so the miss is large and
  unmistakable. A real miss is a few percent, and the same reading applies.

## Grading

Full marks for sections 1 to 4: the two verdicts with frequencies, the start and
end registers of path 1, the RTL line, and the statement that the paths are the
same in both runs. Section 5 is judged on whether the proposed change shortens
the worst path (a pipeline register between the adder inputs and `sum_q`, or
splitting the add into two halves) and on whether the cost is stated (a cycle of
latency, or extra registers).

## Verification of this pack

`tools/edacrux-pack-verify` checks the verdicts and the registers behind the worst
path from the run's own report, log and netlist on every push, without SimCrux.
That establishes the pack agrees with its own fixtures. It does not establish
that a given SimCrux release displays them as the handout describes.
