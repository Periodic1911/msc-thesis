module hazard(
  input logic arm,
  input logic RegWriteM, RegWriteW,
  input logic [4:0] RdE, RdM, RdW,
  input logic [1:0] ResultSrcE, // bit 1 is RISC-V only
  input logic RVPCSrcE, // RISC-V only
  input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
  input logic PCSrcD, PCSrcE, PCSrcM, PCSrcW, BranchTakenE, // ARM only

  output logic StallF, StallD, FlushD, FlushE,
  output logic [1:0] ForwardAE, ForwardBE
  );

/* Register forwarding */
// Don't forward R0 in RISC-V
logic Match_1E_M = (Rs1E == RdM) & (arm | Rs1E != 0);
logic Match_1E_W = (Rs1E == RdW) & (arm | Rs1E != 0);
logic Match_2E_M = (Rs2E == RdM) & (arm | Rs2E != 0);
logic Match_2E_W = (Rs2E == RdW) & (arm | Rs2E != 0);

always_comb begin
  if     (Match_1E_W & RegWriteW) ForwardAE = 2'b01; // Op1E = ResultW
  else if(Match_1E_M & RegWriteM) ForwardAE = 2'b10; // Op1E = ALUOutM
  else                            ForwardAE = 2'b00; // No forwarding

  if     (Match_2E_W & RegWriteW) ForwardBE = 2'b01; // Op2E = ResultW
  else if(Match_2E_M & RegWriteM) ForwardBE = 2'b10; // Op2E = ALUOutM
  else                            ForwardBE = 2'b00; // No forwarding
end

/* Load stall and control stall */
logic Match_12D_E = (Rs1D == RdE) | (Rs2D == RdE);
logic LDStall = Match_12D_E & ResultSrcE[0]; // bit 1 is RISC-V only
logic PCWrPendingF = PCSrcD | PCSrcE | PCSrcM; // ARM only

assign StallD = LDStall;
assign StallF = LDStall | (arm & PCWrPendingF);
assign FlushE = LDStall | (arm & BranchTakenE) | (~arm & RVPCSrcE);
assign FlushD = (arm & (PCWrPendingF | PCSrcW | BranchTakenE)) // ARM
              | (~arm & RVPCSrcE); // RISC-V

endmodule
