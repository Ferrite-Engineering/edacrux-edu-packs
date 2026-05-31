// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Testbench for the traffic-light FSM. 100 MHz clock with posedges at
// multiples of 10 ns, reset held until t=22 ns, then 3000 ns of free
// running — long enough for the FSM to make three full
// RED -> GREEN -> YELLOW -> RED cycles. Students measure the cycle
// period by placing markers on three R -> G transitions.

`timescale 1ns / 1ns

module tb_traffic_light;
    reg        clk;
    reg        rst_n;
    wire [1:0] state;
    wire       red_light;
    wire       green_light;
    wire       yellow_light;

    traffic_light dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .state       (state),
        .red_light   (red_light),
        .green_light (green_light),
        .yellow_light(yellow_light)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_traffic_light);

        rst_n = 1'b0;
        #22;
        rst_n = 1'b1;
        #2978;
        $finish;
    end
endmodule
