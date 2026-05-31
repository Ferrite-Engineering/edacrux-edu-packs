// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Drives the Wishbone B4 master + memory slave pair. 100 MHz clock,
// synchronous active-high reset.

`timescale 1ns / 1ns

module tb_mem;
    reg         clk;
    reg         rst;
    wire [31:0] wb_adr;
    wire [31:0] dat_master_to_slave;
    wire [31:0] dat_slave_to_master;
    wire        wb_we;
    wire [ 3:0] wb_sel;
    wire        wb_stb;
    wire        wb_cyc;
    wire        wb_ack;
    wire [31:0] last_read;
    wire        done;

    wb_master u_master (
        .clk      (clk),
        .rst      (rst),
        .wb_adr   (wb_adr),
        .wb_dat_o (dat_master_to_slave),
        .wb_dat_i (dat_slave_to_master),
        .wb_we    (wb_we),
        .wb_sel   (wb_sel),
        .wb_stb   (wb_stb),
        .wb_cyc   (wb_cyc),
        .wb_ack   (wb_ack),
        .last_read(last_read),
        .done     (done)
    );

    wb_memory #(.ADDR_WIDTH(8)) u_mem (
        .clk     (clk),
        .rst     (rst),
        .wb_adr  (wb_adr),
        .wb_dat_i(dat_master_to_slave),
        .wb_dat_o(dat_slave_to_master),
        .wb_we   (wb_we),
        .wb_sel  (wb_sel),
        .wb_stb  (wb_stb),
        .wb_cyc  (wb_cyc),
        .wb_ack  (wb_ack)
    );

    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_mem);

        rst = 1'b1;
        #22;
        rst = 1'b0;
        #978;        // 1000 ns total — long enough to write+read 8 words
        $finish;
    end
endmodule
