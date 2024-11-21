`timescale 1ns/1ps

module combi_decoder_tb();

logic [31:0] instr;
logic armIn;
logic armD;
logic RegWriteD;
logic MemWriteD;
logic [2:0] ALUControlD;
logic BranchD;
logic ALUSrcD;
logic [1:0] ImmSrcD;
logic [1:0] RegSrcD;
logic PCSrcD;
logic [1:0] FlagWriteD;
`ifdef RISCV
  logic [1:0] ResultSrcD; // bit 1 RISC-V only
`else
  logic ResultSrcD; // bit 1 RISC-V only
`endif
logic JumpD;

logic ARM_tb;

combi_decoder combdec(.*);

initial begin
  ARM_tb = 0;
      instr = 32'h00500113;
  #10 instr = 32'h00C00193;
  #10 instr = 32'hFF718393;
  #10 instr = 32'h0023E233;
  #10 instr = 32'h0041F2B3;
  #10 instr = 32'h004282B3;
  #10 instr = 32'h02728863;
  #10 instr = 32'h0041A233;
  #10 instr = 32'h00020463;
  #10 instr = 32'h00000293;
  #10 instr = 32'h0023A233;
  #10 instr = 32'h005203B3;
  #10 instr = 32'h402383B3;
  #10 instr = 32'h0471AA23;
  #10 instr = 32'h06002103;
  #10 instr = 32'h005104B3;
  #10 instr = 32'h008001EF;
  #10 instr = 32'h00100113;
  #10 instr = 32'h00910133;
  #10 instr = 32'h0221A023;
  #10 instr = 32'h00210063;

  #10 ARM_tb = 1;
      instr = 32'hE04F000F;
  #10 instr = 32'hE2802005;
  #10 instr = 32'hE280300C;
  #10 instr = 32'hE2437009;
  #10 instr = 32'hE1874002;
  #10 instr = 32'hE0035004;
  #10 instr = 32'hE0855004;
  #10 instr = 32'hE0558007;
  #10 instr = 32'h0A00000C;
  #10 instr = 32'hE0538004;
  #10 instr = 32'hAA000000;
  #10 instr = 32'hE2805000;
  #10 instr = 32'hE0578002;
  #10 instr = 32'hB2857001;
  #10 instr = 32'hE0477002;
  #10 instr = 32'hE5837054;
  #10 instr = 32'hE5902060;
  #10 instr = 32'hE08FF000;
  #10 instr = 32'hE280200E;
  #10 instr = 32'hEA000001;
  #10 instr = 32'hE280200D;
  #10 instr = 32'hE280200A;
  #10 instr = 32'hE5802064;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
