
module decode_3_8 (in, out, en);
	input logic [2:0] in;
	input logic en;
	output logic [7:0] out;
	
	wire [1:0] w;
	
	decode_1_2 submodule1 (.in(in[2]), .out(w[1:0]), .en(en));
	decode_2_4 submodule2 (.in(in[1:0]), .out(out[3:0]), .en(w[0]));
	decode_2_4 submodule3 (.in(in[1:0]), .out(out[7:4]), .en(w[1]));	
endmodule

module decode_3_8_testbench();
	logic [2:0] in;
	logic en;
	logic [7:0] out;
	
	decode_3_8 dut (.in, .out, .en);
	
	initial begin
		in[0] = 0;
		in[1] = 0;
		in[2] = 0;
		en = 1'b0;
		#100;
		en = 1'b1;
		#100;
		in[0] = 1;
		#100;
		in[0] = 0;
		in[1] = 1;
		#100;
		in[0] = 1;
		#100;
		in[0] = 0;
		in[1] = 0;
		in[2] = 1;
		#100;
		in[0] = 1;
		#100;
		in[0] = 0;
		in[1] = 1;
		#100;
		in[0] = 1;
		#100;
	end
endmodule