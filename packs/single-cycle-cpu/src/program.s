# SPDX-License-Identifier: CC-BY-4.0
# Hand-assembled RV32I program for the single-cycle CPU lab.
#
# Encoded in src/program.hex (one 32-bit instruction per line, MSB first).
# This .s file is documentation only — the CPU does not assemble it.
#
# Word offsets correspond to PC values (each instruction is 4 bytes).

# pc=0x00  ADDI x1,  x0, 5         ; x1 <- 5
# pc=0x04  ADDI x2,  x0, 7         ; x2 <- 7
# pc=0x08  ADD  x3,  x1, x2        ; x3 <- 12
# pc=0x0C  SUB  x4,  x2, x1        ; x4 <- 2
# pc=0x10  SW   x3,  0(x0)         ; mem[0] <- 12
# pc=0x14  LW   x5,  0(x0)         ; x5 <- 12
# pc=0x18  BEQ  x3,  x5, +8        ; taken (skip the next instr)
# pc=0x1C  ADDI x6,  x0, 0xFF      ; skipped (decoder still decodes it)
# pc=0x20  ADDI x7,  x0, 10        ; x7 <- 10
# pc=0x24  ADDI x8,  x0, 11        ; x8 <- 11
# pc=0x28  ADD  x9,  x7, x8        ; x9 <- 21
# pc=0x2C  ADDI x10, x0, 0x42      ; x10 <- 0x42
# pc=0x30  SW   x10, 4(x0)         ; mem[1] <- 0x42
# pc=0x34  LW   x11, 4(x0)         ; x11 <- 0x42
# pc=0x38  JAL  x0,  0             ; spin (jumps to itself)
