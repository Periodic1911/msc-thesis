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
