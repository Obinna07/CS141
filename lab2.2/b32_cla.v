`timescale 1ns / 1ps

// create a 32-bit carry lookahead adder using 8 4-bit blocks
module b32_cla(X, Y, C_in, Z, overflow);
    input wire [31 : 0] X, Y;
    input wire C_in;
    output wire [31 : 0] Z;
    output wire overflow;

    // wires for each block's carry in/carry out bits (we would need 9 wires since the first block has a carry in, but we ignore the last carry out)
    wire [7 : 0] carry;
    assign carry[0] = C_in;

    // generate 7 of the 8 4-bit CLA blocks, doing the additon 4 bits at a time
    generate
        genvar i;
        for (i = 0; i < 7; i = i + 1) begin
            // note: careful here to make sure the right bits are being selected for each block
            b4_cla_block cla_block  (
                .X(X[(4*i) + 3 : 4*i]),
                .Y(Y[(4*i) + 3 : 4*i]),
                .Z(Z[(4*i) + 3 : 4*i]),
                .C_in(carry[i]),
                .C_out(carry[i+1]),
                .overflow()         // we don't care about the intermediate block's overflow bits
                );
        end
    endgenerate

    // create the last block (and set the output overflow wire, which only comes from the last block)
    b4_cla_block cla_block_last (
        .X(X[31 : 28]),
        .Y(Y[31 : 28]),
        .Z(Z[31 : 28]),
        .C_in(carry[7]),
        .C_out(),                   // we don't care about the last block's carry out bit
        .overflow(overflow)         // but we do care about the last block's overflow bit
        );

endmodule
