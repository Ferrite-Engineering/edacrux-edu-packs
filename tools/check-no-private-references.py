#!/usr/bin/env python3
"""check-no-private-references — this public repository points at nothing a
reader cannot open.

WHY THIS EXISTS

edacrux-edu-packs is public. Its readers are professors, teaching assistants
and students: they have this repository, the open-core products, the published
pages on edacrux.app, and nothing else. A handout that justifies a choice by
citing a section of an unpublished plan, a comment that says "staged in the
closed-source <product>-pro repo", or a README that names an internal
work-stream is a dead end for every one of them — and a quiet disclosure of
how the closed half of the suite is laid out.

Both shapes were really here. This repository's own history carries a path
into the planning repository, a `<product>-pro/docs/...` path, and the
sentence "staged in the closed-source <product>-pro repo" — which was still
in README.md until this script was written. The working tree was cleaned by
hand; nothing stopped it coming back. This script is what stops it.

THE RULE

State the reason in place, or cite something the reader can open: a file in
this repository, a page on edacrux.app, or a product's published docs site.

WHAT IS SCANNED

Every file `git ls-files` reports: RTL, handouts, contracts, README, workflows
and tools alike. A pack's handout is read by more people than any source file
here, so it is held to the same bar. Skipped: this script — see below — files
whose first bytes are not text, and files over _MAX_BYTES, which in this
repository means fixture waveforms.

WHY THE PATTERNS READ ODDLY

This file is public, and a rule table that spells out every private
repository's name IS the disclosure it exists to prevent — a list of
unannounced products, published in a regex. So each sensitive literal is
broken by a regex construct that still matches it: `crux-upd(?:ates)` matches
the update Worker's repository name, but a search of this file for that name
finds nothing. The planted samples below are assembled from fragments for the
same reason — a string literal would re-publish what the pattern hides. The
script is excluded from its own scan anyway, but the exclusion is there so
the rules do not match themselves, not as permission to publish the list.

THE ALLOWLIST

_ALLOWLIST names one exact path and the exact rules it is exempt from, with
the reason. It is empty by design, and an entry that stops matching anything
fails the run, so it cannot rot into a set of standing holes.

USAGE

    tools/check-no-private-references.py            # scan; exit 1 on a finding
    tools/check-no-private-references.py --list-rules

Runs in CI on every push and pull request.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

# Fixture waveforms run to megabytes and are machine output, not prose.
_MAX_BYTES = 1024 * 1024

# This script's own source. Excluded because the rule table below has to spell
# out every pattern it rejects.
_SELF = "tools/check-no-private-references.py"


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: re.Pattern


RULES: list[Rule] = [
    # ── Private repositories, by path or by name ─────────────────────────────
    # The planning repository, as a path. `edacrux.app/` is the public site
    # and `edacrux-edu-packs` is this repository; neither contains that path,
    # so neither matches.
    Rule("private-repo", re.compile(r"(?<![\w.:/@-])edacr(?:ux)/")),
    Rule("private-repo", re.compile(r"Ferrite-Engineering/edacr(?:ux)(?![\w-])")),
    # The Pro overlay as a CONCEPT is public and fine to describe ("the Pro
    # tier adds waivers"). Its repository name is not.
    Rule(
        "private-repo",
        re.compile(r"\b(?:wave|net|lint|sim)crux-pr(?:o)\b", re.I),
    ),
    Rule(
        "private-repo",
        re.compile(
            r"\b(?:wave|net|lint|sim|eda)crux-web(?:site)\b"
            r"|\bferrite-web(?:site)\b|\*-web(?:site)\b",
            re.I,
        ),
    ),
    # The backend services and the unannounced products. Broken literals: see
    # WHY THE PATTERNS READ ODDLY in the module docstring.
    Rule(
        "private-repo",
        re.compile(
            r"\bcrux-upd(?:ates)\b|\bcrux-comm(?:erce)\b"
            r"|\bwavecrux-upd(?:ates)\b|\bpulse(?:crux)\b|\bann(?:eal)\b"
            r"|\bvcd_pars(?:er)\b",
            re.I,
        ),
    ),
    # The beta repositories close at the open-core flip: they are the beta
    # cohort's public record, and archived-then-private is a 404 to anyone who
    # follows a link into one.
    Rule(
        "private-repo",
        re.compile(r"\b(?:wave|net|lint|sim)crux-bet(?:a)\b", re.I),
    ),
    Rule(
        "private-repo",
        re.compile(
            r"\b(?:private|separate|closed[- ]source) "
            r"(?:planning|docs|documentation) repo",
            re.I,
        ),
    ),
    # ── Unpublished planning documents ───────────────────────────────────────
    Rule(
        "private-plan",
        re.compile(
            r"\b(?:project|suite|strategic|ecosystem|business|product"
            r"|commercial[-_ ]launch|EDU pack|ISA pack|launch)[-_ ]plan\b"
            r"|SUITE_PROJECT_PL(?:AN)|COMMERCIAL_LAUNCH_PL(?:AN)"
            r"|ECOSYSTEM_PL(?:AN)|\bplan §",
            re.I,
        ),
    ),
    Rule(
        "private-plan",
        re.compile(
            r"\bconsistency[-_ ]charter\b|\bcharter §|\bexecution[- ]prompts?\b"
            r"|\bedu-outreach-backlog\b|\bsuite-backlog\b",
            re.I,
        ),
    ),
    # ── Roadmap phases: they number a plan the reader does not have ──────────
    #
    # Deliberately narrower than the products' copy of this guard. This is a
    # digital-design teaching repository: "phase" is also a clock concept, and
    # "a two-phase handshake" is a sentence a pack legitimately wants.
    # Requiring the capital P keeps the roadmap sense and lets the electrical
    # one through.
    Rule(
        "plan-phase",
        re.compile(r"\bPhase[ -](?:\d+[a-z]?(?:\.\d+)*|[A-C]\d?)\b"),
    ),
    # ── Tracker identifiers ──────────────────────────────────────────────────
    Rule(
        "tracking-id",
        re.compile(
            r"\bWS-[A-H]\b|\bWS\d\b|\b[Pp]rompt [A-Z]?\d+(?:\.\d+)?\b"
            r"|\bR-CS\d+\b|\bCS\d{1,2}\b|§[A-Z]\d\b|\bIssue-\d+\b"
            r"|\bF-\d{2,3}\b|\(P\d{1,3}\)"
        ),
    ),
    Rule(
        "tracking-id",
        re.compile(
            r"\bCross-Probe Increment\b|\bcampaign item\b|\bruling [A-Z]\d+\b"
            r"|\bconsistency (?:pass|ruling)\b|\baudit-remediation\b",
            re.I,
        ),
    ),
]


@dataclass(frozen=True)
class Allowance:
    rules: frozenset
    reason: str


# Exact path → the rules it is exempt from, and why.
#
# Empty on purpose. An entry is for a public name that happens to match a rule
# — never for a reference that could simply be restated. Shape:
#
#     "packs/x/README.md": Allowance(
#         frozenset({"private-repo"}),
#         "Names the shipped `lintcrux-pro` executable a student runs.",
#     ),
_ALLOWLIST: dict = {}


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    rule: str
    text: str

    def __str__(self) -> str:
        return f"{self.path}:{self.line} [{self.rule}] {self.text}"


def scan(text: str):
    """Every (rule name, line number, matched text) in *text*."""
    hits = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        for rule in RULES:
            for match in rule.pattern.finditer(line):
                hits.append((rule.name, line_number, match.group(0).strip()))
    return hits


def tracked_files(root: Path):
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=str(root),
        capture_output=True,
        check=True,
    )
    paths = [p for p in result.stdout.decode("utf-8").split("\0") if p]
    return sorted(p for p in paths if p != _SELF)


def read_text(path: Path):
    """The file's text, or None for a binary or an oversized fixture."""
    try:
        if path.stat().st_size > _MAX_BYTES:
            return None
        data = path.read_bytes()
    except OSError:
        return None
    if b"\0" in data[:8000]:
        return None
    return data.decode("utf-8", errors="replace")


