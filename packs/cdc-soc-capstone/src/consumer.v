module consumer (input clk_b, rst_n, req_sync, input [7:0] data_bus, output reg [7:0] captured);
  always @(posedge clk_b or negedge rst_n)
    if (!rst_n) captured<=0;
    else if (req_sync) captured<=data_bus;   // captures the UNsynchronised bus
endmodule

