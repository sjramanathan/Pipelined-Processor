`timescale 10ps/1fs

module pcUnit (in, clk, reset, out);
	input logic [63:0] in;
	input logic clk, reset;
	output logic [63:0] out;

	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin : holdingDFF
			D_FF holdingDFF1 (.q(out[i]), .d(in[i]), .reset(reset), .clk(clk));
		end
	endgenerate 

endmodule

module pcUnit_testbench();
	logic [63:0] in, out;
	logic clk, reset;
	
	pcUnit dut (.in, .clk, .reset, .out);
	
	initial begin 
		clk = 0; reset = 0; in = 64'hFFFFFFFFFFFFFFFF; #100;
		clk = 0; reset = 0; in = 64'hFFFFFFFFFFFFFFFF; #100;
		clk = 1; reset = 0; in = 64'hFFFFFFFFFFFFFFFF; #100;
		clk = 0; reset = 0; in = 64'hFFFFFFFFFFFFFFFF; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
		clk = 1; reset = 1; in = 64'h1111111111111111; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
		clk = 1; reset = 0; in = 64'h1111111111111111; #100;
		clk = 0; reset = 0; in = 64'h1111111111111111; #100;
	end

endmodule