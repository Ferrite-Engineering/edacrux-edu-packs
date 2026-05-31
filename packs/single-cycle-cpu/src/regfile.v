// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// 32-entry x 32-bit register file with two asynchronous read ports
// and one synchronous write port. Register x0 is hard-wired to zero.

`timescale 1ns / 1ns

module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [ 4:0] rd_addr,
    input  wire [31:0] rd_data,
    input  wire [ 4:0] rs1_addr,
    output wire [31:0] rs1_data,
    input  wire [ 4:0] rs2_addr,
    output wire [31:0] rs2_data
);
    reg [31:0] regs [0:31];

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0 : regs[rs2_addr];

    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'h0;

    always @(posedge clk) begin
        if (we && rd_addr != 5'd0) begin
            regs[rd_addr] <= rd_data;
        end
    end
endmodule
