#!/usr/bin/env python3
"""Guards the menu paths and shortcuts the handouts name.

Run: python3 -m unittest discover -s tools/tests

A handout that sends a student to "File -> Open Session..." or presses
Ctrl+T is wrong the moment the app has no such control, and nothing else in
this repository would notice: the fixtures verify, the prose still reads well.
That is how several packs came to name controls the applications do not have.

Two checks, both over the Markdown under packs/:

* Every menu path written as **Menu -> Item** must be one of the paths in
  KNOWN_MENU_PATHS. Each entry was taken from the open-core applications'
  English strings and menu layouts, and the product is recorded beside it. A new
  path therefore has to be looked up in the app before it can be added here.
* A list of phrases that earlier handouts used for controls that do not exist
  must not come back.

This is a guard on the wording, not a test that the app works as described. It
does not drive an application.
"""
from __future__ import annotations

import pathlib
import re
import unittest

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
PACKS = REPO / "packs"

# Menu path -> the product whose English strings it comes from.
KNOWN_MENU_PATHS = {
    "File → Open File…": "WaveCrux",
    "Tools → Add Protocol Decoder": "WaveCrux",
    "Tools → Analyze Switching Activity": "WaveCrux",
    "Tools → Compare Waveforms": "WaveCrux",
    "Tools → Next Divergence": "WaveCrux",
    "Tools → Load Cocotb Log": "WaveCrux",
    "View → Toggle Transaction Table": "WaveCrux",
    "Search → Search Signals": "WaveCrux",
    "File → Open Netlist JSON…": "NetCrux",
    "File → Open Source Files…": "LintCrux",
    "File → Open Config…": "SimCrux",
}

# Wording earlier handouts used for controls the applications do not have.
STALE_PHRASES = [
    "Open Session…",
    "Open Cocotb Log…",
    "Add Decoder →",
    "Ctrl+T",
    "Ctrl + T",
    "Ctrl+H",
    "Compare With File",
    "Configure Diff",
    "Reconfigure",
    "Duplicate Lane",
    "X-trace from here",
    "Ctrl + ]",
    "direction filter chip",
]

# `lintcrux fixtures/lint.json` and its siblings: the products take no such
# command line, and the file is not one they open.
STALE_COMMANDS = re.compile(
    r"^\s*(wavecrux|netcrux|lintcrux|simcrux)\s+fixtures/", re.MULTILINE
)

MENU_PATH = re.compile(
    r"\*\*(File|Edit|View|Navigate|Search|Tools|Help) → ([^*]+?)\*\*"
)


def _markdown() -> list[pathlib.Path]:
    return sorted(
        p for p in PACKS.rglob("*.md") if "build" not in p.relative_to(PACKS).parts
    )


def _flat(text: str) -> str:
    """Joins hard-wrapped lines so a path split across two lines still matches."""
    return re.sub(r"\s*\n\s*", " ", text)


class HandoutLabels(unittest.TestCase):
    def test_every_menu_path_is_a_known_one(self) -> None:
        unknown = []
        for path in _markdown():
            for menu, item in MENU_PATH.findall(_flat(path.read_text("utf-8"))):
                full = f"{menu} → {item}"
                if full not in KNOWN_MENU_PATHS:
                    unknown.append(f"{path.relative_to(REPO)}: {full}")
        self.assertEqual(
            unknown,
            [],
            "menu paths not in KNOWN_MENU_PATHS; look each up in the app's "
            "English strings before adding it",
        )

    def test_known_paths_are_all_in_use(self) -> None:
        text = "\n".join(_flat(p.read_text("utf-8")) for p in _markdown())
        unused = [p for p in KNOWN_MENU_PATHS if f"**{p}**" not in text]
        self.assertEqual(unused, [], "drop paths no handout uses any more")

    def test_stale_phrases_have_not_come_back(self) -> None:
        found = []
        for path in _markdown():
            text = _flat(path.read_text("utf-8"))
            for phrase in STALE_PHRASES:
                if phrase in text:
                    found.append(f"{path.relative_to(REPO)}: {phrase}")
        self.assertEqual(found, [])

    def test_no_command_line_launches_of_the_products(self) -> None:
        found = [
            str(p.relative_to(REPO))
            for p in _markdown()
            if STALE_COMMANDS.search(p.read_text("utf-8"))
        ]
        self.assertEqual(found, [])


if __name__ == "__main__":
    unittest.main()
