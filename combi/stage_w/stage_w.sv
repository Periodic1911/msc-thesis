module stage_w (
  input logic clk, rst,

  input logic [31:0] ALUResultM, ReadDataW,
  input logic [31:0] PCPlus4M, // RV only
  input logic [4:0] RdM,
  input logic armM, // combi only

  input logic PCSrcM, // ARM only
  input logic RegWriteM,
  input logic [1:0] ResultSrcM, // bit 1 RV only

  output logic [4:0] RdW,
  output logic [31:0] ResultW,
  output logic PCSrcW, // ARM only
  output logic RegWriteW,
  output logic armW // combi only
  );

logic [1:0] ResultSrcW;
logic [31:0] PCPlus4W; // RV only
logic [31:0] ALUResultW;

flopr #(73) em_stage(clk, rst,
  {
   ALUResultM,
   PCPlus4M, // RV only
   RdM,
   PCSrcM, // ARM only
   RegWriteM,
   ResultSrcM // bit 1 RV only
  },
  {
   ALUResultW,
   PCPlus4W, // RV only
   RdW,
   PCSrcW, // ARM only
   RegWriteW,
   ResultSrcW // bit 1 RV only
  }
  );

`ifdef RISCV `ifdef ARM
flopr #(1) de_stage_armbit(clk, rst,
  armM,
  armW
);

`endif `endif
`ifdef ARM `ifndef RISCV
assign armW = 1;
`endif `endif
`ifdef RISCV `ifndef ARM
assign armW = 0;
`endif `endif


// PCPlus4W is RV only
mux3 #(32)result_mux(ALUResultW, ReadDataW, PCPlus4W,
                     ResultSrcW, ResultW);

endmodule
