`timescale 1 ns / 10 ps

module test_clk_divider();

    // inputs
    localparam T = 10;
    reg clk_in;
    reg rst;

    // outputs
    wire clk_out;

    // Instantiate the Unit Under Test
    clk_divider uut(
	 .clk_in(clk_in),
	 .rst(rst),
	 .clk_out(clk_out)
	 );

    // reset on first half cycle
    initial 
    begin
        rst = 1'b1;  // start clock divider on reset (reset set to high)
        #(T/2);      // wait half of the clock period
        rst = 1'b0;  // set reset to zero
    repeat(100) @(posedge clk_in);
    $finish;
    end

    // 10 ns clock running forever
    always  
		 begin
		 clk_in = 1'b1;
		 #(T/2);
		 clk_in = 1'b0;
		 #(T/2);
		 end

endmodule


