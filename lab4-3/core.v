`timescale 1ns / 1ps
`default_nettype none // helps catch typo related bugs

module core (
              clk, rst, mem_addr0, mem_wr_data0, mem_rd_data0, mem_wr_ena0
            );

   // define input and output wires
   input wire clk, rst;
   input wire [31 : 0] mem_rd_data0;
   output wire [31 : 0] mem_addr0, mem_wr_data0;
   output wire mem_wr_ena0;

    // internal register-related wires
    wire [31 : 0] pc_reg_next, pc_reg_out;
    wire [31 : 0] instr;
    wire [31 : 0] data;
    wire [31 : 0] rf_rd1, rf1_reg_out;
    wire [31 : 0] rf_rd2, rf2_reg_out, mem2reg_mux_out;
    wire [31 : 0] srcA, srcB, alu_result, alu_reg_out;

    // 32-bit zero extension on the 'shamt' field of shift instructions
    wire [31 : 0] zero_extended_shamt;

    // perform sign extension on the immediate field if necessary (instruction bits 15 to 0)
    wire [31 : 0] sign_extended_imm;

    // multiply sign extended immediate by 4 for branch instructions
    wire [31 : 0] shifted_sign_extended_imm;

    // jump target address for J-type instructions
    wire [31 : 0] jump_target_address;

    // control wires
    wire pc_wr, ir_wr, reg_wr;
    wire IorD;
    wire pc_en;
	  wire [1 : 0] mem2reg, pc_src, reg_dst;
	  wire [1 : 0] alu_srcA, alu_srcB;
    wire [3 : 0] alu_control;

    wire [1 : 0] branch;

    wire [4 : 0] reg_dst_in;

    // zero flag for alu
    wire alu_zero;

    // enable the PC register when needed (the second half is for branch instructions; see the controller for details on branch[1 : 0])
    assign pc_en = pc_wr | (branch[0] & ~(branch[1] ^ alu_zero));

    // instantiate the following registers:
    // 1) instruction register (instr_reg)
    // 2) memory output (data) register (data_reg)
    // 3) register file output 1 register (rf1_reg)
    // 4) register file output 2 register (rf2_reg)
    // 5) ALU output register (alu_reg)
    // 6) program counter register (pc_reg)
    register #(.N(32)) instr_reg (.clk(clk), .rst(rst), .d(mem_rd_data0), .q(instr), .ena(ir_wr));
    register #(.N(32)) data_reg (.clk(clk), .rst(rst), .d(mem_rd_data0), .q(data), .ena(1'b1));
    register #(.N(32)) rf1_reg (.clk(clk), .rst(rst), .d(rf_rd1), .q(rf1_reg_out), .ena(1'b1));
    register #(.N(32)) rf2_reg (.clk(clk), .rst(rst), .d(rf_rd2), .q(rf2_reg_out), .ena(1'b1));
    register #(.N(32)) alu_reg (.clk(clk), .rst(rst), .d(alu_result), .q(alu_reg_out), .ena(1'b1));
    pc_register #(.N(32)) pc_reg (.clk(clk), .rst(rst), .d(pc_reg_next), .q(pc_reg_out), .ena(pc_en));

    // assign values to the 'shamt', immediate, and JTA wires
    assign zero_extended_shamt = {{27{1'b0}}, instr[10 : 6]};
    assign sign_extended_imm = {{16{instr[15]}}, instr[15 : 0]};
    assign shifted_sign_extended_imm = sign_extended_imm << 2;
    assign jump_target_address = { pc_reg_next[31 : 28], instr[25 : 0], 2'b00 };

    // instantiate the controller module for control signals
    controller controller (
        .clk(clk),
        .rst(rst),
        .op_code(instr[31 : 26]),
        .funct(instr[5 : 0]),
        .mem2reg(mem2reg),
        .reg_dst(reg_dst),
        .IorD(IorD),
        .pc_src(pc_src),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .ir_wr(ir_wr),
        .mem_wr(mem_wr_ena0),
        .pc_wr(pc_wr),
        .branch(branch),
        .reg_wr(reg_wr),
        .alu_control(alu_control)
    );

    // instantiate register_file
    register_file #(.N(32)) register_file (
        .clk(clk),
        .rst(rst),
        .rd_addr0(instr[25 : 21]),              // get the 'rs' register from the register file (instruction bits 25 to 21)
        .rd_addr1(instr[20 : 16]),              // get the 'rt' register from the register file (instruction bits 20 to 16)
        .wr_addr(reg_dst_in),                   // address of register to be written to
        .rd_data0(rf_rd1),                      // route the 'rs' register data to an intermediate register
        .rd_data1(rf_rd2),                      // route the 'rt' register data to an intermediate register
        .wr_data(mem2reg_mux_out),              // data to overwrite the selected reigster with
        .wr_ena(reg_wr)                         // enable switch to allow overwriting
    );

    // 4:1 mux to determine first input to the ALU:
    // 00: PC register (ex. to increment the PC each cycle)
    // 01: 'rs' register output (for most R-type instructions)
    // 10: zero-extended 'shamt' field for shift instructions
    // 11: PC+4 output (for branch instructions)
    mux_4to1 #(.N(32)) alu_srcA_mux (
        .X0(pc_reg_out),
        .X1(rf1_reg_out),
        .X2(zero_extended_shamt),
        .X3(pc_reg_next),
        .S(alu_srcA),
        .Z(srcA)
    );

    // 4:1 mux to determine the second input to the ALU:
    // 00: 'rt' register output (for R-type instructions, including shifts)
    // 01: 4 to increment the PC by 4 bytes/1 word
    // 10: sign-extended immediate field for most I-type instructions
    // 11: sign-extended immediate field multiplied by 4 for branch instructions
    mux_4to1 #(.N(32)) alu_srcB_mux (
        .X0(rf2_reg_out),
        .X1(4),
        .X2(sign_extended_imm),
        .X3(shifted_sign_extended_imm),
        .S(alu_srcB),
        .Z(srcB)
    );

    alu #(.N(32)) mips_alu (
        .x(srcA),              // first input to the ALU is the "alu_srcA" wire
        .y(srcB),              // second input is the "alu_srcB" wire
        .op_code(alu_control),          // op_code for the ALU
        .z(alu_result),            // output of the ALU goes to the ALU register
        .equal(),
        .zero(alu_zero),
        .overflow()
    );

    // use a 2:1 mux to select the memory fetch address from either the PC (ex. R-type instructions) or the ALU (ex. effective address from 'lw')
    mux_2to1 #(.N(32)) address_mux (
        .X(pc_reg_out),
        .Y(alu_reg_out),
        .S(IorD),
        .Z(mem_addr0)                   // address to fetch instructions/data with from the memory module
    );

    // 4:1 mux to select sources for the next instruction address
    // 00: direct ALU output
    // 01: ALU register output
    // 10: jump target address for J-type instructions
    // 11: address stored in the 'rs' register for the 'jr' instruction
    mux_4to1 #(.N(32)) pc_src_mux (
        .X0(alu_result),
        .X1(alu_reg_out),
        .X2(jump_target_address),
        .X3(rf1_reg_out),
        .S(pc_src),
        .Z(pc_reg_next)
    );

    // 4:1 mux that outptuts address of register to write to
    // 00: the 'rt' register for I-type instructions
    // 01: the 'rd' register for an R-type instruction
    // 10: the $ra/$31 register (for 'jal' instruction)
    mux_4to1 #(.N(5)) reg_dst_mux (
        .X0(instr[20:16]),
        .X1(instr[15:11]),
        .X2(5'b11111),
        .X3(),
        .S(reg_dst),
        .Z(reg_dst_in)
    );

    // 4:1 mux that outputs data to overwirte destination register with
    mux_4to1 #(.N(32)) mem2reg_mux (
        .X0(alu_reg_out),
        .X1(data),
        .X2(pc_reg_out),              // TODO: should this be from PC or PC`? why does this PC get incremented before we save to $ra for 'jal'?
        .X3(),
        .S(mem2reg),
        .Z(mem2reg_mux_out)
    );

    assign mem_wr_data0 = rf2_reg_out;

endmodule
