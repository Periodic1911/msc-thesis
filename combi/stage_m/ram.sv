/* Read-Write Memory block */
module ram #(parameter SIZE_LOG2=13)
            (input clk, rst,
             input WE,
             input [SIZE_LOG2-1:0] A,
             input [31:0] WD,
             output [31:0] RD);

  logic [31:0] mem_ff [2**SIZE_LOG2-1:0];
  logic [31:0] read;

  assign RD = read;

  always_ff @(posedge clk)
    read = mem_ff[A];

  always_ff @(posedge clk)
    if(WE) begin
      mem_ff[A] = WD;
    end

endmodule
