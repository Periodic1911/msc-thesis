module alu(
  input logic [2:0] ALUControlE,
  input logic [31:0] Op1E, Op2E,

`ifdef ARM
  output logic [3:0] ALUFlags, // ARM only
`endif
`ifdef RISCV
  output logic ZeroE, // RISC-V only
`endif
  output logic [31:0] ALUResultE
);

logic [31:0] addResult;

add_sub as(.a(Op1E), .b(Op2E), .q(addResult), .add(~ALUControlE[0])
`ifdef ARM
  ,
  .overflow(overflow), // ARM only
  .cOut(carry)
`endif
  );

always_comb
  case(ALUControlE)
    3'b000: ALUResultE = addResult; // add
    3'b001: ALUResultE = addResult; // sub
    3'b010: ALUResultE = Op1E & Op2E; // and
    3'b011: ALUResultE = Op1E | Op2E; // or
`ifdef RISCV
    // RISC-V only
    3'b101: ALUResultE = (Op1E < Op2E) ? 32'b1 : 32'b0; // slt
    //TODO: reuse add_sub carry chain?
`endif
    default: ALUResultE = 32'hxxxxxxxx; /// ???
  endcase

`ifdef RISCV
assign ZeroE = (ALUResultE == 0); // RISC-V only
`endif

`ifdef ARM
logic neg, zero, carry, overflow; // ARM only
assign ALUFlags = {neg, zero, carry, overflow}; // ARM only

always_comb begin : ARM_Flags // ARM only
  zero = (ALUResultE == 0);
  neg = ALUResultE[31];
end
`endif

endmodule

/* Combined adder-subtractor with one carry chain */
module add_sub(
  input logic [31:0] a, b,
  input logic add,
  output logic [31:0] q,
`ifdef ARM
  output logic cOut,
  output logic overflow // ARM only
`endif
);

logic [31:0] b_inv;
assign b_inv = add ? b : ~b;
logic carry_in = ~add;

`ifdef ARM
logic carry_out;
assign {carry_out, q} = a + b_inv + {31'b0, carry_in};

xor(cOut, carry_out, carry_in);
assign overflow = (~q[31] & a[31] & b_inv[31]) |
                  ( q[31] &~a[31] &~b_inv[31]);

`else
assign q = a + b_inv + {31'b0, carry_in};
`endif

endmodule
