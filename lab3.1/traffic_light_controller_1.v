`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    traffic_light_controller 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
//define states
`define IDLE 4'b0000
`define PED 4'b0001
`define CAR_NS 4'b0011
`define CAR_EW 4'b0010


//useful macros
`define LIGHT_RED 3'b100
`define LIGHT_YELLOW 3'b010
`define LIGHT_GREEN 3'b001

`define PED_NS 2'b10
`define PED_EW 2'b01 
`define PED_BOTH 2'b11 
`define PED_NEITHER 2'b00 

module traffic_light_controller(clk, rst, timer_en, timer_load, timer_init, timer_out, 
										  car_ns, car_ew, ped, light_ns, light_ew, light_ped);

	//port definitions 
	input clk, rst, car_ns, car_ew, ped;
	input wire [3:0] timer_out; 
	
	output reg [3:0] timer_init; 
	output reg [2:0] light_ns, light_ew; 
	output reg [1:0] light_ped;
	output reg timer_load, timer_en; 

	reg [3:0] state, next_state; 
	reg turn_reg; 
	
	
	//change to next state and change value of any internal register
	always @(posedge clk or posedge rst) begin 
		if (rst) begin
			state <= `IDLE; 
			sample_reg <= 0; 
		end
		else
			state <= next_state;
			turn_reg <= next_turn_reg; 	
	end 
	
	//triggers on change of state or inputs
	always @(state, timer_out, rst, ped, car_ns, car_ew) begin 
		case (state) 
				`IDLE : begin 
					
					//set outputs
					light_ns <= `LIGHT_RED;
					light_ew <= `LIGHT_RED;
					light_ped <= `PED_NEITHER; 
					timer_en <= 0; 
					timer_load <= 1; 
					timer_init <= 4'b1111;

					
					//sample state transition
					if (ped)
						next_state <= `PED;
					
					//set next value for internal registers
					sample_reg_next <= 1; 
				end

				`PED : begin

					//set outputs
					light_ns <= `LIGHT_RED;
					light_ew <= `LIGHT_RED;
					light_ped <= `PED_BOTH;
					timer_en <= 1;
					timer_load <= 0;
                    
                    #15

					//sample state transition
                    if (rst)
                        next_state <= `IDLE;
                    
                    else if (car_ns & ~car_ew) begin
                        next_state <= `CAR_NS;
                        timer_en <= 0; 
					    timer_load <= 1; 
					    timer_init <= 4'b1111;
                    end
                   
                    else if (~car_ns & car_ew) begin
                        next_state <= `CAR_EW;
                        timer_en <= 0; 
					    timer_load <= 1; 
					    timer_init <= 4'b1111;
                    end
                    
                    else if (car_ns & car_ew) begin
                         next_state <= turn_reg;
                        turn_reg 
                        timer_en <= 0; 
					    timer_load <= 1; 
					    timer_init <= 4'b1111;  
                    end

				end

                `CAR_NS : begin

                    //set outputs
                    light_ns <= `LIGHT_GREEN;
                    light_ew <= `LIGHT_RED;
                    light_ped <= `PED_NS;
                    turn_reg <= `CAR_EW;
                    timer_en <= 1;
                    timer_load <= 0;

                    if (timer_out = 4'b0110)
                        light_ns <= `LIGHT_YELLOW;

                    if (timer_out <= 4'b0001) begin
                        if (ped) begin
                            next_state <= `PED;
                            timer_en <= 0; 
                            timer_load <= 1; 
                            timer_init <= 4'b1111;
                        end
                        
                        else if(rst)
                            next_state <= `IDLE;

                        else begin
                            next_state <= `CAR_EW;
                            timer_en <= 0; 
                            timer_load <= 1;
                            timer_init <= 4'b1111;
                        end

                end

                `CAR_EW : begin

                    //set outputs
                    light_ns <= `LIGHT_RED;
                    light_ew <= `LIGHT_GREEN;
                    light_ped <= `PED_EW;
                    turn_reg <= `CAR_NS;
                    timer_en <= 1;
                    timer_load <= 0;

                    if (timer_out == 4'b0110)
                        light_ew <= `LIGHT_YELLOW;

                    if (timer_out == 4'b0001) begin
                        if (ped) begin
                            next_state <= `PED;
                            timer_en <= 0; 
                            timer_load <= 1; 
                            timer_init <= 4'b1111;
                        end

                        else if (rst)
                            next_state <= `IDLE;

                        else begin
                            next_state <= `CAR_NS;
                            timer_en <= 0; 
                            timer_load <= 1; 
                            timer_init <= 4'b1111;
                        end
                    end
                end
				
                default : begin 
					light_ns <= `LIGHT_RED;
					light_ew <= `LIGHT_RED;
					light_ped <= `PED_NEITHER; 
					timer_en <= 0; 
					timer_load <= 1;
					timer_init <= 4'b1111;	
					
					next_state <= `IDLE; 
					
					sample_reg_next <= 0; 
				end
		endcase
	end 

endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
