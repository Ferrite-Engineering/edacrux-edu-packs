module decoder (input [7:0] addr, output sel_a, sel_b, sel_ctrl);
  assign sel_a    = (addr[7:4]==4'h0);
  assign sel_b    = (addr[7:4]==4'h1);
  assign sel_ctrl = (addr[7:4]==4'h2);
endmodule

