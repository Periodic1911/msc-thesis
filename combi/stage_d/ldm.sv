module ldm(
  input logic clk,
  input logic [15:0] bits,
  output logic [3:0] current,
  output logic stall,
  input logic stall_en
);

logic [15:0] mask, mbits;

always_ff @(posedge clk)
  if(!(stall && stall_en)) mask <= 16'h0;
  else case(current)
    4'h0: mask <= 16'h0001;
    4'h1: mask <= 16'h0003;
    4'h2: mask <= 16'h0007;
    4'h3: mask <= 16'h000F;
    4'h4: mask <= 16'h001F;
    4'h5: mask <= 16'h003F;
    4'h6: mask <= 16'h007F;
    4'h7: mask <= 16'h00FF;
    4'h8: mask <= 16'h01FF;
    4'h9: mask <= 16'h03FF;
    4'ha: mask <= 16'h07FF;
    4'hb: mask <= 16'h0FFF;
    4'hc: mask <= 16'h1FFF;
    4'hd: mask <= 16'h3FFF;
    4'he: mask <= 16'h7FFF;
    4'hf: mask <= 16'hFFFF;
  endcase

assign mbits = bits & ~mask;

logic [3:0] msc, lsc;

assign msc = {|mbits[15:12], |mbits[11:8], |mbits[7:4], |mbits[3:0]};

logic [1:0] msp, lsp;

penc p1(msc, msp);

mux4 #(4)lscmux(mbits[3:0], mbits[7:4], mbits[11:8], mbits[15:12],
                msp, lsc);

penc p2(lsc, lsp);

assign current = {msp, lsp};
assign stall = |msc;

endmodule

// 4-bit priority encoder
module penc(input logic [3:0] a, output logic [1:0] q);

always_comb
  casez(a)
    4'b???1: q = 2'b00;
    4'b??10: q = 2'b01;
    4'b?100: q = 2'b10;
    4'b1000: q = 2'b11;
    default: q = 2'bx;
  endcase

endmodule
