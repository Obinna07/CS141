`timescale 1ns / 1ps

// create a set less than function
module b32_SLT(X, Y, A);
    input wire [31 : 0] X, Y;
    output wire [31 : 0] A;
    wire [31:0] Z;
    wire overflow, a;

    b32_cla_sub sub (.X(X), .Y(Y), .Z(Z), .overflow(overflow));
    assign a = Z[31] ^ overflow;
    assign A = {31'b0, a};

endmodule
