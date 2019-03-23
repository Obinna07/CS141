// create the N-bit OR operator (op_code 0001)
module bN_or(X, Y, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    output wire [(N-1) : 0] Z;

    assign Z = X | Y;

endmodule
