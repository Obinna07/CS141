`timescale 1ns / 1ps

// create a set less than function
module bN_slt(X, Y, A);
    input wire X, Y;
    output wire [31:0] A;
    wire [31:0] overflow;

    b32_cla_sub sub (.X(X),.Y(Y),.Z(A),.overflow());
    assign A = ~(Z[31]^overflow);

endmodule