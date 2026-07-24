module alu_periph (
    input clk, rst_n, we, input [7:0] addr, wdata, output [7:0] result
);
  wire sel_a, sel_b, sel_ctrl;
  wire [7:0] opa, opb, ctrl;
  reg  [7:0] spare;                     // UNUSED scratch (a lint finding)

  decoder u_dec (.addr(addr), .sel_a(sel_a), .sel_b(sel_b), .sel_ctrl(sel_ctrl));
  reg4 u_ra   (.clk(clk), .rst_n(rst_n), .we(we&sel_a),    .d(wdata), .q(opa));
  reg4 u_rb   (.clk(clk), .rst_n(rst_n), .we(we&sel_b),    .d(wdata), .q(opb));
  reg4 u_ctrl (.clk(clk), .rst_n(rst_n), .we(we&sel_ctrl), .d(wdata), .q(ctrl));
  alu8 u_alu  (.a(opa), .b(opb), .op(ctrl[1:0]), .y(result));
endmodule
