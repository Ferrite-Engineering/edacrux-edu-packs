// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Minimal AXI4-Lite master. After reset releases, it executes a fixed
// sequence:
//   1. WRITE addr=0x00 data=0xA0A0_0000     (in range, expect OKAY)
//   2. WRITE addr=0x04 data=0xB1B1_1111     (in range, expect OKAY)
//   3. WRITE addr=0xFC data=0xDEAD_C0DE     (out of range, expect SLVERR)
//   4. READ  addr=0x00                       (in range, expect OKAY, data=0xA0A0_0000)
//   5. READ  addr=0x80                       (out of range, expect SLVERR)
// then asserts done.

`timescale 1ns / 1ns

module axil_master (
    input  wire        aclk,
    input  wire        aresetn,

    output reg  [31:0] awaddr,
    output reg         awvalid,
    input  wire        awready,

    output reg  [31:0] wdata,
    output reg  [ 3:0] wstrb,
    output reg         wvalid,
    input  wire        wready,

    input  wire [ 1:0] bresp,
    input  wire        bvalid,
    output reg         bready,

    output reg  [31:0] araddr,
    output reg         arvalid,
    input  wire        arready,

    input  wire [31:0] rdata,
    input  wire [ 1:0] rresp,
    input  wire        rvalid,
    output reg         rready,

    output reg  [ 1:0] last_bresp,
    output reg  [ 1:0] last_rresp,
    output reg  [31:0] last_rdata,
    output reg         done
);
    localparam [3:0]
        S_IDLE       = 4'd0,
        S_WR1_REQ    = 4'd1,
        S_WR1_RESP   = 4'd2,
        S_WR2_REQ    = 4'd3,
        S_WR2_RESP   = 4'd4,
        S_WR3_REQ    = 4'd5,
        S_WR3_RESP   = 4'd6,
        S_RD1_REQ    = 4'd7,
        S_RD1_RESP   = 4'd8,
        S_RD2_REQ    = 4'd9,
        S_RD2_RESP   = 4'd10,
        S_DONE       = 4'd11;

    reg [3:0] state;

    task do_write_req(input [31:0] addr, input [31:0] data);
        begin
            awaddr  <= addr;
            awvalid <= 1'b1;
            wdata   <= data;
            wstrb   <= 4'hF;
            wvalid  <= 1'b1;
        end
    endtask

    task do_read_req(input [31:0] addr);
        begin
            araddr  <= addr;
            arvalid <= 1'b1;
        end
    endtask

    always @(posedge aclk) begin
        if (!aresetn) begin
            awaddr     <= 32'h0;
            awvalid    <= 1'b0;
            wdata      <= 32'h0;
            wstrb      <= 4'h0;
            wvalid     <= 1'b0;
            bready     <= 1'b0;
            araddr     <= 32'h0;
            arvalid    <= 1'b0;
            rready     <= 1'b0;
            last_bresp <= 2'b00;
            last_rresp <= 2'b00;
            last_rdata <= 32'h0;
            done       <= 1'b0;
            state      <= S_WR1_REQ;
        end else begin
            // Default deassertions; specific states override
            bready <= 1'b0;
            rready <= 1'b0;

            case (state)
                S_WR1_REQ: begin
                    do_write_req(32'h0000_0000, 32'hA0A0_0000);
                    if (awvalid && awready && wvalid && wready) begin
                        // Both address and data accepted in the same cycle.
                        awvalid <= 1'b0;
                        wvalid  <= 1'b0;
                        bready  <= 1'b1;
                        state   <= S_WR1_RESP;
                    end
                end
                S_WR1_RESP: begin
                    bready <= 1'b1;
                    if (bvalid && bready) begin
                        last_bresp <= bresp;
                        bready     <= 1'b0;
                        state      <= S_WR2_REQ;
                    end
                end

                S_WR2_REQ: begin
                    do_write_req(32'h0000_0004, 32'hB1B1_1111);
                    if (awvalid && awready && wvalid && wready) begin
                        awvalid <= 1'b0;
                        wvalid  <= 1'b0;
                        bready  <= 1'b1;
                        state   <= S_WR2_RESP;
                    end
                end
                S_WR2_RESP: begin
                    bready <= 1'b1;
                    if (bvalid && bready) begin
                        last_bresp <= bresp;
                        bready     <= 1'b0;
                        state      <= S_WR3_REQ;
                    end
                end

                S_WR3_REQ: begin
                    do_write_req(32'h0000_00FC, 32'hDEAD_C0DE); // unmapped
                    if (awvalid && awready && wvalid && wready) begin
                        awvalid <= 1'b0;
                        wvalid  <= 1'b0;
                        bready  <= 1'b1;
                        state   <= S_WR3_RESP;
                    end
                end
                S_WR3_RESP: begin
                    bready <= 1'b1;
                    if (bvalid && bready) begin
                        last_bresp <= bresp;
                        bready     <= 1'b0;
                        state      <= S_RD1_REQ;
                    end
                end

                S_RD1_REQ: begin
                    do_read_req(32'h0000_0000);
                    if (arvalid && arready) begin
                        arvalid <= 1'b0;
                        rready  <= 1'b1;
                        state   <= S_RD1_RESP;
                    end
                end
                S_RD1_RESP: begin
                    rready <= 1'b1;
                    if (rvalid && rready) begin
                        last_rresp <= rresp;
                        last_rdata <= rdata;
                        rready     <= 1'b0;
                        state      <= S_RD2_REQ;
                    end
                end

                S_RD2_REQ: begin
                    do_read_req(32'h0000_0080); // unmapped
                    if (arvalid && arready) begin
                        arvalid <= 1'b0;
                        rready  <= 1'b1;
                        state   <= S_RD2_RESP;
                    end
                end
                S_RD2_RESP: begin
                    rready <= 1'b1;
                    if (rvalid && rready) begin
                        last_rresp <= rresp;
                        last_rdata <= rdata;
                        rready     <= 1'b0;
                        state      <= S_DONE;
                    end
                end

                S_DONE: begin
                    done <= 1'b1;
                end

                default: state <= S_DONE;
            endcase
        end
    end
endmodule
