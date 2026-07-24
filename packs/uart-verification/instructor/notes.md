# Instructor notes — uart-verification

## Point of the lab

The reflex this lab breaks: *red test ⇒ design bug ⇒ change the RTL.* Here the
design is correct and the test is wrong, so a student who "fixes" the DUT makes
it worse. The only way to know which to touch is to look at the waveform — which
is exactly the cross-probe the pair enables.

## The setup

- `src/uart_tx.v` is a correct 8N1 transmitter.
- `tb/tb_uart.v` sends 0x55, 0xA3, 0xFF and checks each on the receive side. The
  `tx_0xFF` check expects **0x00** — a deliberately wrong expectation. The DUT
  transmits 0xFF correctly, so the test fails.

## Answers

- **§1.** `tx_0x55` and `tx_0xA3` pass; `tx_0xFF` fails.
- **§2.** On the line, 0xFF is start(0), eight 1s, stop(1). The DUT sends 0xFF
  correctly — visible directly on `tx`.
- **§3.** The testbench expected 0x00. Wrong expectation; the design is right.
- **§4.** Fix is in the testbench (expect 0xFF). Grading point: the student must
  NOT have modified `src/uart_tx.v`. If they did, ask them what evidence told
  them the DUT was wrong — there is none.

## On the cross-tool step

The regression outcomes are machine-verified against the real run, and the
waveform's idle state is checked against the VCD. The deep-link — failing test in
SimCrux to its transmission in WaveCrux — is declared but not machine-verified;
verifying a live cross-probe needs both apps under automation, which the suite
does not yet expose. Both fixtures come from one testbench run, so the failure and
its waveform are guaranteed to be the same event.

## Common misconceptions

- *"A failing test means the design is broken."* Not necessarily — a test encodes
  someone's belief about correct behaviour, and beliefs can be wrong. This lab is
  the counterexample students remember.
- *"If I make the bar green I am done."* You can make it green by fixing the test
  OR by breaking the DUT to match a wrong expectation. Only one is correct, and
  only the waveform tells you which.

## Using this in a course

Everything here is CC-BY-4.0 — adapt, renumber and rebrand it. Give students the
`student/` material (or the student-only archive) via your LMS; keep `instructor/`
for yourself. For a private, high-stakes assessment, fork the pack and change the
exercise — for example, move the bug into the DUT so the correct fix is the RTL.
