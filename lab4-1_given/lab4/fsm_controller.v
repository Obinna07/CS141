`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
`include "alu_defines.v"
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    fsm_controller 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
module fsm_controller(clk, rst, ena, op_code, funct, ALUSrcA, ALUSrcB, ALUOp, regWrite, irWrite, pcWrite);

	//parameter definitions
	
	//port definitions - customize for different bit widths
	input wire clk, rst, ena;
	input wire [5:0] op_code, funct;
	output reg  regWrite, irWrite, pcWrite;
	output reg [1:0] ALUSrcA, ALUSrcB;
	output reg [3:0] ALUOp; 
	
	reg [3:0] state, next_state; 
	
	wire [3:0] ALUDecoded;
	alu_decoder ALUDecoder (.funct(funct), .alu_code(ALUDecoded));
	
	always @(posedge clk) begin
		if (rst) state <= `STATE_FETCH;
		else if (ena) state <=  next_state;
		else state <= state;
	end
	
	always @(*) begin
		ALUSrcA = 2'b00;
		ALUSrcB = 2'b00;
		ALUOp = 4'b0000;
		regWrite = 1'b0;
		irWrite = 1'b0;
		pcWrite = 1'b0;
		next_state = `STATE_FETCH;
		case(state)
			`STATE_FETCH : begin	
				irWrite = 1'b1;
				pcWrite = 1'b1;
				ALUSrcA = `SRCA_INCPC;
				ALUSrcB = `SRCB_INCPC;
				ALUOp = `ALU_OP_ADD;
				next_state = `STATE_DECODE;
			end
			`STATE_DECODE : begin
				if (op_code == `OP_RTYPE)
					next_state = `STATE_EXECUTE;
				else
					next_state = `STATE_FETCH;
			end
			`STATE_EXECUTE : begin
				if (funct == `FUNC_SLL || funct == `FUNC_SRA || funct == `FUNC_SRL) begin
					ALUSrcA = `SRCA_SHIFT;
					ALUSrcB = `SRCB_SHIFT;
				end
				else begin
					ALUSrcA = `SRCA_REG;
					ALUSrcB = `SRCB_REG;
				end
					
				ALUOp = ALUDecoded;
				next_state = `STATE_WRITEBACK;
			end
			`STATE_WRITEBACK : begin
				regWrite = 1'b1;
				next_state = `STATE_FETCH;
			end
		endcase
	end
			
		

endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
