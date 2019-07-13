`include "alu_defines.v"
`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    alu_decoder 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
module alu_decoder(funct, alu_code);
	
	//parameter definitions

	//port definitions - customize for different bit widths
	input wire [5:0] funct;
	output reg [`ALU_OP_WIDTH - 1: 0] alu_code;
	
	always @(*) begin 
		case (funct)
			`FUNC_ADD : alu_code = `ALU_OP_ADD;
			`FUNC_SUB : alu_code = `ALU_OP_SUB;
			`FUNC_AND : alu_code = `ALU_OP_AND;
			`FUNC_OR : alu_code = `ALU_OP_OR;
			`FUNC_XOR : alu_code = `ALU_OP_XOR;
			`FUNC_NOR : alu_code = `ALU_OP_NOR;
			`FUNC_SLL : alu_code = `ALU_OP_SLL;
			`FUNC_SRA : alu_code = `ALU_OP_SRA;
			`FUNC_SRL : alu_code = `ALU_OP_SRL;
			`FUNC_SLT : alu_code = `ALU_OP_SLT;
			 default : alu_code = `ALU_OP_ADD;
		endcase
	end

endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
