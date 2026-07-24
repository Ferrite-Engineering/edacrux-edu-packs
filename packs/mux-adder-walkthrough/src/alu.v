// A minimal ALU: it either passes A through (zero-extended) or returns A+B,
// selected by `op`. The point of the lab is the STRUCTURE — one adder
// submodule feeding one output multiplexer — not the arithmetic.
module alu (
    input  [3:0] a,
    input  [3:0] b,
    input        op,       // 0 = pass A, 1 = A + B
    output [4:0] y
);
    wire [4:0] sum;

    adder4 u_add (
        .a  (a),
        .b  (b),
        .sum(sum)
    );

    // The output mux: NetCrux draws this as a 2:1 selector on `y`.
    assign y = op ? sum : {1'b0, a};
endmodule
