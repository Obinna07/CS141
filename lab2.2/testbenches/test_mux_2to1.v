`timescale 1ns / 1ps

// testbench for the 2:1 mux module mux_2to1()
module test_mux_2to1;
    // input registers
    reg [31 : 0] X, Y;
    reg S;

    // output wire
    wire [31 : 0] Z;

    // count the number of errors we encounter
    integer errors = 0;

    // insanitiate the uut for the full 32-bit buses we expect in the ALU
    mux_2to1 #(.N(32)) uut (X, Y, S, Z);

    initial begin
        // create a file we can analyze in a waveform viewer (GTKWave)
        $dumpfile("mux_2to1.vcd");
        $dumpvars(0, uut);
        
        X = 0; Y = 0; S = 0; #100;
        X = 0; Y = 1; S = 1; #100;
        X = 1; Y = 0; S = 0; #100;
        X = 2 ** 31; Y = 2 ** 30; S = 0; #100;
        X = 2 ** 31; Y = 2 ** 30; S = 1; #100;

        $display("Test generated %d errors.", errors);

        $finish;
    end

    // each test case brings execution here
    always @(X, Y, S) begin
        #1;

        // $display("TESTING: X = %b, Y = %b, S = %b", X, Y, S);

        if ((S == 0 & Z !== X) | (S == 1 & Z !== Y)) begin
            $display("ERROR: X = %b, Y = %b, S = %b, but Z = %b", X, Y, S, Z);
            errors = errors + 1;
        end
    end

endmodule
