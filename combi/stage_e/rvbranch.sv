module rvbranch(input logic JumpE, ZeroE, BranchE,
                output logic RVPCSrcE);

assign RVPCSrcE = JumpE | (BranchE & ZeroE);

endmodule
