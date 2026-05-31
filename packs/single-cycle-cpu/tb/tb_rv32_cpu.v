// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Runs the single-cycle CPU through its 15-instruction program. 100
// MHz clock; 500 ns simulation gives ~50 instruction cycles, more
// than enough to settle into the JAL self-loop at the end of the
// program.

`timescale 1ns / 1ns

module tb_rv32_cpu;
    reg         clk;
    reg         rst;
    wire [31:0] pc;
    wire [31:0] instr;

    rv32_cpu dut (
        .clk  (clk),
        .rst  (rst),
        .pc   (pc),
        .instr(instr)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_rv32_cpu);

        rst = 1'b1;
        #22;
        rst = 1'b0;
        #478;
        $finish;
    end
endmodule
