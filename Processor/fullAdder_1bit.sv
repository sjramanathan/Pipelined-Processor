`timescale 10ps/1fs

module fullAdder_1bit(a, b, out, Cin, Cout);
	input logic a, b, Cin;
	output logic out, Cout;
	logic [3:0] x, w;
	
	// Gate level logic for the adder. 
	xor #5 xor1 (out, b, a, Cin);
	and #5 and1 (w[1], a, b);
	and #5 and2 (w[2], a, Cin);
	and #5 and3 (w[3], b, Cin);
	or  #5 or1  (Cout, w[1], w[2], w[3]);  
endmodule 

module fullAdder_1bit_testbench();
	logic a, b, out, Cin, Cout;
	
	fullAdder_1bit dut (.a, .b, .out, .Cin, .Cout);
	
	integer i;
	
	initial begin
		for(i=0; i<8; i++) begin
			{a, b, Cin} = i; #100;
		end
	end
endmodule