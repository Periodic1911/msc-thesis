/* Read-Only Memory block */
module prog_mem #(parameter SIZE_LOG2=13) (input clk, input rst, input [SIZE_LOG2-1:0] A, output [31:0] RD);
  logic [31:0] mem_ff [2**SIZE_LOG2-1:0];
  logic [31:0] read;

  assign RD = mem_ff[A];

  /* initialize memory */
  initial begin
    $readmemh("program.hex", mem_ff);
  end
endmodule
