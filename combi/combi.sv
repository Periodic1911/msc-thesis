`define ARM
`define RISCV

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
`ifdef RISCV logic [31:0] PCD, PCPlus4D; `endif
`ifdef RISCV logic [4:0] Rs1D, Rs2D; `endif

`ifdef RISCV
  `ifdef ARM logic armD; `endif
`endif

             /* control outputs */
             logic RegWriteD, MemWriteD, BranchD, ALUSrcD;
             logic [2:0] ALUControlD;
`ifdef ARM   logic PCSrcD; `endif
`ifdef ARM   logic [1:0] FlagWriteD; `endif
`ifdef ARM   logic [3:0] CondD; `endif
`ifdef RISCV logic JumpD; `endif
`ifdef RISCV logic [1:0] ResultSrcD; // bit 1 RISC-V only
`else        logic ResultSrcD; `endif

             /* execute */
             logic [4:0] RdE;
             logic [31:0] WriteDataE;

             logic RegWriteE, MemWriteE;
             logic [31:0] ALUResultE;
             logic [4:0] Rs1E, Rs2E;
`ifdef ARM   logic PCSrcE; `endif
`ifdef ARM   logic BranchTakenE; `endif
`ifdef RISCV logic RVPCSrcE; `endif
`ifdef RISCV logic [31:0] PCTargetE; `endif
`ifdef RISCV logic [31:0] PCPlus4E; `endif
`ifdef RISCV logic [1:0] ResultSrcE; // bit 1 RISC-V only
`else        logic ResultSrcE; `endif

`ifdef RISCV
  `ifdef ARM logic armE; `endif
`endif

             /* memory */
             logic [31:0] ALUResultM, ReadDataW;
             logic [4:0] RdM;
             logic RegWriteM;
`ifdef ARM   logic PCSrcM; `endif
`ifdef RISCV logic [31:0] PCPlus4M; `endif
`ifdef RISCV logic [1:0] ResultSrcM; // bit 1 RV only
`else        logic [1:0] ResultSrcM; `endif

`ifdef RISCV
  `ifdef ARM logic armM; `endif
`endif

             /* writeback */
             logic [4:0] RdW;
             logic [31:0] ResultW;
             logic RegWriteW;
`ifdef ARM   logic PCSrcW; `endif
`ifdef RISCV
  `ifdef ARM logic armW; `endif
`endif

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
