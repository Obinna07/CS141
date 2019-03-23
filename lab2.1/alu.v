`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
//
// CS 141 - Spring 2019
// Module Name:    alu
// Author(s): Obinna Ejikeme, Ricky Williams
// Description: CS 141 programming assignment 2
//
//////////////////////////////////////////////////////////////////////////////////

`include "alu_defines.v"

// create the 32-bit ALU with the following operations and op_codes:
//
// op_code 0000: AND
// op_code 0001: OR
// op_code 0010: XOR
// op_code 0011: NOR
// op_code 0100: reserved (no operation)
// op_code 0101: ADD (signed)
//
// the remaining operations will be implemented in the next lab
module alu(X, Y, Z, op_code, equal, overflow, zero);

	// port definitions - customize for different bit widths
	input  wire [31:0] X;
	input  wire [31:0] Y;
	output wire [31:0] Z;
	input  wire [3:0] op_code;

	// output wires for special input flags
	output wire equal, overflow, zero;

	// output wires for each operation
	wire [31:0] and_out, or_out, xor_out, nor_out, add_out, sub_out, slt_out, srl_out, sll_out, sra_out;

	// instantiate the individual modules for each operation
	bN_and #(.N(32)) AND (.X(X), .Y(Y), .Z(and_out));
	bN_or #(.N(32)) OR (.X(X), .Y(Y), .Z(or_out));
	bN_xor #(.N(32)) XOR (.X(X), .Y(Y), .Z(xor_out));
	bN_adder #(.N(32)) ADD (.X(X), .Y(Y), .Z(add_out), .overflow(overflow));

	// note that there is no need to create a NOR module since we can just negate the output of the OR module
	assign nor_out = ~or_out;

	// instantiate the 16:1 mux module with the ALU operations and op code
	mux_16to1 #(.N(32)) ALU_MUX (.X0(and_out), .X1(or_out), .X2(xor_out), .X3(nor_out), .X4(0), .X5(add_out), .X6(0), .X7(0), .X8(0), .X9(0), .X10(0), .X11(0), .X12(0), .X13(0), .X14(0), .X15(0), .S(op_code), .Z(Z));

endmodule
`default_nettype wire // some Xilinx IP requires that the default_nettype be set to wire
