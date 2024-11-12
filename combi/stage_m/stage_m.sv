module stage_m (
  input logic clk, rst,
  input logic [31:0] ALUResultE, WriteDataE,
`ifdef RISCV
  input logic [31:0] PCPlus4E, // RV only
`endif
  input logic [4:0] RdE,
`ifdef RISCV `ifdef ARM
  input logic armE, // combi only
`endif `endif

  output logic [31:0] ALUResultM, ReadDataW,
`ifdef RISCV
  output logic [31:0] PCPlus4M, // RV only
`endif
  output logic [4:0] RdM,

`ifdef ARM
  input logic PCSrcE, // ARM only
`endif
  input logic RegWriteE,
`ifdef RISCV
  input logic [1:0] ResultSrcE, // bit 1 RV only
`else
  input logic ResultSrcE, // bit 1 RV only
`endif
  input logic MemWriteE,

  output logic PCSrcM, // ARM only
  output logic RegWriteM,
`ifdef RISCV
  output logic [1:0] ResultSrcM, // bit 1 RV only
`else
  output logic ResultSrcM, // bit 1 RV only
`endif
`ifdef RISCV `ifdef ARM
  output logic armM, // combi only
`endif `endif

  /* debug port */
  output logic [31:0] WriteData, DataAddr,
  output logic MemWrite
  );

logic [31:0] WriteDataM;
logic MemWriteM;


`ifdef RISCV
flopr #(33) em_stage_riscv(clk, rst,
  {
   PCPlus4E, // RV only
   ResultSrcE[1]
  },
  {
   PCPlus4M, // RV only
   ResultSrcM[1]
  }
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

flopr #(72) em_stage(clk, rst,
  { ALUResultE, WriteDataE,
   RdE,
   RegWriteE,
   MemWriteE,
   ResultSrcE
   `ifdef RISCV
     [0]
   `endif
   },
  { ALUResultM, WriteDataM,
   RdM,
   RegWriteM,
   MemWriteM,
   ResultSrcM
   `ifdef RISCV
     [0]
   `endif
   }
   );

ram #(13)datamem(clk, rst, MemWriteM, ALUResultM[12:0], WriteDataM, ReadDataW);

assign WriteData = WriteDataM;
assign DataAddr = ALUResultM;
assign MemWrite = MemWriteM;

endmodule
