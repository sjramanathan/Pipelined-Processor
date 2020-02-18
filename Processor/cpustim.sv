`timescale 1ns/10ps

module cpustim(); 		
	logic reset, clk;
	parameter ClockDelay = 20;
	
	integer i;

	CPU_64bit dut (.clk, .reset);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
		reset = 1; 	@(posedge clk);
	   reset = 0; 	@(posedge clk);
						@(posedge clk);
		for (i=0; i<25; i++) begin
						@(posedge clk);
		end
		$stop;
	end

endmodule
