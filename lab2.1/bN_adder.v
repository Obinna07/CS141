`timescale 1ns / 1ps

// create an N-bit full adder with overflow (op_code 0101)
module bN_adder(X, Y, Z, overflow);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    output wire [(N-1) : 0] Z;
    output wire overflow;

    // create the (N+1) intermediate carry_in --> carry_out wires for each 1-bit adder in series
    wire [N : 0] carry;
    assign carry[0] = 0;    // no carry_in bit on the first addition

    // create and link the N 1-bit full adders
    generate
        genvar i;
        for (i = 0; i < N; i = i + 1) begin : generate_adder
            b1_adder adder  (   .X(X[i]),
                                .Y(Y[i]),
                                .C_in(carry[i]),
                                .Z(Z[i]),
                                .C_out(carry[i + 1])
                            );
        end
    endgenerate

    // assign the overflow bit based on the last two carry_out wires
    assign overflow = carry[N] ^ carry[N-1];

endmodule
