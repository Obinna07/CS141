`ifndef FSM_DEFINES
`define FSM_DEFINES

`define FETCH               4'b0000
`define DECODE              4'b0001
`define MEM_ADR             4'b0010
`define MEM_READ            4'b0011
`define MEM_WRITEBACK       4'b0100
`define MEM_WRITE           4'b0101
`define R_EXECUTE           4'b0110
`define ALU_R_WRITEBACK     4'b0111
`define BRANCH_EXECUTE      4'b1000
`define JTA_JUMP            4'b1010
`define MEM_READ_WAIT       4'b1011
`define I_EXECUTE           4'b1100
`define ALU_I_WRITEBACK		  4'b1101
`define JAL_RA_WRITE        4'b1110
`define WAIT_STATE          4'b1111

`endif
