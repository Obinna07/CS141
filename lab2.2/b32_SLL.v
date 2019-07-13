module b32_SLL(Z, S, X);

	parameter N = 32;

	input  wire [(N-1):0] X;
	input  wire     [31:0] S;

	output wire [(N-1):0] Z;

	wire         [63 : 0] shiftX;

	// add another 32 bits (zeros) to the end of the input number
	assign shiftX = {X,32'b0};

	// instantiate mux_32to1 32 times
	generate
	 genvar i;

	 for (i = 0; i < 32; i = i + 1) begin : b32_SLL_mux_gen
		  mux_32to1 #(.N(1)) mux_32to1_i (.Z(Z[31 - i]), .S(S[4 : 0]), .X0(shiftX[63-i]), .X1(shiftX[63 - i - 1]), .X2(shiftX[63 - i - 2]), .X3(shiftX[63 - i - 3]), .X4(shiftX[63 - i - 4]), .X5(shiftX[63 - i - 5]), .X6(shiftX[63 - i - 6]), .X7(shiftX[63 - i - 7]), .X8(shiftX[63 - i - 8]), .X9(shiftX[63 - i - 9]), .X10(shiftX[63 - i - 10]), .X11(shiftX[63 - i - 11]), .X12(shiftX[63 - i - 12]), .X13(shiftX[63 - i - 13]), .X14(shiftX[63 - i - 14]), .X15(shiftX[63 - i - 15]), .X16(shiftX[63 - i - 16]), .X17(shiftX[63 - i - 17]), .X18(shiftX[63 - i - 18]), .X19(shiftX[63 - i - 19]), .X20(shiftX[63 - i - 20]), .X21(shiftX[63 - i - 21]), .X22(shiftX[63 - i - 22]), .X23(shiftX[63 - i - 23]), .X24(shiftX[63 - i - 24]), .X25(shiftX[63 - i - 25]), .X26(shiftX[63 - i - 26]), .X27(shiftX[63 - i - 27]), .X28(shiftX[63 - i - 28]), .X29(shiftX[63 - i - 29]), .X30(shiftX[63 - i - 30]), .X31(shiftX[63 - i - 31]));
	 end

	endgenerate

endmodule
