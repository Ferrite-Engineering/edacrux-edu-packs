`timescale 1ns/1ns
module tb_alu_periph;
  reg clk=0, rst_n=0, we=0; reg [7:0] addr, wdata; wire [7:0] result;
  alu_periph dut (.clk(clk),.rst_n(rst_n),.we(we),.addr(addr),.wdata(wdata),.result(result));
  always #5 clk=~clk;

  task wr(input [7:0] a, input [7:0] d);
    begin @(negedge clk); addr=a; wdata=d; we=1; @(negedge clk); we=0; end
  endtask
  task op_check(input [127:0] nm, input [7:0] a, b, input [7:0] opcode, input [7:0] want);
    begin
      wr(8'h00, a); wr(8'h10, b); wr(8'h20, opcode); #20;
      if (result===want) $display("RESULT %0s PASS", nm);
      else               $display("RESULT %0s FAIL a=%0d b=%0d op=%0d got=%0d want=%0d", nm, a, b, opcode, result, want);
    end
  endtask

  initial begin
    $dumpfile("fixtures/reference.vcd"); $dumpvars(0, tb_alu_periph);
    #20 rst_n=1; #20;
    op_check("add", 8'd10, 8'd7, 8'd0, 8'd17);
    op_check("sub", 8'd20, 8'd6, 8'd1, 8'd14);
    op_check("and", 8'hF0, 8'h3C, 8'd2, 8'h30);
    op_check("or",  8'hF0, 8'h0C, 8'd3, 8'hFC);
    #40 $finish;
  end
endmodule
