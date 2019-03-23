`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
//
// CS 141 - Spring 2019
// Module Name:    alu
// Author(s): Obinna Ejikeme, Ricky Williams, Toba Olokungbemi
// Description: CS 141 programming assignment 2 (part 2)
//
// TODO:
// - (DONE) implement the carry lookahead adder (ADD) to replace bN_ripple_adder(); write the testbench for the lookahead carry adder
// - (DONE) implement signed subtraction (SUB, with OVERFLOW flag); write the testbench for signed subtraction (add special cases for OVERFLOW flag)
// - (DONE) implement signed Set Less Than (SLT, requires signed subtraction); write the testbench for Set Less Than
// - (DONE) implement logical shift right (SRL); write the testbench for logical shift right
// - (DONE) implement logical shift left (SLL); write the testbench for logical shift left
// - (DONE) implement arithmetic shift right (SRA); write the testbench for arithmetic shift right
// - (DONE) implement the ZERO flag; add special cases to ALU testbench to test ZERO flag
// - (DONE) implement the EQUAL flag; add special cases to ALU testbench to test EQUAL flag
// - write description of testing methodology
// - draw sketches for SLT, SLL, SRL, ADD, SUB, and SRA circuits
//
//////////////////////////////////////////////////////////////////////////////////

`include "alu_defines.v"

// create the 32-bit ALU with the following operations and op_codes:
//
// op_code 0000: AND
// op_code 0001: OR
// op_code 0010: XOR
// op_code 0011: NOR
// op_code 0101: ADD (signed)
// op_code 0110: SUB (signed)
// op_code 0111: SLT (Set Less Than, signed)
// op_code 1000: SRL (Right Logical Shift)
// op_code 1001: SLL (Left Logical Shift)
// op_code 1010: SRA (Right Arithmetic Shift)
//
// note that op_codes 0100, 1011 --> 1111 are all reserved (no operation)
//
// the ALU also outputs the following flags:
// 		- EQUAL (set if the inputs are equal)
//		- OVERFLOW (set if overflow occurs in ADD or SUB operations)
//		- ZERO (set if output of operation is 0)

module alu(X, Y, Z, op_code, equal, overflow, zero);

	// port definitions - customize for different bit widths
	input  wire [31:0] X;
	input  wire [31:0] Y;
	output wire [31:0] Z;
	input  wire [3:0] op_code;

	// output wires for special input flags
	output wire equal, overflow, zero;
	output wire add_overflow, sub_overflow;

	// output wires for each operation
	wire [31:0] and_out, or_out, xor_out, nor_out, add_out, sub_out, slt_out, srl_out, sll_out, sra_out;

	// instantiate the individual modules for each operation (NOTE: operations AND, OR, XOR, and NOR can be used with variable bit-lengths)
	bN_and #(.N(32)) AND (.X(X), .Y(Y), .Z(and_out));
	bN_or #(.N(32)) OR (.X(X), .Y(Y), .Z(or_out));
	bN_xor #(.N(32)) XOR (.X(X), .Y(Y), .Z(xor_out));
	b32_cla ADD (.X(X), .Y(Y), .C_in(0), .Z(add_out), .overflow(add_overflow));
	b32_cla_sub SUB (.X(X), .Y(Y), .Z(sub_out), .overflow(sub_overflow));
	b32_SLT SLT (.X(X), .Y(Y), .A(slt_out));
	b32_SRL SRL (.X(X), .S(Y), .Z(srl_out));
	b32_SLL SLL (.X(X), .S(Y), .Z(sll_out));
	b32_SRA SRA (.X(X), .S(Y), .Z(sra_out));

	// note that there is no need to create a NOR module since we can just negate the output of the OR module
	assign nor_out = ~or_out;

	// instantiate the 16:1 mux module with the ALU operations and op code
	mux_16to1 #(.N(32)) ALU_MUX (.X0(and_out), .X1(or_out), .X2(xor_out), .X3(nor_out), .X4(0), .X5(add_out), .X6(sub_out), .X7(slt_out), .X8(srl_out), .X9(sll_out), .X10(sra_out), .X11(0), .X12(0), .X13(0), .X14(0), .X15(0), .S(op_code), .Z(Z));

	// set the OVERFLOW bit based on overflow in the ADD and SUB operations
	assign overflow = add_overflow | sub_overflow;

	// set the ZERO flag high if Z == 0; we just AND all the inverted bits of Z
	assign zero = &(~Z);

	// set the EQUAL flag high if X == Y; perform ~(X XOR Y) and AND all the bits
	assign equal = &(~xor_out);

endmodule
`default_nettype wire // some Xilinx IP requires that the default_nettype be set to wire
