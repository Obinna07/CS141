`timescale 1ns / 1ps

// create an N-bit 2:1 multiplexer
module mux_2to1(X, Y, S, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    input wire S;
    output wire [(N-1) : 0] Z;

    assign Z = S ? Y : X;

endmodule
