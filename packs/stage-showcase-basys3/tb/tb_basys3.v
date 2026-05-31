// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Drives the Basys 3 demo design with a sequence of switch flips and
// button presses, intended to look great when scrubbed in the WaveCrux
// Stage panel hosting the Basys 3 board widget.
//
// Timeline (approximate):
//   t=22       reset releases
//   t=100      sw <- 4'h5
//   t=300      btn[0] pressed (count -> 1)
//   t=600      btn[1] pressed (count -> 2)
//   t=900      sw <- 4'hA, btn[2] pressed (count -> 3)
//   t=1200     btn[3] pressed (count -> 4)
//   t=1500     btn[0] pressed again (count -> 5)
//   t=2000     sw <- 4'hF
//   t=2500     btn[0] pressed (count -> 6)
//   t=3000     finish

`timescale 1ns / 1ns

module tb_basys3;
    reg        clk;
    reg        rst_n;
    reg  [3:0] sw;
    reg  [3:0] btn;
    wire [3:0] led;
    wire [6:0] seg;
    wire [3:0] an;

    basys3_demo dut (
        .clk  (clk),
        .rst_n(rst_n),
        .sw   (sw),
        .btn  (btn),
        .led  (led),
        .seg  (seg),
        .an   (an)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;     // 100 MHz

    task press(input [3:0] mask);
        begin
            btn = btn | mask;
            #10;
            btn = btn & ~mask;
        end
    endtask

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_basys3);

        rst_n = 1'b0;
        sw    = 4'h0;
        btn   = 4'h0;
        #22;
        rst_n = 1'b1;

        #78;        sw = 4'h5;        // t=100
        #200;       press(4'b0001);   // t=300, count -> 1
        #290;       press(4'b0010);   // t=600, count -> 2
        #290;       sw = 4'hA; press(4'b0100);   // t=900, count -> 3
        #290;       press(4'b1000);   // t=1200, count -> 4
        #290;       press(4'b0001);   // t=1500, count -> 5
        #490;       sw = 4'hF;        // t=2000
        #490;       press(4'b0001);   // t=2500, count -> 6
        #500;
        $finish;
    end
endmodule
