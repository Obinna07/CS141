`timescale 1ns / 1ps---0-
`default_nettype none // helps catch typo-related bugs

// testbench for the timer() module in 'timer.v'
module test_timer;
    // input registers and output wires
    reg clk, rst, en, load;
    reg [3 : 0] init;
    wire [3 : 0] out;

    integer delay = 5;

    // instantiate the timer() module as the uut
    timer #(.N(4)) uut (clk, rst, en, load, init, out);

    // run the testbench sequentially
    initial begin
        // create waveform file to analyze if needed
        $dumpfile("timer.vcd");
        $dumpvars(0, uut);

        // show the time, clock, enable, and counter when any value changes
        $display("time \t clk \t rst \t load \t init \t en \t out");
        $monitor("%g \t %b \t %b \t %b \t %b \t %b \t %b", $time, clk, rst, load, init, en, out);

        // initialize the registers
        clk = 0;
        en = 0;
        rst = 0;
        load = 0;

        // load the value 4'b1101 = 13 into the counter
        #(delay);
        load = 1;
        init = 4'b1101;
        #(delay);

        // turn the load bit off and turn on the enable to allow for decrementing
        #(delay);
        load = 0;
        en = 1;
        #(delay);

        // reset the counter to its maximum value after some time
        #(10 * delay);
        rst = 1;
        #(delay);

        // let the counter go to 0 (and stop at 0)
        #(delay);
        rst = 0;
        #(40 * delay);

        $finish;

    end

    // generate a clock by flipping the .clk bit every .delay ticks
    always begin
        #(delay);
        clk = ~clk;
    end

endmodule
