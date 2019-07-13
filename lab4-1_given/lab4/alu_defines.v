`ifndef ALU_DEFINES
`define ALU_DEFINES

`define ALU_OP_WIDTH 4
`define ALU_OP_AND 4'b0000
`define ALU_OP_OR  4'b0001
`define ALU_OP_XOR 4'b0010
`define ALU_OP_NOR 4'b0011
`define ALU_OP_SLT 4'b0100
`define ALU_OP_SLL 4'b0101
`define ALU_OP_SRL 4'b0110
`define ALU_OP_ADD 4'b0111
`define ALU_OP_SUB 4'b1000
`define ALU_OP_SRA 4'b1011

`define SRCA_REG 2'b00
`define SRCA_INCPC 2'b01
`define SRCA_SHIFT 2'b10

`define SRCB_REG 2'b00
`define SRCB_INCPC 2'b01
`define SRCB_SHIFT 2'b10

`define FUNC_ADD 6'b100000
`define FUNC_SUB 6'b100010
`define FUNC_AND 6'b100100
`define FUNC_OR 6'b100101
`define FUNC_XOR 6'b100110
`define FUNC_NOR 6'b100111
`define FUNC_SLL 6'b000000
`define FUNC_SRA 6'b000011
`define FUNC_SRL 6'b000010
`define FUNC_SLT 6'b101010
`define FUNC_JR 6'b001000

`define OP_RTYPE 6'b000000
`define OP_ADDI 6'b001000
`define OP_ANDI 6'b001100
`define OP_ORI 6'b001101
`define OP_XORI 6'b001110
`define OP_SLTI 6'b001010
`define OP_BEQ 6'b000100
`define OP_BNE 6'b000101
`define OP_J 6'b000010
`define OP_JAL 6'b000011
`define OP_LW 6'b100011
`define OP_SW 6'b101011

`define STATE_FETCH 4'b0000
`define STATE_DECODE 4'b0001
`define STATE_EXECUTE 4'b0110
`define STATE_WRITEBACK 4'b0111
`define STATE_FETCHB 4'b1000

`define REG_ZERO 5'b00000
`define REG_AT 5'b00001
`define REG_V0 5'b00010
`define REG_V1 5'b00011
`define REG_A0 5'b00100
`define REG_A1 5'b00101
`define REG_A2 5'b00110
`define REG_A3 5'b00111
`define REG_T0 5'b01000
`define REG_T1 5'b01001
`define REG_T2 5'b01010
`define REG_T3 5'b01011
`define REG_T4 5'b01100
`define REG_T5 5'b01101
`define REG_T6 5'b01110
`define REG_T7 5'b01111
`define REG_S0 5'b10000
`define REG_S1 5'b10001
`define REG_S2 5'b10010
`define REG_S3 5'b10011
`define REG_S4 5'b10100
`define REG_S5 5'b10101
`define REG_S6 5'b10110
`define REG_S7 5'b10111
`define REG_T8 5'b11000
`define REG_T9 5'b11001
`define REG_K0 5'b11010
`define REG_K1 5'b11011
`define REG_GP 5'b11100
`define REG_SP 5'b11101
`define REG_FP 5'b11110
`define REG_RA 5'b11111

`endif
