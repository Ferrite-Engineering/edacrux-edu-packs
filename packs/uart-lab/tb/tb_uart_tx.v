// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Drives the UART transmitter with four bytes: 0x55, 0xAA, 0x55, 0xAA.
// 50 MHz clock, 8-N-1, 115_207 baud (CYCLES_PER_BIT = 434).
//
// Simulation length: ~360 us — long enough for all four bytes to leave
// the transmitter with a little idle slack on either end.

`timescale 1ns / 1ns

module tb_uart_tx;
    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx;
    wire       tx_busy;

    uart_tx #(.CYCLES_PER_BIT(434)) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .tx      (tx),
        .tx_busy (tx_busy)
    );

    // 50 MHz: 20 ns period, posedges at 20, 40, 60, ...
    initial clk = 1'b1;
    always #10 clk = ~clk;

    task send_byte(input [7:0] b);
        begin
            @(negedge clk);
            tx_data  = b;
            tx_start = 1'b1;
            @(negedge clk);
            tx_start = 1'b0;
            wait (tx_busy == 1'b0);   // wait for completion
            @(negedge clk);            // small idle gap
        end
    endtask

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_uart_tx);

        rst_n    = 1'b0;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        #45;                  // hold reset until just after posedge 40
        rst_n = 1'b1;

        send_byte(8'h55);
        send_byte(8'hAA);
        send_byte(8'h55);
        send_byte(8'hAA);

        #1000;                 // post-last-byte idle tail
        $finish;
    end
endmodule
