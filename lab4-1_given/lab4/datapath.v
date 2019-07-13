`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
`include "alu_defines.v"
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2015
// Module Name:    datapath 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
module datapath(clk, rst, op_code, funct, ALUSrcA, ALUSrcB, ALUOp, regWrite, pcWrite, rs, rt, rd, shamt, pc);

	//parameter definitions

	//port definitions - customize for different bit widths
	input wire clk, rst, regWrite, pcWrite;
	input wire [1:0] ALUSrcA, ALUSrcB;
	input wire [3:0] ALUOp;
	input wire [5:0] op_code, funct;
	input wire [4:0] rs, rt, rd, shamt;
	output reg [31:0] pc;
	wire [31:0] rd_data0, rd_data1, wr_data, alu_out;
	wire equal, zero, overflow;
	reg [31:0] alu_input1, alu_input2, alu_reg;
	
	register_file REGFILE(.clk(clk), .rst(rst), .rd_addr0(rs), .rd_addr1(rt), .wr_addr(rd), .rd_data0(rd_data0), .rd_data1(rd_data1), .wr_data(alu_reg), .wr_ena(regWrite));	
	
	alu ALU (.x(alu_input1), .y(alu_input2), .op_code(ALUOp), .z(alu_out), .equal(equal), .zero(zero), .overflow(overflow));
	
	always @(posedge clk) begin 
		if (rst)
			pc <= 32'h00400000;
		else if (pcWrite)
			pc <= alu_out;
			
		alu_reg <= alu_out;
	end
		
	always @(*) begin 
		case (ALUSrcA)
			`SRCA_REG : alu_input1 = rd_data0;
			`SRCA_INCPC : alu_input1 = pc;
			`SRCA_SHIFT : alu_input1 = rd_data1;
			 default : alu_input1 = 32'b0;
		endcase	
		
		case (ALUSrcB)
			`SRCB_REG : alu_input2 = rd_data1;
			`SRCB_INCPC : alu_input2 = 32'b100;
			`SRCB_SHIFT : alu_input2 = shamt;
			 default : alu_input2 = 32'b0;
		endcase	
	end
	
	
endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
