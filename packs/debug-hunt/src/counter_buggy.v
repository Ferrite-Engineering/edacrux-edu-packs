// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Buggy implementation of an 8-bit synchronous counter. Looks
// suspiciously similar to the golden version — but contains a single-
// character bug. **Spoiler: the bug is on the enable-test line.**
//
// Do NOT consult `counter_golden.v` until after you have first tried
// to find the bug from the waveform diff alone.

`timescale 1ns / 1ns

module counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [7:0] count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        count <= 8'd0;
        else if (~enable)  count <= count + 8'd1;   // <-- BUG
    end
endmodule
