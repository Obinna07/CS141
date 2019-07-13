`timescale 1ns / 1ps

// create an N-bit full ripple-carry adder with overflow (NOT used in the final ALU; taken from lab2.1 for testing)
module bN_ripple_adder(X, Y, Z, C_in, overflow);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    input wire C_in;
    output wire [(N-1) : 0] Z;
    output wire overflow;

    // create the (N+1) intermediate carry_in --> carry_out wires for each 1-bit adder in series
    wire [N : 0] carry;
    assign carry[0] = C_in;

    // create and link the N 1-bit full adders
    generate
        genvar i;
        for (i = 0; i < N; i = i + 1) begin : generate_ripple_adder
            b1_adder ripple_adder   (   .X(X[i]),
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
