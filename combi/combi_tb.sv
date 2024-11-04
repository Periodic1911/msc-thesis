module combi_tb();

logic clk;
logic reset;
logic arm = 1;
logic [31:0] WriteData, DataAdr;
logic MemWrite;

// instantiate device to be tested
combi dut(clk, reset, arm, WriteData, DataAdr, MemWrite);

// initialize test
initial begin
  reset = 1; # 22; reset = 0;
  #500 $display("Simulation timed out after 500 ns");
  $exit;
end

// generate clock to sequence tests
always begin
  clk = 1; # 5; clk = 0; # 5;
end

// check results
always @(negedge clk) begin
  if(MemWrite) begin
    if(DataAdr === 100 & WriteData === 7) begin
      $display("Simulation succeeded");
      $exit;
    end else if (DataAdr !== 96) begin
      $display("Simulation failed");
      $exit;
    end
  end
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
