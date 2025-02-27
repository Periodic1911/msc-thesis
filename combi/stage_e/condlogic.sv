module condlogic(input logic armE,
                 input logic [3:0] CondE,
                 input logic [3:0] ALUFlags,
                 input logic [1:0] FlagWriteE,
                 input logic PCSrc, RegWrite, MemWrite,
                 input logic [1:0] BranchE,
                 input logic [3:0] FlagsE,
                 output logic [3:0] FlagsD,
                 output logic PCSrcE, RegWriteE_ARM, MemWriteE_ARM,
                 output logic [1:0] BranchTakenE);

logic [1:0] FlagWrite;
logic CondEx;
logic [3:0] Flags;

mux2 #(2)flagmux1(FlagsE[3:2], ALUFlags[3:2], FlagWrite[1], FlagsD[3:2]);
mux2 #(2)flagmux0(FlagsE[1:0], ALUFlags[1:0], FlagWrite[0], FlagsD[1:0]);
mux2 #(4)rvarmflagmux(ALUFlags, FlagsE, armE, Flags);

// write controls are conditional
condcheck cc(CondE, Flags, CondEx);

assign FlagWrite = FlagWriteE & {2{CondEx}};
assign RegWriteE_ARM = RegWrite & CondEx;
assign MemWriteE_ARM = MemWrite & CondEx;
assign PCSrcE = PCSrc & CondEx;
assign BranchTakenE = BranchE & {2{CondEx}};

endmodule

module condcheck(input logic [3:0] Cond,
                 input logic [3:0] Flags,
                 output logic CondEx);

logic neg, zero, carry, overflow, ge;

assign {neg, zero, carry, overflow} = Flags;
assign ge = (neg == overflow);

always_comb
  case(Cond)
    4'b0000: CondEx = zero; // EQ
    4'b0001: CondEx = ~zero; // NE
    4'b0010: CondEx = carry; // CS
    4'b0011: CondEx = ~carry; // CC
    4'b0100: CondEx = neg; // MI
    4'b0101: CondEx = ~neg; // PL
    4'b0110: CondEx = overflow; // VS
    4'b0111: CondEx = ~overflow; // VC
    4'b1000: CondEx = carry & ~zero; // HI
    4'b1001: CondEx = ~(carry & ~zero); // LS
    4'b1010: CondEx = ge; // GE
    4'b1011: CondEx = ~ge; // LT
    4'b1100: CondEx = ~zero & ge; // GT
    4'b1101: CondEx = ~(~zero & ge); // LE
    4'b1110: CondEx = 1'b1; // Always
    default: CondEx = 1'bx; // undefined
  endcase

endmodule
