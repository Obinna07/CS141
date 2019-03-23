`timescale 1ns / 1ps
`include "alu_defines.v"

// testbench for the full 32-bit ALU module alu()
module test_alu;

    // input registers
    reg signed [31:0] X, Y;
    reg [3:0] op_code;

    // output wires
    wire signed [31:0] Z;

    // note that since we only test one operation at a time, we only need to check one overflow bit (we use one for each operation in the actual ALU)
    wire equal, overflow, zero;

    // other registers/variables
    integer errors = 0;     // total number of errors testbench finds
    integer delay = 200;    // time to delay before each operation test
    reg o_bit;              // overflow bit to test against for ADD and SUB operations
    reg [1 : 0] z_bit;      // bits to test against ZERO flag (setting it to 2 means we're *not* testing for ZERO)
    reg [1 : 0] e_bit;      // bits to test against EQUAL flag (setting it to 2 means we're *not* testing for EQUAL)

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

        // initialize registers
        z_bit = 2;
        e_bit = 2;

        // test cases for AND operation
        op_code = 4'b0000;
        X = 8'b00010001; Y = 8'b00010000;                       #(delay);
        X = 2 ** 30 + 2 ** 29; Y = 2 ** 31 + 2 ** 30 + 2 ** 29; #(delay);

        // test cases for OR operation
        op_code = 4'b0001;
        X = 8'b10101010; Y = 8'b01010101;   #(delay);
        X = 8'b11111111; Y = 8'b00000000;   #(delay);

        // test cases for XOR operation
        op_code = 4'b0010;
        X = 8'b10001001; Y = 8'b01110110;   #(delay);
        X = 8'b10000001; Y = 8'b10000000;   #(delay);

        // test cases for NOR operation
        op_code = 4'b0011;
        X = 8'b10101010; Y = 8'b01010101;   #(delay);
        X = 8'b11111001; Y = 8'b11111111;   #(delay);

        // test cases for ADD operation
        op_code = 4'b0101;
        o_bit = 0;  // test cases that should set the overflow bit low
        X = 2 ** 28; Y = 2 ** 29 + 2 ** 28; #(delay);
        X = 1000003; Y = 1000007;           #(delay);
        X = -123456; Y = 654321;            #(delay);
        X = -(2 ** 30); Y = -(2 ** 30);     #(delay);

        //test cases for SLT function
        op_code = 4'b0111;
        X = 2**30; Y = 2**29; #(delay);
        X = 8'b11111110; Y = 8'b10010010; #(delay);
        X = 8'b01111110; Y = 8'b10010010; #(delay);
        X = 8'b11111110; Y = 8'b01010010; #(delay);

        o_bit = 1;  // test cases that should set the overflow bit high
		X = 2 ** 30; Y = 2 ** 30;           #(delay);
        X = -(2 ** 31); Y = -(2 ** 31);     #(delay);

        // test cases for the SUB operation
        op_code = 4'b0110;
        o_bit = 0;  // test cases that should set the overflow bit low
        X = 2 ** 30; Y = 2 ** 30;           #(delay);
        X = 2 ** 30; Y = -(2 ** 30) + 1;    #(delay);
        X = 123456789; Y = 987654321;       #(delay);
        X = 2; Y = -3;                      #(delay);
        X = -3; Y = 10007;                  #(delay);

        o_bit = 1;  // test cases that should set the overflow bit high
        X = 2 ** 30; Y = -(2 ** 31) + 1;    #(delay);
        X = -1; Y = -(2 ** 31);             #(delay);

        // test cases for the SRL operation
        op_code = 4'b1000;
		X = 100; Y = 2;                     #(delay);
		X = 12; Y = 2;                      #(delay);
        X = -8; Y = 15;                     #(delay);
		X = 12; Y = 17;                     #(delay);
        X = -15; Y = 4;                     #(delay);

        // test cases for the SLL operation
        op_code = 4'b1001;
		X = 100; Y = 2;                     #(delay);
		X = 12; Y = 2;                      #(delay);
        X = -8; Y = 15;                     #(delay);
		X = 12; Y = 17;                     #(delay);
        X = -15; Y = 4;                     #(delay);

        // test cases for the SRA operation
        op_code = 4'b1010;
        X = 1234567; Y = 3;                 #(delay);
        X = -123456; Y = 10;                #(delay);
        X = 0; Y = 15;                      #(delay);
        X = -(2 * 31); Y = 31;              #(delay);

        // test cases for the ZERO flag
        z_bit = 0;  // test cases that should set the ZERO flag low
        op_code = 4'b0001;
        X = 8'b10101010; Y = 8'b01010101;   #(delay);   // X = ~Y, so X OR Y should set the ZERO flag low (Z != 0)
        op_code = 4'b0101;
        X = 12005; Y = -12004;              #(delay);   // X + Y = 1, so ZERO should be set low (Z != 0)

        z_bit = 1;  // test cases that should set the ZERO flag high (NOTE: we have at least one test case for each operation)
        op_code = 4'b0000;
        X = 8'b00000000; Y = 8'b10101110;   #(delay);   // X = 0, so X AND Y = 0 and ZERO should go high

        op_code = 4'b0001;  // OR
        X = 8'b00000000; Y = 8'b00000000;   #(delay);

        op_code = 4'b0010;  // XOR
        X = 8'b10010110; Y = 8'b10010110;   #(delay);

        op_code = 4'b0110;  // SUB
        X = -3; Y = -3;                      #(delay);

        op_code = 4'b0111;  // SLT
        X =   (2 ** 30); Y =   (2 ** 20);   #(delay);

        op_code = 4'b1000;  // SRL
        X = 8'b00000110; Y = 4;              #(delay);

        op_code = 4'b1001;  // SLL
        X = 8'b01100000; Y = 30;             #(delay);

        op_code = 4'b1010;  // SRA
        X = 8'b00000110; Y = 4;             #(delay);

        op_code = 4'b0101;  // ADD
        X = -9999; Y = 9999;                #(delay);   // X = -Y, so X ADD Y = 0 and ZERO should go high

        // reset the zero bits so we don't test for ZERO later on
        z_bit = 2;

        // test cases for EQUAL flag
        e_bit = 0;  // test cases that should set the EQUAL flag low
        X = 0; Y = 1;                                   #(delay);
        X = -(2 ** 15); Y = 2 ** 15;                    #(delay);
        X = 2 ** 27 + 2 ** 3; Y = -(2 ** 27 + 2 ** 3);  #(delay);
        X = (2 ** 31) - 1; Y = -(2 ** 31);              #(delay);

        e_bit = 1;  // test cases that should set the EQUAL flag high
        X = 0; Y = 0;                                   #(delay);
        X = 2 ** 30; Y = 2 ** 30;                       #(delay);
        X = -(2 ** 31); Y = -(2 ** 31);                 #(delay);
        X = 8'b10101010; Y = 8'b10101010;               #(delay);

        // reset the equal bits so we don't test for EQUAL later on
        e_bit = 2;

        $display("This test generated %d errors.", errors);
        $finish;
    end

    // an 'always' block is executed whenever any of the variables in the sensitivity
    // list are changed (X or Y in this case)
    always @(X, Y) begin : op_test
        #(delay / 2);

        $display("Performing op_code %b on inputs X = %d, Y = %d", op_code, X, Y);

        // check if the ZERO flag is set as it should be for the special cases (when z_bit !== 2)
        if (z_bit !== 2) begin
            if (zero !== z_bit) begin
                $display("ERROR: ZERO flag was set to %b when it should be %b; op_code = %b, X = %b, Y = %b, Z = %b", zero, z_bit, op_code, X, Y, Z);
                errors = errors + 1;
            end

            // since we're only testing for the ZERO flag, break out of this block so we don't re-test the other functions
            disable op_test;
        end

        // check if the EQUAL flag is set as it should be (only when e_bit !== 2)
        if (e_bit !== 2) begin
            if (equal !== e_bit) begin
                $display("ERROR: EQUAL flag was set to %b when it should be %b; X = %d, Y = %d", equal, e_bit, X, Y);
                errors = errors + 1;
            end

            disable op_test;
        end

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

            `ALU_OP_SUB: begin
                if (Z !== X - Y) begin
                    $display("ERROR: Expected %d - %d = %d (overflow %b), but outputted %d (overflow %b) instead", X, Y, (X - Y), o_bit, Z, overflow);
                    errors = errors + 1;
                end
            end

            `ALU_OP_SLT: begin
                if ((X < Y & Z !== 1) | (X > Y & Z !== 0)) begin
                    $display("ERROR: X = %d, Y = %d, but Z = (X < Y) = %b", X, Y, Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_SRL: begin
                if (Z !== (X >> Y)) begin
                    $display("ERROR: Expected %b >> %d = %b, but outputted %b instead", X, Y, (X >> Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_SLL: begin
                if (Z !== (X << Y)) begin
                    $display("ERROR: Expected %b >> %d = %b, but outputted %b instead", X, Y, (X << Y), Z);
                    errors = errors + 1;
                end
            end

            `ALU_OP_SRA: begin
                if (Z !== (X >>> Y)) begin
                    $display("ERROR: Expected %b >>> %d = %b, but outputted %b instead", X, Y, (X >>> Y), Z);
                    errors = errors + 1;
                end
            end

            default : begin
                // executes at default
                if (Z !== 32'd0) begin
                    $display("ERROR HAPPENED! invalid op code, Z was not zero, op_code = %b, X = %h, Y = %h, Z = %h", op_code, X, Y, Z);
                    errors = errors + 1;
                end
            end
        endcase

    end

endmodule
