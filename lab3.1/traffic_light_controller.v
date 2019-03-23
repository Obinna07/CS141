`timescale 1ns / 1ps
`default_nettype none // helps catch typo-related bugs

//////////////////////////////////////////////////////////////////////////////////
//
// CS 141 - Fall 2015
// Module Name:    traffic_light_controller
// Author(s):
// Description:
//
//
//////////////////////////////////////////////////////////////////////////////////

// define states
`define IDLE 4'b0000
`define PED 4'b0001
`define PED_TIME 4'b0010
`define PED_NEXT 4'b0011
`define CAR_NS_GREEN 4'b0100
`define CAR_NS_YELLOW 4'b0101
`define CAR_EW_GREEN 4'b0110
`define CAR_EW_YELLOW 4'b0111
`define TIMER_GREEN 4'b1000
`define TIMER_YELLOW 4'b1001

// useful macros
`define LIGHT_RED 3'b100
`define LIGHT_YELLOW 3'b010
`define LIGHT_GREEN 3'b001

`define PED_NS 2'b10
`define PED_EW 2'b01
`define PED_BOTH 2'b11
`define PED_NEITHER 2'b00

module traffic_light_controller(clk, rst, timer_en, timer_load, timer_init,
								timer_out, car_ns, car_ew, ped, light_ns, light_ew, light_ped);

	//port definitions
	input clk, rst, car_ns, car_ew, ped;
	input wire [3:0] timer_out;

	output reg [3:0] timer_init;
	output reg [2:0] light_ns, light_ew;
	output reg [1:0] light_ped;
	output reg timer_load, timer_en;

	reg [3:0] state, next_state;
	reg [3:0] turn_reg, turn_reg_next;
	reg [7:0] light_reg, light_reg_next = 8'b10000100;

	// change to next state and change value of any internal register
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= `IDLE;
			turn_reg <= `CAR_NS_GREEN;
		end
		else begin
			state <= next_state;
			light_reg <= light_reg_next;
			turn_reg <= turn_reg_next;
		end
	end

	// triggers on change of state or inputs
	//always @(state, turn_reg, light_reg, timer_out, rst, ped, car_ns, car_ew) begin
	always @* begin

		case (state)
				`IDLE : begin
					// set outputs
					light_reg_next[7:5] <= `LIGHT_RED;
					light_reg_next[2:0] <= `LIGHT_RED;
					light_reg_next[4:3] <= `PED_NEITHER;
					turn_reg_next <= `CAR_NS_GREEN;

					next_state <= `PED;
				end

				`PED : begin
					// set outputs
					light_reg_next[7:5] <= `LIGHT_RED;
					light_reg_next[2:0] <= `LIGHT_RED;
					light_reg_next[4:3] <= `PED_BOTH;
					turn_reg_next <= turn_reg;

					timer_en <= 0;
					timer_load <= 1;
					timer_init <= 4'b1111;

					next_state <= `PED_TIME;
				end

				`PED_TIME : begin
					timer_en <= 1;
					timer_load <= 0;

					light_reg_next <= light_reg;
					turn_reg_next <= turn_reg;

					if (timer_out == 4'b0001)
						next_state <= `PED_NEXT;
					else
						next_state <= `PED_TIME;

				end

				`PED_NEXT : begin
					light_reg_next <= light_reg;
					turn_reg_next <= turn_reg;

					if (car_ns & ~car_ew)
						next_state <= `CAR_NS_GREEN;

					else if (~car_ns & car_ew) begin
						next_state <= `CAR_EW_GREEN;
					end

					else if (car_ns & car_ew | ~car_ns & ~car_ew) begin
						next_state <= turn_reg;
					end
				end

				`CAR_NS_GREEN : begin
					// set outputs
					light_reg_next[7:5] <= `LIGHT_GREEN;
					light_reg_next[2:0] <= `LIGHT_RED;
					light_reg_next[4:3] <= `PED_NS;
					turn_reg_next <= `CAR_EW_GREEN;

          timer_en <= 0;
        	timer_load <= 1;
					timer_init <= 4'b1010;

					next_state <= `TIMER_GREEN;
          end

				`TIMER_GREEN : begin
					timer_en <= 1;
					timer_load <= 0;

					light_reg_next <= light_reg;
					turn_reg_next <= turn_reg;

					if (timer_out == 4'b0001) begin
						if (light_ns == `LIGHT_GREEN)
							next_state <= `CAR_NS_YELLOW;
						else if (light_ew == `LIGHT_GREEN)
							next_state <= `CAR_EW_YELLOW;
					end
					else begin
						next_state <= `TIMER_GREEN;
					end
				end

				`CAR_NS_YELLOW : begin
					light_reg_next[7:5] <= `LIGHT_YELLOW;
					light_reg_next[2:0] <= `LIGHT_RED;
					light_reg_next[4:3] <= `PED_NS;
					turn_reg_next <= `CAR_EW_GREEN;

					timer_en <= 0;
					timer_load <= 1;
					timer_init <= 4'b0101;

					next_state <= `TIMER_YELLOW;
				end

				`TIMER_YELLOW : begin
					timer_en <= 1;
					timer_load <= 0;

					light_reg_next <= light_reg;
					turn_reg_next <= turn_reg;

					if (timer_out == 4'b0001) begin

						if (ped) begin
							next_state <= `PED;
						end

						else begin
							/*if (light_ns == `LIGHT_YELLOW)
								next_state <= `CAR_EW_GREEN;
							else
								next_state <= `CAR_NS_GREEN;*/

							next_state <= turn_reg;
						end
					end
					else begin
						next_state <= `TIMER_YELLOW;
					end
				end

				 `CAR_EW_GREEN : begin
					// set outputs
					light_reg_next[7:5] <= `LIGHT_RED;
					light_reg_next[2:0] <= `LIGHT_GREEN;
					light_reg_next[4:3] <= `PED_EW;
					turn_reg_next <= `CAR_NS_GREEN;

					timer_en <= 0;
					timer_load <= 1;
					timer_init <= 4'b1010;

					next_state <= `TIMER_GREEN;
				 end

				 `CAR_EW_YELLOW : begin
					// set outputs
					light_reg_next[7:5] <= `LIGHT_RED;
					light_reg_next[2:0] <= `LIGHT_YELLOW;
					light_reg_next[4:3] <= `PED_EW;
					turn_reg_next <= `CAR_NS_GREEN;

					timer_en <= 0;
					timer_load <= 1;
					timer_init <= 4'b0101;

					next_state <= `TIMER_YELLOW;
				end

                default : begin
						light_ns <= `LIGHT_RED;
						light_ew <= `LIGHT_RED;
						light_ped <= `PED_NEITHER;
						timer_en <= 0;
						timer_load <= 1;
						timer_init <= 4'b1111;

						next_state <= `IDLE;

					end
		endcase

		light_ns <= light_reg[7:5];
		light_ew <= light_reg[2:0];
		light_ped <= light_reg[4:3];

	end

endmodule
`default_nettype wire // some Xilinx IP requires that the default_nettype be set to wire
