# Security policy

## Reporting a vulnerability

**Please do not open a public issue.** Email
[support@ferriteengineering.com](mailto:support@ferriteengineering.com) with
`Security` in the subject line.

Useful things to include, as far as you have them: the pack and its version,
the tool and version you opened it with, what an attacker can do, and the
smallest file or steps that show it. A pack directory that reproduces it is
worth more than a description of one.

## What to expect

Ferrite Engineering is a small team, so here is the honest version rather than
a service-level agreement: you will get a human acknowledgement within five
business days, and from there an explanation of what we think the impact is
and what we intend to do about it. If we disagree that it is a vulnerability
we will say so and why, rather than going quiet.

We will credit you by name in the release notes if you would like to be
credited, and we will not involve lawyers over a good-faith report.

## What this repository is, for the purposes of a report

This is **content**, not an application: RTL, testbenches, waveform fixtures,
handouts, and a small amount of Python and shell that builds and checks them.
There is no service here, nothing is deployed from it, and it holds no
credential of any kind.

So the reports that matter are about what happens when someone else's machine
consumes this content.

## Where we would look first

- **`tools/edacrux-pack-verify`** — it parses a pack's `fixtures/*.vcd` and
  `fixtures/expected.json`. A pack is untrusted input the moment anyone runs
  this against a pack they did not write. A crash is a bug; a path escape or
  an execution is a vulnerability.
- **`tools/generate-sessions.py`** and **`tools/build-*.sh`** — anything that
  takes a pack name or a path from the tree and passes it to a shell.
- **`pack.yaml` and the manifest schema** — a field that a consuming tool
  resolves to a filesystem path. A pack that can name `../../` and have a
  tool follow it is a real report, here or in that tool.
- **`build.sh` in each pack** — these invoke Icarus Verilog, Yosys and
  Verilator on the pack's own RTL. A professor who clones a third-party pack
  and runs `build.sh` is running that pack's script; if our tooling makes that
  look safer than it is, say so.

## Not vulnerabilities

**A pack's RTL containing a deliberate bug.** Several packs exist precisely to
give students something broken to find. A failing assertion, a race, or an
unreset flop in `packs/debug-hunt/` is the exercise, not a defect.

**Licence-tier gating in the tools that open these packs.** That is a
commercial mechanism in those products, running on hardware its user controls,
and it is not a security boundary.

## Third-party engines

The build scripts invoke external EDA engines — Icarus Verilog, Yosys,
Verilator, cocotb — as separate processes. A flaw inside one of those belongs
upstream with that project. How we invoke them, what we pass them, and what we
do with what they return is ours: report that here.
