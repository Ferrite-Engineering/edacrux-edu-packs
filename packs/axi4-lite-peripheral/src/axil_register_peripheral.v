// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Minimal AXI4-Lite register peripheral. Eight 32-bit registers
// mapped at word offsets 0x00..0x1C (byte addresses 0x00, 0x04, ...,
// 0x1C). Any access beyond the mapped range returns SLVERR
// (BRESP / RRESP = 2'b10).
//
// Tightly-coupled handshakes:
//   * AWREADY and WREADY are tied high; the slave always accepts
//     address+data on the cycle they are presented.
//   * The write response (BVALID) is asserted one cycle after the
//     write completes; BREADY must be high to clear it.
//   * Read response (RVALID) is asserted one cycle after the read
//     address is accepted; RREADY must be high to clear it.

`timescale 1ns / 1ns

module axil_register_peripheral (
    input  wire        aclk,
    input  wire        aresetn,

    // Write address channel
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output wire        awready,

    // Write data channel
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    input  wire        wvalid,
    output wire        wready,

    // Write response channel
    output reg  [ 1:0] bresp,
    output reg         bvalid,
    input  wire        bready,

    // Read address channel
    input  wire [31:0] araddr,
    input  wire        arvalid,
    output wire        arready,

    // Read data channel
    output reg  [31:0] rdata,
    output reg  [ 1:0] rresp,
    output reg         rvalid,
    input  wire        rready
);
    localparam [1:0] RESP_OKAY   = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;

    reg [31:0] regs [0:7];

    assign awready = 1'b1;
    assign wready  = 1'b1;
    assign arready = ~rvalid;     // accept new address only when last R is consumed

    wire        write_handshake = awvalid & wvalid;
    wire [31:0] write_addr      = awaddr;
    wire        addr_in_range_w = (write_addr[31:5] == 27'h0);
    wire [ 2:0] word_idx_w      = write_addr[4:2];

    wire        read_handshake  = arvalid & arready;
    wire        addr_in_range_r = (araddr[31:5] == 27'h0);
    wire [ 2:0] word_idx_r      = araddr[4:2];

    integer i;
    always @(posedge aclk) begin
        if (!aresetn) begin
            for (i = 0; i < 8; i = i + 1) regs[i] <= 32'h0;
            bresp  <= 2'b00;
            bvalid <= 1'b0;
            rdata  <= 32'h0;
            rresp  <= 2'b00;
            rvalid <= 1'b0;
        end else begin
            // Write side
            if (write_handshake && !bvalid) begin
                if (addr_in_range_w) begin
                    if (wstrb[0]) regs[word_idx_w][ 7: 0] <= wdata[ 7: 0];
                    if (wstrb[1]) regs[word_idx_w][15: 8] <= wdata[15: 8];
                    if (wstrb[2]) regs[word_idx_w][23:16] <= wdata[23:16];
                    if (wstrb[3]) regs[word_idx_w][31:24] <= wdata[31:24];
                    bresp <= RESP_OKAY;
                end else begin
                    bresp <= RESP_SLVERR;
                end
                bvalid <= 1'b1;
            end else if (bvalid && bready) begin
                bvalid <= 1'b0;
            end

            // Read side
            if (read_handshake) begin
                if (addr_in_range_r) begin
                    rdata <= regs[word_idx_r];
                    rresp <= RESP_OKAY;
                end else begin
                    rdata <= 32'hDEAD_BEEF;     // sentinel for unmapped reads
                    rresp <= RESP_SLVERR;
                end
                rvalid <= 1'b1;
            end else if (rvalid && rready) begin
                rvalid <= 1'b0;
            end
        end
    end
endmodule
