// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Reference (golden) implementation of an 8-bit synchronous counter
// with active-low reset and clock enable. Counts up by one each clock
// cycle while `enable` is asserted.

`timescale 1ns / 1ns

module counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [7:0] count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        count <= 8'd0;
        else if (enable)   count <= count + 8'd1;
    end
endmodule
