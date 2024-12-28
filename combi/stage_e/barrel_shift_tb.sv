module barrel_shift_tb();
logic [31:0] a;
logic [4:0] shift;
logic [1:0] op;
logic [31:0] q;

barrel_shift dut(.*);

initial begin
  op = 2'b01; // logical right
  a = 32'hF000DEAD;
  shift = 0;
  #10 shift = 1;
  #10 shift = 2;
  #10 shift = 3;
  #10 shift = 4;
  #10 shift = 8;
  #10 shift = 16;
  #10 shift = 17;
  #10 shift = 31;
  #10 op = 2'b10; // arith right
  shift = 0;
  #10 shift = 1;
  #10 shift = 2;
  #10 shift = 3;
  #10 shift = 4;
  #10 shift = 8;
  #10 shift = 16;
  #10 shift = 17;
  #10 shift = 31;
  #10 op = 2'b11; // rotate right
  shift = 0;
  #10 shift = 1;
  #10 shift = 2;
  #10 shift = 3;
  #10 shift = 4;
  #10 shift = 8;
  #10 shift = 16;
  #10 shift = 17;
  #10 shift = 31;
  #10 $exit;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
