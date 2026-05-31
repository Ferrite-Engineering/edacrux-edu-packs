// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Wishbone B4 classic synchronous memory slave. 256 words x 32 bits.
// Byte-enable `sel` is honored for writes (per-byte mask). Reads are
// always full 32-bit.
//
// Handshake: ack is asserted for exactly one cycle, the cycle after
// cyc & stb are observed valid.

`timescale 1ns / 1ns

module wb_memory #(parameter ADDR_WIDTH = 8) (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] wb_adr,
    input  wire [31:0] wb_dat_i,
    output reg  [31:0] wb_dat_o,
    input  wire        wb_we,
    input  wire [ 3:0] wb_sel,
    input  wire        wb_stb,
    input  wire        wb_cyc,
    output reg         wb_ack
);
    reg [31:0] mem [0:(1<<ADDR_WIDTH)-1];

    wire active = wb_cyc & wb_stb & ~wb_ack;
    wire [ADDR_WIDTH-1:0] word_addr = wb_adr[ADDR_WIDTH+1:2]; // 4-byte aligned

    always @(posedge clk) begin
        if (rst) begin
            wb_ack   <= 1'b0;
            wb_dat_o <= 32'h0000_0000;
        end else if (active) begin
            wb_ack <= 1'b1;
            if (wb_we) begin
                if (wb_sel[0]) mem[word_addr][ 7: 0] <= wb_dat_i[ 7: 0];
                if (wb_sel[1]) mem[word_addr][15: 8] <= wb_dat_i[15: 8];
                if (wb_sel[2]) mem[word_addr][23:16] <= wb_dat_i[23:16];
                if (wb_sel[3]) mem[word_addr][31:24] <= wb_dat_i[31:24];
            end else begin
                wb_dat_o <= mem[word_addr];
            end
        end else begin
            wb_ack <= 1'b0;
        end
    end
endmodule
