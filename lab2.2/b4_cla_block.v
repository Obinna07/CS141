`timescale 1ns / 1ps

module b4_cla_block(X, Y, Z, C_in, C_out, overflow);
    input wire [3 : 0] X, Y;    // 4-bit inputs
    input wire C_in;            // carry in for this block
    output wire [3 : 0] Z;      // 4-bit output
    output wire C_out, overflow;          // carry out for this block / potential overflow bit

    // perform the addition with a 4-bit ripple carry adder
    bN_ripple_adder #(.N(4)) cla_block_add (
        .X(X),
        .Y(Y),
        .Z(Z),
        .C_in(C_in),
        .overflow(overflow)             // this overflow output only matters for the last block in the full CLA
        );

    // wires for the block's generate (G) and propogate (G) carry signals
    wire [3 : 0] G, P;
    wire blockG, blockP;

    // generate the column-wise generate (G_i) and propogate (P_i) signals
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            and #1 gen (G[i], X[i], Y[i]);
            or #1 prop (P[i], X[i], Y[i]);
        end
    endgenerate

    // AND the individual propogate signals to form the block propogate signal
    assign blockP = &P;

    // generate the AND and OR gates needed to form the block generate signal
    assign blockG = G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & G[0])))));

    // use the block propogate and generate signals to output this block's carry out
    assign C_out = blockG | (blockP & C_in);

endmodule
