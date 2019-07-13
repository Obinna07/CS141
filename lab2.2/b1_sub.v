`timescale 1ns / 1ps

// create a 1-bit full subtract
module b1_sub(X, Y, C_in, Z, C_out);
    input wire X, Y, C_in;
    output wire Z, C_out;

    wire carry_sum, cout1, cout2, cout3;

    b1_adder add_neg (.X(X), .Y(~Y), .C_in(C_in), .Z(Z), .C_out(C_out));

endmodule