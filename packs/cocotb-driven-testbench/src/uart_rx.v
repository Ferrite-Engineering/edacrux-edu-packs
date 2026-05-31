// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// UART receiver. 8-N-1, configurable bit period in clock cycles
// (CYCLES_PER_BIT = 434 at 50 MHz gives 115_207 baud).
//
// State machine:
//   IDLE   -- waiting for start-bit (falling edge on rx)
//   START  -- align cursor to mid-bit then sample (must read 0)
//   DATA   -- 8 cycles of mid-bit sampling, LSB first
//   STOP   -- sample stop bit (must read 1)
// On the end of STOP a one-cycle pulse on `rx_valid` accompanies
// `rx_data` with the received byte.

`timescale 1ns / 1ns

module uart_rx #(parameter CYCLES_PER_BIT = 434) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] rx_data,
    output reg        rx_valid
);
    localparam [1:0] IDLE  = 2'd0;
    localparam [1:0] START = 2'd1;
    localparam [1:0] DATA  = 2'd2;
    localparam [1:0] STOP  = 2'd3;

    reg [1:0] state;
    reg [9:0] cycle;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;

    // Mid-bit cycle count (e.g. 434/2 = 217).
    localparam integer HALF_BIT = CYCLES_PER_BIT / 2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            cycle    <= 10'd0;
            bit_idx  <= 3'd0;
            data_reg <= 8'd0;
            rx_data  <= 8'd0;
            rx_valid <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                IDLE: begin
                    if (rx == 1'b0) begin
                        cycle <= 10'd0;
                        state <= START;
                    end
                end
                START: begin
                    // Wait HALF_BIT cycles to align with the middle of
                    // the start bit, then confirm rx is still 0.
                    if (cycle == HALF_BIT - 1) begin
                        if (rx == 1'b0) begin
                            cycle   <= 10'd0;
                            bit_idx <= 3'd0;
                            state   <= DATA;
                        end else begin
                            // Glitch -- abort and return to IDLE.
                            state <= IDLE;
                        end
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
                DATA: begin
                    if (cycle == CYCLES_PER_BIT - 1) begin
                        cycle <= 10'd0;
                        data_reg[bit_idx] <= rx;
                        if (bit_idx == 3'd7) state <= STOP;
                        else                 bit_idx <= bit_idx + 3'd1;
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
                STOP: begin
                    if (cycle == CYCLES_PER_BIT - 1) begin
                        cycle    <= 10'd0;
                        rx_data  <= data_reg;
                        rx_valid <= 1'b1;
                        state    <= IDLE;
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
            endcase
        end
    end
endmodule
