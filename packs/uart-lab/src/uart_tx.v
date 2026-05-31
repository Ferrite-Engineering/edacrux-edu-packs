// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// UART transmitter, 8-N-1 (8 data bits, no parity, 1 stop bit). At the
// default CYCLES_PER_BIT = 434 and a 50 MHz clock this gives an
// effective baud rate of 50_000_000 / 434 = 115_207 Hz, well within
// any conforming UART receiver's tolerance for the nominal 115_200.
//
// One-shot use: assert tx_start for at least one cycle while
// tx_busy = 0 to enqueue tx_data. The byte is shifted out LSB first.

`timescale 1ns / 1ns

module uart_tx #(parameter CYCLES_PER_BIT = 434) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output wire       tx_busy
);
    localparam [1:0] IDLE  = 2'd0;
    localparam [1:0] START = 2'd1;
    localparam [1:0] DATA  = 2'd2;
    localparam [1:0] STOP  = 2'd3;

    reg [1:0] state;
    reg [9:0] cycle;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;

    assign tx_busy = (state != IDLE);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tx       <= 1'b1;
            cycle    <= 10'd0;
            bit_idx  <= 3'd0;
            data_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        cycle    <= 10'd0;
                        state    <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (cycle == CYCLES_PER_BIT - 1) begin
                        cycle   <= 10'd0;
                        bit_idx <= 3'd0;
                        state   <= DATA;
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (cycle == CYCLES_PER_BIT - 1) begin
                        cycle <= 10'd0;
                        if (bit_idx == 3'd7) state <= STOP;
                        else                 bit_idx <= bit_idx + 3'd1;
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (cycle == CYCLES_PER_BIT - 1) begin
                        cycle <= 10'd0;
                        state <= IDLE;
                    end else begin
                        cycle <= cycle + 10'd1;
                    end
                end
            endcase
        end
    end
endmodule
