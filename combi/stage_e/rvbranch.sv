module rvbranch(input logic JumpE, BranchE,
                input logic [3:0] ALUFlags,
                input logic [3:0] CondE,
                output logic RVPCSrcE);

logic BranchTaken;
assign RVPCSrcE = JumpE | (BranchE & BranchTaken);

logic neg, zero, carry, overflow, ge;

assign {neg, zero, carry, overflow} = ALUFlags;
assign ge = (neg == overflow);

always_comb
  case(CondE)
    4'b0000: BranchTaken = zero; // EQ
    4'b0001: BranchTaken = ~zero; // NE
    4'b0010: BranchTaken = ~carry; // CC
    4'b0011: BranchTaken = carry; // CS
    4'b1010: BranchTaken = ge; // GE
    4'b1011: BranchTaken = ~ge; // LT
    default: BranchTaken = 1'bx; // undefined
  endcase


endmodule
