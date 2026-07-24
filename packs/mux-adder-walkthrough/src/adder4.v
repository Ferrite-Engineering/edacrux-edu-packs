// A 4-bit ripple-add. Kept as its own module so NetCrux shows it as a
// pushable/poppable block in the hierarchy.
module adder4 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    assign sum = a + b;
endmodule
