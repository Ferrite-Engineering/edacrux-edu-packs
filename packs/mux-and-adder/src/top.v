// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Top-level wrapper instantiating an 8-bit 2:1 mux feeding an 8-bit
// adder. The `clk` port carries no design logic — it exists so the
// student has a periodic signal to practice transition navigation
// against in the waveform.

`timescale 1ns / 1ns

module top (
    input  wire       clk,
    input  wire       sel,
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [7:0] c_in,
    input  wire       cin,
    output wire [7:0] result,
    output wire       cout
);
    wire [7:0] mux_out;

    mux2to1 #(.WIDTH(8)) u_mux (
        .sel(sel),
        .a  (a_in),
        .b  (b_in),
        .y  (mux_out)
    );

    adder8 u_add (
        .a   (mux_out),
        .b   (c_in),
        .cin (cin),
        .sum (result),
        .cout(cout)
    );
endmodule
