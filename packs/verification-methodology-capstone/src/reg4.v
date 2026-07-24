`timescale 1ns/1ns
// Register-mapped ALU peripheral. Write operands to regs, write an opcode to
// CTRL, read the result. Integrates a decoder, a register file and an ALU — a
// small but complete unit for a full verification-methodology pass.

module reg4 (input clk, rst_n, we, input [7:0] d, output reg [7:0] q);
  always @(posedge clk or negedge rst_n) if(!rst_n) q<=8'h0; else if(we) q<=d;
endmodule

