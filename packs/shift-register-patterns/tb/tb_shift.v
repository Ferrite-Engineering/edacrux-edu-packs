// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Drives the shift register and the LFSR side-by-side from a common
// 100 MHz clock. The shift register receives the known 8-bit pattern
// 10110100 (MSB first) one bit per cycle starting at posedge t=30.
// The LFSR runs continuously and completes its 31-state cycle in
// 310 ns, repeating cleanly over the 3 us simulation.

`timescale 1ns / 1ns

module tb_shift;
    reg        clk;
    reg        rst_n;
    reg        sin;
    wire [7:0] q;
    wire       sout;
    wire [4:0] lfsr_state;

    shift_reg u_shift (
        .clk  (clk),
        .rst_n(rst_n),
        .sin  (sin),
        .q    (q),
        .sout (sout)
    );

    lfsr5 u_lfsr (
        .clk  (clk),
        .rst_n(rst_n),
        .state(lfsr_state)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_shift);

        rst_n = 1'b0;
        sin   = 1'b0;
        #22;
        rst_n = 1'b1;

        // sin is sampled on each posedge starting at t=30. Set each
        // bit between posedges so the value is stable at sample time.
        // Pattern: 10110100 (MSB first).
        #3;          sin = 1'b1;   // stable for posedge at t=30
        #10;         sin = 1'b0;   // stable for posedge at t=40
        #10;         sin = 1'b1;   // posedge at t=50
        #10;         sin = 1'b1;   // posedge at t=60
        #10;         sin = 1'b0;   // posedge at t=70
        #10;         sin = 1'b1;   // posedge at t=80
        #10;         sin = 1'b0;   // posedge at t=90
        #10;         sin = 1'b0;   // posedge at t=100
        #10;         sin = 1'b0;   // idle from posedge t=110 onward

        // Continue running until t=3000 ns to give the LFSR multiple
        // full 31-cycle periods.
        #2895;
        $finish;
    end
endmodule
