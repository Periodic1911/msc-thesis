module stage_w (
  input logic clk, rst, arm,

  input logic [31:0] ALUResultM, ReadDataW,
  input logic [31:0] PCPlus4M, // RV only
  input logic [4:0] RdM,

  input logic PCSrcM, // ARM only
  input logic RegWriteM,
  input logic [1:0] ResultSrcM, // bit 1 RV only

  output logic [4:0] RdW,
  output logic [31:0] ResultW,
  output logic PCSrcW, // ARM only
  output logic RegWriteW
  );

logic [1:0] ResultSrcW;
logic [4:0] RdW;
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

// PCPlus4W is RV only
mux3 #(32)result_mux(ReadDataW, PCPlus4W, ALUResultW,
                     ResultSrcW, ResultW);

endmodule
