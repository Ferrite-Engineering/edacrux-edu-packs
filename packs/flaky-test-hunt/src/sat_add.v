module sat_add (input signed [7:0] a, input signed [7:0] b, output signed [7:0] y);
  wire signed [8:0] sum = a + b;          // 9-bit true sum
  // Correct positive saturation; BUGGY negative saturation (uses +127 not -128).
  assign y = (sum > 9'sd127)  ? 8'sd127 :
             (sum < -9'sd128) ? 8'sd127 :   // BUG: should be -8'sd128
             sum[7:0];
endmodule
