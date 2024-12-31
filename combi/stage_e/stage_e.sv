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
  input logic RegWriteD, MemWriteD,
  input logic [1:0] ALUSrcD,
  input logic [1:0] BranchD,
  input logic [3:0] ALUControlD,
  input logic [4:0] ShiftAmtD, // ARM only
  input logic [2:0] ShiftTypeD, // ARM only
  input logic PCSrcD, // ARM only
  input logic [1:0] FlagWriteD, // ARM only
  input logic [3:0] CondD, // ARM only
  input logic [1:0] ResultSrcD, // RISC-V only
  input logic [1:0] MemSizeD,
  input logic MemSignedD,

  output logic [1:0] ResultSrcE, // bit 1 is RISC-V only
  output logic PCSrcE, // ARM only
  output logic RegWriteE, MemWriteE,
  output logic [1:0] MemSizeE,
  output logic MemSignedE,

  output logic [1:0] BranchTakenE, // bit 0 RISC-V only
  output logic [31:0] PCTargetE, // RISC-V only
  output logic armE, // combi only

  input logic [31:0] ALUResultM, ResultW,

  /* hazard unit */
  input logic FlushE,
  input logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1E, Rs2E
  );

logic [31:0] Rd1E, Rd2E;
logic [31:0] immextE;
logic [31:0] PCE; // RISC-V only
logic RegWrite, MemWrite;
logic [1:0] ALUSrcE;
logic [1:0] BranchE; // bit 0 RISC-V only
logic [3:0] ALUControlE;
logic PCSrc; // ARM only
logic [1:0] FlagWriteE; // ARM only
logic [3:0] CondE; // ARM only

logic [3:0] FlagsE, FlagsD; // ARM only

// ARM only
logic RegWriteE_ARM, MemWriteE_ARM;
assign RegWriteE = armE ? RegWriteE_ARM : RegWrite;
assign MemWriteE = armE ? MemWriteE_ARM : MemWrite;
condlogic condl(.*);

// ARM only
logic [2:0] ShiftTypeE;
logic [4:0] ShiftAmtE;

logic [3:0] ALUFlags;
alu myalu(.*);

logic [31:0] Op1E, Op1Inter, Op2E;

mux3 #(32)forwardMux1(Rd1E, ResultW, ALUResultM, ForwardAE, Op1Inter);
mux2 #(32)PCMux1(Op1Inter, PCE, ALUSrcE[1] & ~armE, Op1E);
mux3 #(32)forwardMux2(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
mux3 #(32)immMux2(WriteDataE, immextE, {FlagsE, 28'b0}, (ALUSrcE & {armE, 1'b1}), Op2E); // FlagsE is ARM only

assign PCTargetE = PCE + immextE;

flopr #(209) de_stage(clk, (rst | FlushE),
  {
  Rd1D, Rd2D, RdD, immextD,
  PCD, PCPlus4D, // RISC-V only
  Rs1D, Rs2D, // RISC-V only
  /* control inputs */
  RegWriteD, MemWriteD, BranchD, ALUSrcD,
  MemSizeD, MemSignedD,
  ALUControlD,
  PCSrcD, // ARM only
  FlagWriteD, // ARM only
  CondD, // ARM only
  FlagsD, // ARM only
  ResultSrcD, // bit 1 RISC-V only
  ShiftTypeD, // ARM only
  ShiftAmtD // ARM only
  },
  {
  Rd1E, Rd2E, RdE, immextE,
  PCE, PCPlus4E, // RISC-V only
  Rs1E, Rs2E, // RISC-V only
  /* control inputs */
  RegWrite, MemWrite, BranchE, ALUSrcE,
  MemSizeE, MemSignedE,
  ALUControlE,
  PCSrc, // ARM only
  FlagWriteE, // ARM only
  CondE, // ARM only
  FlagsE, // ARM only
  ResultSrcE, // bit 1 RISC-V only
  ShiftTypeE, // ARM only
  ShiftAmtE // ARM only
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
