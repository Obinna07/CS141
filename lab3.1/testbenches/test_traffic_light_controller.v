`timescale 1ns / 1ps

module test_traffic_light_controller;

    // input regs
	reg clk, rst, car_ns, car_ew, ped;
	wire [3:0] timer_out;
    reg [3:0] test_case;

    // output wires
    wire [3:0] timer_init;
	wire [2:0] light_ns, light_ew;
	wire [1:0] light_ped;
	wire timer_load, timer_en;

    traffic_light_controller uut (
        .clk(clk),
        .rst(rst),
        .car_ns(car_ns),
        .car_ew(car_ew),
        .ped(ped),
        .timer_out(timer_out),
        .timer_init(timer_init),
        .light_ns(light_ns),
        .light_ew(light_ew),
        .light_ped(light_ped),
        .timer_load(timer_load),
        .timer_en(timer_en)
    );

	timer #(.N(4)) timert (.clk(clk), .rst(0), .en(timer_en), .load(timer_load), .init(timer_init), .out(timer_out));


    initial begin
        $dumpfile("traffic_light_controler.vcd");
        $dumpvars(0, uut);

		$display("time \t rst \t init \t timer \t cns \t cew \t ped \t lns \t lew \t lped");
		$monitor("%g \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b", $time, rst, timer_init, timer_out, car_ns, car_ew, ped, light_ns, light_ew, light_ped);

        // intialize inputs
		clk = 0;

		// first test case: one car on the NS road
		test_case = 0;
		rst = 0;
        car_ns = 1;
        car_ew = 0;
        ped = 0;

		#1000;
		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		// second test case: one car on the EW road
        test_case = 1;
        rst = 0;
        car_ns = 0;
        car_ew = 1;
        ped = 0;

        #1000;
		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		// third test case: cars on both roads
        test_case = 2;
        rst = 0;
        car_ns = 1;
        car_ew = 1;
        ped = 0;

        #1000;
		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		// fourth test case: one car on the NS road, but reset during execution
        test_case = 3;
        rst = 0;
        car_ns = 1;
        car_ew = 0;
        ped = 0;
		#300; rst = 1;
		#10; rst = 0;
		#700;
		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		// fifth test case: one car on NS road, one pedestrian after 5 minutes
		test_case = 4;
		rst = 0;
		car_ns = 1;
		car_ew = 0;
		ped = 0;
		#300; ped = 1;
		#700;
		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		/*
		// sixth test case:
		test_case = 5;
		rst = 0;
		car_ns = 1;
		car_ew = 1;
		ped = 0;

		$display("\nResetting...");
		rst = 1; #10;
		$display("");

		#100

		/*
		  test_case = 6;
		  rst = 0;
		  car_ns = 1;
		  car_ew = 1;
		  ped = 1;

		  #100

		  test_case = 7;
		  rst = 1;
		  car_ns = 0;
		  car_ew = 0;
		  ped = 0;

		  #100

		  test_case = 8;
		  rst = 1;
		  car_ns = 0;
		  car_ew = 0;
		  ped = 1;

		  #100

		  test_case = 9;
		  rst = 1;
		  car_ns = 0;
		  car_ew = 1;
		  ped = 0;

		  #100

		  test_case = 10;
		  rst = 1;
		  car_ns = 0;
		  car_ew = 1;
		  ped = 1;

		  #100

		  test_case = 11;
		  rst = 1;
		  car_ns = 1;
		  car_ew = 0;
		  ped = 0;

		  #100

		  test_case = 12;
		  rst = 1;
		  car_ns = 1;
		  car_ew = 0;
		  ped = 1;

		  #100

		  test_case = 13;
		  rst = 1;
		  car_ns = 1;
		  car_ew = 1;
		  ped = 0;

		  #100

		  test_case = 14;
		  rst = 1;
		  car_ns = 1;
		  car_ew = 1;
		  ped = 1;

		  #100*/

        //$display("This test is over.");

        $finish;

    end

	always begin
		#5;
		clk = ~clk;
	end

endmodule
