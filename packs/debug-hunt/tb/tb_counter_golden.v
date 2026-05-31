// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Stimulus for the golden counter. 100 MHz clock, reset until t=22 ns,
// `enable` toggles partway through to exercise both behaviours.

`timescale 1ns / 1ns

module tb_counter_golden;
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
        $dumpfile("fixtures/golden.vcd");
        $dumpvars(0, tb_counter_golden);

        rst_n  = 1'b0;
        enable = 1'b0;
        #22;
        rst_n  = 1'b1;
        enable = 1'b1;
        #178;            // count from 0x01 to ~0x12 with enable=1
        enable = 1'b0;
        #100;            // hold for 100 ns; counter should NOT advance
        enable = 1'b1;
        #200;            // resume counting
        $finish;
    end
endmodule
