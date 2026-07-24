# single-cycle-cpu — student handout

This lab traces a tiny **RV32I single-cycle CPU** executing a known
15-instruction program. Each instruction executes in *exactly one*
clock cycle — there is no pipelining and no hazards. At each clock
edge:

1. PC presents the next instruction address.
2. The instruction memory returns the encoded 32-bit instruction on
   `instr`.
3. The CPU decodes the instruction, reads source registers, computes
   the ALU output, computes the next PC, and (on the same cycle's
   clock edge) writes back to the destination register or to data
   memory.

The program is documented in [`../src/program.s`](../src/program.s)
and machine-encoded in [`../src/program.hex`](../src/program.hex).

## Setup

1. Launch WaveCrux, **File → Open Session…** select
   `fixtures/reference.wavecrux`. (Or open `fixtures/reference.vcd`
   and add `pc`, `instr`, `alu_out`, `rf_we`, `branch_taken`, and a
   few `regs[N]` entries from the register file.)

## Part 1 — apply the RISC-V decoder

1. Right-click on `instr` (or `pc`) and choose **Add Decoder →
   RISC-V**.
2. WaveCrux loads the binding from
   `decoders/riscv_binding.json` (RV32I, 32-bit XLEN).
3. Click **Apply**. A new lane appears beneath `instr` showing the
   decoded mnemonic at each cycle.
4. Open the **Transaction Table** (**Ctrl+T**).

> **A:** The table should list 14 distinct retired instructions (the
> first 7 cycles plus PC 0x20 onward — note that PC=0x1C is *never*
> executed because BEQ skipped it). The 14th and onward are
> repetitions of the `jal` self-loop.

## Part 2 — navigate the hierarchy

1. Expand `tb_rv32_cpu.dut` in the signal tree.
2. Expand `u_regfile`. The 32 register entries appear as
   `regs[0]`..`regs[31]`.
3. Expand `dut` further to see the data memory `dmem[0]`..`dmem[31]`.

> **Q:** What register holds `x1`, what holds `x10`, what holds the
> stack pointer (x2 in conventional RISC-V calling convention)?
>
> ___________________________________________________________________

## Part 3 — correlate execution with register writes

1. Add the following register lanes to the lane panel (drag from the
   signal tree or use Ctrl+F):
   - `regs[1]`, `regs[2]`, `regs[3]`, `regs[4]`, `regs[5]`,
     `regs[7]`, `regs[8]`, `regs[9]`, `regs[10]`, `regs[11]`.
2. Display all in **Decimal** or **Hexadecimal** (your choice).
3. Move the cursor through the trace and watch the registers update.

> **A:** Note the time at which `regs[3]` first becomes 12 (the sum
> of x1=5 and x2=7).
>
> Time = ____ ns. Cycle number from reset (use the cursor / 10 ns) = ____

## Part 4 — exercises

### Exercise 1 — find the branch

The BEQ at PC=0x18 is taken (because x3 == x5 == 12, both 0x0C).

1. Focus the `pc` row.
2. Press **Home** then **E** repeatedly. The cursor steps every
   10 ns — once per instruction.

> **Q:** Identify the cycle where `pc` advances from `0x18` to
> `0x20`, skipping `0x1C` entirely. What time is that? What does
> the `branch_taken` lane read at that moment?
>
> ___________________________________________________________________

### Exercise 2 — verify the immediate field

The BEQ encoding for "+8" produces the offset `imm_b = 8`. The
machine-code value of the BEQ instruction is `0x00518463`.

> **Q:** Decode the imm_b field by hand from `0x00518463`. *(Hint:
> the layout is `imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1],
> imm[11], opcode` — bits 31, 30:25, 24:20, 19:15, 14:12, 11:8, 7,
> 6:0.)*
>
> imm_b in binary = ___________________ ; in decimal = ____

### Exercise 3 — what would happen if x3 != x5?

If `mem[0]` stored a different value than 12, then after LW the
register `x5` would hold that other value, and the BEQ at PC=0x18
would NOT be taken.

> **Q:** In that case, what is the next PC after BEQ? And how would
> the program's behavior change overall?
>
> ___________________________________________________________________

## What to turn in

A screenshot showing:
- The RISC-V decoder lane with at least the first 8 instructions
  decoded.
- The register file lanes for x1, x3, x5, x10, x11 with their final
  values.
- A marker on the BEQ branch-taken cycle.

Plus answers to Parts 2, 3, and the three exercises.

---

## Cross-probing to the datapath (NetCrux)

The waveform showed you the CPU *in time* — instructions flowing through, registers
changing value cycle by cycle. NetCrux shows you the CPU *in space*: the datapath
those values move through.

```
netcrux fixtures/netlist.json
```

- The top module, `rv32_cpu`, is assembled from two blocks you can push into: an
  **instruction memory** (`imem`) and a **register file** (`regfile`). Find both.
- Pick a register whose value you watched change in the waveform. In NetCrux, open
  `regfile` and find the write path: the write-address, write-data and write-enable
  that an executing instruction drives.
- Connect the two views: the value you saw appear at a specific time in the
  waveform arrived through exactly this write path in the structure. Time and space,
  the same event.

> On a full install this is a cross-probe: select the register in WaveCrux, land on
> its write path in NetCrux. Here you make the jump by hand — the structure you land
> on is the real synthesised datapath.
