`timescale 10ps/1fs

module CPU_64bit (clk, reset);
	input logic clk, reset;
	logic [63:0] DaRF, DaForward, DaEX, DbRF, DbForward, DbEX, DbMem, WriteDataWB, WriteDataWB_BL, WriteDataMem, aluBRF, aluBForward, aluBEX, aluResultEX, aluResultMem, dataMemOut, 
	             fullImm16, addIMuxOut, immSelector, newPC, ultimatePC, oldPC, prevPC, thePC, normalIncPC, branchIncPC, bToAdder, BLvalueIF, BLvalueRF, BLvalueEX, BLvalueWB, BLvalueMEM,
					 postShiftB, altBInput, movzMux, toRegFinal, forwardOne, forwardTwo;
	logic [31:0] instructionIF, instructionRF;
	logic [25:0] brAddr26;
	logic [18:0] condAddr19;
	logic [15:0] imm16;
	logic [11:0] imm12;
	logic [10:0] opcode;
	logic [8:0] dAddr9;
	logic [4:0] RdRF, RdEX, RdMem, RdWB, RdWB_BL, Rm, Rn, Rmux;
	logic [1:0] ForwardA, ForwardB, ForwardData;
	
   //Control signals
   logic negative, zero, fastZero, overflow, carry_out, nTrue, zTrue, oTrue, cTrue,
	      zeroFlag, carryFlag, overflowFlag, negativeFlag;
	logic [2:0] ALUOpRF, ALUOpEX;
	logic RegWriteRF, RegWriteEX, RegWriteMem, RegWriteWB;
	logic MemWriteRF, MemWriteEX, MemWriteMem;
	logic Reg2Loc;
	logic Reg3Loc;
	//, Reg3LocEX, Reg3LocMem, Reg3LocWB;
	logic [4:0] newRd_RF, newRd_EX, newRd_Mem, newRd_WB;
	logic Imm_12;
	logic ALUSrc;
	logic MemToRegRF, MemToRegEX, MemToRegMem;
	logic UncondBr;
	logic BrTaken;
	logic wasBranch;
	logic BLSignal, BLSignalEX, BLSignalMem, BLSignalWB;
	logic BRSignal;
	logic read_enableRF, read_enableEX, read_enableMem;
	logic flagSetRF, flagSetEx, ForwardFlag;
	logic [3:0] xfer_sizeRF, xfer_sizeEX, xfer_sizeMem;
	
   //Instruction decode
	assign RdRF = 	 	  instructionRF[4:0];
	assign Rn = 	 	  instructionRF[9:5];
	assign Rm = 	 	  instructionRF[20:16];
	assign opcode = 	  instructionRF[31:21];
	assign imm12 =  	  instructionRF[21:10];
	assign dAddr9 = 	  instructionRF[20:12];
	assign imm16 =      instructionRF[20:5];
	assign brAddr26 =   instructionRF[25:0];
	assign condAddr19 = instructionRF[23:5];

	//Control Logic Cloud  --- Need to add mux for the Reg3Loc
	
   controlLogic theBrain (.OpCode(opcode), .zero(zeroFlag), .notFlagZero(fastZero), .negative(negativeFlag), .carryout(carryFlag), .overflow(overflowFlag), .RegWrite(RegWriteRF), 
									.Reg2Loc, .Reg3Loc, .ALUSrc, .ALUOp(ALUOpRF), .MemWrite(MemWriteRF), .MemToReg(MemToRegRF), .UncondBr, .BrTaken,  
									.Imm_12, .xfer_size(xfer_sizeRF), .read_en(read_enableRF), .flagSet(flagSetRF), .wasBranch, .BLSignal, .BRSignal); 

	//Fast zero flag for pipeline
	
	zero_flag advancedBranch (.result(aluBRF), .checkZero(fastZero));
	
	//Control signal "buffers"/pipline stages
	
	D_FF ALUOpFlop0 (.q(ALUOpEX[0]), .d(ALUOpRF[0]), .reset, .clk);
	D_FF ALUOpFlop1 (.q(ALUOpEX[1]), .d(ALUOpRF[1]), .reset, .clk);
	D_FF ALUOpFlop2 (.q(ALUOpEX[2]), .d(ALUOpRF[2]), .reset, .clk);
	
	D_FF flagSetFlop0 (.q(flagSetEX), .d(flagSetRF), .reset, .clk);
	
	D_FF MemWriteFlop0 (.q(MemWriteEX), .d(MemWriteRF), .reset, .clk);
	D_FF MemWriteFlop1 (.q(MemWriteMem), .d(MemWriteEX), .reset, .clk);
	
	D_FF read_enableFlop0 (.q(read_enableEX), .d(read_enableRF), .reset, .clk);
	D_FF read_enableFlop1 (.q(read_enableMem), .d(read_enableEX), .reset, .clk);
	
	D_FF xfer_sizeFlop0 (.q(xfer_sizeEX[0]), .d(xfer_sizeRF[0]), .reset, .clk);
	D_FF xfer_sizeFlop1 (.q(xfer_sizeEX[1]), .d(xfer_sizeRF[1]), .reset, .clk);
	D_FF xfer_sizeFlop2 (.q(xfer_sizeEX[2]), .d(xfer_sizeRF[2]), .reset, .clk);
	D_FF xfer_sizeFlop3 (.q(xfer_sizeEX[3]), .d(xfer_sizeRF[3]), .reset, .clk);
	D_FF xfer_sizeFlop4 (.q(xfer_sizeMem[0]), .d(xfer_sizeEX[0]), .reset, .clk);
	D_FF xfer_sizeFlop5 (.q(xfer_sizeMem[1]), .d(xfer_sizeEX[1]), .reset, .clk);
	D_FF xfer_sizeFlop6 (.q(xfer_sizeMem[2]), .d(xfer_sizeEX[2]), .reset, .clk);
	D_FF xfer_sizeFlop7 (.q(xfer_sizeMem[3]), .d(xfer_sizeEX[3]), .reset, .clk);
	
	
	D_FF MemToRegFlop0 (.q(MemToRegEX), .d(MemToRegRF), .reset, .clk);
	D_FF MemToRegFlop1 (.q(MemToRegMem), .d(MemToRegEX), .reset, .clk);
	
	D_FF RegWriteFlop0 (.q(RegWriteEX), .d(RegWriteRF), .reset, .clk);
	D_FF RegWriteFlop1 (.q(RegWriteMem), .d(RegWriteEX), .reset, .clk);
	D_FF RegWriteFlop2 (.q(RegWriteWB), .d(RegWriteMem), .reset, .clk);
	
	
	/*D_FF Reg3LocFlop0 (.q(Reg3LocEX), .d(Reg3Loc), .reset, .clk);
	D_FF Reg3LocFlop1 (.q(Reg3LocMem), .d(Reg3LocEX), .reset, .clk);
	D_FF Reg3LocFlop2 (.q(Reg3LocWB), .d(Reg3LocMem), .reset, .clk);*/
	
	D_FF BLSignalFlop0 (.q(BLSignalEX), .d(BLSignal), .reset, .clk);
	D_FF BLSignalFlop1 (.q(BLSignalMem), .d(BLSignalEX), .reset, .clk);
	D_FF BLSignalFlop2 (.q(BLSignalWB), .d(BLSignalMem), .reset, .clk);
	
	//D_FF_enable the flags so they don't change until certain operations.

	D_FF_enable forZero (.q(zTrue), .d(zero), .en(flagSetEX), .clk);
	D_FF_enable forNegative (.q(nTrue), .d(negative), .en(flagSetEX), .clk);
	D_FF_enable forCarryout (.q(cTrue), .d(carry_out), .en(flagSetEX), .clk);
	D_FF_enable forOverflow (.q(oTrue), .d(overflow), .en(flagSetEX), .clk);

	//If the flag is needed early, route it forward with forwarding logic!

   mux2_1 forZeroForward (.in({zero, zTrue}), .sel(ForwardFlag), .out(zeroFlag));
	mux2_1 forNegativeForward (.in({negative, nTrue}), .sel(ForwardFlag), .out(negativeFlag));
	mux2_1 forCarryoutForward (.in({carry_out, cTrue}), .sel(ForwardFlag), .out(carryFlag));
	mux2_1 forOverflowForward (.in({overflow, oTrue}), .sel(ForwardFlag), .out(overflowFlag));


	//Program counter logic 
	
	//Conditional/unconditional branching PC increment logic
	
	// Selects between brAddr26 or condAddr19. Select signal is UncondBr.
	mux128_64 unCondBrMUX (.inOne({{38{brAddr26[25]}}, brAddr26}), .inZero({{45{condAddr19[18]}}, condAddr19}), .sel(UncondBr), .out(postShiftB));
	
	// Shifts value (either brAddr26 or condAddr19) from brSelect by 2 bits (<<2).
	shifter brShifter (.value(postShiftB), .direction(1'b0), .distance(6'b000010), .result(bToAdder));
	
	
	//Normal PC increment logic
	
	pcUnit theProgramCounter (.in(ultimatePC), .clk(clk), .reset(reset), .out(oldPC));
	
	// PC = PC + 4
	fullAdder_64bit normalCounter (.A(thePC), .B({{60{1'b0}}, 4'b0100}), .result(normalIncPC));
	
	assign BLvalueIF = normalIncPC;
	
	// PC = PC + SignExtend((BrAddr26)/(CondAddr19))<<2.
	fullAdder_64bit branchCounter (.A(bToAdder), .B(thePC), .result(branchIncPC));
	
	// Mux that decides between PC+4 or PC = PC + SignExtend((BrAddr26)/(CondAddr19))<<2.
	mux128_64 brTakenMUX (.inOne(branchIncPC), .inZero(normalIncPC), .sel(BrTaken), .out(newPC));
	mux128_64 BRMUX (.inOne(DbRF), .inZero(newPC), .sel(BRSignal), .out(ultimatePC)); ////////////FIGURE OUT LATERON
	
   //Instruction Memory
	
	instructmem theInstructions (.address(oldPC), .instruction(instructionIF), .clk(clk));

	
	//Old PC flip flop for branching
	
	mux128_64 oldPCMUX (.inOne(prevPC), .inZero(oldPC), .sel(wasBranch), .out(thePC));	
	Pipe_D_FF oldPCDFF (.q(prevPC), .d(oldPC), .reset, .clk);
	
	
	//IF - RF Pipe
	
	Pipe_D_FF_32 ifrfo (.q(instructionRF), .d(instructionIF), .reset, .clk);
	
	//DataPath
	
	//Regfile
	
	// MUX Rm and Rd. Reg2Loc is the selection signal for mux and selects which register to send through
	mux10_5 regMux (.inOne(Rm), .inZero(RdRF), .sel(Reg2Loc), .out(Rmux));
	mux10_5 regMuxBR (.inOne(5'b11110), .inZero(RdRF), .sel(Reg3Loc), .out(newRd_RF));// Regfile will have two 64 bit outputs. Registers Rn, Rd, and the output of mux10_5 (choosing between
	
   regfile registerFile (.ReadData1(DaForward), .ReadData2(DbForward), .WriteData(WriteDataWB_BL), .ReadRegister1(Rn), 
	                      .ReadRegister2(Rmux), .WriteRegister(newRd_WB), .RegWrite(RegWriteWB), .clk);
	
   
	
	//Forwarding logic
	ForwardingUnit superFast (.ForwardA, .ForwardB, .ForwardData, .ForwardFlag, .flagSetEX, .wasBranch, .ALUSrc, .ExMem_RegWrite(RegWriteEX), .MemWB_RegWrite(RegWriteMem), .ExMem_Rd(newRd_EX), .MemWB_Rd(newRd_Mem), .Rn(Rn), .Rm(Rmux));
	
	
	//MUXs for forwarding
	mux128_64 BLEXMUX (.inOne(BLvalueEX), .inZero(aluResultEX), .sel(BLSignalEX), .out(forwardOne));
	mux128_64 BLMEMMUX (.inOne(BLvalueMEM), .inZero(WriteDataMem), .sel(BLSignalMem), .out(forwardTwo));
	
	mux256_64 forwardAMUX (.inThree(64'h0000000000000000), .inTwo(forwardOne), .inOne(forwardTwo), .inZero(DaForward), .sel(ForwardA), .out(DaRF));
	mux256_64 forwardBMUX (.inThree(64'h0000000000000000), .inTwo(forwardOne), .inOne(forwardTwo), .inZero(aluBForward), .sel(ForwardB), .out(aluBRF));
	mux256_64 forwardDataBMUX (.inThree(64'h0000000000000000), .inTwo(forwardOne), .inOne(forwardTwo), .inZero(DbForward), .sel(ForwardData), .out(DbRF));
	
	
	//Immediate and Address MUXing 	
	
	
	// This mux decides whether to send Imm12 (for the ADDI instruction) or Daddr9 to the ALUSrc mux.
	mux128_64 immOrAddrMux (.inOne({{52{1'b0}}, imm12}), .inZero({{55{dAddr9[8]}}, dAddr9}), .sel(Imm_12), .out(addIMuxOut));
	
	//ALU Hookups
		
	//Sends either ReadData2 (register Db) or the choice between Imm_12 and Daddr9
	mux128_64 alusrcMUX (.inOne(addIMuxOut), .inZero(DbForward), .sel(ALUSrc), .out(aluBForward));
	
	//RF - EX Pipes
	
	Pipe_D_FF rfex0 (.q(DaEX), .d(DaRF), .reset, .clk);
	Pipe_D_FF rfex1 (.q(DbEX), .d(DbRF), .reset, .clk);
	Pipe_D_FF rfex2 (.q(aluBEX), .d(aluBRF), .reset, .clk);
	
	//Pipe_D_FF_5 rfex4 (.q(RdEX), .d(RdRF), .reset, .clk);
	Pipe_D_FF_5 newrdex0 (.q(newRd_EX), .d(newRd_RF), .reset, .clk);
	Pipe_D_FF_5 newrdex1 (.q(newRd_Mem), .d(newRd_EX), .reset, .clk);
	Pipe_D_FF_5 newrdex2 (.q(newRd_WB), .d(newRd_Mem), .reset, .clk);
	
	// The final 64 bit ALU hookup
	alu mainALU (.A(DaEX), .B(aluBEX), .cntrl(ALUOpEX), .result(aluResultEX), .negative, .zero, .overflow, .carry_out);
	
	
	//EX - MEM Pipes
	
	Pipe_D_FF exmem0 (.q(DbMem), .d(DbEX), .reset, .clk);
	Pipe_D_FF exmem1 (.q(aluResultMem), .d(aluResultEX), .reset, .clk);
	
	//Pipe_D_FF_5 exmem3 (.q(RdMem), .d(RdEX), .reset, .clk);
	Pipe_D_FF blvalue1 (.q(BLvalueRF), .d(BLvalueIF), .reset, .clk);
	Pipe_D_FF blvalue2 (.q(BLvalueEX), .d(BLvalueRF), .reset, .clk);
	Pipe_D_FF blvalue3 (.q(BLvalueMEM), .d(BLvalueEX), .reset, .clk);
	Pipe_D_FF blvalue4 (.q(BLvalueWB), .d(BLvalueMEM), .reset, .clk);
	
	
	//DataMem hookups
   
	datamem dataMemory (.address(aluResultMem), .write_enable(MemWriteMem), .read_enable(read_enableMem), .write_data(DbMem), .clk(clk), .xfer_size(xfer_sizeMem), .read_data(dataMemOut));
	
	mux128_64 datamemMUX (.inOne(dataMemOut), .inZero(aluResultMem), .sel(MemToRegMem), .out(WriteDataMem));	
	mux128_64 datamemMUX2 (.inOne(BLvalueWB), .inZero(WriteDataWB), .sel(BLSignalWB), .out(WriteDataWB_BL));

	
	//MEM - WB Pipes
	
	Pipe_D_FF memwb0 (.q(WriteDataWB), .d(WriteDataMem), .reset, .clk);
	
endmodule
