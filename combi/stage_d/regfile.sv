module regfile(input logic clk,
               input logic armD, // combi only
               input logic we3,
               input logic [4:0] ra1, ra2, wa3,
               input logic [31:0] wd3,
               input logic [31:0] r15, // ARM only
               output logic [31:0] rd1, rd2 );

logic [31:0] rf[31:0];

always_ff @(posedge clk)
  if(we3) rf[wa3] <= wd3;

assign rd1 = register_read(ra1);
assign rd2 = register_read(ra2);

/* if in RISC-V mode, return 0 when the address is 0 */
/* if in ARM mode, return r15 when the address is 15 */
function logic [31:0] register_read(logic [4:0] a);
  if(armD) register_read = (a[3:0] == 4'b1111) ? r15 : rf[a];
  else register_read = (a == 0) ? 0 : rf[a];
endfunction

endmodule
