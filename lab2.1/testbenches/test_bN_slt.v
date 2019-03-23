`timescale 1ns / 1ps

// testbench for the 1-bit adder module b1_adder()
module test_bN_slt;
    // input registers
    reg X, Y;

    // output wires
    wire Z;
    
    b1_adder uut (X, Y, Z);

    initial begin
        $monitor ($time, " X = %b, Y = %b, Z = %b", X, Y, Z);

        X = 0; Y = 0; #10;      // delay 10 units to allow values to propogate
        X = 1; Y = 0; #10;
        X = 0; Y = 1; #10;
        X = 1; Y = 1; #10;
        X = 32d'25 Y = 32d'5
        X = 32d'25 Y = -32d'5

        $finish; #10;
    end
endmodule
