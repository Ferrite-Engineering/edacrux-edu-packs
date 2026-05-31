// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Read-only instruction memory. 64 words deep (256 bytes); contents
// loaded from `program.hex` at simulation start. Address is byte-
// addressed but only word-aligned access is honoured (lower two bits
// ignored).

`timescale 1ns / 1ns

module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:63];
    initial $readmemh("src/program.hex", mem);
    assign instr = mem[addr[7:2]];
endmodule
