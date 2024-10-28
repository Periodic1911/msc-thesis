`timescale 1ns/1ps

module add_sub_tb;

  logic [31:0] a, b;
  logic add;
  logic [31:0] q;
  logic cOut;

add_sub dut(.*);

initial begin
  add = 1;
  a = 32'h00000001;
  b = 32'h00000001;
  #10
  add = 1;
  a = 32'h80000000;
  b = 32'h80000000;
  #10
  add = 0;
  a = 32'h00000002;
  b = 32'h00000001;
  if(cOut != 1) $warning("Carry on subtract without overflow is wrong");
  #10
  add = 0;
  a = 32'h00000001;
  b = 32'h00000002;
  if(cOut != 0) $warning("Carry on subtract with overflow is wrong");
  #10;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
