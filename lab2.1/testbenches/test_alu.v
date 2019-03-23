`timescale 1ns / 1ps
`include "alu_defines.v"

// testbench for the full 32-bit ALU module alu()
module test_alu;

    // input registers
    reg signed [31:0] X, Y;
    reg [3:0] op_code;
    reg o_bit;          // overflow bit to test against for ADD operation

    integer errors = 0;

    // output wires
    wire signed [31:0] Z;
    wire equal, overflow, zero;

    // instantiate the ALU module as the uut
    alu uut (
        .X(X),
        .Y(Y),
        .Z(Z),
        .op_code(op_code),
        .equal(equal),
        .overflow(overflow),
        .zero(zero)
    );

    initial begin
        // create waveform file to analyze if needed
        $dumpfile("alu.vcd");
        $dumpvars(0, uut);

        // test cases for AND operation
        op_code = 4'b0000;
        X = 8'b00010001; Y = 8'b00010000;                       #200;
        X = 2 ** 30 + 2 ** 29; Y = 2 ** 31 + 2 ** 30 + 2 ** 29; #200;

        // test cases for OR operation
        op_code = 4'b0001;
        X = 8'b10101010; Y = 8'b01010101;   #200;
        X = 8'b11111111; Y = 8'b00000000;   #200;

        // test cases for XOR operation
        op_code = 4'b0010;
        X = 8'b10001001; Y = 8'b01110110;   #200;
        X = 8'b10000001; Y = 8'b10000000;   #200;

        // test cases for NOR operation
        op_code = 4'b0011;
        X = 8'b10101010; Y = 8'b01010101;   #200;
        X = 8'b11111001; Y = 8'b11111111;   #200;

        // test cases for ADD operation
        op_code = 4'b0101;
        o_bit = 0;  // test cases that should set the overflow bit low
        X = 2 ** 28; Y = 2 ** 29 + 2 ** 28; #200;
        X = 1000003; Y = 1000007;           #200;
        X = -123456; Y = 654321;            #200;
        X = -(2 ** 30); Y = -(2 ** 30);     #200;

        o_bit = 1;  // test cases that should set the overflow bit high
		X = 2 ** 30; Y = 2 ** 30;           #200;
        X = -(2 ** 31); Y = -(2 ** 31);     #200;

        $display("This test generated %d errors.", errors);
        $finish;
    end

    // an 'always' block is executed whenever any of the variables in the sensitivity
    // list are changed (X, Y, or op_code in this case)
    always @(X, Y) begin
        #100;

        // check if the operation being tested was done correctly
        case (op_code)
            // only executes when the op code is 0000 (AND), etc.
            `ALU_OP_AND : begin
                if(Z !== (X & Y)) begin
                    $display("ERROR: Expected %h AND %h = %h, but outputted %h instead.", X, Y, (X & Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_XOR : begin
                if (Z !== (X ^ Y)) begin
                    $display("ERROR: Expected %h XOR %h = %h, but outputted %h instead", X, Y, (X ^ Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_OR : begin
                if (Z !== (X | Y)) begin
                    $display("ERROR: Expected %h OR %h = %h, but outputted %h instead", X, Y, (X | Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_NOR: begin
                if (Z !== ~(X | Y)) begin
                    $display("ERROR: Expected %h NOR %h = %h, but outputted %h instead", X, Y, ~(X | Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_ADD: begin
                if (Z !== (X + Y) | overflow !== o_bit) begin
                    $display("ERROR! Expected %d + %d = %d (overflow %b), but outputted %d (overflow %b) instead", X, Y, (X + Y), o_bit, Z, overflow);
                    errors = errors + 1;
                end
            end

            /* `ALU_OP_SUB: begin
                if (Z !== X - Y) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not X - Y, op_code = %b, X = %d, Y = %d, Z = %d", op_code, X, Y, Z);
                end
            end
            `ALU_OP_SLT: begin
                if (Z !== X ^ Y) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not X XOR Y, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                end
            end
            `ALU_OP_SRL: begin
                if (Z !== X ^ Y) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not X XOR Y, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                end
            end
            `ALU_OP_SLL: begin
                if (Z !== X ^ Y) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not X XOR Y, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                end
            end
            `ALU_OP_SRA: begin
                if (Z !== X ^ Y) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not X XOR Y, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                end
            end */

            default : begin
                // executes at default
                if (Z !== 32'd0) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not zero, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                end
            end
        endcase

    end

endmodule
