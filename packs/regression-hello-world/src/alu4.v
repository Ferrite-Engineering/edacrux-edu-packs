module alu4 (input [3:0] a, input [3:0] b, input [1:0] op, output reg [4:0] y);
  always @(*) case (op)
    2'd0: y = a + b;
    2'd1: y = a - b;
    2'd2: y = {1'b0, a & b};
    2'd3: y = {1'b0, a | b};
    default: y = 5'bxxxxx;
  endcase
endmodule
