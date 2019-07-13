`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    insr_decoder 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
module insr_decoder(instruction, op_code, rs, rt, rd, shamt, funct);

	//parameter definitions

	//port definitions - customize for different bit widths
	input wire[31:0] instruction;
	output wire[5:0] op_code, funct;
	output wire[4:0] rs, rt, rd, shamt;
	
	assign op_code = instruction[31:26];
	assign rs = instruction[25:21];
	assign rt = instruction[20:16];
	assign rd = instruction[15:11];
	assign shamt = instruction[10:6];
	assign funct = instruction[5:0];


endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
