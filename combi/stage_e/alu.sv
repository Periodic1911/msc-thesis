module alu(
  input logic [3:0] ALUControlE,
  input logic [31:0] Op1E, Op2E,

  output logic [31:0] ALUResultE,
  output logic [3:0] ALUFlags, // ARM only
  output logic ZeroE // RISC-V only
);

logic [31:0] addResult;

add_sub as(.a(Op1E), .b(Op2E), .q(addResult), .add(~ALUControlE[0]), .cOut(carry),
  .overflow(overflow) // ARM only
  );

always_comb
  case(ALUControlE)
    4'b0000: ALUResultE = addResult; // add
    4'b0001: ALUResultE = addResult; // sub
    4'b0010: ALUResultE = Op1E & Op2E; // and
    4'b0011: ALUResultE = Op1E | Op2E; // or
    4'b0100: ALUResultE = Op1E ^ Op2E; // xor
    // RISC-V only
    4'b0101: ALUResultE = (Op1E < Op2E) ? 32'b1 : 32'b0; // slt TODO: reuse add_sub carry chain?
    default: ALUResultE = 32'hxxxxxxxx; /// ???
  endcase

assign ZeroE = (ALUResultE == 0); // RISC-V only

logic neg, zero, carry, overflow; // ARM only
assign ALUFlags = {neg, zero, carry, overflow}; // ARM only

always_comb begin : ARM_Flags // ARM only
  zero = (ALUResultE == 0);
  neg = ALUResultE[31];
end

endmodule

/* Combined adder-subtractor with one carry chain */
module add_sub(
  input logic [31:0] a, b,
  input logic add,
  output logic [31:0] q,
  output logic cOut,
  output logic overflow // ARM only
);

logic [31:0] b_inv;
assign b_inv = add ? b : ~b;
logic carry_in = ~add;
logic carry_out;

assign {carry_out, q} = a + b_inv + {31'b0, carry_in};
xor(cOut, carry_out, carry_in);
assign overflow = (~q[31] & a[31] & b_inv[31]) |
                  ( q[31] &~a[31] &~b_inv[31]);

endmodule

/* Barrel shifter with support for
* - 00 logical left shift
* - 10/01 arithmetic/logical right shift
* - 11 rotate right
*/
module barrel_shift(
  input logic [31:0] a,
  input logic [4:0] shift,
  input logic [1:0] op,
  output logic [31:0] q
);

logic signExt;
assign signExt = (op == 2'b10) ? a[31] : 1'b0;
logic rot = (op == 2'b11);

logic [31:0] rshift_stage [4:0];
logic [15:0] rs16;
mux2 #(16) brs16 ({16{signExt}}, a[15:0], rot, rs16);
mux2 #(32) brshift16 (a, {rs16, a[31:16]}, shift[4], rshift_stage[4]);
logic [7:0] rs8;
mux2 #(8)  brs8 ({8{signExt}}, rshift_stage[4][7:0], rot, rs8);
mux2 #(32) brshift8 (rshift_stage[4], {rs8, rshift_stage[4][31:8]}, shift[3], rshift_stage[3]);
logic [3:0] rs4;
mux2 #(4)  brs4 ({4{signExt}}, rshift_stage[3][3:0], rot, rs4);
mux2 #(32) brshift4 (rshift_stage[3], {rs4, rshift_stage[3][31:4]}, shift[2], rshift_stage[2]);
logic [1:0] rs2;
mux2 #(2)  brs2 ({2{signExt}}, rshift_stage[2][1:0], rot, rs2);
mux2 #(32) brshift2 (rshift_stage[2], {rs2, rshift_stage[2][31:2]}, shift[1], rshift_stage[1]);
logic rs1;
mux2 #(1)  brs1 (signExt, rshift_stage[1][0], rot, rs1);
mux2 #(32) brshift1 (rshift_stage[1], {rs1, rshift_stage[1][31:1]}, shift[0], rshift_stage[0]);

assign q = rshift_stage[0];

endmodule
