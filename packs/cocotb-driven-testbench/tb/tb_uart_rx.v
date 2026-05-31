// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Pure-Verilog stimulus for the UART receiver. Drives the rx line
// with the same byte sequence (0x55, 0xAA, 0x55, 0xAA) a cocotb
// testbench would have produced -- but without the cocotb runtime.
// The companion fixtures/cocotb_run.log is hand-crafted to match
// this waveform's event timing.

`timescale 1ns / 1ns

module tb_uart_rx;
    reg        clk;
    reg        rst_n;
    reg        rx;
    wire [7:0] rx_data;
    wire       rx_valid;

    uart_rx #(.CYCLES_PER_BIT(434)) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .rx      (rx),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

    // 50 MHz clock.
    initial clk = 1'b1;
    always #10 clk = ~clk;

    task send_byte(input [7:0] b);
        integer i;
        begin
            // Start bit
            rx = 1'b0;
            #8680;
            // 8 data bits LSB-first
            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i];
                #8680;
            end
            // Stop bit
            rx = 1'b1;
            #8680;
        end
    endtask

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_uart_rx);

        rst_n = 1'b0;
        rx    = 1'b1;
        #45;
        rst_n = 1'b1;

        // Inter-frame idle so the receiver IDLE state is clearly
        // visible before the first start bit.
        #100;

        send_byte(8'h55);
        #1000;
        send_byte(8'hAA);
        #1000;
        send_byte(8'h55);
        #1000;
        send_byte(8'hAA);
        #2000;

        $finish;
    end
endmodule
