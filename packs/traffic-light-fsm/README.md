# traffic-light-fsm

A 3-state traffic-light FSM (RED → GREEN → YELLOW → RED) with a 30-cycle
dwell per state, driven at 100 MHz. Students apply a GTKWave-compatible
translate filter so the 2-bit `state` signal renders as named labels,
open the **FSM Visualizer** panel to see state transitions graphically,
and measure the FSM period by placing markers on three R → G
transitions.

- **Difficulty:** intro
- **Estimated time:** 60 minutes
- **Prerequisites:** none
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the lab walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes. The
translate filter lives in [`translate/fsm_states.txt`](translate/fsm_states.txt).
