module stage_e(
  input logic clk, rst, arm,

  input logic [31:0] Rd1D, Rd2D,
  input logic [31:0] immextD,
  input logic [4:0] RdD,
  input logic [31:0] PCD, PCPlus4D, // RISC-V only
  input logic [4:0] Rs1D, Rs2D, // RISC-V only

  output logic [31:0] PCPlus4E, // RISC-V only
  output logic [4:0] RdE,
  output logic [31:0] WriteDataE, ALUResultE,

  /* control inputs */
  input logic RegWriteD, MemWriteD, BranchD, ALUSrcD,
  input logic [2:0] ALUControlD,
  input logic PCSrcD, // ARM only
  input logic [1:0] FlagWriteD, // ARM only
  input logic [3:0] CondD, // ARM only
  input logic [1:0] ResultSrcD, // RISC-V only
  input logic JumpD, // RISC-V only

  output logic [1:0] ResultSrcE, // bit 1 is RISC-V only
  output logic PCSrc, // ARM only
  output logic RegWrite, MemWrite,

  output logic BranchTakenE, // ARM only
  output logic RVPCSrcE, // RISC-V only
  output logic [31:0] PCTargetE, // RISC-V only

  input logic [31:0] ALUResultM, ResultW,

  /* hazard unit */
  input logic FlushE,
  input logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1E, Rs2E
  );

logic [31:0] Rd1E, Rd2E;
logic [31:0] immextE;
logic [31:0] PCE; // RISC-V only
logic [4:0] Rs1E, Rs2E; // RISC-V only
logic RegWriteE, MemWriteE, BranchE, ALUSrcE;
logic [2:0] ALUControlE;
logic PCSrcE; // ARM only
logic [1:0] FlagWriteE; // ARM only
logic [3:0] CondE; // ARM only
logic [1:0] ResultSrcE; // RISC-V only
logic JumpE; // RISC-V only


flopr #(196) de_stage(clk, (rst | FlushE),
  {
  Rd1D, Rd2D, immextD, RdD,
  PCD, PCPlus4D, // RISC-V only
  Rs1D, Rs2D, // RISC-V only
  /* control inputs */
  RegWriteD, MemWriteD, BranchD, ALUSrcD,
  ALUControlD,
  PCSrcD, // ARM only
  FlagWriteD, // ARM only
  CondD, // ARM only
  FlagsD, // ARM only
  ResultSrcD, // bit 1 RISC-V only
  JumpD // RISC-V only
  },
  {
  Rd1E, Rd2E, immextE, RdE,
  PCE, PCPlus4E, // RISC-V only
  Rs1E, Rs2E, // RISC-V only
  /* control inputs */
  RegWriteE, MemWriteE, BranchE, ALUSrcE,
  ALUControlE,
  PCSrcE, // ARM only
  FlagWriteE, // ARM only
  CondE, // ARM only
  FlagsE, // ARM only
  ResultSrcE, // bit 1 RISC-V only
  JumpE // RISC-V only
  }
);

logic [3:0] FlagsE, FlagsD; // ARM only

// ARM only
condlogic condl(.*,
  );

rvbranch branch_rv(.*); // RV only

logic ZeroE; // RV only
logic [3:0] ALUFlags; // ARM only
alu myalu(.*);

logic [31:0] Op1E, Op2E;

mux3 #(32)forwardMux1(Rd1E, ResultW, ALUResultM, ForwardAE, Op1E);
mux3 #(32)forwardMux2(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
mux2 #(32)immMux2(WriteDataE, immextE, ALUSrcE, Op2E);

assign PCTargetE = PCE + immextE;

endmodule