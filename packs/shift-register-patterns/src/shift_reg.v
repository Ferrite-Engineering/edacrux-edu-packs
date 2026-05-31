// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 8-bit shift register. New data enters at q[0]; old data drops out
// from q[7]. Serial-out `sout` mirrors q[7].

`timescale 1ns / 1ns

module shift_reg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sin,
    output reg  [7:0] q,
    output wire       sout
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 8'd0;
        else        q <= {q[6:0], sin};
    end
    assign sout = q[7];
endmodule
