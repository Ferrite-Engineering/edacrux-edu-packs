# Your first regression

**Tool:** SimCrux · **Time:** ~45 minutes · **Files:** `src/alu4.v`, `tb/tb_alu.v`

Verification is a loop: run a suite of tests, look at what passed and what
failed, fix the design or the test, run again. Before you can debug a *failing*
regression you should know exactly what a *clean* one looks like. That is this
lab.

## Setup

```
./build.sh                      # run the regression
simcrux fixtures/results.json   # open the dashboard
```

The design under test is a 4-function ALU (`src/alu4.v`): add, subtract, AND, OR.
The suite (`tb/tb_alu.v`) is six directed tests.

## 1. Read the summary

The dashboard opens on the summary. Answer, just from it:

- How many tests ran?
- How many passed? How many failed?

A directed regression's headline is a single fraction: passed / total. Here it
should be **6 / 6**.

## 2. What is a directed test?

Open `tb/tb_alu.v` and read the `check` calls. Each one:

- drives known inputs (`a`, `b`, `op`),
- names an expected output,
- and the testbench compares and records PASS or FAIL automatically.

That is a *directed* test: you, the engineer, chose the case and the answer. Pick
one — say `add_carry` — and confirm you can see, in the RTL, why 15 + 1 should be
16 and why the result needs five bits.

## 3. Read a single test

On the dashboard, find the test named **`sub_zero`**.

- What is its outcome?
- What was it checking? (Find it in the testbench.)

Being able to go from "the dashboard shows this test" to "here is the case it
covers" is the everyday move of a verification engineer.

## 4. Make it fail — on purpose

The best way to understand green is to break it. In `src/alu4.v`, change the
subtract case (`op == 2'd1`) to `a + b`. Rebuild and reopen.

- Which test(s) go red? Why exactly those and not the others?
- Put the `-` back. Rebuild. All green again.

This is the whole loop in miniature: a change, a red test that points straight at
it, a fix, green.

## What you should be able to do now

Run a regression, read its summary and per-test status, connect a test on the
dashboard to the case it covers, and recognise — and deliberately break — a clean
run. Every SimCrux lab from here is a harder version of this loop.
