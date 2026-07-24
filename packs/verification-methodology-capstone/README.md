# verification-methodology-capstone

A **Tier-C capstone** using all four EDA Crux tools. Unlike the labs, this is a
multi-week **project**: you are given a small integrated design — a register-mapped
ALU peripheral — and a starting point in each tool, and you take it through a
complete verification-methodology pass, ending in a written report.

- **Tools:** NetCrux + LintCrux + SimCrux + WaveCrux (Open Core)
- **Format:** term project (~2-4 weeks) · advanced
- **HDL:** Verilog

## Build

```
./build.sh
```

Builds the baseline in every tool from one design: the Yosys netlist (NetCrux),
the Verilator lint report (LintCrux), a four-test directed regression (SimCrux)
and the waveform (WaveCrux).

## What is verified

The pack ships a real, consistent starting point, and CI verifies it: the
structure integrates the expected blocks, the lint baseline has the findings to
triage, the directed regression is green, and the result bus is idle at reset.
These are the **baseline** the student builds on — the project's deliverables
(extended coverage, triage decisions, the report) are assessed by the instructor,
not the verifier. As with the pair packs, cross-tool deep-links are declared, not
machine-verified.

## Using this in a course

This is an assessment scaffold: give students the `student/` brief via your LMS;
the `instructor/` folder holds the rubric. Fork it to retarget the peripheral or
raise the coverage bar for your own course.
