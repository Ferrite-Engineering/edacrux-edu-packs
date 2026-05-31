// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Same stimulus as tb_counter_golden, but binds the *buggy* counter
// and dumps to fixtures/buggy.vcd. Identical stimulus + same VCD
// signal names is essential for the waveform diff to align.

`timescale 1ns / 1ns

module tb_counter_buggy;
    reg       clk;
    reg       rst_n;
    reg       enable;
    wire [7:0] count;

    counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .enable(enable),
        .count (count)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/buggy.vcd");
        $dumpvars(0, tb_counter_buggy);

        rst_n  = 1'b0;
        enable = 1'b0;
        #22;
        rst_n  = 1'b1;
        enable = 1'b1;
        #178;
        enable = 1'b0;
        #100;
        enable = 1'b1;
        #200;
        $finish;
    end
endmodule
