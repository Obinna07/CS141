`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
//
// CS 141 - Fall 2015
//
// Module Name:    clk_divider
//
// Author(s):
//
// Description (from assignment): "This clock divider takes an internal 100 Mhz clock and converts
// it to 1 cycle/second (1 Hz). It takes in a clk_in signal from the internal clock and a reset signal (rst). Each
// time the internal clock goes through a cycle, a register (r_next) increments its state by one. When the internal clock
// is halfway through the external clock's period (50 Mhz), r_next is reset to zero, and another register (r_reg), which has the
// same state as the external clock will go low (it starts high). After another 50 MHz, r_next will reset to 0 again and r_reg
// will go high (so it goes high every 100 MHz).
//
//
//////////////////////////////////////////////////////////////////////////////////
module clk_divider(clk_in, rst, clk_out);

	//parameter definitions
	parameter N = 100;

	//port definitions - customize for different bit widths
	input wire clk_in;
	input wire rst;
	output wire clk_out;

	// 2 registers, one for next-state logic (counts clk-ins) and one to hold values for clk_out until needed
	reg[31:0] r_next;
	reg       r_reg;

	always @(posedge clk_in)
		begin

			if (rst)
				r_reg <= 0; // asynchronous reset
			else if (r_next == N/2)
				begin
					r_reg <= ~r_reg;
					r_next <= 0;
				end
			else
				r_next <= r_next + 1; // keeps track of # of clk_ins

		end

	assign clk_out = r_reg;

endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
