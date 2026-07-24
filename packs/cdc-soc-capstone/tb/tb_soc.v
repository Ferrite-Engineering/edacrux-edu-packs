`timescale 1ns/1ns
module tb_soc;
  reg clk_a=0, clk_b=0, rst_n=0; wire [7:0] captured;
  soc_top dut (.clk_a(clk_a), .clk_b(clk_b), .rst_n(rst_n), .captured(captured));
  always #5  clk_a=~clk_a;   // 100 MHz-ish
  always #7  clk_b=~clk_b;   // asynchronous, slower — a real clock-domain pair

  // The regression checks the SAFE path: after reset, the synchronized request
  // eventually causes SOME capture (the sync2 handshake works). It does NOT
  // assert the captured DATA value — that is exactly the unreliable, CDC-hazard
  // path the student must analyse by hand.
  reg [7:0] first_cap; integer seen;
  initial begin
    $dumpfile("fixtures/reference.vcd"); $dumpvars(0, tb_soc);
    #20 rst_n=1;
    seen=0; first_cap=0;
    #400;
    if (captured!==8'hxx) begin $display("RESULT sync_handshake_captures PASS"); end
    else                       $display("RESULT sync_handshake_captures FAIL");
    // A second check: the safe request bit is a clean two-flop synchronised value
    // (no metastable X on req_sync in steady state).
    if (dut.req_sync===1'b0 || dut.req_sync===1'b1) $display("RESULT req_is_two_flop_clean PASS");
    else                                            $display("RESULT req_is_two_flop_clean FAIL");
    #20 $finish;
  end
endmodule
