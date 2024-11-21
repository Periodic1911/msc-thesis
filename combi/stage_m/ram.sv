/* Read-Write Memory block */
module ram #(parameter SIZE_LOG2=13, parameter WIDTH=32)
            (input clk, rst,
             input WE,
             input [SIZE_LOG2-1:0] A,
             input [WIDTH-1:0] WD,
             output [WIDTH-1:0] RD);

  logic [WIDTH-1:0] mem_ff [2**SIZE_LOG2-1:0];
  logic [WIDTH-1:0] read;

  assign RD = read;

  always_ff @(posedge clk)
    read = mem_ff[A];

  always_ff @(posedge clk)
    if(WE) begin
      mem_ff[A] = WD;
    end

endmodule
