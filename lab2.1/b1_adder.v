`timescale 1ns / 1ps

// create a 1-bit full adder
module b1_adder(X, Y, C_in, Z, C_out);
    input wire X, Y, C_in;
    output wire Z, C_out;

    wire carry_sum, cout1, cout2, cout3;

    // note that the sum bit Z = (X ^ Y) ^ C_in
    xor #1  gate1 (carry_sum, X, Y),
            gate2 (Z, carry_sum, C_in);

    // also note that carry out bit C_out = (X & Y) | (X & C_in) | (Y & C_in)
    and #1  gate3 (cout1, X, Y),
            gate4 (cout2, X, C_in),
            gate5 (cout3, Y, C_in);
    or  #1  gate6 (C_out, cout1, cout2, cout3);

endmodule
