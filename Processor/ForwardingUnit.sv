module ForwardingUnit(ForwardA, ForwardB, ForwardData, ForwardFlag, flagSetEX, wasBranch, ALUSrc, ExMem_RegWrite, MemWB_RegWrite, ExMem_Rd, MemWB_Rd, Rn, Rm);
	input logic ExMem_RegWrite, MemWB_RegWrite, flagSetEX, wasBranch, ALUSrc;
	input logic [4:0] ExMem_Rd, MemWB_Rd, Rn, Rm;
	output logic [1:0] ForwardA, ForwardB, ForwardData;
	output logic ForwardFlag;
	
	always_comb begin 
		if ((ExMem_RegWrite) & (ExMem_Rd != 5'b11111) & (ExMem_Rd == Rn)) begin
			ForwardA = 2'b10;	
		end else if ((MemWB_RegWrite) & (MemWB_Rd != 5'b11111) & (MemWB_Rd == Rn)) begin
			ForwardA = 2'b01;
		end else begin
			ForwardA = 2'b00;	
		end
		
		if ((ExMem_RegWrite) & (ExMem_Rd != 5'b11111) & (ExMem_Rd == Rm) & (!ALUSrc)) begin
			ForwardB = 2'b10;
		
		end else if ((MemWB_RegWrite) & (MemWB_Rd != 5'b11111) & (MemWB_Rd == Rm) & (!ALUSrc)) begin
			ForwardB = 2'b01;
		end else begin
			ForwardB = 2'b00;	
		end
		
		if ((ExMem_RegWrite) & (ExMem_Rd != 5'b11111) & (ExMem_Rd == Rm)) begin // we changed Rm to Rn
			ForwardData = 2'b10;
	 	
		end else if ((MemWB_RegWrite) & (MemWB_Rd != 5'b11111) & (MemWB_Rd == Rm)) begin
			ForwardData = 2'b01;
		end else begin
			ForwardData = 2'b00;	
		end

		
		if (flagSetEX & wasBranch)
			ForwardFlag = 1;
		else
			ForwardFlag = 0;
		
	end

endmodule 