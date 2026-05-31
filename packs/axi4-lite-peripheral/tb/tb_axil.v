// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// AXI4-Lite master + register peripheral testbench. 100 MHz aclk,
// active-low aresetn.

`timescale 1ns / 1ns

module tb_axil;
    reg         aclk;
    reg         aresetn;

    wire [31:0] awaddr;
    wire        awvalid;
    wire        awready;
    wire [31:0] wdata;
    wire [ 3:0] wstrb;
    wire        wvalid;
    wire        wready;
    wire [ 1:0] bresp;
    wire        bvalid;
    wire        bready;
    wire [31:0] araddr;
    wire        arvalid;
    wire        arready;
    wire [31:0] rdata;
    wire [ 1:0] rresp;
    wire        rvalid;
    wire        rready;

    wire [ 1:0] last_bresp;
    wire [ 1:0] last_rresp;
    wire [31:0] last_rdata;
    wire        done;

    axil_master u_master (
        .aclk      (aclk),
        .aresetn   (aresetn),
        .awaddr    (awaddr),
        .awvalid   (awvalid),
        .awready   (awready),
        .wdata     (wdata),
        .wstrb     (wstrb),
        .wvalid    (wvalid),
        .wready    (wready),
        .bresp     (bresp),
        .bvalid    (bvalid),
        .bready    (bready),
        .araddr    (araddr),
        .arvalid   (arvalid),
        .arready   (arready),
        .rdata     (rdata),
        .rresp     (rresp),
        .rvalid    (rvalid),
        .rready    (rready),
        .last_bresp(last_bresp),
        .last_rresp(last_rresp),
        .last_rdata(last_rdata),
        .done      (done)
    );

    axil_register_peripheral u_slave (
        .aclk   (aclk),
        .aresetn(aresetn),
        .awaddr (awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata  (wdata),
        .wstrb  (wstrb),
        .wvalid (wvalid),
        .wready (wready),
        .bresp  (bresp),
        .bvalid (bvalid),
        .bready (bready),
        .araddr (araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata  (rdata),
        .rresp  (rresp),
        .rvalid (rvalid),
        .rready (rready)
    );

    initial aclk = 1'b1;
    always #5 aclk = ~aclk;

    initial begin
        $dumpfile("fixtures/reference.vcd");
        $dumpvars(0, tb_axil);

        aresetn = 1'b0;
        #22;
        aresetn = 1'b1;
        #978;
        $finish;
    end
endmodule
