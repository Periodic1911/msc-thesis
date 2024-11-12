module stage_d(
  input logic clk, rst,

  input logic [31:0] RDD, PCPlus4F, ResultW,
  input logic [4:0] RdW,
`ifdef RISCV
  input logic [31:0] PCF, // RISC-V only
`endif

  input logic RegWriteW,

  output logic [31:0] Rd1D, Rd2D,
  output logic [31:0] immextD,
  output logic [4:0] RdD,
`ifdef RISCV
  output logic [31:0] PCD, PCPlus4D, // RISC-V only
  output logic [4:0] Rs1D, Rs2D, // RISC-V only
`endif

  /* control outputs */
  output logic RegWriteD, MemWriteD, BranchD, ALUSrcD,
  output logic [2:0] ALUControlD,
`ifdef ARM
  output logic PCSrcD, // ARM only
  output logic [1:0] FlagWriteD, // ARM only
  output logic [3:0] CondD, // ARM only
`endif
`ifdef RISCV
  output logic [1:0] ResultSrcD, // bit 1 RISC-V only
`else
  output logic ResultSrcD,
`endif
`ifdef RISCV
  output logic JumpD, // RISC-V only
`endif
`ifdef RISCV `ifdef ARM
  output logic armD, // combi only
`endif `endif

  input logic StallD, FlushD
  );

logic [31:0] PCPlus8D = PCPlus4F;
logic [1:0] ImmSrcD;
`ifdef ARM
logic [1:0] RegSrcD; // ARM only
`endif

combi_decoder dec(.*);

assign RdD = (armD) ? {1'b0, instr[15:12]} : instr[11:7];

logic [4:0] ra1, ra2;
always_comb
`ifdef ARM
  `ifdef RISCV
  if(armD) begin
  `endif
    // Mux ARM RegSrc
    ra1 = RegSrcD[0] ? 5'd15 : {1'b0, instr[19:16]};
    ra2 = {1'b0, RegSrcD[1] ? RdD[3:0] : instr[3:0]};
`endif /* ARM */
`ifdef RISCV
  `ifdef ARM
  end else begin
  `endif
    // RISC-V assignment
    ra1 = instr[19:15];
    ra2 = instr[24:20];
  `ifdef ARM
  end
  `endif
`endif /* RISCV */

assign {Rs1D, Rs2D} = {ra1, ra2};

`ifdef ARM
assign CondD = instr[31:28]; // ARM only
`endif

regfile rf(.clk(~clk), .*, .wa3(RdW), .we3(RegWriteW), .wd3(ResultW),
`ifdef ARM
  .r15(PCPlus8D), // ARM only
`endif
  .rd1(Rd1D), .rd2(Rd2D));

extend ext(.*, .immsrc(ImmSrcD), .immext(immextD));

logic [31:0] PCD_r, PCPlus4D_r;
assign PCD = PCD_r;
assign PCPlus4D = PCPlus4D_r;

logic [31:0] instr = RDD;

flopenr #(64) fd_stage(
  clk, (rst | FlushD), ~StallD,
  {PCF, PCPlus4F},
  {PCD_r, PCPlus4D_r}
);

`ifdef RISCV `ifdef ARM
logic armIn; // combi only

flopenr #(1) fd_stage_combi(
  clk, (rst | FlushD), ~StallD,
  armD,
  armIn
);
`endif `endif


endmodule
