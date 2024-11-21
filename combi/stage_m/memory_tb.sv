module memory_tb();
logic clk, rst;
logic WE;
logic [1:0] MemSize;
logic MemSigned;
logic [12:0] A;
logic [31:0] WD;
logic [31:0] RD;

memory #($bits(A)) dut(.*);

always begin
  clk = 1; # 5; clk = 0; # 5;
end

initial begin
  rst = 1;
  #20 rst = 0;
  A = 96;
  WD = 32'h44332211;
  WE = 1;
  MemSize = 2;
  #10
  WD = 0;
  WE = 0;
  #10 A = 97;
  #10 A = 98;
  #10 A = 99;
  #10 $exit;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
