/* Read-Only Memory block */
module prog_mem #(parameter SIZE_LOG2=13) (input clk, input rst, input [SIZE_LOG2-1:0] A, output [31:0] RD, input FlushD, StallD);
  logic [31:0] mem_ff [2**SIZE_LOG2-1:0];
  logic [31:0] read;

  assign RD = read;

  always_ff @(posedge clk)
    if(rst | FlushD) read = 32'b0;
    else if (!StallD) read = mem_ff[A];

  /* initialize memory */
  initial begin
`ifdef RISCV `ifdef ARM
    $readmemh("stage_f/program_combi.hex", mem_ff);
`endif `endif
`ifdef ARM `ifndef RISCV
    $readmemh("stage_f/program_arm.hex", mem_ff);
`endif `endif
`ifdef RISCV `ifndef ARM
    $readmemh("stage_f/program_rv.hex", mem_ff);
`endif `endif
  end
endmodule
