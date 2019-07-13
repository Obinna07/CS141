`timescale 1ns / 1ps
`default_nettype none // helps catch typo related bugs

`include "alu_defines.v"
`include "fsm_defines.v"
`include "op_defines.v"
`include "funct_defines.v"

module controller   (
                        clk, op_code, funct, rst, mem2reg, reg_dst, IorD, pc_src, alu_srcB, alu_srcA, ir_wr, mem_wr, pc_wr, branch, reg_wr, alu_control
                    );

  input clk, rst;
  input [5:0] op_code, funct;

  output reg [1:0] alu_srcA, alu_srcB;
  output reg IorD, ir_wr, mem_wr, pc_wr, reg_wr;
  output reg [1 : 0] mem2reg, reg_dst, pc_src;

  // the branch control signal is 2-bits wide:
  // the 0th bit is set if we're doing a branch instruction, zero otherwise
  // the 1st bit is set if we're doing a BEQ, zero otherwise (for BNE)
  output reg [1 : 0] branch;

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
        pc_src <= 2'b00;
        ir_wr <= 1;                     // allow the IR to be written to load the new instruction
        pc_wr <= 1;                     // allow the PC to be written to be incremented

        reg_wr <= 0;
        mem_wr <= 0;
        branch <= 2'b00;

        next_state <= `DECODE;
      end

      // send instruction to assembler to decode
      // will need to wait a cycle to read from memory
      `DECODE : begin
        ir_wr <= 0;                     // prevent the IR from being rewritten before we're done with this instruction
        pc_wr <= 0;                     // prevent the PC from being rewritten since we've already incremented it

        // set up the ALU to add PC+4 and the shifted sign-extended immediate to calculate the branch target address
        alu_control <= `ALU_OP_ADD;
        alu_srcA <= 2'b11;
        alu_srcB <= 2'b11;

        // go to the state for R-type instructions
        if (op_code == `OP_RTYPE)
            next_state <= `R_EXECUTE;
        // go to the state for 'lw' and 'sw' instructions
        else if (op_code == `OP_LW || op_code == `OP_SW)
            next_state <= `MEM_ADR;
        // go to the state for the 'j' instructions
        else if (op_code == `OP_J)
            next_state <= `JTA_JUMP;
        // go to the state for the 'jal' instruction
        else if (op_code == `OP_JAL)
            next_state <= `JAL_RA_WRITE;
        // go to the state for 'beq' and 'bne' instructions
        else if (op_code == `OP_BEQ || op_code == `OP_BNE)
            next_state <= `BRANCH_EXECUTE;
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
        if (op_code == `OP_LW)
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
        reg_dst <= 2'b00;               // write the 'rt' register (NOT the 'rd' register, as in R-type instructions)
        mem2reg <= 2'b01;               // rewrite 'rt' with the data fetched from memory (NOT the ALU result, as in regular I-type instructions)
        reg_wr <= 1;                    // enable the register file to be rewritten

        //next_state <= `FETCH;           // we're done with this instruction, so fetch the next one
        next_state <= `WAIT_STATE;
      end

      // for 'sw' instructions: write the 'rt' register contents to the effective address in memory
      `MEM_WRITE : begin
        IorD <= 1;                      // use the effective address calculated by ALU (NOT from the PC)
        mem_wr <= 1;                    // enable the memory to be rewritten

        //next_state <= `FETCH;           // we're done with this instruction, so fetch the next one
        next_state <= `WAIT_STATE;
      end

      // configure the ALU op_code (alu_control) and arguments (srcA, srcB) based on what R-type instruction we're doing
      // the ALU is used and the result is stored in the ALU results register (alu_reg)
      `R_EXECUTE : begin
        // for most R-type instructions, the ALU uses the 'rs' register and 'rt' register as inputs
        if (funct == `FUNCT_AND) begin
          alu_control <= `ALU_OP_AND;
          alu_srcA <= 2'b01;                // select the 'rs' register from alu_srcA_mux
          alu_srcB <= 2'b00;                // select the 'rt' register from alu_srcB_mux
        end
        else if (funct == `FUNCT_OR) begin
          alu_control <= `ALU_OP_OR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_XOR) begin
          alu_control <= `ALU_OP_XOR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_NOR) begin
          alu_control <= `ALU_OP_NOR;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        // for shift R-type instructions, the ALU uses the 'rt' register and the 'shamt' field as inputs
        else if (funct == `FUNCT_SLL) begin
          alu_control <= `ALU_OP_SLL;
          alu_srcA <= 2'b10;                  // select the zero-extended 'shamt' from alu_srcA_mux
          alu_srcB <= 2'b00;                  // select the 'rt' register from alu_srcB_mux
        end
        else if (funct == `FUNCT_SRL) begin
          alu_control <= `ALU_OP_SRL;
          alu_srcA <= 2'b10;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_SRA) begin
          alu_control <= `ALU_OP_SRA;
          alu_srcA <= 2'b10;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_SLT) begin
          alu_control <= `ALU_OP_SLT;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_ADD) begin
          alu_control <= `ALU_OP_ADD;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        else if (funct == `FUNCT_SUB) begin
          alu_control <= `ALU_OP_SUB;
          alu_srcA <= 2'b01;
          alu_srcB <= 2'b00;
        end
        // for the 'jr' instruction, change the pc_next_reg to the 'rs' register output
        else if (funct == `FUNCT_JR) begin
          pc_wr <= 1;
          pc_src <= 2'b11;
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
        reg_dst <= 2'b01;           // write the result to 'rd' (NOT 'rt', as in I-type instructions)
        mem2reg <= 2'b00;           // write the ALU result to 'rd' (NOT the data fetched from memory, as in 'lw')
        reg_wr <= 1;                // enable the register file to write

        next_state <= `FETCH;   // we're done with this instruction, so get the next one
      end

      // configure the ALU op_code (alu_control) and arguments (srcA, srcB) based on what I-type instruction we're doing
      // the ALU is used and the result is stored in the ALU results register (alu_reg)
      `I_EXECUTE : begin
        alu_srcA <= 2'b01;      // use the 'rs' register as the first ALU argument
        alu_srcB <= 2'b10;      // use the sign-extended immediate as the second ALU argument

        if (op_code == `OP_ANDI)
            alu_control <= `ALU_OP_AND;
        else if (op_code == `OP_ORI)
            alu_control <= `ALU_OP_OR;
        else if (op_code == `OP_XORI)
            alu_control <= `ALU_OP_XOR;
        else if (op_code == `OP_SLTI)
            alu_control <= `ALU_OP_SLT;
        else if (op_code == `OP_ADDI)
            alu_control <= `ALU_OP_ADD;

        // if we somehow get an op_code that doesn't match these, just do an 'ori' operation
        else
            alu_control <= `ALU_OP_OR;

        next_state <= `ALU_I_WRITEBACK;
      end

      // subtract the 'rs' and 'rt' registers to decide whether or not we're branching ('beq' and 'bne')
      `BRANCH_EXECUTE : begin
        // subtract the registers to look at the 'zero' flag for branching
        alu_control <= `ALU_OP_SUB;
        alu_srcA <= 2'b01;    // get the 'rs' register from alu_srcA_mux
        alu_srcB <= 2'b00;    // get the 'rt' register from alu_srcB_mux

        // get the next PC input from the ALU output register
        pc_src <= 2'b01;

        // set the branch control signal based on whether we're doing a 'beq' or a 'bne'
        if (op_code == `OP_BEQ)
          branch <= 2'b11;
        else
          branch <= 2'b01;

        // wait a cycle to allow the branch to occur
        next_state <= `WAIT_STATE;
      end

      // write the result of an I-type instruction to the 'rt' register
      `ALU_I_WRITEBACK : begin
        reg_dst <= 2'b00;       // write the result to 'rt' (NOT 'rd', as in R-type instructions)
        mem2reg <= 2'b00;       // write the ALU result to 'rt' (NOT the data fetched from memory, as in 'lw')
        reg_wr <= 1;            // enable the register file to be rewritten

        // wait an extra state for the result to the be written to the register file
        next_state <= `WAIT_STATE;
      end

      // set the next PC target to the jump target address of a 'j' or 'jal' instruction
      `JTA_JUMP : begin
        pc_wr <= 1;             // allow the PC register to be rewritten
        pc_src <= 2'b10;        // tell the PC src mux to choose the jump target address this time

        reg_wr <= 0;            // stop the 'ra' register from being rewritten again if we're coming from `JAL_RA_WRITE

        // wait an extra state for the jump to occur
        next_state <= `WAIT_STATE;
      end

      // wait a cycle before fetching the next instruction
      `WAIT_STATE : begin
        reg_wr <= 0;            // prevent the register file from overwriting something
        IorD <= 0;
        branch <= 2'b00;
        next_state <= `FETCH;
      end

      // write the (PC + 4) ALU output to the $ra register
      `JAL_RA_WRITE : begin
        reg_dst <= 2'b10;       // allow the 'ra' register to be rewritten
        mem2reg <= 2'b10;       // use the (PC + 4) ALU output to write the 'ra' register with
        reg_wr <= 1;            // allow the register file to be edited

        next_state <= `JTA_JUMP;  // execute the rest of the jump with the JTA
      end

    endcase
  end
endmodule
