module stage_e(
  input logic clk, rst,

  input logic [31:0] Rd1D, Rd2D,
  input logic [31:0] immextD,
  input logic [4:0] RdD,
  input logic [31:0] PCD, PCPlus4D, // RISC-V only
  input logic [4:0] Rs1D, Rs2D, // RISC-V only
  input logic armD, // combi only

  output logic [31:0] PCPlus4E, // RISC-V only
  output logic [4:0] RdE,
  output logic [31:0] WriteDataE, ALUResultE,

  /* control inputs */
  input logic RegWriteD, MemWriteD, BranchD, ALUSrcD,
  input logic [3:0] ALUControlD,
  input logic PCSrcD, // ARM only
  input logic [1:0] FlagWriteD, // ARM only
  input logic [3:0] CondD, // ARM only
  input logic [1:0] ResultSrcD, // RISC-V only
  input logic JumpD, // RISC-V only

  output logic [1:0] ResultSrcE, // bit 1 is RISC-V only
  output logic PCSrcE, // ARM only
  output logic RegWriteE, MemWriteE,

  output logic BranchTakenE, // ARM only
  output logic RVPCSrcE, // RISC-V only
  output logic [31:0] PCTargetE, // RISC-V only
  output logic armE, // combi only

  input logic [31:0] ALUResultM, ResultW,
  input logic PCResD,

  /* hazard unit */
  input logic FlushE,
  input logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1E, Rs2E
  );

logic [31:0] Rd1E, Rd2E;
logic [31:0] immextE;
logic [31:0] PCE; // RISC-V only
logic RegWrite, MemWrite, BranchE, ALUSrcE;
logic [3:0] ALUControlE;
logic PCSrc; // ARM only
logic [1:0] FlagWriteE; // ARM only
logic [3:0] CondE; // ARM only
logic JumpE; // RISC-V only

logic [3:0] FlagsE, FlagsD; // ARM only

// ARM only
logic RegWriteE_ARM, MemWriteE_ARM;
assign RegWriteE = armE ? RegWriteE_ARM : RegWrite;
assign MemWriteE = armE ? MemWriteE_ARM : MemWrite;
condlogic condl(.*);

rvbranch branch_rv(.*); // RV only

logic ZeroE; // RV only
logic [3:0] ALUFlags; // ARM only
alu myalu(.*);

logic [31:0] Op1E, Op2E;

mux3 #(32)forwardMux1(Rd1E, ResultW, ALUResultM, ForwardAE, Op1E);
mux3 #(32)forwardMux2(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
mux2 #(32)immMux2(WriteDataE, immextE, ALUSrcE, Op2E);

logic [31:0] PCPlus4;
logic PCResE;
mux2 #(32)PCmux(PCPlus4, PCTargetE, PCResE, PCPlus4E);

assign PCTargetE = PCE + immextE;

flopr #(198) de_stage(clk, (rst | FlushE),
  {
  Rd1D, Rd2D, RdD, immextD,
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
  PCResD, // RISC-V only
  JumpD // RISC-V only
  },
  {
  Rd1E, Rd2E, RdE, immextE,
  PCE, PCPlus4, // RISC-V only
  Rs1E, Rs2E, // RISC-V only
  /* control inputs */
  RegWrite, MemWrite, BranchE, ALUSrcE,
  ALUControlE,
  PCSrc, // ARM only
  FlagWriteE, // ARM only
  CondE, // ARM only
  FlagsE, // ARM only
  ResultSrcE, // bit 1 RISC-V only
  PCResE, // RISC-V only
  JumpE // RISC-V only
  }
);

`ifdef RISCV `ifdef ARM
flopr #(1) de_stage_armbit(clk, (rst | FlushE),
  armD,
  armE
);

`endif `endif
`ifdef ARM `ifndef RISCV
assign armE = 1;
`endif `endif
`ifdef RISCV `ifndef ARM
assign armE = 0;
`endif `endif

endmodule
