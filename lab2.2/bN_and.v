// create the N-bit AND operator (op_code 0000)
module bN_and(X, Y, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X, Y;
    output wire [(N-1) : 0] Z;

    assign Z = X & Y;

endmodule
