// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Testbench for the mux + adder hierarchical design.
//
// The design itself is fully combinational, but the testbench drives a
// free-running 100 MHz clock through it so students have a periodic
// signal to navigate against. The interesting input combinations are
// applied at clean 50 ns boundaries:
//
//   t=50  ns:  sel=0, a=0x12, b=0x34, c=0x10, cin=0  → mux_out=0x12, result=0x22, cout=0
//   t=100 ns:  sel=1                                  → mux_out=0x34, result=0x44, cout=0
//   t=150 ns:  sel=0, a=0xFF, c=0x01                 → mux_out=0xFF, result=0x00, cout=1
//   t=200 ns:  sel=1, b=0x80, c=0x80, cin=0          → mux_out=0x80, result=0x00, cout=1
//   t=250 ns:  finish

`timescale 1ns / 1ns

module tb_top;
    reg        clk;
    reg        sel;
    reg  [7:0] a_in;
    reg  [7:0] b_in;
    reg  [7:0] c_in;
    reg        cin;
    wire [7:0] result;
    wire       cout;

    top dut (
        .clk   (clk),
        .sel   (sel),
        .a_in  (a_in),
        .b_in  (b_in),
        .c_in  (c_in),
        .cin   (cin),
        .result(result),
        .cout  (cout)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_top);

        sel  = 1'b0;
        a_in = 8'h00;
        b_in = 8'h00;
        c_in = 8'h00;
        cin  = 1'b0;

        #50;
        // Case 1: mux selects a, no carry. result = 0x12 + 0x10 = 0x22.
        sel  = 1'b0;
        a_in = 8'h12;
        b_in = 8'h34;
        c_in = 8'h10;
        cin  = 1'b0;

        #50;
        // Case 2: same data, sel flips to b. result = 0x34 + 0x10 = 0x44.
        sel  = 1'b1;

        #50;
        // Case 3: mux selects a=0xFF, c=0x01. result = 0x00, cout = 1.
        sel  = 1'b0;
        a_in = 8'hFF;
        c_in = 8'h01;

        #50;
        // Case 4: mux selects b=0x80, c=0x80, cin=0. result = 0x00, cout = 1.
        sel  = 1'b1;
        b_in = 8'h80;
        c_in = 8'h80;
        cin  = 1'b0;

        #50;
        $finish;
    end
endmodule
