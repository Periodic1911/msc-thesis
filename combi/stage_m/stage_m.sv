module stage_m (
  input logic clk, rst,
  input logic [31:0] ALUResultE, WriteDataE,
  input logic [31:0] PCPlus4E, // RV only
  input logic [4:0] RdE,
  input logic armE, // combi only

  output logic [31:0] ALUResultM, ReadDataW,
  output logic [31:0] PCPlus4M, // RV only
  output logic [4:0] RdM,

  input logic PCSrcE, // ARM only
  input logic RegWriteE,
  input logic [1:0] ResultSrcE, // bit 1 RV only
  input logic MemWriteE,
  input logic [1:0] MemSizeE,
  input logic MemSignedE,

  output logic PCSrcM, // ARM only
  output logic RegWriteM,
  output logic [1:0] ResultSrcM, // bit 1 RV only
  output logic armM, // combi only

  /* debug port */
  output logic [31:0] WriteData, DataAddr,
  output logic MemWrite
  );

logic [31:0] WriteDataM;
logic MemWriteM;
logic [1:0] MemSizeM;
logic MemSignedM;

flopr #(109) em_stage(clk, rst,
  { ALUResultE, WriteDataE,
   PCPlus4E, // RV only
   RdE,
   PCSrcE, // ARM only
   RegWriteE,
   ResultSrcE,
   MemWriteE,
   MemSizeE,
   MemSignedE
   },
  { ALUResultM, WriteDataM,
   PCPlus4M, // RV only
   RdM,
   PCSrcM, // ARM only
   RegWriteM,
   ResultSrcM,
   MemWriteM,
   MemSizeM,
   MemSignedM
   }
 );

`ifdef RISCV `ifdef ARM
flopr #(1) de_stage_armbit(clk, rst,
  armE,
  armM
);

`endif `endif
`ifdef ARM `ifndef RISCV
assign armM = 1;
`endif `endif
`ifdef RISCV `ifndef ARM
assign armM = 0;
`endif `endif

memory #(13)datamem(clk, rst, MemWriteM, MemSizeM, MemSignedM, ALUResultM[12:0], WriteDataM, ReadDataW);
//ram #(13)datamem(clk, rst, MemWriteM, ALUResultM[14:2], WriteDataM, ReadDataW);

assign WriteData = WriteDataM;
assign DataAddr = ALUResultM;
assign MemWrite = MemWriteM;

endmodule
