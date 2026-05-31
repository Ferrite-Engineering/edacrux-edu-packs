# counter-lab

An 8-bit synchronous up-counter with active-low reset, clock enable, and an
overflow strobe — the canonical first WaveCrux lab. Students open
`fixtures/reference.vcd`, add signals to the lane panel, change display
formats, navigate clock-edge-to-clock-edge with **Q** / **E**, and locate
the rollover from `0xFF` back to `0x00`.

- **Difficulty:** intro
- **Estimated time:** 45 minutes
- **Prerequisites:** none
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the lab walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading guidance and
common-mistake notes. The full manifest is in [`pack.yaml`](pack.yaml).