# ── Self-tests ───────────────────────────────────────────────────────────────
#
# A guard whose patterns have rotted into ones that match nothing passes
# silently and forever. These run on every invocation, so that cannot happen
# without the run going red. They are also the readable specification of what
# each rule is for.
#
# Assembled from fragments, so that this public file does not itself contain
# the names — the same reason the patterns above are written as they are.

_PLANTED = {
    "private-repo path": "see `" + "edacr" + "ux/docs/specs/cxp-spec.md`",
    "private-repo overlay": "staged in the closed-source wavecrux" + "-pro repo",
    "private-repo website": "published from lintcrux" + "-website",
    "private-repo beta": "file it against wavecrux" + "-beta",
    "private-repo backend": "counted by the crux-" + "updates Worker",
    "private-plan": "rationale in the WaveCrux project plan §10.5",
    "private-plan file": "- `SUITE_PROJECT_" + "PLAN.md` — the tier framework",
    "plan-phase": "landed in Phase 6",
    "plan-phase suffix": "deferred to Phase 4c",
    "tracking-id": "the cross-probe panel (WS-B)",
    "tracking-id prompt": "covered by prompt A8",
}

_CLEAN = [
    "CXP §9.9, published at https://edacrux.app/cxp#sec-9-9",
    "the Pro tier adds waiver management; the open core does not",
    "open the pack in WaveCrux (https://docs.wavecrux.app/getting-started)",
    "this repository is Ferrite-Engineering/edacrux-edu-packs",
    "the clock phase 2 non-overlapping generator",
    "a two-phase handshake, req then ack",
    "see LICENSE-CONTENT for the CC BY 4.0 terms",
    "rebuild with ./build.sh; fixtures/expected.json is the contract",
    "students open reference.vcd in WaveCrux and check the checkpoints",
]


