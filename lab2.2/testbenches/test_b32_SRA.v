`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:   CS141
// Engineer:  Obinna Ejikeme, Ricky Williams
////////////////////////////////////////////////////////////////////////////////

`include "alu_defines.v"

module test_b32_SRA;

	// Inputs
	reg signed [31:0] X;
	reg [31 : 0] S;

	// Outputs
	wire signed [31:0] Z;

	// Instantiate the Unit Under Test (UUT)
	b32_SRA #(.N(32)) uut (
		.X(X),
		.S(S),
		.Z(Z)
	);

	initial begin
		$dumpfile("b32_SRA.vcd");
		$dumpvars(0, uut);

        // test cases with S = 0
        S = 0;
        X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

		// test cases with S = 1
        S = 1;
		X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

		// test cases with S = 2
        S = 2;
		X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

        // test cases with S = 3
        S = 3;
		X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

        // test case with S = 7
        S = 7;
        X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

        // test case with S = 15
        S = 15;
        X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

        // test case with S = 23
        S = 23;
        X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

        // test case with S = 31
        S = 31;
        X = 8; #1000;
		X = 12; #1000;
        X = 14; #1000;
        X = 7; #1000;
        X = -15; #1000;
        X = -3; #1000;
        X = -1; #1000;
        X = -10; #1000;

		  $display("done");

		$finish;

	end

	// an 'always' block is executed whenever any of the variables in the sensitivity
	// list are changed (X, Y, or test_case here)
	always @(X, S) begin
		#200;

		//$display("Calculating...shifting %b %d places", X, S);

		if (Z !== (X >>> S)) begin
			$display("ERROR: Either X did not shift correctly when S was set to %d, or it did not retain its sign; X = %b, Z = %b", S, X, Z);
        end
	end

endmodule
