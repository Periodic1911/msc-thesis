/* memory module supports:
* - byte, halfword, and word read/writes
* - sign extenstion for byte and halfword reads
* - unaligned halfword an word writes
*/
module memory #(parameter SIZE_LOG2=13)
            (input clk, rst,
             input WE,
             input [1:0] MemSize,
             input MemSigned,
             input [SIZE_LOG2-1:0] A,
             input [31:0] WD,
             output [31:0] RD);

logic [7:0] wBytes [3:0];
logic [7:0] rBytes [3:0];

always_comb write_align:
  case(A[1:0])
    2'b00: {wBytes[3],wBytes[2],wBytes[1],wBytes[0]} = WD;
    2'b01: {wBytes[0],wBytes[3],wBytes[2],wBytes[1]} = WD;
    2'b10: {wBytes[1],wBytes[0],wBytes[3],wBytes[2]} = WD;
    2'b11: {wBytes[1],wBytes[2],wBytes[0],wBytes[3]} = WD;
  endcase

logic [31:0] read;
assign RD = read;
always_comb read_align:
  case(A[1:0])
    2'b00: read = {rBytes[3],rBytes[2],rBytes[1],rBytes[0]};
    2'b01: read = {rBytes[0],rBytes[3],rBytes[2],rBytes[1]};
    2'b10: read = {rBytes[1],rBytes[0],rBytes[3],rBytes[2]};
    2'b11: read = {rBytes[1],rBytes[2],rBytes[0],rBytes[3]};
  endcase

logic [SIZE_LOG2-3:0] APlus4 = A[SIZE_LOG2-1:2] + 11'b1;
logic [SIZE_LOG2-3:0] AA = A[SIZE_LOG2-1:2];
logic [SIZE_LOG2-3:0] addrAlign [3:0];
always_comb addr_align:
  case(A[1:0])
    2'b00: addrAlign = {AA    ,AA    ,AA    ,AA    };
    2'b01: addrAlign = {AA    ,AA    ,AA    ,APlus4};
    2'b10: addrAlign = {AA    ,AA    ,APlus4,APlus4};
    2'b11: addrAlign = {AA    ,APlus4,APlus4,APlus4};
  endcase

ram #(SIZE_LOG2-2, 8) ram00 (clk, rst, WE, addrAlign[0], wBytes[0], rBytes[0]);
ram #(SIZE_LOG2-2, 8) ram01 (clk, rst, WE, addrAlign[1], wBytes[1], rBytes[1]);
ram #(SIZE_LOG2-2, 8) ram10 (clk, rst, WE, addrAlign[2], wBytes[2], rBytes[2]);
ram #(SIZE_LOG2-2, 8) ram11 (clk, rst, WE, addrAlign[3], wBytes[3], rBytes[3]);

endmodule
