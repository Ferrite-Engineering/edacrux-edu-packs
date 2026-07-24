// Randomized regression. SEED is passed via +seed=N. The directed tests are
// deterministic; the `random_stress` test draws random operands, so whether it
// hits the negative-overflow bug depends on the seed -> flaky across seeds.
module tb_sat;
  reg signed [7:0] a, b;
  wire signed [7:0] y;
  integer seed, i, fails;
  reg signed [8:0] truth;
  reg signed [7:0] expect_y;

  sat_add dut (.a(a), .b(b), .y(y));

  function signed [7:0] model(input signed [8:0] s);
    model = (s > 9'sd127) ? 8'sd127 : (s < -9'sd128) ? -8'sd128 : s[7:0];
  endfunction

  task chk(input [127:0] nm, input signed [7:0] exp);
    begin #1;
      if (y === exp) $display("RESULT %0s PASS", nm);
      else           $display("RESULT %0s FAIL got=%0d exp=%0d", nm, y, exp); end
  endtask

  initial begin
    if (!$value$plusargs("seed=%d", seed)) seed = 1;
    // directed, always-pass
    a=8'sd10;  b=8'sd20;  chk("add_small", model(a+b));
    a=8'sd120; b=8'sd50;  chk("pos_overflow_sat", model(a+b));   // +sat correct
    // random stress: hits the negative-overflow bug only for some seeds
    fails = 0;
    for (i=0;i<3;i=i+1) begin
      a = $random(seed); b = $random(seed);
      truth = a + b; expect_y = model(truth); #1;
      if (y !== expect_y) fails = fails + 1;
    end
    if (fails==0) $display("RESULT random_stress PASS");
    else          $display("RESULT random_stress FAIL mismatches=%0d", fails);
    $finish;
  end
endmodule
