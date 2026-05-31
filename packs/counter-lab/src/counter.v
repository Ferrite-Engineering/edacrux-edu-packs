// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 8-bit synchronous up-counter with active-low reset, clock enable, and
// combinational overflow strobe. Intended as the very first lab in the
// WaveCrux EDU Learning Pack catalog — minimal yet exercising every
// signal-display surface a student will use later.

`timescale 1ns / 1ns

module counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [7:0] count,
    output wire       overflow
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        count <= 8'd0;
        else if (enable)   count <= count + 8'd1;
    end

    // High for one clock cycle each time the counter is parked at 0xFF
    // with the enable asserted (i.e. the cycle in which it is about to
    // wrap to zero).
    assign overflow = enable && (count == 8'hFF);
endmodule
