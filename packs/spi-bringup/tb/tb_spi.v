`timescale 1ns/1ns
module tb_spi;
  reg clk=0, rst_n=0, start=0; reg [7:0] tx_byte;
  wire sclk, cs_n, mosi, done; wire [7:0] rx_byte;
  reg miso;
  spi_master #(.DIV(2)) dut (.clk(clk),.rst_n(rst_n),.start(start),.tx_byte(tx_byte),
                             .miso(miso),.sclk(sclk),.cs_n(cs_n),.mosi(mosi),.done(done),.rx_byte(rx_byte));
  always #5 clk=~clk;

  // Loopback slave: MISO echoes MOSI, so a correct master receives what it sent.
  always @(*) miso = mosi;

  task xfer(input [127:0] nm, input [7:0] b);
    begin
      @(negedge clk); tx_byte=b; start=1; @(negedge clk); start=0;
      #4000;                          // plenty of time for an 8-bit mode-0 transfer
      if (rx_byte===b) $display("RESULT %0s PASS", nm);
      else             $display("RESULT %0s FAIL sent=%02x got=%02x", nm, b, rx_byte);
    end
  endtask

  initial begin
    $dumpfile("fixtures/reference.vcd"); $dumpvars(0, tb_spi);
    #20 rst_n=1; #40;
    xfer("loopback_0x3C", 8'h3C);
    xfer("loopback_0xA5", 8'hA5);
    xfer("loopback_0xFF", 8'hFF);
    #100 $finish;
  end
endmodule
