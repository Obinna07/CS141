// Creat an N-bit 32:1 multiplexer

module mux_32to1(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23, X24, X25, X26, X27, X28, X29, X30, X31, S, Z);
    parameter N = 4;
    
    input wire [(N-1) : 0] X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23, X24, X25, X26, X27, X28, X29, X30, X31;
    input wire [4 : 0] S;

    output wire [(N-1) : 0] Z;

    // instantiate the 16:1 mux and the 2:1 mux to create the 32:1 mux
    wire [(N-1) : 0] mux0, mux1;
    mux_16to1 #(.N(N)) MUX32_0 (.X0(X0), .X1(X1), .X2(X2), .X3(X3), .X4(X4), .X5(X5), .X6(X6), .X7(X7), .X8(X8), .X9(X9), .X10(X10), .X11(X11), .X12(X12), .X13(X13), .X14(X14), .X15(X15), .S(S[3 : 0]), .Z(mux0));
    mux_16to1 #(.N(N)) MUX32_1 (.X0(X16), .X1(X17), .X2(X18), .X3(X19), .X4(X20), .X5(X21), .X6(X22), .X7(X23), .X8(X24), .X9(X25), .X10(X26), .X11(X27), .X12(X28), .X13(X29), .X14(X30), .X15(X31), .S(S[3 : 0]), .Z(mux1));
    mux_2to1  #(.N(N)) MUX32_2 (.X(mux0), .Y(mux1), .S(S[4]), .Z(Z));

endmodule