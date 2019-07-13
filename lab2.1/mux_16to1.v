// create an N-bit 16:1 multiplexer
module mux_16to1(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, S, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15;
    input wire [3 : 0] S;

    output wire [(N-1) : 0] Z;

    // instantiate the 8:1 mux and the 2:1 mux to create the 16:1 mux
    wire [(N-1) : 0] mux0, mux1;
    mux_8to1 #(.N(N)) MUX16_0 (.X0(X0), .X1(X1), .X2(X2), .X3(X3), .X4(X4), .X5(X5), .X6(X6), .X7(X7), .S(S[2 : 0]), .Z(mux0));
    mux_8to1 #(.N(N)) MUX16_1 (.X0(X8), .X1(X9), .X2(X10), .X3(X11), .X4(X12), .X5(X13), .X6(X14), .X7(X15), .S(S[2 : 0]), .Z(mux1));
    mux_2to1 #(.N(N)) MUX16_2 (.X(mux0), .Y(mux1), .S(S[3]), .Z(Z));

endmodule
