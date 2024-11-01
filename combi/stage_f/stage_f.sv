module stage_f (
  input clk,
  input rst,
  input arm,

  input RVPCSrcE,
  input BranchTakenE,
  input PCSrcW,

  input [31:0] PCTargetE,
  input [31:0] ALUResultE,
  input [31:0] ResultW,

  output [31:0] RDD,

  output [31:0] PCF,
  output [31:0] PCPlus4F,

  input StallF, FlushD
 );

logic [31:0] PCF3, PCF2, PCF1;
/* ARM muxes */
assign PCF3 = (arm & PCSrcW) ? ResultW : PCPlus4F;
assign PCF2 = (arm & BranchTakenE) ? ALUResultE : PCF3;
/* RV mux */
assign PCF1 = (!arm & RVPCSrcE) ? PCTargetE : PCF2;

logic [31:0] _PCF;
/* PC register */
always_ff @(posedge clk) begin: PC_REG
  if (!StallF) begin
    _PCF <= PCF1;
  end
end

/* Program memory */
prog_mem rom(.*, .A(_PCF[12:0]), .RD(RDD));

assign PCPlus4F = _PCF + 4;
assign PCF = _PCF;

endmodule
