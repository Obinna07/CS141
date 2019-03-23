`timescale 1ns / 1ps

// testbench for the 4-bit adder unit used in the carry lookahead adder
module test_b4_cla_block;

	// input registers
	reg signed [3 : 0] X, Y;
    reg C_in;
	reg c_bit;		// register to separate test cases by carry out

	// output wires
	wire signed [3 : 0] Z;
	wire C_out;

	integer errors = 0;

	b4_cla_block uut (
		.X(X),
		.Y(Y),
		.Z(Z),
        .C_in(C_in),
		.C_out(C_out),
        .overflow()
	);

	initial begin
		$dumpfile("bN_ripple_adder.vcd");
		$dumpvars(0, uut);

		// test cases that should not have the carry out set
		c_bit = 0;
        C_in = 0; X = 4'b0000; Y = 4'b0000;   #200;
        C_in = 0; X = 4'b0001; Y = 4'b0101;   #200;
        C_in = 0; X = 4'b1001; Y = 4'b0100;   #200;
        C_in = 1; X = 4'b0001; Y = 4'b0001;   #200;

		// test cases that do have the carry out set
		c_bit = 1;
        C_in = 0; X = 4'b1111; Y = 4'b1111;   #200;
        C_in = 0; X = 4'b1100; Y = 4'b1100;   #200;
        C_in = 0; X = 4'b1000; Y = 4'b1000;   #200;

		$display("This test generated %d errors.", errors);

		$finish;

	end

	// an 'always' block is executed whenever any of the variables in the sensitivity
	// list are changed (X or Y here)
	always @(X, Y) begin
		#100;

		$display("Calculating %b + %b = %b, carry_in = %b, carry_out = %b", X, Y, (X + Y + C_in), C_in, c_bit);

		if (Z !== (X + Y + C_in) | C_out !== c_bit) begin
			$display("ERROR: either Z is not equal to X + Y or the carry out is incorrect; X = %d, Y = %d, Z = %d, C_in = %b, C_out = %b", X, Y, Z, C_in, C_out);
			errors = errors + 1;
        end
	end

endmodule
