
module D_FF_enable (q, d, en, clk);
	input logic d, en, clk;
	output logic q;
	logic outFromMux;
	logic [1:0] in;
	
	assign in[0] = q;
	assign in[1] = d;

	//Create a flip flop from the submodule D_FF
	D_FF d0 (.q(q), .d(outFromMux), .reset(1'b0), .clk);
	
	//Create a MUX through the submodule mux2_1
	mux2_1 theMux (.in(in[1:0]), .sel(en), .out(outFromMux));
	
endmodule 

module D_FF_enable_testbench();
	logic d, en, clk;
	logic q;

	D_FF_enable dut (.q, .d, .en, .clk);

	initial begin
		q=0; d=0; en=0; clk=0; #10;
		
		//Testing en signal at 0
		d=1; en=0; clk=0; #10;
		d=1; en=0; clk=1; #10;
		d=1; en=0; clk=0; #10;
		d=1; en=0; clk=1; #10;
		d=0; en=0; clk=0; #10;
		
		//Testing en signal at 1
		d=1; en=1; clk=0; #10;
		d=1; en=1; clk=0; #10;
		d=1; en=1; clk=1; #10;
		d=1; en=1; clk=0; #10;
		d=1; en=1; clk=1; #10;
		d=1; en=1; clk=0; #10;
		
		//Testing en signal at 0
		d=0; en=0; clk=0; #10;
		d=0; en=0; clk=0; #10;
		d=0; en=0; clk=1; #10;
		d=0; en=0; clk=0; #10;
		d=0; en=0; clk=1; #10;
		d=0; en=0; clk=0; #10;
	end
endmodule 