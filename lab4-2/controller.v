`timescale 1ns / 1ps
`default_nettype none // helps catch typo related bugs

// TODO:
// - assign binary strings to all FSM states in 'fsm_defines.v'

`include "alu_defines.v"
`include "fsm_defines.v"

module controller   (
                        clk, op_code, funct, rst, mem2reg, reg_dst, IorD, pc_src, alu_srcB, alu_srcA, ir_wr, mem_wr, pc_wr, branch, reg_wr, alu_control
                    );

  input clk, rst;
  input [5:0] op_code, funct;

  output reg [1:0] alu_srcA, alu_srcB;
  output reg mem2reg, reg_dst, IorD, pc_src, ir_wr, mem_wr, pc_wr, branch, reg_wr;

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

      // get new instruction and write to register file
      `FETCH : begin
        IorD <= 0;                      // get an instruction (not data) from memory
        alu_srcA <= 2'b00;              // select the PC register output as the first ALU argument
        alu_srcB <= 2'b01;              // select 4 [bytes] as the second ALU argument (to increment the PC by one word)
        alu_control <= `ALU_OP_ADD;     // prepare the ALU to increment the PC
        pc_src <= 0;
        ir_wr <= 1;                     // allow the IR to be written to load the new instruction
        pc_wr <= 1;                     // allow the PC to be written to be incremented
        
        next_state <= `DECODE;
      end

      // send instruction to assembler to decode
      // will need to wait a cycle to read from memory
      `DECODE : begin
        //alu_srcA <= 2'b00;
        //alu_srcB <= 2'b11;
        ir_wr <= 0;                     // prevent the IR from being rewritten before we're done with this instruction
        pc_wr <= 0;                     // prevent the PC from being rewritten since we've already incremented it

        // go to the state for R-type instructions
        if (op_code == 6'b000000)
            next_state <= `R_EXECUTE;
        // go to the state for 'lw' and 'sw' instructions
        else if (op_code == 6'b100011 || op_code == 6'b101011)
            next_state <= `MEM_ADR;
        // go to the state for regular I-type instructions ('addi', 'andi', etc.)
        else
            next_state <= `I_EXECUTE;
      end

      // use the ALU to calculate the effective address needed for a 'lw' or 'sw' instruction
      `MEM_ADR : begin
        alu_srcA <= 2'b01;              // use the 'rs' register for the first ALU argument
        alu_srcB <= 2'b10;              // use the sign extended immediate for the second ALU argument
        alu_control <= `ALU_OP_ADD;     // add 'rs' and the immediate together to calculate the effective address

        // if we're dealing with a 'lw' instruction, go to the state that deals with that
        if (op_code == 6'b100011)
          next_state <= `MEM_READ;

        // otherwise, this is a 'sw' instruction, so go to the other relevant state
        else
          next_state <= `MEM_WRITE;
      end

      // for 'lw' instructions: get the data at the effective address and store it in the data register
      `MEM_READ : begin
        IorD <= 1;                      // get a data address (calculated via the ALU, not the PC) from memory

        // go to a waiting state since the memory module needs an additional clock cycle to read
        next_state <= `MEM_READ_WAIT;
      end

      // for 'lw' instructions: wait an additional clock cycle for the memory module to read the data needed
      `MEM_READ_WAIT : begin
        next_state <= `MEM_WRITEBACK;
      end

      // for 'lw' instructions: write the data fetched from memory to the 'rt' register
      `MEM_WRITEBACK : begin
        reg_dst <= 0;                   // write the 'rt' register (NOT the 'rd' register, as in R-type instructions)
        mem2reg <= 1;                   // rewrite 'rt' with the data fetched from memory (NOT the ALU result, as in regular I-type instructions)
        reg_wr <= 1;                    // enable the register file to be rewritten

        next_state <= `FETCH;           // we're done with this instruction, so fetch the next one
      end

      // for 'sw' instructions: write the 'rt' register contents to the effective address in memory
      `MEM_WRITE : begin
        IorD <= 1;                      // use the effective address calculated by ALU (NOT from the PC)
        mem_wr <= 1;                    // enable the memory to be rewritten

        next_state <= `FETCH;           // we're done with this instruction, so fetch the next one
      end

      // configure the ALU op_code (alu_control) and arguments (srcA, srcB) based on what R-type instruction we're doing
      // the ALU is used and the result is stored in the ALU results register (alu_reg)
      `R_EXECUTE : begin
        // for most R-type instructions, the ALU uses the 'rs' register and 'rt' register as inputs
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
        // for shift R-type instructions, the ALU uses the 'rt' register and the 'shamt' field as inputs
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

        next_state <= `ALU_R_WRITEBACK;
      end

      // write the result of an R-type instruction to the destination register ('rd')
      `ALU_R_WRITEBACK : begin
        reg_dst <= 1;           // write the result to 'rd' (NOT 'rt', as in I-type instructions)
        mem2reg <= 0;           // write the ALU result to 'rd' (NOT the data fetched from memory, as in 'lw')
        reg_wr <= 1;            // enable the register file to write

        next_state <= `FETCH;   // we're done with this instruction, so get the next one
      end

      // configure the ALU op_code (alu_control) and arguments (srcA, srcB) based on what I-type instruction we're doing
      // the ALU is used and the result is stored in the ALU results register (alu_reg)
      `I_EXECUTE : begin
        alu_srcA <= 2'b01;      // use the 'rs' register as the first ALU argument
        alu_srcB <= 2'b11;      // use the sign-extended immediate as the second ALU argument

        if (op_code == 6'b001100)
            alu_control <= `ALU_OP_AND;
        else if (op_code == 6'b001101)
            alu_control <= `ALU_OP_OR;
        else if (op_code == 6'b001110)
            alu_control <= `ALU_OP_XOR;
        else if (op_code == 6'b001010)
            alu_control <= `ALU_OP_SLT;
        else if (op_code == 6'b001000)
            alu_control <= `ALU_OP_ADD;

        // if we somehow get an op_code that doesn't match these, just do an 'ori' operation
        else
            alu_control <= `ALU_OP_OR;

        next_state <= `ALU_I_WRITEBACK;
      end

      /*
      `BRANCH : begin
        alu_srcA <= 2'b01;
        alu_srcB <= 2'b00;
        pc_src <= 1;
        branch <= 1;
        next_state <= `FETCH;
      end
      */

      // write the result of an I-type instruction to the 'rt' register
      `ALU_I_WRITEBACK : begin
        reg_dst <= 0;           // write the result to 'rt' (NOT 'rd', as in R-type instructions)
        mem2reg <= 0;           // write the ALU result to 'rt' (NOT the data fetched from memory, as in 'lw')
        reg_wr <= 1;            // enable the register file to be rewritten

        next_state <= `FETCH;   // we're done with this instruction, so get the next one
      end

    endcase
  end
endmodule
