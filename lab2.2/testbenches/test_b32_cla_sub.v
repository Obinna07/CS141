`timescale 1ns / 1ps

// testbench for the 32-bit subtractor module b32_cla_sub()
// this is basically the same as the ripple carry adder testbench
module test_b32_cla_sub;
    // input registers
    reg signed [31 : 0] X, Y;
    reg o_bit;

    // output wires
    wire signed [31 : 0] Z;
    wire overflow;

    integer errors = 0;

    b32_cla_sub uut (
        .X(X),
        .Y(Y),
        .Z(Z),
        .overflow(overflow)
        );

    initial begin
        $dumpfile("b32_cla.vcd");
        $dumpvars(0, uut);

        // test cases that should have no overflow bit
		o_bit = 0;
        X = 1; Y = 0;                   #200;
        X = 10000; Y = 9999;            #200;
        X = 2 ** 30; Y = 2 ** 29;       #200;
        X = 2 ** 30; Y = 2 ** 30;       #200;
        X = -123456; Y = -123456;       #200;
        X = -3; Y = 99997;              #200;
        X = 10006; Y = -9994;           #200;
        X = 2 ** 30; Y = -1;            #200;

		// test cases that should set the overflow bit high
	    o_bit = 1;
        X = -(2 ** 31); Y = 1;                  #200;
        X = -(2 ** 30); Y = 2 ** 30 + 2 ** 29;  #200;
        X = 2 ** 30; Y = -(2 ** 30);            #200;
        X = 2 ** 29; Y = -(2 ** 31);            #200;

		$display("This test generated %d errors.", errors);

		$finish;
    end

    always @(X, Y) begin
        #100;

        $display("Calculating %d - %d = %d, overflow = %b", X, Y, (X - Y), o_bit);

        if (Z !== (X - Y) | overflow !== o_bit) begin
            $display("ERROR: either Z is not X + Y or the overflow bit is incorrect; (X, Y, Z, overflow) = (%d, %d, %d, %b)", X, Y, Z, overflow);
            errors = errors + 1;
        end
    end


endmodule
