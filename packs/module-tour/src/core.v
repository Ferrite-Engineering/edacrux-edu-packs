// A small datapath core: two register slots feeding an ALU, with a bypass.
// Enough hierarchy and shared nets to make fan-in / fan-out navigation real.
module regslot (input clk, input rst_n, input en, input [7:0] d, output reg [7:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 8'h00;
    else if (en) q <= d;
endmodule

module alu8 (input [7:0] a, input [7:0] b, input op, output [7:0] y);
  assign y = op ? (a + b) : (a & b);
endmodule

module core (
    input        clk, rst_n,
    input        we_a, we_b, op,
    input  [7:0] din,
    output [7:0] result
);
  wire [7:0] ra, rb, alu_y;

  regslot u_ra (.clk(clk), .rst_n(rst_n), .en(we_a), .d(din),   .q(ra));
  regslot u_rb (.clk(clk), .rst_n(rst_n), .en(we_b), .d(alu_y), .q(rb));
  alu8    u_alu(.a(ra), .b(rb), .op(op), .y(alu_y));

  assign result = alu_y;
endmodule
