`timescale 1ns / 1ps
`default_nettype none // helps catch typo-related bugs

//////////////////////////////////////////////////////////////////////////////////
//
// CS 141 - Spring 2019
//
// Description (from assignment): "The timer produces a 4-bit (unsigned) output (out) that represents
// the current time remaining. The timer takes a reset (rst) input, which when asserted, should reset the
// timer to the maximum value. The timer also takes an initial value (init) and a (load) signal. When load is high,
// the current time remaining should get set to the init value. There is also an enable (en) input, and when en is high,
// the timer should decrement by 1, but should stop at 0. If en is not asserted, the timer should stay at
// its current value (unless a load or reset occurs). rst should take highest precedence, followed by load,
// and then en. The output should only change on positive edges of the input clock, which should be the
// 1Hz signal from the clock divider."
//
//////////////////////////////////////////////////////////////////////////////////
module timer(clk, rst, en, load, init, out);

	// parameter definitions
	parameter N = 4;

	// port definitions - customize for different bit widths
	input wire clk, rst, en, load;
	input wire [(N-1) : 0] init;
	output wire [(N-1) : 0] out;

	// registers to hold the timer's current and next states
	reg [(N-1) : 0] timer_state, timer_next;

	// pass the next state onto the current state on the rising clock edge
	always @(posedge clk)
	begin
		timer_state <= timer_next;
	end

	// update the next state
	always @*
	begin
		// reset the timer to the maximum value if .rst (reset) is high
		if (rst)
			timer_next = 4'b1111;

		// otherwise load the values from .init into the timer if .load is high
		else if (load)
			timer_next = init;

		// otherwise, if the timer isn't at 0 yet and .en (enable) is high, decrement the counter
		else if (en & (|timer_state))		// if we OR all the bits of .timer_state, we should get a 1 unless the state is already at 0
			timer_next = timer_state - 1;

		else
			timer_next = timer_state;
	end

	// combinational logic output
	assign out = timer_state;

endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
