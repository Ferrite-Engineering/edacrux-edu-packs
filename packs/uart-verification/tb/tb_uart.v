`timescale 1ns/1ns
module tb_uart;
  reg clk=0, rst_n=0, start=0; reg [7:0] data; wire tx, busy;
  localparam CPB=4;
  uart_tx #(.CLKS_PER_BIT(CPB)) dut (.clk(clk),.rst_n(rst_n),.start(start),.data(data),.tx(tx),.busy(busy));
  always #5 clk=~clk;   // 10ns period; one bit = CPB*10 = 40ns

  reg [7:0] rx; integer k;
  // Deterministic fixed-delay capture: pulse start, skip the start bit, then
  // sample each of 8 data bits at its centre. No wait() -> cannot hang.
  task send_and_capture(input [7:0] d);
    begin
      @(negedge clk); data=d; start=1; @(negedge clk); start=0;
      #(CPB*10);            // consume the start bit
      #(CPB*10/2);          // move to centre of bit0
      for (k=0;k<8;k=k+1) begin rx[k]=tx; #(CPB*10); end
      #(CPB*10*2);          // let it return to idle before the next byte
    end
  endtask
  task check(input [127:0] nm, input [7:0] sent, input [7:0] want);
    begin
      send_and_capture(sent);
      if (rx===want) $display("RESULT %0s PASS", nm);
      else           $display("RESULT %0s FAIL sent=%02x got=%02x want=%02x", nm, sent, rx, want);
    end
  endtask
  initial begin
    $dumpfile("fixtures/reference.vcd"); $dumpvars(0, tb_uart);
    #20 rst_n=1; #40;
    check("tx_0x55", 8'h55, 8'h55);
    check("tx_0xA3", 8'hA3, 8'hA3);
    check("tx_0xFF", 8'hFF, 8'h00);   // BAD EXPECTATION: wants 0x00 for 0xFF -> FAIL by design
    #100 $finish;
  end
endmodule
