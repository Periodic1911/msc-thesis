module stage_e(
  input logic clk, rst,

  input logic [31:0] Rd1D, Rd2D,
  input logic [31:0] immextD,
  input logic [4:0] RdD,
`ifdef RISCV
  input logic [31:0] PCD, PCPlus4D, // RISC-V only
  input logic [4:0] Rs1D, Rs2D, // RISC-V only
`ifdef ARM
  input logic armD, // combi only
`endif
`endif

`ifdef RISCV
  output logic [31:0] PCPlus4E, // RISC-V only
`endif
  output logic [4:0] RdE,
  output logic [31:0] WriteDataE, ALUResultE,

  /* control inputs */
  input logic RegWriteD, MemWriteD, BranchD, ALUSrcD,
  input logic [2:0] ALUControlD,
`ifdef ARM
  input logic PCSrcD, // ARM only
  input logic [1:0] FlagWriteD, // ARM only
  input logic [3:0] CondD, // ARM only
`endif
`ifdef RISCV
  input logic [1:0] ResultSrcD, // bit 1 is RISC-V only
`else
  input logic ResultSrcD,
`endif
`ifdef RISCV
  input logic JumpD, // RISC-V only
`endif

`ifdef RISCV
  output logic [1:0] ResultSrcE, // bit 1 is RISC-V only
`else
  output logic ResultSrcE,
`endif
`ifdef ARM
  output logic PCSrcE, // ARM only
`endif
  output logic RegWriteE, MemWriteE,

`ifdef ARM
  output logic BranchTakenE, // ARM only
`endif
`ifdef RISCV
  output logic RVPCSrcE, // RISC-V only
  output logic [31:0] PCTargetE, // RISC-V only
`endif
`ifdef ARM
  output logic armE, // combi only
`endif

  input logic [31:0] ALUResultM, ResultW,

  /* hazard unit */
  input logic FlushE,
  input logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1E, Rs2E
  );

logic [31:0] Rd1E, Rd2E;
logic [31:0] immextE;
`ifdef RISCV
logic [31:0] PCE; // RISC-V only
`endif
logic RegWrite, MemWrite, BranchE, ALUSrcE;
logic [2:0] ALUControlE;
`ifdef ARM
logic PCSrc; // ARM only
logic [1:0] FlagWriteE; // ARM only
logic [3:0] CondE; // ARM only
`endif
`ifdef RISCV
logic JumpE; // RISC-V only
`endif

`ifdef ARM
logic [3:0] FlagsE, FlagsD; // ARM only

// ARM only
logic RegWriteE_ARM, MemWriteE_ARM;
logic [3:0] ALUFlags; // ARM only
assign RegWriteE = armE ? RegWriteE_ARM : RegWrite;
assign MemWriteE = armE ? MemWriteE_ARM : MemWrite;
condlogic condl(.*);
`endif

`ifdef RISCV
rvbranch branch_rv(.*); // RV only

logic ZeroE; // RV only
`endif

alu myalu(.*);

logic [31:0] Op1E, Op2E;

mux3 #(32)forwardMux1(Rd1E, ResultW, ALUResultM, ForwardAE, Op1E);
mux3 #(32)forwardMux2(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
mux2 #(32)immMux2(WriteDataE, immextE, ALUSrcE, Op2E);

assign PCTargetE = PCE + immextE;

flopr #(76) de_stage_riscv(clk, (rst | FlushE),
  {
  PCD, PCPlus4D, // RISC-V only
  Rs1D, Rs2D, // RISC-V only
  JumpD, // RISC-V only
  ResultSrcD[1] // bit 1 RISC-V only
  },
  {
  PCE, PCPlus4E, // RISC-V only
  Rs1E, Rs2E, // RISC-V only
  JumpE, // RISC-V only
  ResultSrcE[1] // bit 1 RISC-V only
  }
);

flopr #(11) de_stage_arm(clk, (rst | FlushE),
  {
  PCSrcD, // ARM only
  FlagWriteD, // ARM only
  CondD, // ARM only
  FlagsD // ARM only
  },
  {
  PCSrc, // ARM only
  FlagWriteE, // ARM only
  CondE, // ARM only
  FlagsE // ARM only
  }
);

flopr #(1) de_stage_combi(clk, (rst | FlushE),
  armD, // combi only
  armE  // combi only
);

flopr #(109) de_stage(clk, (rst | FlushE),
  {
  Rd1D, Rd2D, RdD, immextD,
  /* control inputs */
  RegWriteD, MemWriteD, BranchD, ALUSrcD,
  ALUControlD,
  ResultSrcD
  `ifdef RISCV 
    [0]
  `endif // bit 1 RISC-V only
  },
  {
  Rd1E, Rd2E, RdE, immextE,
  /* control inputs */
  RegWrite, MemWrite, BranchE, ALUSrcE,
  ALUControlE,
  ResultSrcE
  `ifdef RISCV 
    [0]
  `endif // bit 1 RISC-V only
  }
);

endmodule
