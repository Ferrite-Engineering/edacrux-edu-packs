module alu8 (input [7:0] a, b, input [1:0] op, output reg [7:0] y);
  always @(*) case(op) 2'd0:y=a+b; 2'd1:y=a-b; 2'd2:y=a&b; default:y=a|b; endcase
endmodule

