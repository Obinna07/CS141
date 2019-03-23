`timescale 1ns / 1ps

// testbench for the 1-bit adder module b1_adder()
module test_b1_adder;
    // input registers
    reg X, Y, C_in;

    // output wires
    wire Z, C_out;
    
    b1_adder uut (X, Y, C_in, Z, C_out);

    initial begin
        $monitor ($time, " X = %b, Y = %b, C_in = %b, Z = %b, C_out = %b", X, Y, C_in, Z, C_out);

        X = 0; Y = 0; C_in = 0; #10;    // delay 10 units to allow values to propogate
        X = 1; Y = 0; C_in = 0; #10;
        X = 0; Y = 1; C_in = 0; #10;
        X = 1; Y = 1; C_in = 0; #10;
        X = 0; Y = 0; C_in = 1; #10;
        X = 1; Y = 0; C_in = 1; #10;
        X = 0; Y = 1; C_in = 1; #10;
        X = 1; Y = 1; C_in = 1; #10;

        $finish; #10;
    end
endmodule
