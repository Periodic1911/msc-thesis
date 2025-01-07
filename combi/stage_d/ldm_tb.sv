`timescale 1ns/1ps

module ldm_tb();

logic clk;
logic [15:0] bits;
logic [3:0] current;
logic stall;
logic stall_en;

ldm ldm(.*);

// generate clock to sequence tests
always begin
  clk = 1; # 5; clk = 0; # 5;
end

initial begin
  // stim
  stall_en = 1'b1;
  bits = 16'hFFFF;
  #170 stall_en = 1'b0;
  #31 stall_en = 1'b1;
  bits = 16'h8421;
  #10 wait(!stall);
  stall_en = 1'b0;
  #1000 $exit;
  /*
  stall_en = 1'b1;
  for(int i = 1, int j = 0; i <= 2**15; i<<=1, j++) begin
    bits = i[15:0];
    #10 if(current == j[3:0]); else $display("ERROR: %016b -> %x %x", bits, current, j);
  end
  bits = 16'b0;
  #10 bits = 16'hFFFF;
  #10 bits = 16'h0003;
  #10 bits = 16'h8004;
  #10 bits = 16'hF0C0;
  #10;
  */
end


initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
