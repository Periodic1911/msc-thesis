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


`ifdef RISCV
flopr #(32) em_stage_riscv(clk, rst,
   PCPlus4E, // RV only
   PCPlus4M // RV only
);
`endif

`ifdef ARM
flopr #(1) em_stage_arm(clk, rst,
   PCSrcE, // ARM only
   PCSrcM // ARM only
);
`endif

`ifdef RISCV `ifdef ARM
flopr #(1) em_stage_combi(clk, rst,
   armE,
   armM
);
`endif `endif

flopr #(73) em_stage(clk, rst,
  { ALUResultE, WriteDataE,
   RdE,
   RegWriteE,
   ResultSrcE,
   MemWriteE
   },
  { ALUResultM, WriteDataM,
   RdM,
   RegWriteM,
   ResultSrcM,
   MemWriteM
   }
   );

ram #(13)datamem(clk, rst, MemWriteM, ALUResultM[14:2], WriteDataM, ReadDataW);

assign WriteData = WriteDataM;
assign DataAddr = ALUResultM;
assign MemWrite = MemWriteM;

endmodule
