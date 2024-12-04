module combi_tb();

logic clk;
logic reset;
logic [31:0] WriteData, DataAdr;
logic MemWrite;

// instantiate device to be tested
combi dut(clk, reset, WriteData, DataAdr, MemWrite);

// initialize test
initial begin
  reset = 1; # 22; reset = 0;
  #10_000 $display("Simulation timed out after 10000 ns");
  $exit;
end

// generate clock to sequence tests
always begin
  clk = 1; # 5; clk = 0; # 5;
end

// check results
always @(negedge clk) begin
  if(MemWrite) begin
    if(DataAdr === 32'h10000000) begin
      $write("%c",WriteData[7:0]);
    end
    if(DataAdr === 100 & WriteData === 25) begin
      $display("RISCV Simulation succeeded");
      #40 $exit;
    end else if(DataAdr === 100 & WriteData === 7) begin
      $display("ARM   Simulation succeeded");
    end/* else if (DataAdr !== 96) begin
      $display("Simulation failed");
      $exit;
    end*/
  end
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

endmodule
