module pc_register(clk, rst, d, q, ena);

	parameter N = 32;
	input wire clk, rst, ena;
	input wire [N-1:0] d;
	output reg [N-1:0] q;

	always @(posedge clk) begin
		if(rst) begin
			q <= 32'b00000000010000000000000000000000;
		end
		else if (ena) begin
			q <= d;
		end
		else begin
			q <= q;
		end
	end

endmodule
