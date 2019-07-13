`timescale 1ns / 1ps

// testbench for a 3-bit ripple carry adder built from the 1-bit adder b1_adder() module
// this testbench was created to better understand how to test the full 32-bit ripple carry adder we implemented in the ALU
module test_b3_ripple_adder;

	// input registers
	reg signed [2:0] X, Y;
	reg test_case;

	// output registers
	wire signed [2:0] Z;
	wire overflow;

	integer errors = 0;

	// instantiate the bN_ripple_adder with 3 bits for the uut
	bN_ripple_adder #(.N(3)) uut (
		.X(X),
		.Y(Y),
		.Z(Z),
		.overflow(overflow)
	);

	initial begin
		// create a file to analyze in a waveform viewer (GTKWave)
		$dumpfile("b3_ripple_adder.vcd");
		$dumpvars(0, uut);

		// test cases that should have no overflow bit
		X = 0; Y = 0; test_case = 0; 	#200;				// Z = 0, overflow = 0
		X = 1; Y = -1; test_case = 0; 	#200;				// Z = 0, overflow = 0
		X = 2; Y = -1; test_case = 0; 	#200;				// Z = 1, overflow = 0
		X = 2; Y = 1; test_case = 0; 	#200;				// Z = 3, overflow = 0
		X = -1; Y = -1; test_case = 0; 	#200;				// Z = -2, overflow = 0
		X = -2; Y = -2; test_case = 0; 	#200;				// Z = -4, overflow = 0

		// test cases that should set the overflow bit high
		X = 2; Y = 2; test_case = 1; 	#200;				// Z = -1, overflow = 1
		X = -2; Y = -3; test_case = 1;	#200;				// Z = 3, overflow = 1

		$display("This test generated %d errors.", errors);

		$finish;

	end

	// an 'always' block is executed whenever any of the variables in the sensitivity
	// list are changed (X, Y, or test_case here)
	always @(X, Y) begin
		#100;

		$display("Calculating %d + %d = %d, overflow = %b", X, Y, (X + Y), test_case);

		if (Z !== (X + Y) | overflow !== test_case) begin
			$display("ERROR: either Z is not equal to X + Y or the overflow bit is incorrect; X = %d, Y = %d, Z = %d, overflow = %b", X, Y, Z, overflow);
			errors = errors + 1;
        end
	end

endmodule
