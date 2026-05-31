// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Parameterized 2:1 multiplexer. `sel = 0` selects `a`; `sel = 1` selects `b`.

`timescale 1ns / 1ns

module mux2to1 #(parameter WIDTH = 8) (
    input  wire             sel,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? b : a;
endmodule
