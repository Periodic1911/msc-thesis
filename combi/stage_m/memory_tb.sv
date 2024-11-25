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
  WD = 32'hAABBCC11;
  WE = 1;
  MemSize = 2;
  #10
  A = 97;
  WD = 32'h55443322;
  #10
  WD = 0;
  WE = 0;
  #10 A = 97;
  #10 A = 98;
  #10 A = 99;
  #10 A = 96;
  MemSigned = 0;
  MemSize = 0;
  #10
  MemSize = 1;
  #10 A = 97;
  MemSize = 0;
  #10
  MemSize = 1;
  #10 A = 100;
  WD = 32'h40808080;
  WE = 1;
  #10
  WE = 0;
  MemSigned = 1;
  MemSize = 0;
  #10
  MemSize = 1;
  #10
  MemSize = 2;
  #10 $exit;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
