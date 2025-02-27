module hazard(
  input logic armD, armE, armM, armW,
  input logic RegWriteM, RegWriteW,
  input logic [4:0] RdE, RdM, RdW,
  input logic [1:0] ResultSrcE, // bit 1 is RISC-V only
  input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
  input logic PCSrcD, PCSrcE, PCSrcM, PCSrcW,
  input logic [1:0] BranchTakenE, // bit 0 RISC-V only
  input logic StallFD, // ARM only
  input logic [1:0] FwdE, // ARM only
  input logic [1:0] FwdD, // ARM only

  output logic StallF, StallD, FlushD, FlushE,
  output logic [1:0] ForwardAE, ForwardBE
  );

/* Register forwarding */
// Don't forward R0 in RISC-V
logic Match_1E_M = (Rs1E == RdM) & (armE | Rs1E != 0);
logic Match_1E_W = (Rs1E == RdW) & (armE | Rs1E != 0);
logic Match_2E_M = (Rs2E == RdM) & (armE | Rs2E != 0);
logic Match_2E_W = (Rs2E == RdW) & (armE | Rs2E != 0);

always_comb begin
  if(&FwdE & armE)                ForwardAE = 2'b00; // No forwarding
  else if(Match_1E_M & RegWriteM) ForwardAE = 2'b10; // Op1E = ALUOutM
  else if(FwdE[0] & armE)         ForwardAE = 2'b10; // Op1E = ALUOutM
  else if(Match_1E_W & RegWriteW) ForwardAE = 2'b01; // Op1E = ResultW
  else                            ForwardAE = 2'b00; // No forwarding

  if(&FwdE & armE)                ForwardBE = 2'b00; // No forwarding
  else if(Match_2E_M & RegWriteM) ForwardBE = 2'b10; // Op2E = ALUOutM
  else if(FwdE[1] & armE)         ForwardBE = 2'b10; // Op2E = ALUOutM
  else if(Match_2E_W & RegWriteW) ForwardBE = 2'b01; // Op2E = ResultW
  else                            ForwardBE = 2'b00; // No forwarding
end

/* Load stall and control stall */
logic Match_12D_E = (Rs1D == RdE) | (Rs2D == RdE);
logic LDStall;
assign LDStall = Match_12D_E & ResultSrcE[0] & ~&FwdD; // bit 1 is RISC-V only
logic PCWrPendingF;
assign PCWrPendingF = (armD & PCSrcD) | (armE & PCSrcE) | (armM & PCSrcM); // ARM only

assign StallD = LDStall | StallFD;
assign StallF = LDStall | PCWrPendingF | StallFD;
assign FlushE = LDStall | |BranchTakenE;
assign FlushD = (PCWrPendingF | (armW & PCSrcW) | |BranchTakenE);

endmodule
