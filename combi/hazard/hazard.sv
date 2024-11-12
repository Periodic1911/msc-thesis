module hazard(
`ifdef RISCV `ifdef ARM
  input logic armD, armE, armM, armW,
`endif `endif
  input logic RegWriteM, RegWriteW,
  input logic [4:0] RdE, RdM, RdW,
`ifdef RISCV
  input logic [1:0] ResultSrcE, // bit 1 is RISC-V only
`else
  input logic ResultSrcE,
`endif
`ifdef RISCV
  input logic RVPCSrcE, // RISC-V only
`endif
  input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
`ifdef ARM
  input logic PCSrcD, PCSrcE, PCSrcM, PCSrcW, BranchTakenE, // ARM only
`endif

  output logic StallF, StallD, FlushD, FlushE,
  output logic [1:0] ForwardAE, ForwardBE
  );

/* Register forwarding */
// Don't forward R0 in RISC-V
`ifdef RISCV `ifndef ARM
  logic armE = 0;
`endif `endif
`ifndef RISCV `ifdef ARM
  logic armE = 1;
`endif `endif
logic Match_1E_M = (Rs1E == RdM) & (armE | Rs1E != 0);
logic Match_1E_W = (Rs1E == RdW) & (armE | Rs1E != 0);
logic Match_2E_M = (Rs2E == RdM) & (armE | Rs2E != 0);
logic Match_2E_W = (Rs2E == RdW) & (armE | Rs2E != 0);

always_comb begin
  if     (Match_1E_M & RegWriteM) ForwardAE = 2'b10; // Op1E = ALUOutM
  else if(Match_1E_W & RegWriteW) ForwardAE = 2'b01; // Op1E = ResultW
  else                            ForwardAE = 2'b00; // No forwarding

  if     (Match_2E_M & RegWriteM) ForwardBE = 2'b10; // Op2E = ALUOutM
  else if(Match_2E_W & RegWriteW) ForwardBE = 2'b01; // Op2E = ResultW
  else                            ForwardBE = 2'b00; // No forwarding
end

/* Load stall and control stall */
logic Match_12D_E = (Rs1D == RdE) | (Rs2D == RdE);
logic LDStall;
`ifdef RISCV
assign LDStall = Match_12D_E & ResultSrcE[0]; // bit 1 is RISC-V only
`else
assign LDStall = Match_12D_E & ResultSrcE; // bit 1 is RISC-V only
`endif
logic PCWrPendingF;
`ifdef ARM `ifdef RISCV
assign PCWrPendingF = (armD & PCSrcD) | (armE & PCSrcE) | (armM & PCSrcM); // ARM only
`endif `endif
`ifdef ARM `ifndef RISCV
assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM; // ARM only
`endif `endif

assign StallD = LDStall;
assign StallF = LDStall | PCWrPendingF;
assign FlushE = LDStall | (armE & BranchTakenE) | (~armE & RVPCSrcE);
assign FlushD = 
`ifndef RISCV `ifdef ARM
              (PCWrPendingF | PCSrcW | BranchTakenE); // ARM
`endif `endif
`ifdef RISCV `ifdef ARM
              (PCWrPendingF | (armW & PCSrcW) | (armE & BranchTakenE)) // ARM
              | (~armE & RVPCSrcE); // RISC-V
`endif `endif
`ifdef RISCV `ifndef ARM
              RVPCSrcE; // RISC-V
`endif `endif

endmodule
