`timescale 1ns / 1ps
`default_nettype none

// the following module is made for SIMULATION ONLY - most of the language
// constructs used here will not synthesize, but will simulate
module testbench();
	reg [7:0] switch; // input
	wire [7:0] led; // output

	integer count; // count the number of bits in the 'switch' bus
	integer index;

	// instantiate unit under test (uut)
	main uut (switch, led);

	// count of the number of errors
	integer error = 0;

	initial begin
		for (switch = 0; switch != 8'b11111111; switch = switch + 1) begin
			#10; // wait for inputs to propagate

			// test for part 1
			if (switch[0] && switch[1] !== led[0]) begin
				$display("ERROR: switch[0]=%b, switch[1]=%b, led[0]=%b", switch[0], switch[1], led[0]);
				error = error + 1;
			end

			// test for part 2
			if (led[1] == switch[2] && ~switch[3]) begin
				$display("ERROR: switch[2]=%b, switch[3]=%b, led[1]=%b", switch[2], switch[3], led[1]);
				error = error + 1;
			end

			// test for part 3
			count = 0;
			for (index = 0; index < 8; index = index + 1) begin
				count = count + switch[index];
			end

			// only pass the test if led[2] is on when count is even only
			if (led[2] == count % 2) begin
				$display("ERROR: count=%d, led[2]=%b", count, led[2]);
				error = error + 1;
			end

			// test for part 4
			if ((switch[4] && led[3] !== led[0]) | (~switch[4] && led[3] !== led[1])) begin
				$display("ERROR: switch[4]=%b, led[0]=%b, led[1]=%b, led[3]=%b", switch[4], led[0], led[1], led[3]);
				error = error + 1;
			end
		end

		#10;
		$display("Finished with %d errors", error);

		$finish;
	end
endmodule

`default_nettype wire
