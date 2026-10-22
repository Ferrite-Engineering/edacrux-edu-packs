#!/usr/bin/env python3
"""Tests for the SimCrux Flow state checks in tools/edacrux-pack-verify.

Run: python3 -m unittest discover -s tools/tests

Two kinds of test. The first group runs the checker over the committed pack and
over damaged copies of it, so a check that cannot fail would be caught. The
second group builds tiny synthetic runs in a temp directory (a LibreLane-shaped
run, an OpenSTA-format report) to pin the parts of the vocabulary that no
committed pack exercises yet. Synthetic runs are written by hand from the file
formats, not produced by any tool, and say so; they are not evidence about a
tool release.
"""
from __future__ import annotations

import importlib.machinery
import importlib.util
import json
import pathlib
import shutil
import tempfile
import unittest

TOOLS = pathlib.Path(__file__).resolve().parent.parent
REPO = TOOLS.parent
PACK = REPO / "packs" / "fpga-timing-slow-path"
VIOLATED = "fixtures/flow/runs/path_adder/violated-1000mhz"
MET = "fixtures/flow/runs/path_adder/met-12mhz"


def _load():
    path = str(TOOLS / "edacrux-pack-verify")
    loader = importlib.machinery.SourceFileLoader("pack_verify", path)
    spec = importlib.util.spec_from_loader("pack_verify", loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


pv = _load()


def run_flow(pack: pathlib.Path, flow: dict) -> list[tuple[str, bool, str]]:
    checks: list[tuple[str, bool, str]] = []
    pv.verify_flow_state(pack, "t", flow, lambda n, ok, d="": checks.append((n, ok, d)))
    return checks


def failed(checks):
    return [c for c in checks if not c[1]]


class CommittedPack(unittest.TestCase):
    def test_the_pack_verifies(self):
        r = pv.verify_pack(PACK)
        self.assertEqual(r.failures, [])
        self.assertGreaterEqual(len(r.checks), 20)

    def test_every_pack_still_verifies(self):
        for pack in sorted((REPO / "packs").iterdir()):
            if pack.is_dir():
                self.assertTrue(pv.verify_pack(pack).ok, pack.name)

    def test_the_two_runs_have_the_verdicts_their_own_files_state(self):
        self.assertEqual(pv.FlowRunDir(PACK / VIOLATED).verdict(), "violated")
        self.assertEqual(pv.FlowRunDir(PACK / MET).verdict(), "met")

    def test_the_final_log_line_is_what_decides_the_log_reading(self):
        run = pv.FlowRunDir(PACK / VIOLATED)
        (achieved, token, constraint), = run.log_clocks.values()
        self.assertEqual(token, "FAIL")
        self.assertEqual(constraint, 1000.0)
        # the first Max frequency line is the pre-route estimate, higher than the
        # final figure the checker keeps
        self.assertAlmostEqual(achieved, 60.91, places=2)


class Damaged(unittest.TestCase):
    """Copy the pack, break one thing, and the checker must say so."""

    def setUp(self):
        self.tmp = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        self.pack = self.tmp / "fpga-timing-slow-path"
        shutil.copytree(PACK, self.pack)

    def mapped(self, **over):
        mr = {"source": "src/path_adder.v", "rank": 1,
              "start_registers": ["src_a", "src_b"], "end_register": "sum_q",
              "statement_line": 16,
              "declaration_lines": {"src_a": 10, "src_b": 11, "sum_q": 12}}
        mr.update(over)
        return {"run": VIOLATED, "mapped_register": mr}

    def test_a_wrong_verdict_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "verdict": "met"})
        self.assertTrue(failed(c))

    def test_a_report_edited_to_meet_makes_the_log_disagree(self):
        rp = self.pack / VIOLATED / "report.json"
        data = json.loads(rp.read_text())
        for v in data["fmax"].values():
            v["constraint"] = 10
        rp.write_text(json.dumps(data))
        c = run_flow(self.pack, {"run": VIOLATED, "verdict": "met"})
        self.assertTrue(any("log's final" in n for n, ok, _ in failed(c)))

    def test_a_metric_outside_its_bounds_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "metrics": [
            {"key": "fmax__achieved__mhz", "min": 100}]})
        self.assertTrue(failed(c))

    def test_a_metric_the_run_does_not_have_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "metrics": [
            {"key": "no__such__metric", "min": 0}]})
        self.assertTrue(failed(c))

    def test_a_metric_with_no_bound_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "metrics": [
            {"key": "fmax__achieved__mhz"}]})
        self.assertTrue(failed(c))

    def test_the_wns_is_the_period_slack(self):
        c = run_flow(self.pack, {"run": VIOLATED, "metrics": [
            # by hand: 1000/1000 - 1000/60.905 = 1 - 16.419 ns
            {"key": "timing__setup__wns", "max": -15.3, "min": -15.5}]})
        self.assertEqual(failed(c), [])

    def test_the_register_expectation_passes_on_the_real_run(self):
        self.assertEqual(failed(run_flow(self.pack, self.mapped())), [])

    def test_a_wrong_end_register_fails(self):
        c = run_flow(self.pack, self.mapped(end_register="src_a"))
        self.assertTrue(failed(c))

    def test_a_wrong_start_register_fails(self):
        c = run_flow(self.pack, self.mapped(start_registers=["sum_q"]))
        self.assertTrue(failed(c))

    def test_a_wrong_statement_line_fails(self):
        c = run_flow(self.pack, self.mapped(statement_line=14))
        self.assertTrue(failed(c))

    def test_a_wrong_declaration_line_fails(self):
        c = run_flow(self.pack, self.mapped(
            declaration_lines={"src_a": 14}))
        self.assertTrue(failed(c))

    def test_without_synth_json_simcrux_would_list_the_path_unmapped(self):
        (self.pack / VIOLATED / "synth.json").unlink()
        c = run_flow(self.pack, self.mapped())
        self.assertTrue(any("synth.json" in n for n, _, _ in failed(c)))

    def test_a_netlist_without_the_statement_fails(self):
        sp = self.pack / VIOLATED / "synth.json"
        sp.write_text(sp.read_text().replace("path_adder.v:16.", "path_adder.v:99."))
        c = run_flow(self.pack, self.mapped())
        self.assertTrue(any("line 16" in n for n, _, _ in failed(c)))

    def test_a_missing_run_directory_fails_and_never_continues(self):
        c = run_flow(self.pack, {"run": "fixtures/flow/runs/nope", "verdict": "met"})
        self.assertEqual([n for n, ok, _ in c if ok], [])
        self.assertTrue(failed(c))

    def test_a_run_outside_the_pack_is_refused(self):
        for rel in ("../fpga-timing-slow-path", "/etc", "fixtures/../../x"):
            c = run_flow(self.pack, {"run": rel, "verdict": "met"})
            self.assertTrue(failed(c), rel)

    def test_a_symlink_out_of_the_pack_is_refused(self):
        outside = self.tmp / "outside"
        shutil.copytree(self.pack / VIOLATED, outside)
        link = self.pack / "fixtures" / "flow" / "link"
        link.symlink_to(outside, target_is_directory=True)
        c = run_flow(self.pack, {"run": "fixtures/flow/link", "verdict": "violated"})
        self.assertTrue(failed(c))

    def test_an_unknown_flow_field_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "verdct": "met"})
        self.assertTrue(failed(c))

    def test_a_verdict_that_is_not_a_token_fails(self):
        c = run_flow(self.pack, {"run": VIOLATED, "verdict": "Violated"})
        self.assertTrue(failed(c))

    def test_steps_on_a_nextpnr_run_fail(self):
        c = run_flow(self.pack, {"run": VIOLATED, "steps": [
            {"id": "x", "status": "completed"}]})
        self.assertTrue(failed(c))

    def test_the_worst_path_ends_are_read_from_the_report(self):
        c = run_flow(self.pack, {"run": VIOLATED, "worst_path": {
            "rank": 1, "startpoint": "src_a_SB_DFF_Q_23_DFFLC",
            "endpoint": "sum_q_SB_DFF_Q_DFFLC",
            "segment_types": ["clk-to-q", "routing", "logic", "setup"],
            "delay_ns": {"min": 16.0, "max": 17.0}}})
        self.assertEqual(failed(c), [])
        c = run_flow(self.pack, {"run": VIOLATED, "worst_path": {
            "endpoint": "src_a_SB_DFF_Q_23_DFFLC"}})
        self.assertTrue(failed(c))

    def test_a_flow_pack_without_runs_is_not_a_flow_pack_and_needs_results(self):
        shutil.rmtree(self.pack / "fixtures" / "flow")
        r = pv.verify_pack(self.pack)
        self.assertFalse(r.ok)


