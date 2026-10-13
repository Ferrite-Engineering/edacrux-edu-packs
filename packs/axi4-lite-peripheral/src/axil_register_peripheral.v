// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Minimal AXI4-Lite register peripheral. Eight 32-bit registers
// mapped at word offsets 0x00..0x1C (byte addresses 0x00, 0x04, ...,
// 0x1C). Any access beyond the mapped range returns SLVERR
// (BRESP / RRESP = 2'b10).
//
// Handshakes:
//   * AW and W are independent channels. The slave registers whichever
//     arrives first and commits the write once it holds both, in either
//     order or in the same cycle.
//   * AWREADY / WREADY are high while that channel's slot is empty and
//     no write response is pending. Deasserting them is how the slave
//     applies backpressure, so every accepted write is completed.
//   * The write response (BVALID) is asserted one cycle after the
//     write commits and held until the master takes it with BREADY.
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

    // Write channel holding registers. aw_seen / w_seen mean "this
    // channel has handshaked for the write now in progress".
    reg        aw_seen;
    reg [31:0] aw_addr_q;
    reg        w_seen;
    reg [31:0] w_data_q;
    reg [ 3:0] w_strb_q;

    assign awready = ~aw_seen & ~bvalid;
    assign wready  = ~w_seen  & ~bvalid;
    assign arready = ~rvalid;     // accept new address only when last R is consumed

    wire        aw_handshake    = awvalid & awready;
    wire        w_handshake     = wvalid  & wready;
    wire        aw_have         = aw_seen | aw_handshake;
    wire        w_have          = w_seen  | w_handshake;
    // Both halves present: commit this cycle. aw/w handshakes only
    // happen while BVALID is low, so a commit never overwrites a
    // response the master has not yet taken.
    wire        write_commit    = aw_have & w_have;

    wire [31:0] write_addr      = aw_seen ? aw_addr_q : awaddr;
    wire [31:0] write_data      = w_seen  ? w_data_q  : wdata;
    wire [ 3:0] write_strb      = w_seen  ? w_strb_q  : wstrb;
    wire        addr_in_range_w = (write_addr[31:5] == 27'h0);
    wire [ 2:0] word_idx_w      = write_addr[4:2];

    wire        read_handshake  = arvalid & arready;
    wire        addr_in_range_r = (araddr[31:5] == 27'h0);
    wire [ 2:0] word_idx_r      = araddr[4:2];

    integer i;
    always @(posedge aclk) begin
        if (!aresetn) begin
            for (i = 0; i < 8; i = i + 1) regs[i] <= 32'h0;
            aw_seen   <= 1'b0;
            aw_addr_q <= 32'h0;
            w_seen    <= 1'b0;
            w_data_q  <= 32'h0;
            w_strb_q  <= 4'h0;
            bresp  <= 2'b00;
            bvalid <= 1'b0;
            rdata  <= 32'h0;
            rresp  <= 2'b00;
            rvalid <= 1'b0;
        end else begin
            // Write side
            if (write_commit) begin
                if (addr_in_range_w) begin
                    if (write_strb[0]) regs[word_idx_w][ 7: 0] <= write_data[ 7: 0];
                    if (write_strb[1]) regs[word_idx_w][15: 8] <= write_data[15: 8];
                    if (write_strb[2]) regs[word_idx_w][23:16] <= write_data[23:16];
                    if (write_strb[3]) regs[word_idx_w][31:24] <= write_data[31:24];
                    bresp <= RESP_OKAY;
                end else begin
                    bresp <= RESP_SLVERR;
                end
                bvalid  <= 1'b1;
                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
            end else begin
                // Only one half has arrived: hold it until the other does.
                if (aw_handshake) begin
                    aw_seen   <= 1'b1;
                    aw_addr_q <= awaddr;
                end
                if (w_handshake) begin
                    w_seen   <= 1'b1;
                    w_data_q <= wdata;
                    w_strb_q <= wstrb;
                end
                if (bvalid && bready) bvalid <= 1'b0;
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
