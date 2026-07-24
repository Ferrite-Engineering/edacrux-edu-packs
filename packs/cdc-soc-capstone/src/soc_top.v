module soc_top (input clk_a, clk_b, rst_n, output [7:0] captured);
  wire req; wire [7:0] data; wire req_sync;
  producer u_prod (.clk_a(clk_a), .rst_n(rst_n), .req(req), .data(data));
  sync2    u_sync (.clk(clk_b), .rst_n(rst_n), .d(req), .q(req_sync));       // req: SAFE (2-flop)
  consumer u_cons (.clk_b(clk_b), .rst_n(rst_n), .req_sync(req_sync),
                   .data_bus(data), .captured(captured));                     // data: HAZARD
endmodule