class SyntheticLibreLaneRun(unittest.TestCase):
    """A hand-written run shaped like a LibreLane run directory: numbered step
    directories, resolved.json and final/metrics.json. Not tool output."""

    def setUp(self):
        self.tmp = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        self.run = self.tmp / "pack" / "fixtures" / "flow" / "runs" / "d" / "RUN_1"
        self.run.mkdir(parents=True)
        self.pack = self.tmp / "pack"
        (self.run / "resolved.json").write_text("{}")

    def step(self, name, done=True):
        d = self.run / name
        d.mkdir()
        if done:
            (d / "state_out.json").write_text("{}")

    def metrics(self, data):
        (self.run / "final").mkdir(exist_ok=True)
        (self.run / "final" / "metrics.json").write_text(json.dumps(data))

    def flow(self, **kw):
        return run_flow(self.pack, {"run": "fixtures/flow/runs/d/RUN_1", **kw})

    def test_a_completed_run_with_negative_slack_is_violated(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": -0.4})
        self.assertEqual(failed(self.flow(kind="librelane", verdict="violated")), [])
        self.assertTrue(failed(self.flow(verdict="met")))

    def test_slack_is_folded_across_corners_as_a_minimum(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws__corner:tt": 0.5,
                      "timing__setup__ws__corner:ss": -0.1})
        self.assertEqual(failed(self.flow(verdict="violated", metrics=[
            {"key": "timing__setup__ws", "max": -0.05}])), [])

    def test_a_violation_count_above_zero_is_violated(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0, "route__drc_errors": 3})
        self.assertEqual(failed(self.flow(verdict="violated")), [])

    def test_clean_metrics_are_met(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0, "route__drc_errors": 0})
        self.assertEqual(failed(self.flow(verdict="met")), [])

    def test_metrics_with_none_of_the_verdict_keys_are_unrecognised(self):
        self.step("01-yosys-synthesis")
        self.metrics({"design__instance__count": 10})
        self.assertEqual(failed(self.flow(verdict="unrecognised")), [])

    def test_a_run_with_no_final_metrics_is_stopped_at_the_newest_step(self):
        self.step("01-yosys-synthesis")
        self.step("02-openroad-floorplan")
        self.step("03-openroad-globalplacement", done=False)
        self.assertEqual(failed(self.flow(verdict="stopped", steps=[
            {"id": "yosys-synthesis", "status": "completed"},
            {"id": "openroad-floorplan", "status": "completed"},
            {"id": "openroad-globalplacement", "status": "failed"}])), [])

    def test_a_step_with_the_wrong_status_fails(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0})
        c = self.flow(steps=[{"id": "yosys-synthesis", "status": "failed"}])
        self.assertTrue(failed(c))

    def test_an_unknown_step_or_status_fails(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0})
        self.assertTrue(failed(self.flow(steps=[{"id": "nope", "status": "completed"}])))
        self.assertTrue(failed(self.flow(steps=[
            {"id": "yosys-synthesis", "status": "done"}])))

    def test_skipped_is_declared_only_not_silently_verified(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0})
        c = self.flow(steps=[{"id": "yosys-synthesis", "status": "skipped"}])
        self.assertEqual(failed(c), [])
        self.assertTrue(any("declared only" in n for n, _, _ in c))

    def test_an_ambiguous_metric_must_name_the_exact_key(self):
        self.step("01-yosys-synthesis")
        self.metrics({"area__core__um2__corner:a": 5.0})
        self.assertTrue(failed(self.flow(metrics=[
            {"key": "area__core__um2", "min": 0}])))

    def test_mapped_register_applies_to_nextpnr_only(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": 1.0})
        self.assertTrue(failed(self.flow(mapped_register={"source": "x.v"})))

    def test_an_opensta_worst_path_report(self):
        self.step("01-yosys-synthesis")
        self.metrics({"timing__setup__ws": -0.2})
        rpt = self.run / "reports"
        rpt.mkdir()
        (rpt / "setup.rpt").write_text(
            "Startpoint: _101_ (rising edge-triggered flip-flop clocked by clk)\n"
            "Endpoint: _202_ (rising edge-triggered flip-flop clocked by clk)\n"
            "Path Group: clk\n"
            "Path Type: max\n"
            "\n"
            "   -0.20   slack (VIOLATED)\n"
            "\n"
            "Startpoint: _303_ (rising edge-triggered flip-flop clocked by clk)\n"
            "Endpoint: _404_ (rising edge-triggered flip-flop clocked by clk)\n"
            "    0.90   slack (MET)\n")
        ok = self.flow(worst_path={"report": "reports/setup.rpt",
                                   "startpoint": "_101_", "endpoint": "_202_",
                                   "slack": "violated"})
        self.assertEqual(failed(ok), [])
        wrong = self.flow(worst_path={"report": "reports/setup.rpt",
                                      "startpoint": "_303_"})
        self.assertTrue(failed(wrong))
        self.assertTrue(failed(self.flow(worst_path={"report": "reports/none.rpt"})))
        self.assertTrue(failed(self.flow(worst_path={"rank": 1})))


if __name__ == "__main__":
    unittest.main()
