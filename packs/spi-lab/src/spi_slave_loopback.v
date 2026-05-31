// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Simple SPI mode-0 slave. Samples MOSI on the rising edge of SCLK and
// shifts the bits into an 8-bit receive register. When chip-select
// returns high, the most-recently-received byte is latched into
// `last_byte` — students inspect this in the waveform to verify that
// the wire-level decoding matches the byte the master sent.
//
// MISO is held inactive (low). A full loopback that drives MISO with
// the previous byte would muddle the pedagogy (mode-0 MISO timing is
// already covered by the `miso` lane in the waveform with the
// SPI decoder applied).

`timescale 1ns / 1ns

module spi_slave_loopback (
    input  wire sclk,
    input  wire mosi,
    output wire miso,
    input  wire cs_n,
    input  wire rst_n
);
    reg [7:0] rx_shift;
    reg [7:0] last_byte;

    assign miso = 1'b0;

    always @(posedge sclk or negedge rst_n) begin
        if (!rst_n)        rx_shift <= 8'h00;
        else if (!cs_n)    rx_shift <= {rx_shift[6:0], mosi};
    end

    always @(posedge cs_n or negedge rst_n) begin
        if (!rst_n) last_byte <= 8'h00;
        else        last_byte <= rx_shift;
    end
endmodule
