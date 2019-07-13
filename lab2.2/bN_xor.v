// create the N-bit XOR operator (op_code 0010)
module bN_xor(X, Y, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    output wire [(N-1) : 0] Z;

    assign Z = X ^ Y;

endmodule
