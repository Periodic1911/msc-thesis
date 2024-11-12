module stage_f (
  input clk,
  input rst,
`ifdef RISCV `ifdef ARM
  input armW, armE, // combi only
`endif `endif

`ifdef RISCV
  input RVPCSrcE,
`endif
`ifdef ARM
  input BranchTakenE,
  input PCSrcW,
`endif

`ifdef RISCV
  input [31:0] PCTargetE,
`endif
`ifdef ARM
  input [31:0] ALUResultE,
  input [31:0] ResultW,
`endif

  output [31:0] RDD,

`ifdef RISCV
  output [31:0] PCF,
  output [31:0] PCPlus4F,
`endif

  input StallF, StallD, FlushD
 );

`ifndef RISCV
logic [31:0] PCPlus4F;
logic [31:0] PCF;
`endif

logic [31:0] PCF3, PCF2, PCF1;
/* ARM muxes */
`ifdef ARM
  `ifdef RISCV
    assign PCF3 = (armW & PCSrcW) ? ResultW : PCPlus4F;
    assign PCF2 = (armE & BranchTakenE) ? ALUResultE : PCF3;
  `else
    assign PCF3 = PCSrcW ? ResultW : PCPlus4F;
    assign PCF2 = BranchTakenE ? ALUResultE : PCF3;
    assign PCF1 = PCF2;
  `endif
`endif
/* RV mux */
`ifdef RISCV
  `ifdef ARM
    assign PCF1 = (!armE & RVPCSrcE) ? PCTargetE : PCF2;
  `else
    assign PCF1 = RVPCSrcE ? PCTargetE : PCF2;
  `endif
`endif

logic [31:0] _PCF;
/* PC register */
always_ff @(posedge clk) begin: PC_REG
  if(rst) _PCF <= 32'b0;
  else if (!StallF) _PCF <= PCF1;
end

/* Program memory */
prog_mem rom(.*, .A(_PCF[14:2]), .RD(RDD));

assign PCPlus4F = _PCF + 4;
assign PCF = _PCF;

endmodule
