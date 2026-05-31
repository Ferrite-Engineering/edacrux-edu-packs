// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Testbench for the 8-bit synchronous counter.
//
// Clock convention: `clk` starts at 1 and toggles every 5 ns, so the
// first posedge is at t=10 ns and subsequent posedges land on every
// multiple of 10 ns (10, 20, 30, ...). This gives clean, pedagogical
// numbers in the waveform — students can read transition times directly
// off the cursor.
//
// Timing:
//   * Reset (`rst_n`) is held low from t=0 through t=22 ns. The posedge
//     at t=20 still sees rst_n=0, so the first increment happens at the
//     posedge at t=30. That places `count = 8'h01` at t=30, `count =
//     8'h80` at t=1300, `count = 8'hFF` at t=2570, and the rollover to
//     `count = 8'h00` at t=2580.
//   * Enable goes high at t=22 alongside reset release.
//   * Simulation finishes at t=3000 ns so the rollover and the
//     overflow strobe are clearly bracketed in the waveform.

`timescale 1ns / 1ns

module tb_counter;
    reg        clk;
    reg        rst_n;
    reg        enable;
    wire [7:0] count;
    wire       overflow;

    counter dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (enable),
        .count   (count),
        .overflow(overflow)
    );

    // 100 MHz: 10 ns period, posedges at 10, 20, 30, ...
    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_counter);

        rst_n  = 1'b0;
        enable = 1'b0;

        #22;          // hold reset for 22 ns; reset releases at t=22
        rst_n  = 1'b1;
        enable = 1'b1;

        #2978;        // bring the total run length to 3000 ns
        $finish;
    end
endmodule
