`timescale 10ps/1fs

module mux10_5 (inOne, inZero, sel, out);
	input logic [4:0] inOne, inZero;
	input logic sel;
	output logic [4:0] out;

	genvar i;
	
	generate 
		for (i = 0; i < 5; i++) begin : eachRouteMux
			mux2_1 routeMux1 (.in({inOne[i], inZero[i]}), .sel(sel), .out(out[i]));
		end
	endgenerate 

endmodule

module mux10_5_testbench();
	logic [4:0] inOne, inZero, out;
	logic sel;
	
	mux10_5 dut (.inOne, .inZero, .sel, .out);
	
	initial begin 
		sel = 0; inOne = 5'b11111; inZero = 5'b00000; #100;
		sel = 1;				                     		 #100;
		sel = 0;				                      		 #100;
		sel = 1;				                       		 #100;
		sel = 0;				                      		 #100;
	end

endmodule