`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    mips 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
module mips(clk, rst, addr, rd_val, wr_ena, wr_val);

	//parameter definitions

	//port definitions - customize for different bit widths
	input wire clk, rst;
	output wire wr_ena;
	input wire [31:0] rd_val;
	output wire [31:0] addr, wr_val;
	
	wire  regWrite, irWrite, pcWrite;
	wire [1:0] ALUSrcA, ALUSrcB;
	wire [3:0] ALUOp;
	wire [5:0] op_code, funct;
	wire [4:0] rs, rt, rd, shamt;
	wire [31:0] pc;
	
	reg [31:0] instruction;
	
	always @(posedge clk) begin 
		if (irWrite)
			instruction <= rd_val;
	end
			
	
	insr_decoder INSTRUCTION_DECODER(.instruction(instruction), .op_code(op_code), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .funct(funct));

	fsm_controller FSMControl (.clk(clk), .rst(rst), .ena(1'b1), .op_code(op_code), .funct(funct), .ALUSrcA(ALUSrcA), 
										.ALUSrcB(ALUSrcB), .ALUOp(ALUOp), .regWrite(regWrite), .irWrite(irWrite), .pcWrite(pcWrite));
	
	datapath DATAPATH (.clk(clk), .rst(rst), .op_code(op_code), .funct(funct), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .ALUOp(ALUOp), 
								.regWrite(regWrite), .pcWrite(pcWrite), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .pc(pc));				
	
	assign addr = pc;
	assign wr_ena = 1'b0;
	assign wr_val = 1'b0;
	

endmodule
