# single-cycle-cpu — instructor notes

## Learning objectives recap

1. Apply the WaveCrux RISC-V instruction decoder to a `pc + instr`
   signal pair.
2. Navigate a CPU's hierarchy and reach into its register file from
   the signal tree.
3. Correlate each instruction with its register-file or memory side
   effect.
4. Recognize branch behaviour in the PC trace.

## Program summary

| Cycle (t/10) | PC   | Instruction         | Effect |
|---|---|---|---|
| 1 | 0x00 | `addi x1, x0, 5`   | x1 ← 5 |
| 2 | 0x04 | `addi x2, x0, 7`   | x2 ← 7 |
| 3 | 0x08 | `add  x3, x1, x2`  | x3 ← 12 |
| 4 | 0x0C | `sub  x4, x2, x1`  | x4 ← 2 |
| 5 | 0x10 | `sw   x3, 0(x0)`   | mem[0] ← 12 |
| 6 | 0x14 | `lw   x5, 0(x0)`   | x5 ← 12 |
| 7 | 0x18 | `beq  x3, x5, +8`  | branch taken, skip 0x1C |
|   | 0x1C | `addi x6, x0, 0xFF` | *never executed* |
| 8 | 0x20 | `addi x7, x0, 10`  | x7 ← 10 |
| 9 | 0x24 | `addi x8, x0, 11`  | x8 ← 11 |
| 10 | 0x28 | `add  x9, x7, x8` | x9 ← 21 |
| 11 | 0x2C | `addi x10, x0, 0x42` | x10 ← 0x42 |
| 12 | 0x30 | `sw   x10, 4(x0)` | mem[1] ← 0x42 |
| 13 | 0x34 | `lw   x11, 4(x0)` | x11 ← 0x42 |
| 14+ | 0x38 | `jal  x0, 0`      | self-loop (rd=x0, imm=0) |

Cycle numbering counts from reset deassertion (t = 22 ns); cycle N
ends at posedge t = (20 + 10·N).

## Exercise answers

**Part 2.** In the register file, `x1` is `regs[1]`, `x10` is
`regs[10]`. The "stack pointer" (x2) is `regs[2]`. Even though this
program uses x2 just as a temporary, the convention is that x2 is sp.

**Part 3.** `regs[3]` first becomes 0x0C (12) at t = 50 ns (cycle 3,
i.e. the ADD x3, x1, x2 commit).

**Exercise 1.** The PC transition from `0x18` to `0x20` happens at
t = 90 ns. The `branch_taken` lane reads `1` for the duration of the
BEQ cycle (t = 80 to t = 90 ns).

**Exercise 2.** Decoding `0x00518463`:
- bits [31] = 0 → imm[12] = 0
- bits [30:25] = 000000 → imm[10:5] = 0
- bits [24:20] = 00101 → rs2 = 5
- bits [19:15] = 00011 → rs1 = 3
- bits [14:12] = 000 → funct3 = 000 (BEQ)
- bits [11:8] = 0100 → imm[4:1] = 0100 = 4
- bit [7] = 0 → imm[11] = 0
- bits [6:0] = 1100011 → opcode (BRANCH)

Assembling `imm_b = imm[12], imm[11], imm[10:5], imm[4:1], 0`
gives `0 | 0 | 000000 | 0100 | 0` = 0b0_0_000000_0100_0 = 8 ✓

**Exercise 3.** If `mem[0]` did not equal `x3`, the BEQ would *not*
be taken. PC would advance from `0x18` to `0x1C` (the next sequential
instruction), executing `ADDI x6, x0, 0xFF` and setting x6 to 0xFF.
The rest of the program would then run as normal (the next
instruction at PC=0x20 is independent of x6). So the only behavioural
difference would be that `x6` would hold 0xFF instead of 0.

## Common student mistakes

- **Looking for x0 changes.** Some students will mark x0 (regs[0])
  in the lane panel and expect it to take various values. x0 is
  hard-wired to zero in RISC-V — the writeback logic explicitly
  discards writes to x0. Coach: x0 is a "discard sink."
- **Reading the wrong PC for the branch.** The `pc` lane at t = 80
  shows the PC of the *currently-executing* instruction (BEQ at
  0x18). At t = 90 (next posedge), pc updates to 0x20. The branch
  target is *not* "fetched on the same cycle" — it appears at the
  next clock edge.
- **Confusing word-address vs byte-address arithmetic.** The
  instruction memory is word-indexed internally (`mem[addr[7:2]]`)
  but the address bus is byte-addressed. So PC = 0x4 reads
  mem[0x1] = 0x00700113 (the second instruction). Show the
  `mem[addr[7:2]]` line in `src/imem.v` if students get confused.

## Grading rubric (suggested)

| Item | Points |
|---|---:|
| RISC-V decoder applied with all 14 instructions visible | 3 |
| Register lanes for at least 5 of x1..x11 added | 1 |
| Branch-taken cycle correctly identified (t=90 ns, branch_taken=1) | 2 |
| Exercise 2: imm_b = 8 with correct decoding | 2 |
| Exercise 3: x6 = 0xFF, rest of program unaffected | 2 |
| **Total** | **10** |

## Re-running the build

```bash
cd packs/single-cycle-cpu
./build.sh
```

The `$readmemh` warning about "Not enough words in the file for the
requested range [0:63]" is **expected** — the imem reserves 64 slots
but only 15 instructions are populated. The remaining slots stay at
0, which a real CPU would interpret as an illegal instruction, but
the JAL at PC=0x38 traps execution before any of those slots are
ever fetched.

## Cross-tool upgrade (WaveCrux + NetCrux)

Now a pair. The WaveCrux half is unchanged — trace the RISC-V program through the
waveform, reading registers and the instruction stream over time. The NetCrux half
adds the *spatial* view: the same CPU as a datapath assembled from an instruction
memory and a register file, so students connect "this register changed at cycle N"
to "through this write path".

The structural facts (rv32_cpu instantiates imem and regfile) are machine-verified
against the synthesised netlist. The cross-probe deep-link — register in WaveCrux to
write path in NetCrux — is declared but not machine-verified; a live cross-probe
needs both apps under automation, which the suite does not yet expose. The jump is
by hand here, onto real structure.
