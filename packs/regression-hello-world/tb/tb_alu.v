// A directed regression suite over alu4. Each check prints a machine-parseable
// result line: "RESULT <test_name> <PASS|FAIL>". build.sh turns these into the
// results.json a SimCrux dashboard would show.
module tb_alu;
  reg  [3:0] a, b;
  reg  [1:0] op;
  wire [4:0] y;
  integer pass_count = 0, total = 0;

  alu4 dut (.a(a), .b(b), .op(op), .y(y));

  task check;
    input [127:0] name;
    input [4:0]   expected;
    begin
      total = total + 1;
      #1;
      if (y === expected) begin
        pass_count = pass_count + 1;
        $display("RESULT %0s PASS", name);
      end else begin
        $display("RESULT %0s FAIL got=%0d exp=%0d", name, y, expected);
      end
    end
  endtask

  initial begin
    a=4'd3;  b=4'd4;  op=2'd0; check("add_basic",      5'd7);
    a=4'd15; b=4'd1;  op=2'd0; check("add_carry",      5'd16);
    a=4'd9;  b=4'd4;  op=2'd1; check("sub_basic",      5'd5);
    a=4'd12; b=4'd10; op=2'd2; check("and_basic",      5'd8);
    a=4'd12; b=4'd10; op=2'd3; check("or_basic",       5'd14);
    a=4'd0;  b=4'd0;  op=2'd1; check("sub_zero",       5'd0);
    $display("SUMMARY %0d/%0d", pass_count, total);
    $finish;
  end
endmodule
