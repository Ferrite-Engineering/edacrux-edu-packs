// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// SPI master + passive slave loopback test. 50 MHz system clock, SCLK
// divides down to 5 MHz, four bytes transmitted MSB-first.

`timescale 1ns / 1ns

module tb_spi;
    reg  clk;
    reg  rst_n;
    wire sclk;
    wire mosi;
    wire miso;
    wire cs_n;

    spi_master u_master (
        .clk  (clk),
        .rst_n(rst_n),
        .sclk (sclk),
        .mosi (mosi),
        .cs_n (cs_n),
        .miso (miso)
    );

    spi_slave_loopback u_slave (
        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .cs_n (cs_n),
        .rst_n(rst_n)
    );

    initial clk = 1'b1;
    always #10 clk = ~clk;       // 50 MHz, posedges at 20, 40, ...

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_spi);

        rst_n = 1'b0;
        #45;
        rst_n = 1'b1;

        #15000;                  // long enough for all 4 bytes + idle slack
        $finish;
    end
endmodule
