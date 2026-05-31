# memory-controller

A Wishbone B4 classic master writes the pattern `0xCAFE0000 .. 0xCAFE0007`
to consecutive 32-bit word addresses of a 256-word memory slave, then
reads them back and stores the result in `last_read`. Students learn
the cyc / stb / ack handshake, apply the WaveCrux Wishbone decoder,
and identify the most-toggling signal with the switching-activity
heatmap.

- **Difficulty:** intermediate
- **Estimated time:** 90 minutes
- **Prerequisites:** counter-lab
- **License:** CC-BY-4.0 (see top-level [`LICENSE-CONTENT`](../../LICENSE-CONTENT))

See [`student/handout.md`](student/handout.md) for the walkthrough and
[`instructor/notes.md`](instructor/notes.md) for grading notes.
