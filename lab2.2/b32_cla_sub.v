`timescale 1ns / 1ps

// use the 32-bit carry lookahead adder to create a 32-bit subtractor
// note that subtraction is the same as addition with the second input negated,
// so we perform a two's complement on Y and then add X + (-Y) with the CLA
module b32_cla_sub(X, Y, Z, overflow);
    input wire [31 : 0] X, Y;
    output wire [31 : 0] Z;
    output wire overflow;

    // take the complement of the second input (we use a carry in to simulate the full 2's complement)
    wire [31 : 0] Yc = ~Y;

    // perform Z = X + (-Y) and get the overflow bit
    b32_cla cla_sub (
        .X(X),
        .Y(Yc),
        .C_in(1),           // using the carry in with the inverted Y simulates taking the 2's complement of Y
        .Z(Z),
        .overflow(overflow)
        );

endmodule
