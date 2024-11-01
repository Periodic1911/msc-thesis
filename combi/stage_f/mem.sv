/* Read-Only Memory block */
module prog_mem #(parameter SIZE_LOG2=13) (input clk, input [SIZE_LOG2-1:0] A, output [31:0] RD, input FlushD);
  logic [31:0] mem_ff [2**SIZE_LOG2-1:0];
  logic [31:0] read;

  assign RD = read;

  always_ff @(posedge clk)
    if(!FlushD) read = mem_ff[A];
    else read = 32'b0;

  /* initialize memory */
  initial begin
    $readmemh("program.hex", mem_ff);
  end
endmodule
