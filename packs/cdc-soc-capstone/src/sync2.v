module sync2 (input clk, rst_n, d, output q);
  reg meta, ff;
  always @(posedge clk or negedge rst_n) if(!rst_n) {meta,ff}<=0; else {ff,meta}<={meta,d};
  assign q = ff;
endmodule

