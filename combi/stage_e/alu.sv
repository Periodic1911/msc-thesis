module alu(
  input logic armE,
  input logic [4:0] ALUControlE,
  input logic [31:0] Op1E, Op2E,
  input logic [2:0] ShiftTypeE,
  input logic [4:0] ShiftAmtE,

  output logic [31:0] ALUResultE,
  output logic [3:0] ALUFlags
);

logic [31:0] addResult;

add_sub as(.a(Op1E), .b(Op2Shifted), .q(addResult),
  .add(~{(ALUControlE[4]&ALUControlE[2]), ALUControlE[0]}), .cOut(carry),
  .overflow(overflow)
  );

logic [31:0] shiftInput, shiftResult;
logic [4:0] shiftAmount;
logic [1:0] shiftOp;

mux2 #(2)shopmux(ALUControlE[1:0],ShiftTypeE[1:0],armE,shiftOp);

mux2 #(32)shinmux(Op1E,Op2E,armE,shiftInput);
mux4 #(5)shamtmux1(Op2E[4:0],Op2E[4:0],Op1E[4:0],ShiftAmtE,
                   {armE,ShiftTypeE[2]},
                   shiftAmount);

barrel_shift bs(shiftInput, shiftAmount, shiftOp, shiftResult);

logic [31:0] Op2Shifted;
mux2 #(32)armmux(Op2E,shiftResult,armE,Op2Shifted);

logic rv_ge = (addResult[31] == overflow);

always_comb
  case(ALUControlE)
    5'b00000: ALUResultE = addResult; // add
    5'b00001: ALUResultE = addResult; // sub
    5'b00010: ALUResultE = Op1E & Op2Shifted; // and
    5'b00011: ALUResultE = Op1E | Op2Shifted; // or
    5'b00100: ALUResultE = Op1E ^ Op2Shifted; // xor
    5'b00110: ALUResultE = Op2Shifted; // forward immediate
    // RISC-V only
    5'b00101: ALUResultE = {31'b0, ~rv_ge}; // slt
    5'b00111: ALUResultE = {31'b0, carry}; // sltu
    5'b01000: ALUResultE = shiftResult; // sll
    5'b01001: ALUResultE = shiftResult; // srl
    5'b01010: ALUResultE = shiftResult; // sra
    // ARM only
    5'b10111: ALUResultE = ~Op2Shifted; // mvn
    5'b10000: ALUResultE = Op1E & ~Op2Shifted; // bic
    5'b10100: ALUResultE = addResult; // rsb
    default: ALUResultE = 32'hxxxxxxxx; /// ???
  endcase

logic neg, zero, carry, overflow;
assign ALUFlags = {neg, zero, carry, overflow};

always_comb begin : ARM_Flags
  zero = (ALUResultE == 0);
  neg = ALUResultE[31];
end

endmodule

/* Combined adder-subtractor with one carry chain */
module add_sub(
  input logic [31:0] a, b,
  input logic [1:0] add,
  output logic [31:0] q,
  output logic cOut,
  output logic overflow // ARM only
);

logic [31:0] b_inv, a_inv;
assign b_inv = add[0] ? b : ~b;
assign a_inv = add[1] ? a : ~a;
logic carry_in = ~(&add);
logic carry_out;

assign {carry_out, q} = a_inv + b_inv + {31'b0, carry_in};
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

logic [31:0] arshift_stage [4:0];
mux2 #(32) barshift16 (a, {{16{signExt}}, a[31:16]}, shift[4], arshift_stage[4]);
mux2 #(32) barshift8 (arshift_stage[4], {{8{signExt}}, arshift_stage[4][31:8]}, shift[3], arshift_stage[3]);
mux2 #(32) barshift4 (arshift_stage[3], {{4{signExt}}, arshift_stage[3][31:4]}, shift[2], arshift_stage[2]);
mux2 #(32) barshift2 (arshift_stage[2], {{2{signExt}}, arshift_stage[2][31:2]}, shift[1], arshift_stage[1]);
mux2 #(32) barshift1 (arshift_stage[1], {signExt, arshift_stage[1][31:1]}, shift[0], arshift_stage[0]);

logic [31:0] ror_stage [4:0];
mux2 #(32) bror16 (a, {a[15:0], a[31:16]}, shift[4], ror_stage[4]);
mux2 #(32) bror8 (ror_stage[4], {ror_stage[4][7:0], ror_stage[4][31:8]}, shift[3], ror_stage[3]);
mux2 #(32) bror4 (ror_stage[3], {ror_stage[3][3:0], ror_stage[3][31:4]}, shift[2], ror_stage[2]);
mux2 #(32) bror2 (ror_stage[2], {ror_stage[2][1:0], ror_stage[2][31:2]}, shift[1], ror_stage[1]);
mux2 #(32) bror1 (ror_stage[1], {ror_stage[1][0], ror_stage[1][31:1]}, shift[0], ror_stage[0]);

logic [31:0] lshift_stage [4:0];
mux2 #(32) blshift16 (a, {a[15:0], 16'b0}, shift[4], lshift_stage[4]);
mux2 #(32) blshift8 (lshift_stage[4], {lshift_stage[4][23:0], 8'b0}, shift[3], lshift_stage[3]);
mux2 #(32) blshift4 (lshift_stage[3], {lshift_stage[3][27:0], 4'b0}, shift[2], lshift_stage[2]);
mux2 #(32) blshift2 (lshift_stage[2], {lshift_stage[2][29:0], 2'b0}, shift[1], lshift_stage[1]);
mux2 #(32) blshift1 (lshift_stage[1], {lshift_stage[1][30:0], 1'b0}, shift[0], lshift_stage[0]);

always_comb
  case(op)
    2'b00: q = lshift_stage[0];
    2'b01: q = arshift_stage[0];
    2'b10: q = arshift_stage[0];
    2'b11: q = ror_stage[0];
  endcase

endmodule
