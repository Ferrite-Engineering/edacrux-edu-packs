// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 5-bit maximum-length linear-feedback shift register. The taps are
// state[4] and state[2], implementing the primitive polynomial
// x^5 + x^3 + 1. Initial state on reset is 5'b00001; the period is 31.

`timescale 1ns / 1ns

module lfsr5 (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [4:0] state
);
    wire feedback = state[4] ^ state[2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= 5'b00001;
        else        state <= {state[3:0], feedback};
    end
endmodule
