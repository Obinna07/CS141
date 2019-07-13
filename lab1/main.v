`timescale 1ns / 1ps  // sets the timescale (for simulation)
`default_nettype none // overrides default behaviour: errors when a net type is not declired

module main(switch, led);
	// declare inputs and outputs
	input wire [7:0] switch;
	output wire [7:0] led;

	// turn off the last 4 LEDs
	assign led[7:4] = 4'b0000;

	// feature 1: turn on the first LED only if switches 0 and 1 are both on
	assign led[0] = switch[0] && switch[1];

	// feature 2: implement implication with switches 2 and 3 on LED 1
	assign led[1] = (~switch[2]) | switch[3];

	// feature 3: turn on led[2] if there are an even number of switches on
	assign led[2] = ~(^switch);

	// feature 4: set led[3] to led[0] if switch[4] is on; else set led[3] = led[1]
	assign led[3] = (switch[4] && led[0]) | (~switch[4] && led[1]);

endmodule

`default_nettype none // reengages default behaviour: needed for other Xilinx modules
