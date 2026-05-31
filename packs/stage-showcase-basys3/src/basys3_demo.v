// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Digilent Basys 3 board demo. Drives 4 LEDs from 4 switches (direct
// passthrough), and drives a 4-digit common-anode 7-segment display
// with a 4-bit counter that increments on each rising edge of any of
// 4 push buttons.
//
// Targeting the WaveCrux Stage panel, not real hardware -- the
// design is deliberately tiny and the 7-segment encoder uses the
// standard Basys 3 active-low segment polarity.

`timescale 1ns / 1ns

module basys3_demo (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [ 3:0] sw,        // SW[3:0]
    input  wire [ 3:0] btn,       // BTN[3:0] -- any rising edge increments
    output wire [ 3:0] led,       // LED[3:0]
    output reg  [ 6:0] seg,       // CG..CA, active low (Basys 3 convention)
    output wire [ 3:0] an         // anodes; we drive a single digit (an[0]=0) for simplicity
);
    // ── Switch passthrough ──────────────────────────────────────────
    assign led = sw;

    // ── Single active digit (rightmost) ────────────────────────────
    assign an = 4'b1110;

    // ── Button edge detector ────────────────────────────────────────
    reg [3:0] btn_prev;
    wire any_rising_edge = |(btn & ~btn_prev);

    // ── Internal 4-bit count ────────────────────────────────────────
    reg [3:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_prev <= 4'b0000;
            count    <= 4'd0;
        end else begin
            btn_prev <= btn;
            if (any_rising_edge) count <= count + 4'd1;
        end
    end

    // ── 4-bit -> 7-segment encoder (active-low, hexadecimal) ────────
    always @(*) begin
        case (count)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
