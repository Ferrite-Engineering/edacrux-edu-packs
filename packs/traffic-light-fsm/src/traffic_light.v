// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 3-state traffic-light FSM: RED -> GREEN -> YELLOW -> RED. Dwell-time
// counter holds each state for 30 cycles, so at the 100 MHz testbench
// clock each state lasts 300 ns and one full RED/GREEN/YELLOW cycle
// takes 900 ns.

`timescale 1ns / 1ns

module traffic_light (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [1:0] state,
    output wire       red_light,
    output wire       green_light,
    output wire       yellow_light
);
    localparam [1:0] RED    = 2'b00;
    localparam [1:0] GREEN  = 2'b01;
    localparam [1:0] YELLOW = 2'b10;

    reg [4:0] dwell;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RED;
            dwell <= 5'd0;
        end else if (dwell == 5'd29) begin
            dwell <= 5'd0;
            case (state)
                RED:     state <= GREEN;
                GREEN:   state <= YELLOW;
                YELLOW:  state <= RED;
                default: state <= RED;
            endcase
        end else begin
            dwell <= dwell + 5'd1;
        end
    end

    assign red_light    = (state == RED);
    assign green_light  = (state == GREEN);
    assign yellow_light = (state == YELLOW);
endmodule
