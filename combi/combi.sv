//`define ARM
//`define RISCV

module combi (
  input logic clk, rst,
  output logic [31:0] WriteData, DataAddr,
  output logic MemWrite
);

/* fetch */
logic [31:0] RDD;

logic [31:0] PCF;
logic [31:0] PCPlus4F;

/* decode */
logic [31:0] Rd1D, Rd2D;
logic [31:0] immextD;
logic [4:0] RdD;
logic [31:0] PCD, PCPlus4D; // RISC-V only
logic [4:0] Rs1D, Rs2D; // RISC-V only
logic armD;

/* control outputs */
logic RegWriteD, MemWriteD;
logic [1:0] ALUSrcD;
logic [1:0] BranchD; // bit 0 RISC-V only
logic [1:0] MemSizeD;
logic MemSignedD;
logic [3:0] ALUControlD;
logic [4:0] ShiftAmtD; // ARM only
logic [2:0] ShiftTypeD; // ARM only
logic PCSrcD; // ARM only
logic [1:0] FlagWriteD; // ARM only
logic [3:0] CondD; // ARM only
logic [1:0] ResultSrcD; // bit 1 RISC-V only

/* execute */
logic [31:0] PCPlus4E; // RISC-V only
logic [4:0] RdE;
logic [31:0] WriteDataE; //, ALUResultE;

logic [1:0] ResultSrcE; // bit 1 is RISC-V only
logic PCSrcE; // ARM only
logic RegWriteE, MemWriteE;
logic [1:0] MemSizeE;
logic MemSignedE;

logic [1:0] BranchTakenE; // bit 0 RV only
logic [31:0] PCTargetE; // RISC-V only
logic [31:0] ALUResultE;

logic [4:0] Rs1E, Rs2E;
logic armE;

/* memory */
logic [31:0] ALUResultM, ReadDataW;
logic [31:0] PCPlus4M; // RV only
logic [4:0] RdM;

logic PCSrcM; // ARM only
logic RegWriteM;
logic [1:0] ResultSrcM; // bit 1 RV only
logic armM;

/* writeback */
logic [4:0] RdW;
logic [31:0] ResultW;
logic PCSrcW; // ARM only
logic RegWriteW;
logic armW;

/* hazzard unit */
logic StallF, StallD, FlushD, FlushE;
logic [1:0] ForwardAE, ForwardBE;


stage_f f_stage(.*);
stage_d d_stage(.*);
stage_e e_stage(.*);
stage_m m_stage(.*);
stage_w w_stage(.*);
hazard hazrdunit(.*);

endmodule