def self_test():
    failures = []
    for label, sample in _PLANTED.items():
        if not scan(sample):
            failures.append(
                f"no rule matches the planted {label!r} sample: {sample!r} "
                "— a pattern has rotted into one that catches nothing"
            )
    for sample in _CLEAN:
        hits = scan(sample)
        if hits:
            rules = ", ".join(sorted({h[0] for h in hits}))
            failures.append(
                f"public text is wrongly rejected by [{rules}]: {sample!r}"
            )
    return failures


def stale_allowlist_entries(root: Path):
    """Allowlist entries that no longer exempt anything."""
    stale = []
    for path, allowance in _ALLOWLIST.items():
        text = read_text(root / path)
        exempted = (
            []
            if text is None
            else [h for h in scan(text) if h[0] in allowance.rules]
        )
        if not exempted:
            stale.append(f"{path} ({allowance.reason})")
    return stale


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fail if a tracked file points at the private side of the suite."
    )
    parser.add_argument(
        "--list-rules",
        action="store_true",
        help="print the rule names and patterns, then exit",
    )
    args = parser.parse_args()

    if args.list_rules:
        for rule in RULES:
            print(f"{rule.name:14} {rule.pattern.pattern}")
        return 0

    root = Path(__file__).resolve().parent.parent

    failures = self_test()
    if failures:
        print("The guard itself is broken:", file=sys.stderr)
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
        return 2

    files = tracked_files(root)
    findings = []
    for relative in files:
        text = read_text(root / relative)
        if text is None:
            continue
        allowance = _ALLOWLIST.get(relative)
        for rule_name, line, matched in scan(text):
            if allowance is not None and rule_name in allowance.rules:
                continue
            findings.append(Finding(relative, line, rule_name, matched))

    if findings:
        print(
            "A public file references something only the private side of the\n"
            "suite can open. State the reason in place, or cite a file in this\n"
            "repository, a page on edacrux.app, or a product's docs site:\n",
            file=sys.stderr,
        )
        for finding in findings:
            print(f"  {finding}", file=sys.stderr)
        return 1

    stale = stale_allowlist_entries(root)
    if stale:
        print(
            "These allowlist entries exempt nothing any more — delete them:",
            file=sys.stderr,
        )
        for entry in stale:
            print(f"  {entry}", file=sys.stderr)
        return 1

    print(
        f"no private references in {len(files)} tracked files "
        f"({len(RULES)} rules, {len(_ALLOWLIST)} allowlist entries)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
