module stage_m (
  input logic clk, rst, arm,
  input logic [31:0] ALUResultE, WriteDataE,
  input logic [31:0] PCPlus4E, // RV only
  input logic [4:0] RdE,

  output logic [31:0] ALUResultM, ReadDataW,
  output logic [31:0] PCPlus4M, // RV only
  output logic [4:0] RdM,

  input logic PCSrcE, // ARM only
  input logic RegWriteE,
  input logic [1:0] ResultSrcE, // bit 1 RV only
  input logic MemWriteE,

  output logic PCSrcM, // ARM only
  output logic RegWriteM,
  output logic [1:0] ResultSrcM, // bit 1 RV only

  /* debug port */
  output logic [31:0] WriteData, DataAddr,
  );

logic [31:0] WriteDataM;
logic MemWriteM;

flopr #(106) em_stage(clk, rst,
  { ALUResultE, WriteDataE,
   PCPlus4E, // RV only
   RdE,
   PCSrcE, // ARM only
   RegWriteE,
   ResultSrcE,
   MemWriteE
   },
  { ALUResultM, WriteDataM,
   PCPlus4M, // RV only
   RdM,
   PCSrcM, // ARM only
   RegWriteM,
   ResultSrcM,
   MemWriteM
   }
   );

ram datamem(clk, rst, MemWriteM, ALUResultM, WriteDataM, ReadDataW);

assign WriteData = WriteDataM;
assign DataAddr = ALUResultM;

endmodule
