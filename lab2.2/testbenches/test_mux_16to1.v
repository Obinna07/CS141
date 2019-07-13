`timescale 1ns / 1ps

// testbench for the full 32-bit 16:1 mux module mux_16to1()
module test_mux_16to1;
    // input registers
    reg signed [31 : 0] X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15;
    reg [3 : 0] S;

    // output wires
    wire signed [31 : 0] Z;

    integer errors = 0;

    // insanitiate the 16:1 mux as the testbench's uut
    mux_16to1 #(.N(32)) uut (X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, S, Z);

    initial begin
        // create waveform viewer file for debugging
        $dumpfile("mux_16to1.vcd");
        $dumpvars(0, uut);

        // give unique values to each of the input registers; the actual values
        // we use should not mattter for testing a mux, as long as we can tell
        // the inputs apart (we set input i to decimal value i)
        X0 = 'd0; X1 = 'd1; X2 = 'd2; X3 = 'd3; X4 = 'd4; X5 = 'd5; X6 = 'd6; X7 = 'd7;
        X8 = 'd8; X9 = 'd9; X10 = 'd10; X11 = 'd11; X12 = 'd12; X13 = 'd13; X14 = 'd14; X15 = 'd15;
        #1;

        // loop all values of the select input and test
        for (S = 4'b0000; S < 4'b1000; S = S + 1) begin
            #20;
            if (Z !== S) begin
                $display("ERROR: S = %b, but Z = %b", S, Z);
                errors = errors + 1;
            end
        end

        $display("This test generated %d errors.", errors);
        $finish;
    end

endmodule
