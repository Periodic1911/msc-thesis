module stage_f (
  input clk,
  input rst,
  input armW, armE, // combi only

  input RVPCSrcE,
  input BranchTakenE,
  input PCSrcW,

  input [31:0] PCTargetE,
  input [31:0] ALUResultE,
  input [31:0] ResultW,

  output [31:0] RDD,

  output [31:0] PCF,
  output [31:0] PCPlus4F,

  input StallF, StallD, FlushD
 );

logic [31:0] PCF3, PCF2, PCF1;
/* ARM muxes */
assign PCF3 = (armW & PCSrcW) ? ResultW : PCPlus4F;
assign PCF2 = (armE & BranchTakenE) ? ALUResultE : PCF3;
/* RV mux */
assign PCF1 = (!armE & RVPCSrcE) ? PCTargetE : PCF2;

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
