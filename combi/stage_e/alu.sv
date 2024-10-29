module alu(
  input logic [2:0] ALUControlE,
  input logic [31:0] Op1E, Op2E,

  output logic [31:0] ALUResultE,
  output logic [3:0] Flags, // ARM only
  output logic ZeroE // RISC-V only
);

logic [31:0] addResult;

add_sub as(.a(Op1E), .b(Op2E), .q(addResult), .add(ALUControlE[0]), .cOut(carry));

always_comb
  case(ALUControlE)
    3'b000: ALUResultE = addResult; // add
    3'b001: ALUResultE = addResult; // sub
    3'b010: ALUResultE = Op1E & Op2E; // and
    3'b011: ALUResultE = Op1E | Op2E; // or
    // RISC-V only
    3'b101: ALUResultE = (Op1E < Op2E) ? 32'b1 : 32'b0; // slt
    default: ALUResultE = 32'hxxxxxxxx; /// ???
  endcase

assign ZeroE = (ALUResultE == 0); // RISC-V only

logic neg, zero, carry, overflow;
assign Flags = {neg, zero, carry, overflow};

always_comb begin : ARM_Flags // ARM only
  zero = (ALUResultE == 0);
  neg = ALUResultE[31];
  overflow = (~ALUResultE[31] & Op1E[31] & Op2E[31]) |
             ( ALUResultE[31] &~Op1E[31] &~Op2E[31]);
end

endmodule

/* Combined adder-subtractor with one carry chain */
module add_sub(
  input logic [31:0] a, b,
  input logic add,
  output logic [31:0] q,
  output logic cOut
);

logic [31:0] b_inv = add ? b : ~b;
logic carry_in = ~add;
logic carry_out;

assign {carry_out, q} = a + b_inv + {31'b0, carry_in};
xor(cOut, carry_out, carry_in);

endmodule
