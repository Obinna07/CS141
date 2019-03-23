// create an N-bit 8:1 multiplexer
module mux_8to1(X0, X1, X2, X3, X4, X5, X6, X7, S, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X0, X1, X2, X3, X4, X5, X6, X7;
    input wire [2 : 0] S;

    output wire [(N-1) : 0] Z;

    // instantiate the 4:1 mux and the 2:1 mux to create the 8:1 mux
    wire [(N-1) : 0] mux0, mux1;
    mux_4to1 #(.N(N)) MUX8_0 (.X0(X0), .X1(X1), .X2(X2), .X3(X3), .S(S[1 : 0]), .Z(mux0));
    mux_4to1 #(.N(N)) MUX8_1 (.X0(X4), .X1(X5), .X2(X6), .X3(X7), .S(S[1 : 0]), .Z(mux1));
    mux_2to1 #(.N(N)) MUX8_2 (.X(mux0), .Y(mux1), .S(S[2]), .Z(Z));

endmodule
