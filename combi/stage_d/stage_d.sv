module stage_d(
  input logic clk, rst,

  input logic [31:0] RDD, PCPlus4F, ResultW,
  input logic [4:0] RdW,
  input logic [31:0] PCF, // RISC-V only

  input logic RegWriteW,

  output logic [31:0] Rd1D, Rd2D,
  output logic [31:0] immextD,
  output logic [4:0] RdD,
  output logic [31:0] PCD, PCPlus4D, // RISC-V only
  output logic [4:0] Rs1D, Rs2D, // RISC-V only

  /* control outputs */
  output logic RegWriteD, MemWriteD, BranchD, ALUSrcD,
  output logic [1:0] MemSizeD,
  output logic MemSignedD,
  output logic [3:0] ALUControlD,
  output logic PCSrcD, // ARM only
  output logic [1:0] FlagWriteD, // ARM only
  output logic [3:0] CondD, // ARM only
  output logic [1:0] ResultSrcD, // bit 1 RISC-V only
  output logic JumpD, // RISC-V only
  output logic PCResD, // RISC-V only
  output logic armD, // combi only

  input logic StallD, FlushD
  );

`ifdef RISCV `ifdef ARM
logic armIn; // combi only
logic wasNotFlushed; // combi only

flopenr #(1) fd_stage_armbit(clk, rst, ~StallD,
  armD,
  armIn
);

flopenr #(1) fd_stage_wasFlushed(clk, (rst | FlushD), ~StallD,
  1'b1,
  wasNotFlushed
);
`endif `endif
`ifdef ARM `ifndef RISCV
logic armIn = 1;
logic wasNotFlushed = 1;
assign armD = 1;
`endif `endif
`ifdef RISCV `ifndef ARM
logic armIn = 0;
logic wasNotFlushed = 1;
assign armD = 0;
`endif `endif


logic [31:0] PCPlus8D = PCPlus4F;
logic [2:0] ImmSrcD;
logic [1:0] RegSrcD; // ARM only

combi_decoder dec(.*);

assign RdD = (armD) ? {1'b0, instr[15:12]} : instr[11:7];

logic [4:0] ra1, ra2;
always_comb
  if(armD) begin
    // Mux ARM RegSrc
    ra1 = RegSrcD[0] ? 5'd15 : {1'b0, instr[19:16]};
    ra2 = {1'b0, RegSrcD[1] ? RdD[3:0] : instr[3:0]};
  end else begin
    // RISC-V assignment
    ra1 = instr[19:15];
    ra2 = instr[24:20];
  end

assign {Rs1D, Rs2D} = {ra1, ra2};

assign CondD = instr[31:28]; // ARM only

regfile rf(.clk(~clk), .*, .wa3(RdW), .we3(RegWriteW), .wd3(ResultW),
  .r15(PCPlus8D), // ARM only
  .rd1(Rd1D), .rd2(Rd2D));

extend ext(.*, .immsrc(ImmSrcD), .immext(immextD));

logic [31:0] PCD_r, PCPlus4D_r;
assign PCD = PCD_r;
assign PCPlus4D = PCPlus4D_r;

logic [31:0] instr = RDD;

flopenr #(64) fd_stage(clk, (rst | FlushD), ~StallD,
  {PCF, PCPlus4F},
  {PCD_r, PCPlus4D_r}
);

endmodule
