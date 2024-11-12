module stage_w (
  input logic clk, rst,

  input logic [31:0] ALUResultM, ReadDataW,
`ifdef RISCV
  input logic [31:0] PCPlus4M, // RV only
`endif
  input logic [4:0] RdM,
`ifdef RISCV `ifdef ARM
  input logic armM, // combi only
`endif `endif

`ifdef ARM
  input logic PCSrcM, // ARM only
`endif
  input logic RegWriteM,
`ifdef RISCV
  input logic [1:0] ResultSrcM, // bit 1 RV only
`else
  input logic ResultSrcM, // bit 1 RV only
`endif

  output logic [4:0] RdW,
  output logic [31:0] ResultW,
`ifdef ARM
  output logic PCSrcW, // ARM only
`endif
`ifdef RISCV `ifdef ARM
  output logic armW, // combi only
`endif `endif
  output logic RegWriteW
  );

logic [1:0] ResultSrcW;
`ifdef RISCV
logic [31:0] PCPlus4W; // RV only
`endif
logic [31:0] ALUResultW;

`ifdef RISCV
flopr #(33) em_stage_riscv(clk, rst,
  {
   PCPlus4M, // RV only
   ResultSrcM[1] // bit 1 RV only
  },
  {
   PCPlus4W, // RV only
   ResultSrcW[1] // bit 1 RV only
  }
);
`endif

`ifdef ARM
flopr #(1) em_stage_arm(clk, rst,
   PCSrcM, // ARM only
   PCSrcW // ARM only
);
`endif

`ifdef RISCV `ifdef ARM
flopr #(1) em_stage_combi(clk, rst,
   armM,
   armW
);
`endif `endif

flopr #(39) em_stage(clk, rst,
  {
   ALUResultM,
   RdM,
   RegWriteM,
   ResultSrcM
   `ifdef RISCV
     [0] // bit 1 RV only
   `endif
  },
  {
   ALUResultW,
   RdW,
   RegWriteW,
   ResultSrcW
   `ifdef RISCV
     [0] // bit 1 RV only
   `endif
  }
  );

// PCPlus4W is RV only
mux3 #(32)result_mux(ALUResultW, ReadDataW, PCPlus4W,
                     ResultSrcW, ResultW);

endmodule
