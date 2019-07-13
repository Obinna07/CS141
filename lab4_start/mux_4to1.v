// create an N-bit 4:1 multiplexer
module mux_4to1(X0, X1, X2, X3, S, Z);
    parameter N = 4;

    input wire [(N-1) : 0] X0, X1, X2, X3;
    input wire [1 : 0] S;

    output wire [(N-1) : 0] Z;

    // instantiate to 2:1 mux to create the 4:1 mux
    wire [(N-1) : 0] mux0, mux1;
    mux_2to1 #(.N(N)) MUX4_0 (.X(X0), .Y(X1), .S(S[0]), .Z(mux0));
    mux_2to1 #(.N(N)) MUX4_1 (.X(X2), .Y(X3), .S(S[0]), .Z(mux1));
    mux_2to1 #(.N(N)) MUX4_2 (.X(mux0), .Y(mux1), .S(S[1]), .Z(Z));

endmodule
