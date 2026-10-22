# Find the slow path

**Tool:** SimCrux 1.2 or later · **Time:** ~45 minutes · **Files:** `src/path_adder.v`, `simcrux.yaml`, `fixtures/flow/`

An FPGA tool does not tell you "your design is slow" in one place. It prints a
clock frequency, a list of paths, and a log, and you have to connect them to the
RTL you wrote. This lab is that connection, done on a design small enough to
read in a minute.

You work from two runs that were captured earlier with open FPGA toolchains:
Yosys synthesised `src/path_adder.v` for an iCE40 UP5K, and nextpnr placed and
routed it. Both runs are the same design. Only the clock constraint differs.

| Run directory | Constraint |
|---|---|
| `violated-1000mhz` | 1000 MHz |
| `met-12mhz` | 12 MHz |

## Setup

1. In SimCrux choose File > Open Config... and select `simcrux.yaml` in the pack
   folder.
2. Choose View > Flow Runs.

The Flow Runs panel lists both runs, under the design `path_adder`. Neither was
started by SimCrux: it read them from their run directories, which is why no
tool needs to be installed.

## 1. Read the verdict

Select the run `violated-1000mhz`.

- What is its verdict?
- What is the achieved clock frequency, and what was the constraint?

Now select `met-12mhz` and answer the same two questions.

A **Violated** run is a finding about your design: the tool finished and reported
that a clock fell short. It is not an error and nothing crashed. A run that
stopped early reads **Stopped**, and a run with nothing to read reads **Did not
run**. Keep the three apart: only the first tells you something about the RTL.

Open the log of the violated run (Open Run Log) and find the last line that
starts `Max frequency for clock`. It says FAIL. The first such line, earlier in
the log, is a pre-routing estimate and is higher. The verdict comes from the
final report, never from the program's exit status.

**Check yourself:** the two runs reach the same frequency. Why does one pass and
the other fail?

## 2. Find the worst path

With the violated run selected, look at the Worst paths table. Path 1 is the
slowest path the report lists.

- Which cell does path 1 start at, and which does it end at?
- Open the path's detail. Add up the delay of the segments by type: clock-to-q,
  routing, logic, setup. Which type dominates?

A path in an FPGA report is a chain of segments between two registers: the
launching register's clock-to-output, then alternating routing and logic through
the combinational logic, then the capturing register's setup time. The slowest
path is the one with the largest total.

## 3. Map the path back to the RTL

The tool names cells after what it built, not after what you wrote, but the names
usually keep a trace of your register names. Read the start cell and the end cell
of path 1 again.

- Which register of `src/path_adder.v` does each end belong to?

SimCrux shows this as the path's mapping, for example `register src_a`. The
path's context menu also has Open statement in editor, which opens a source line
the path comes from. Whatever line it opens, find in `src/path_adder.v` the one
statement that computes the end register. It is the only deep logic between two
registers in the file:

`src/path_adder.v` line 16
```verilog
    sum_q <= src_a + src_b;
```

- Why does one addition between two 24-bit registers make a path this long, when
  `src_a` and `src_b` themselves are each one shift away from the previous
  register?
- Look at the middle of the path in the detail view. Many logic segments come one
  after another with almost no routing between them. What is the FPGA doing, and
  why is that fast per step but slow in total?

## 4. Same design, a lower clock

Select `met-12mhz`. Its worst path starts and ends at the same two
registers. Compare its path 1 with the violated run's path 1.

- Are the paths different, or only the verdict?
- What does that tell you about where the constraint lives: in the design, or in
  the run?

## 5. Fix it on paper

You do not have to run anything. Propose one change to `src/path_adder.v` that
would shorten the worst path, and say what it costs. (Hint: you may add a
register, and it will cost you a clock cycle of latency.) Then say what you would
look at first in a new run to see whether it worked.

## What you should be able to do now

Read the verdict of a place-and-route run from its report, separate a violation
from a run that did not finish, name the registers at the two ends of the worst
path, and follow it to the RTL line that makes it slow. The same moves apply to a
bigger design on any target nextpnr supports.
