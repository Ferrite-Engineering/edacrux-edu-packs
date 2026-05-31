// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// SPI mode-0 master with an internal /10 clock divider that takes a
// 50 MHz system clock to a 5 MHz SCLK. After reset, the master walks
// through an internal 4-byte ROM and transmits 0x12, 0x34, 0x56, 0x78
// MSB-first, with a short CS_n high gap between each byte.
//
// Mode 0:
//   * CPOL = 0  -- SCLK idles low.
//   * CPHA = 0  -- master changes MOSI on the falling edge of SCLK;
//                  slave samples MOSI on the rising edge of SCLK.
//
// Cycle plan at 50 MHz (`clk`):
//   * Each SCLK half-period is 5 system cycles (100 ns).
//   * Each SCLK full period is 10 system cycles (200 ns), so SCLK is 5 MHz.
//   * Each byte takes 80 system cycles to clock out (8 * 200 / 20).
//   * Between bytes the master deasserts CS_n for 20 system cycles
//     (400 ns idle gap).

`timescale 1ns / 1ns

module spi_master (
    input  wire clk,
    input  wire rst_n,
    output reg  sclk,
    output reg  mosi,
    output reg  cs_n,
    input  wire miso
);
    // Transmit ROM: held in registers initialised on reset.
    reg [7:0] tx_byte0;
    reg [7:0] tx_byte1;
    reg [7:0] tx_byte2;
    reg [7:0] tx_byte3;

    // Sequencer states.
    localparam [3:0] S_IDLE    = 4'd0;
    localparam [3:0] S_SETUP   = 4'd1;   // cs_n driven low; one-cycle setup before SCLK
    localparam [3:0] S_BIT_LO  = 4'd2;   // SCLK low half (5 system cycles)
    localparam [3:0] S_BIT_HI  = 4'd3;   // SCLK high half (5 system cycles)
    localparam [3:0] S_GAP     = 4'd4;   // cs_n high between bytes (20 system cycles)
    localparam [3:0] S_DONE    = 4'd5;

    reg [3:0] state;
    reg [2:0] div;        // 0..4 within each half-period
    reg [2:0] bit_idx;    // 0..7 (counts down from 7 for MSB-first)
    reg [1:0] byte_idx;   // 0..3
    reg [4:0] gap_count;
    reg [7:0] shift;

    wire [7:0] current_byte =
        (byte_idx == 2'd0) ? tx_byte0 :
        (byte_idx == 2'd1) ? tx_byte1 :
        (byte_idx == 2'd2) ? tx_byte2 :
                             tx_byte3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            cs_n      <= 1'b1;
            tx_byte0  <= 8'h12;
            tx_byte1  <= 8'h34;
            tx_byte2  <= 8'h56;
            tx_byte3  <= 8'h78;
            state     <= S_IDLE;
            div       <= 3'd0;
            bit_idx   <= 3'd7;
            byte_idx  <= 2'd0;
            gap_count <= 5'd0;
            shift     <= 8'h00;
        end else begin
            case (state)
                S_IDLE: begin
                    cs_n  <= 1'b0;          // assert CS_n for the new byte
                    shift <= current_byte;
                    mosi  <= current_byte[7]; // MSB first
                    bit_idx <= 3'd7;
                    div   <= 3'd0;
                    state <= S_SETUP;
                end

                S_SETUP: begin
                    // Hold one cycle of CS-setup with SCLK low before the first bit.
                    state <= S_BIT_LO;
                    div   <= 3'd0;
                end

                S_BIT_LO: begin
                    sclk <= 1'b0;
                    if (div == 3'd4) begin
                        // Move to SCLK high.
                        sclk <= 1'b1;
                        div  <= 3'd0;
                        state <= S_BIT_HI;
                    end else begin
                        div <= div + 3'd1;
                    end
                end

                S_BIT_HI: begin
                    sclk <= 1'b1;
                    if (div == 3'd4) begin
                        // Bit complete. Shift to the next bit or move on.
                        div  <= 3'd0;
                        sclk <= 1'b0;
                        if (bit_idx == 3'd0) begin
                            // Byte complete.
                            cs_n      <= 1'b1;
                            mosi      <= 1'b0;
                            gap_count <= 5'd0;
                            if (byte_idx == 2'd3) state <= S_DONE;
                            else                  state <= S_GAP;
                        end else begin
                            // Next bit: present new MOSI on this falling edge.
                            bit_idx <= bit_idx - 3'd1;
                            mosi    <= shift[bit_idx - 1];
                            state   <= S_BIT_LO;
                        end
                    end else begin
                        div <= div + 3'd1;
                    end
                end

                S_GAP: begin
                    if (gap_count == 5'd19) begin
                        gap_count <= 5'd0;
                        byte_idx  <= byte_idx + 2'd1;
                        state     <= S_IDLE;
                    end else begin
                        gap_count <= gap_count + 5'd1;
                    end
                end

                S_DONE: begin
                    sclk <= 1'b0;
                    cs_n <= 1'b1;
                    mosi <= 1'b0;
                end

                default: state <= S_DONE;
            endcase
        end
    end
endmodule
