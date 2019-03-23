`timescale 1ns / 1ps

// testbench for the N-bit ripple-carry adder module bN_ripple_adder()
module test_bN_ripple_adder;

	// input registers
	reg signed [31:0] X, Y;
	reg test_case;		// register to separate test cases

	// output wires
	wire signed [31:0] Z;
	wire overflow;

	integer errors = 0;

	bN_ripple_adder #(.N(32)) uut (
		.X(X),
		.Y(Y),
		.Z(Z),
		.C_in(0),
		.overflow(overflow)
	);

	initial begin
		$dumpfile("bN_ripple_adder.vcd");
		$dumpvars(0, uut);

		// test cases that should have no overflow bit
		test_case = 0;
		X = 1; Y = 0; 						#200;
		X = 4'b0100; Y = 4'b0100;			#200;
		X = 8'b00011111; Y = 8'b00011111;   #200;
        X = 8'b00011000; Y = 8'b00011000;   #200;
		X = 11111; Y = 99999;				#200;
		X = 1000; Y = -999;					#200;
		X = -123456; Y = -789;				#200;
		X = 2 ** 29; Y = 2 ** 29;			#200;
		X = -(2 ** 30); Y = -(2 ** 30);		#200;

		// test cases that should set the overflow bit high
		test_case = 1;
		X = 2 ** 30; Y = 2 ** 30;		#200;
		X = -(2 ** 31); Y = -(2 ** 31);	#200;

		$display("This test generated %d errors.", errors);

		$finish;

	end

	// an 'always' block is executed whenever any of the variables in the sensitivity
	// list are changed (X or Y here)
	always @(X, Y) begin
		#100;

		$display("Calculating %d + %d = %d, overflow = %b", X, Y, (X + Y), test_case);

		if (Z !== (X + Y) | overflow !== test_case) begin
			$display("ERROR: either Z is not equal to X + Y or the overflow bit is incorrect; X = %d, Y = %d, Z = %d, overflow = %b", X, Y, Z, overflow);
			errors = errors + 1;
        end
	end

endmodule
