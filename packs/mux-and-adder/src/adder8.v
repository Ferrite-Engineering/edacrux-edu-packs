// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 8-bit unsigned adder with carry-in and carry-out. Synthesized form
// would map to a ripple-carry chain in a CPLD; for simulation the
// behavioural `+` is sufficient and produces the same waveform.

`timescale 1ns / 1ns

module adder8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire [7:0] sum,
    output wire       cout
);
    assign {cout, sum} = a + b + cin;
endmodule
