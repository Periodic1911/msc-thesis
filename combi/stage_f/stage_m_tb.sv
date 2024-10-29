`timescale 1ns/1ps

module stage_m_tb ();
logic clk;
logic rst;
logic arm;
logic RVPCSrcE;
logic BranchTakenE;
logic PCSrcW;
logic [31:0] PCTargetE;
logic [31:0] ALUResultE;
logic [31:0] ResultW;
logic [31:0] RDD;
logic [31:0] PCF;
logic [31:0] PCPlus4F;
logic StallF;

stage_m test(.*);

always
  #20 clk = ~clk; // clock period 25MHz (40ns)
initial
  clk = 0;

initial begin
  rst = 1;
  #40 rst = 0;
  arm = 0;
  RVPCSrcE = 1;
  PCTargetE = 32'h1000;
  #40 
  arm = 1;
  PCSrcW = 1;
  ResultW = 32'h2000;
  #40 
  arm = 1;
  BranchTakenE = 1;
  ALUResultE = 32'h3000;
  #40 $exit();
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
