module b32_SRL(Z, S, X);

	parameter N = 32;

	input  wire [31 : 0] X;
	input  wire     [31 :0] S;

	output wire [31:0] Z;

	wire         [63 :0] shiftX;

	// add another 32 bits (zeros) to the end of the input number
	assign shiftX = {32'b0, X};

	// instantiate mux_32to1 32 times
	generate
	 genvar i;

	 for (i = 0; i < 32; i = i + 1) begin : b32_SRL_mux_gen
		  mux_32to1 #(.N(1)) mux_32to1_i (.Z(Z[i]), .S(S[4 : 0]),
		  	.X0(shiftX[i]),
			.X1(shiftX[i + 1]),
			.X2(shiftX[i + 2]),
			.X3(shiftX[i + 3]),
			.X4(shiftX[i + 4]),
			.X5(shiftX[i + 5]),
			.X6(shiftX[i + 6]),
			.X7(shiftX[i + 7]),
			.X8(shiftX[i + 8]),
			.X9(shiftX[i + 9]),
			.X10(shiftX[i + 10]),
			.X11(shiftX[i + 11]),
			.X12(shiftX[i + 12]),
			.X13(shiftX[i + 13]), .X14(shiftX[i + 14]), .X15(shiftX[i + 15]), .X16(shiftX[i + 16]), .X17(shiftX[i + 17]), .X18(shiftX[i + 18]), .X19(shiftX[i + 19]), .X20(shiftX[i + 20]), .X21(shiftX[i + 21]), .X22(shiftX[i + 22]), .X23(shiftX[i + 23]), .X24(shiftX[i + 24]), .X25(shiftX[i + 25]), .X26(shiftX[i + 26]), .X27(shiftX[i + 27]), .X28(shiftX[i + 28]), .X29(shiftX[i + 29]), .X30(shiftX[i + 30]), .X31(shiftX[i + 31]));
	 end

	endgenerate

endmodule
