# Instructor notes: read your run

## Purpose

Students learn to read the result of an open-PDK run the way a flow engineer
does: from the records the run leaves, not from the exit status. They separate a
step that stopped the flow from a checker whose error LibreLane deferred, read
the worst slack and the violation counts from the metrics, and follow the worst
setup path to the registers at its ends. The design is deliberately tiny so the
whole chain from verdict to register fits in one sitting.

The lab is scoped to open PDKs (here sky130A, with LibreLane 3.0.16). What
students read are findings, not signoff, about one small design. Say so at the
start: a run that meets timing is one finding among several, and a foundry's own
flow, decks and rules are outside this lab.

## Before class

- SimCrux 1.2 or later. LibreLane, Nix and the PDK are not needed: the run is
  committed under `fixtures/flow/runs/path_adder/`.
- Students open the pack's `simcrux.yaml` with File > Open Config... and then
  View > Flow Runs. If the panel is empty, the project did not load: look for a
  message about `simcrux.yaml` first.
- SimCrux reads LibreLane 3.0.15 and 3.0.16 runs as verified. A run from another
  release shows a "reader not verified" note and is read best-effort. If a
  student re-runs the design with a different release, expect that note.
- A re-run needs LibreLane 3.0.16 and the sky130A PDK on the PATH SimCrux sees.
  On macOS a GUI app started from the Dock does not see a Nix or Homebrew PATH:
  start SimCrux from a terminal. A re-run writes to `runs/<tag>/` beside
  `config.yaml` and never touches `fixtures/`.

## Timing (60 minutes)

| Section | Minutes |
|---|---|
| Setup | 5 |
| 1. Read the verdict | 8 |
| 2. Find the step that failed | 10 |
| 3. Read the metrics | 12 |
| 4. Find the worst path | 10 |
| 5. Map the path back to the RTL | 8 |
| 6. What would you try next | 7 |

## Points worth stopping on

- **Violated is not stopped.** The flow finished: every step ran and the final
  metrics exist. The failed step is a checker. LibreLane defers a checker's error
  so that the checks after it still run, which is why the steps after the failed
  one are Completed. A run that stopped has its failed step last and no final
  metrics.
- **The exit status is not the verdict.** LibreLane exits with status 2 here, as
  it does for a run that stopped. Students who read the status treat this run as
  a crash. The records say otherwise.
- **Corners.** The checker looks at the typical corners; the table's worst slack
  comes from the slow corner. Both are real findings. A design that misses only
  in the slow corner and meets in the typical ones is a different conversation
  from one that misses everywhere.
- **Instance names are not register names.** `_354_` and `_400_` are Yosys's
  names for anonymous cells. SimCrux finds the register behind a flip-flop by the
  public net on its output, and labels the mapping with how precise it is. It is
  the nearest register the synthesised design records, not proof of source.
- **The carry chain.** The path is long because 24 bits of carry ripple through
  nine logic cells in one clock cycle.

## Common misconceptions

- "The failed step is the slow step." The checker reads the numbers an earlier
  step (`OpenROAD.STAPostPNR`) produced and raises the error. It does no timing.
- "Zero Magic DRC and LVS errors mean the run is fine." They mean the checks that
  ran found no errors on this design. The timing finding stands, and neither
  count says more than that.
- "The worst slack in the table is the slack of path 1." Path 1 is the worst path
  of the typical corner's report. The table's worst slack is the minimum over
  every corner, taken from a different report.
- "Fix the clock constraint." Relaxing the period is a legitimate experiment, and
  it changes the question, not the design. Ask what the design can do at 2 ns.

## Grading

Full marks for sections 1 to 5: the verdict and the reason it is not a stopped
run, the failed step and the status of the steps after it, the worst slack in two
corners with the violation counts, the two ends of path 1, and the registers and
RTL line behind them. Section 6 is judged on whether the proposed change shortens
the worst path (a pipeline register inside the adder, or splitting the add into
two halves with a registered carry) and whether the cost is stated (a cycle of
latency, or extra registers), and on whether the student says what to read first
in a new run: the verdict, the worst slack, and path 1's ends.

## Verification of this pack

`tools/edacrux-pack-verify` checks the step statuses, the metrics and the first
path of the typical corner's setup report from the run's own records on every
push, without SimCrux. That establishes the pack agrees with its own fixtures. It
does not establish that a given SimCrux release displays the run as the handout
describes, and it does not check the register behind each end of the path: the
test suite pins that from the final netlist.
