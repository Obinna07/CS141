`timescale 1ns / 1ps
`default_nettype none // helps catch typo related bugs

`include "alu_defines.v"

// define states
`define FETCH               4'b0000
`define DECODE              4'b0001
`define MemAdr              4'b0010
`define MemRead             4'b0011
`define MemWriteback        4'b0100
`define MemWrite            4'b0101
`define EXECUTE             4'b0110
`define AluWriteback        4'b0111
`define BRANCH              4'b1000
`define AddiWriteback       4'b1001          // deleted AddiExecute because it was the same as MemAdr
`define JUMP                4'b1010
`define WAIT_MemRead        4'b1011
// `define WAIT_MemAdr         4'b1100
// `define WAIT_			          4'b1101
// // `define WAIT_BRANCH         4'b1101
// // `define WAIT_AddiExecute    4'b1110

module controller (clk, op_code, funct, rst, mem2reg, reg_dst, IorD, pc_src, alu_srcB, alu_srcA, ir_wr, mem_wr, pc_wr, branch, reg_wr, alu_control);

  input clk, rst;
  input [5:0] op_code, funct;

  output reg [1:0] alu_srcA, alu_srcB;
  output reg       mem2reg, reg_dst, IorD, pc_src, ir_wr, mem_wr, pc_wr, branch, reg_wr;

  output reg [3 : 0] alu_control;

  reg [3:0] state, next_state;

  always @(posedge clk or posedge rst) begin
    if (rst)
      state <= `FETCH;
    else
      state <= next_state;
  end

  always @* begin
    case (state)

      // get new instruction and right to register file
      `FETCH : begin
        IorD <= 0;
        alu_srcA <= 2'b00;
        alu_srcB <= 2'b01;
        alu_control <= `ALU_OP_ADD;
        pc_src <= 0;
        ir_wr <= 1;
        pc_wr <= 1;
        next_state <= `DECODE;
      end

      // send instruction to assembler to decode
      // will need to wait a cycle to read from memory
      `DECODE : begin
        alu_srcA <= 2'b00;
        //alu_srcB <= 2'b11;
        ir_wr <= 0;
        pc_wr <= 0;
        if (op_code == 6'b000000)
          next_state <= `EXECUTE;
        else
          next_state <= `MemAdr;
      end

      `MemAdr : begin
        alu_srcA <= 2'b01;
        alu_srcB <= 2'b10;
        // check if it's load word
        if (op_code == 35)
          next_state <= `MemRead;
        // or if it's store word
        else if (op_code == 43)
          next_state <= `MemWrite;
        // or if it's addi (because MemAdr and AddiExecute or identical states)
        else if (op_code == 6'b001000)
          next_state <= `AddiWriteback;
      end

      `MemRead : begin
        IorD <= 1;
        next_state <= `WAIT_MemRead;
      end

      `MemWriteback : begin
        reg_dst <= 0;
        mem2reg <= 1;
        reg_wr <= 1;
        next_state <= `FETCH;
      end

      `MemWrite : begin
        IorD <= 1;
        mem_wr <= 1;
        next_state <= `FETCH;
      end

      `EXECUTE : begin

        if (funct == 6'b100100) begin
          alu_control <= `ALU_OP_AND;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b100101) begin
          alu_control <= `ALU_OP_OR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b100110) begin
          alu_control <= `ALU_OP_XOR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b100111) begin
          alu_control <= `ALU_OP_NOR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b000000) begin
          alu_control <= `ALU_OP_SLL;
          alu_srcA <= 2'b10;
          alu_srcB <= 2'b10;
        end
        else if (funct == 6'b000010) begin
          alu_control <= `ALU_OP_SRL;
          alu_srcA <= 2'b10;
          alu_srcB <= 2'b10;
        end
        else if (funct == 6'b000011) begin
          alu_control <= `ALU_OP_SRA;
          alu_srcA <= 2'b10;
          alu_srcB <= 2'b10;
        end
        else if (funct == 6'b101010) begin
          alu_control <= `ALU_OP_SLT;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b100000) begin
          alu_control <= `ALU_OP_ADD;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == 6'b100010) begin
          alu_control <= `ALU_OP_SUB;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else begin
          alu_control <= `ALU_OP_OR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end

        next_state <= `AluWriteback;
      end

      `AluWriteback : begin
        reg_dst <= 1;
        mem2reg <= 0;
        reg_wr <= 1;
        next_state <= `FETCH;
      end

      `BRANCH : begin
        alu_srcA <= 2'b01;
        alu_srcB <= 2'b00;
        pc_src <= 1;
        branch <= 1;
        next_state <= `FETCH;
      end

      // `AddiExecute : begin
      //   alu_srcA <= 1;
      //   alu_srcB <= 2'b10;
      //   next_state <= `AddiWriteback;
      // end

      `AddiWriteback : begin
        reg_dst <= 0;
        mem2reg <= 0;
        reg_wr <= 1;
        next_state <= `FETCH;
      end

      // `WAIT_DECODE : begin
      //   // check if instrution op code is for load/ store word (also go here for addi)
      //   if (op_code == 35 | op_code == 43)
      //     next_state <= `MemAdr;
      //   else if (op_code == 0)                    // check if it's an r-type instruction
      //     next_state <= `EXECUTE;
      //   else if (op_code == 6'b000100)            // check if it's beq (branch if equal)
      //     next_state <= `BRANCH;
      //   else if (op_code == 6'b000010)            // check if it's a jump instruction
      //     next_state <= `JUMP;
      // end

      `WAIT_MemRead : begin
        next_state <= `MemWriteback;
      end
      //
      // `WAIT_BRANCH : begin
      // end
      //
      // `WAIT_AddiExecute : begin
      // end
      //
      // `WAIT_JUMP : begin
      // end
    endcase
  end
endmodule
