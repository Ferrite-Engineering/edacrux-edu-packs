// Designed critical path. The only deep combinational path between registers in
// this design runs from src_a and src_b through a 24-bit carry chain into sum_q.
// src_a and src_b are shift registers fed from one input, so the design needs
// only three pins (clk, d, q) and fits any family's package without a pin map.
module path_adder (
  input  wire clk,
  input  wire d,
  output wire q
);
  reg [23:0] src_a;
  reg [23:0] src_b;
  reg [24:0] sum_q;
  always @(posedge clk) begin
    src_a <= {src_a[22:0], d};
    src_b <= {src_b[22:0], d ^ src_b[23]};
    sum_q <= src_a + src_b;
  end
  assign q = ^sum_q;
endmodule
