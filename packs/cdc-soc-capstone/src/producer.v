`timescale 1ns/1ns
// A two-clock-domain SoC fragment: a producer counts in clk_a; a request bit is
// safely double-flopped into clk_b, but an 8-bit data word crosses UNsynchronised
// — a deliberate CDC hazard for manual analysis. (The free toolchain has no CDC
// engine; identifying this crossing is a student methodology deliverable.)

module producer (input clk_a, rst_n, output reg req, output reg [7:0] data);
  reg [7:0] cnt;
  always @(posedge clk_a or negedge rst_n)
    if (!rst_n) begin cnt<=0; req<=0; data<=0; end
    else begin cnt<=cnt+1; data<=cnt; req<=cnt[3]; end   // data changes every clk_a
endmodule

