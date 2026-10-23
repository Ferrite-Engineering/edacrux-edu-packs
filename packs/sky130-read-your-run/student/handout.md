# Read your run

**Tool:** SimCrux 1.2 or later · **Time:** ~60 minutes · **Files:** `src/path_adder.v`, `simcrux.yaml`, `fixtures/flow/`

An open-PDK flow does not hand you one answer. LibreLane runs dozens of steps,
each leaves its own directory behind, and the result is spread over a log, a
table of metrics and a timing report. This lab is about reading that run:
what happened, how bad the worst number is, and where in your design the worst
path begins and ends. The design is small enough to read in a minute.

You work from one run captured earlier with LibreLane 3.0.16 on the open sky130A
PDK. Yosys synthesised `src/path_adder.v`, OpenROAD placed and routed it, and
Magic, KLayout and Netgen checked the result. The clock is 2 ns.

What you read here is a set of findings about one small design on one open PDK,
and nothing in it says a chip made from this design would work.

## Setup

1. In SimCrux choose File > Open Config... and select `simcrux.yaml` in the pack
   folder.
2. Choose View > Flow Runs.

The Flow Runs panel lists the run `timing-2ns` under the design `path_adder`.
SimCrux did not start it: it read it from its run directory, which is why you
need no LibreLane, Nix or PDK installed. The panel also says that results are
findings, not signoff.

## 1. Read the verdict

Select the run.

- What is its verdict?
- Open the run log (Open Run Log). Did the flow reach its last step, or stop
  somewhere in the middle?

A **Violated** run is a finding about your design: the flow finished and some
check it makes did not pass. A run that **Stopped** has no final results at all,
and a run that **Did not run** has nothing to read. Keep the three apart: only
the first tells you something about the RTL.

LibreLane exited with status 2 on this run, and it would exit with status 2 on a
run that stopped halfway too. The verdict does not come from the exit status. It
comes from what the run left behind, which is what the next two sections read.

## 2. Find the step that failed

Look at the Steps table.

- Which step is marked **Failed**?
- Find the steps after it. Do they have a status of their own? What does that
  tell you about the way LibreLane treats this kind of failure?
- Find `Yosys.Synthesis` and `OpenROAD.STAPostPNR`. What are their statuses?

A step is **Completed** when it wrote its output state. The failed step wrote
none. For most steps that would end the run, and the failed step would be the
last one listed. This one is a checker: it reads results that earlier steps
already produced and raises an error, and LibreLane holds that error back until
the end of the flow so that the later checks still get to run.

**Check yourself:** the failed step is not the step that made the path slow. Which
earlier step produced the timing numbers the checker read?

## 3. Read the metrics

Select the Metrics table. Its first column is the whole design; the others are
the timing corners the run analysed.

- What is the **Worst setup slack** for the whole design? In which corner column
  is that value?
- What is it in the nominal typical corner, `nom_tt_025C_1v80`?
- How many **Setup violations** does the run count? How many does the nominal
  typical corner have?
- Find **Hold violations**, **Routing DRC errors**, **Magic DRC errors** and
  **LVS errors**. What do they read?

Slack is the time left over: required arrival minus actual arrival. Negative
slack is a miss. A corner is one combination of process, voltage and
temperature, and the slow, hot, low-voltage corner is the pessimistic one.

**Check yourself:** the checker that failed looks at the typical corners only
(`TIMING_VIOLATION_CORNERS` in `resolved.json` is `*tt*`). The worst slack in the
table is far more negative than the typical corner's. Is the failure caused by
the worst number in the table? What would change if the checker looked at every
corner?

The run also reports the instance count of sequential cells, which is how many
flip-flops it has. Count the registers in `src/path_adder.v` (look at the
declarations on lines 10 to 12) and compare.

## 4. Find the worst path

With the run selected, look at the Worst paths table. Path 1 is the worst setup
path in the typical corner's report. (The run keeps that corner's report and no
other, so the table shows that corner.)

- Which instance does path 1 start at, and which does it end at?
- What does the Mapping column say for the two ends?
- Open the path's detail. Count the logic cells between the two flip-flops. Which
  segment type is the longest?

The names `_354_` and `_400_` are what Yosys called the flip-flops when it wrote
the netlist. They are not names you wrote. SimCrux looks for the register behind
each one, and the Mapping column says how sure it is: a register it names is the
nearest register the synthesised design records, not proof of where in your
source the flip-flop came from.

You can check a mapping yourself. `fixtures/flow/runs/path_adder/timing-2ns/06-yosys-synthesis/path_adder.nl.v`
is the netlist. Search it for the instance name and read the net on its `Q` pin.

## 5. Map the path back to the RTL

- Which register of `src/path_adder.v` is the start flip-flop one bit of? Which is
  the end flip-flop one bit of?
- Which line of the RTL computes the end register?

`src/path_adder.v` line 16
```verilog
    sum_q <= src_a + src_b;
```

- Why does a 24-bit addition between two registers make a path this long, when
  `src_a` and `src_b` are each only one shift away from the register before?
- Look at the middle of the path. What is the logic doing, bit after bit?

## 6. What would you try next

You do not have to run anything.

- The clock period is 2 ns and path 1 misses by a little under a nanosecond in
  the typical corner. Estimate the period at which the typical corner would meet.
  Say why that estimate is only a first guess.
- Propose one change to `src/path_adder.v` that shortens the worst path, and say
  what it costs. (You may add a register, and it will cost a clock cycle of
  latency.)
- Say which three things you would read first in a new run to see whether your
  change worked.

## What you should be able to do now

Read the result of an open-PDK run from its own records: which step failed and
whether the flow went on, how far the worst slack is below zero and in which
corner, and the registers at the two ends of the worst path. Tell a finding about
a design from a flow that did not finish. The same moves apply to a bigger design
on any open PDK LibreLane supports.
