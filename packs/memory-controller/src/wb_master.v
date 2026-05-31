// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Wishbone B4 classic master that automatically writes 8 known values
// to consecutive 32-bit word addresses, then reads them back and
// stores the result in `last_read`. Designed for visualization in a
// waveform viewer rather than for synthesis.
//
// Pattern: writes 0xCAFE_0000 .. 0xCAFE_0007 to word addresses 0..7
// (byte addresses 0x00 .. 0x1C), then reads them back in the same
// order.

`timescale 1ns / 1ns

module wb_master (
    input  wire        clk,
    input  wire        rst,
    output reg  [31:0] wb_adr,
    output reg  [31:0] wb_dat_o,
    input  wire [31:0] wb_dat_i,
    output reg         wb_we,
    output reg  [ 3:0] wb_sel,
    output reg         wb_stb,
    output reg         wb_cyc,
    input  wire        wb_ack,
    output reg  [31:0] last_read,
    output reg         done
);
    localparam [2:0] S_RESET     = 3'd0;
    localparam [2:0] S_WRITE     = 3'd1;
    localparam [2:0] S_WRITE_ACK = 3'd2;
    localparam [2:0] S_READ      = 3'd3;
    localparam [2:0] S_READ_ACK  = 3'd4;
    localparam [2:0] S_DONE      = 3'd5;

    reg [2:0] state;
    reg [3:0] idx;        // 0..7 plus one to terminate
    reg [3:0] next_idx;

    always @(posedge clk) begin
        if (rst) begin
            wb_adr    <= 32'h0;
            wb_dat_o  <= 32'h0;
            wb_we     <= 1'b0;
            wb_sel    <= 4'h0;
            wb_stb    <= 1'b0;
            wb_cyc    <= 1'b0;
            last_read <= 32'h0;
            done      <= 1'b0;
            state     <= S_WRITE;
            idx       <= 4'd0;
            next_idx  <= 4'd0;
        end else begin
            case (state)
                S_WRITE: begin
                    if (idx == 4'd8) begin
                        // All writes done; reset index for reads.
                        idx     <= 4'd0;
                        wb_cyc  <= 1'b0;
                        wb_stb  <= 1'b0;
                        wb_we   <= 1'b0;
                        state   <= S_READ;
                    end else begin
                        wb_adr   <= {24'h0, idx[2:0], 2'b00}; // word-aligned
                        wb_dat_o <= 32'hCAFE_0000 | {28'h0, idx[3:0]};
                        wb_we    <= 1'b1;
                        wb_sel   <= 4'hF;
                        wb_stb   <= 1'b1;
                        wb_cyc   <= 1'b1;
                        state    <= S_WRITE_ACK;
                    end
                end
                S_WRITE_ACK: begin
                    if (wb_ack) begin
                        wb_stb <= 1'b0;
                        wb_cyc <= 1'b0;
                        wb_we  <= 1'b0;
                        idx    <= idx + 4'd1;
                        state  <= S_WRITE;
                    end
                end
                S_READ: begin
                    if (idx == 4'd8) begin
                        wb_cyc <= 1'b0;
                        wb_stb <= 1'b0;
                        done   <= 1'b1;
                        state  <= S_DONE;
                    end else begin
                        wb_adr <= {24'h0, idx[2:0], 2'b00};
                        wb_we  <= 1'b0;
                        wb_sel <= 4'hF;
                        wb_stb <= 1'b1;
                        wb_cyc <= 1'b1;
                        state  <= S_READ_ACK;
                    end
                end
                S_READ_ACK: begin
                    if (wb_ack) begin
                        last_read <= wb_dat_i;
                        wb_stb    <= 1'b0;
                        wb_cyc    <= 1'b0;
                        idx       <= idx + 4'd1;
                        state     <= S_READ;
                    end
                end
                S_DONE: begin
                    wb_cyc <= 1'b0;
                    wb_stb <= 1'b0;
                end
                default: state <= S_DONE;
            endcase
        end
    end
endmodule
