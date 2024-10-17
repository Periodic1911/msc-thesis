module combi_decoder(input logic [31:0] instr,
                     input logic arm,
                     output logic RegWriteD,
                     output logic MemWriteD,
                     output logic [2:0] ALUControlD,
                     output logic BranchD,
                     output logic ALUSrcD,
                     output logic [1:0] ImmSrcD,

                     /* ARM only */
                     output logic PCSrcD,
                     output logic MemtoRegD,
                     output logic [1:0] FlagWriteD,
                     output logic [1:0] RegSrcD,

                     /* RISC-V only */
                     output logic [1:0] ResultSrcD,
                     output logic JumpD);

/* RISC-V */
logic opb5, funct7b5;
logic [2:0] funct3;
logic [1:0] ALUOp;
logic [2:0] RV_ALUControl;
logic [6:0] RV_op;
logic [1:0] ResultSrc;
logic RV_MemWrite, RV_Branch, RV_ALUSrc, RV_RegWrite, Jump;
logic [1:0] RV_ImmSrc;

assign {opb5, funct7b5, funct3, RV_op} = {
  instr[5],
  instr[30],
  instr[14:12],
  instr[6:0] };

rv_aludec rv_adec(.*, .ALUControl(RV_ALUControl));
rv_maindec rv_mdec(.*, .op(RV_op), .MemWrite(RV_MemWrite), .Branch(RV_Branch), .RegWrite(RV_RegWrite), .ImmSrc(RV_ImmSrc), .ALUSrc(RV_ALUSrc) );

/* ARM */
logic [1:0] ARM_Op;
logic [5:0] Funct;
logic [3:0] Rd;
logic [1:0] FlagW;
logic PCSrc, ARM_RegWrite, ARM_MemWrite, MemtoReg, ARM_ALUSrc, ARM_Branch;
logic [1:0] ARM_ImmSrc, RegSrc, ARM_ALUControl;

assign {ARM_Op, Funct, Rd} = {
  instr[27:26],
  instr[25:20],
  instr[15:12] };

arm_decoder arm_dec(.*, .Op(ARM_Op), .RegW(ARM_RegWrite), .MemW(ARM_MemWrite), .ALUSrc(ARM_ALUSrc), .ImmSrc(ARM_ImmSrc), .ALUControl(ARM_ALUControl), .Branch(ARM_Branch) );

/* Combine RISC-V and ARM */
always_comb
  if(arm) begin
    /* Don't care about RISC-V outputs */
    ResultSrcD = 2'bx;
    JumpD = 1'bx;

    /* Shared */
    RegWriteD = ARM_RegWrite;
    MemWriteD = ARM_MemWrite;
    ALUControlD = {1'bx, ARM_ALUControl};
    BranchD = ARM_Branch;
    ALUSrcD = ARM_ALUSrc;
    ImmSrcD = ARM_ImmSrc;

    /* ARM Only */
    PCSrcD = PCSrc;
    MemtoRegD = MemtoReg;
    FlagWriteD = FlagW;
    RegSrcD = RegSrc;

  end else begin /* RISC-V */
    /* Don't care about ARM outputs */
    PCSrcD = 1'bx;
    MemtoRegD = 1'bx;
    FlagWriteD = 2'bx;
    RegSrcD = 2'bx;

    /* Shared */
    RegWriteD = RV_RegWrite;
    MemWriteD = RV_MemWrite;
    ALUControlD = RV_ALUControl;
    BranchD = RV_Branch;
    ALUSrcD = RV_ALUSrc;
    ImmSrcD = RV_ImmSrc;

    /* RISC-V */
    ResultSrcD = ResultSrc;
    JumpD = Jump;
  end


endmodule


module rv_aludec(input logic opb5,
                 input logic [2:0] funct3,
                 input logic funct7b5,
                 input logic [1:0] ALUOp,
                 output logic [2:0] ALUControl);

logic RtypeSub;
assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract

always_comb
  case(ALUOp)
    2'b00: ALUControl = 3'b000; // addition
    2'b01: ALUControl = 3'b001; // subtraction
    default: case(funct3) // R–type or I–type ALU
      3'b000: if (RtypeSub)
                ALUControl = 3'b001; // sub
              else
                ALUControl = 3'b000; // add, addi
      3'b010:  ALUControl = 3'b101; // slt, slti
      3'b110:  ALUControl = 3'b011; // or, ori
      3'b111:  ALUControl = 3'b010; // and, andi
      default: ALUControl = 3'bxxx; // ???
    endcase
  endcase

endmodule

module rv_maindec(input logic [6:0] op,
                  output logic [1:0] ResultSrc,
                  output logic MemWrite,
                  output logic Branch, ALUSrc,
                  output logic RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [1:0] ALUOp);

logic [10:0] controls;

assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
  ResultSrc, Branch, ALUOp, Jump} = controls;

always_comb
  case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
    7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
    7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
    7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type
    7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
    7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU
    7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
    default: controls = 11'bx_xx_x_x_xx_x_xx_x; // ???
  endcase

endmodule

module arm_decoder(input logic [1:0] Op,
                   input logic [5:0] Funct,
                   input logic [3:0] Rd,
                   output logic Branch,
                   output logic [1:0] FlagW,
                   output logic PCSrc, RegW, MemW,
                   output logic MemtoReg, ALUSrc,
                   output logic [1:0] ImmSrc, RegSrc, ALUControl);

logic [9:0] controls;
logic ALUOp;

// Main Decoder
always_comb
  case(Op)
    // Data-processing immediate
    2'b00: if (Funct[5]) controls = 10'b0000101001;
    // Data-processing register
    else controls = 10'b0000001001;
    // LDR
    2'b01: if (Funct[0]) controls = 10'b0001111000;
    // STR
    else controls = 10'b1001110100;
    // B
    2'b10: controls = 10'b0110100010;
    // Unimplemented
    default: controls = 10'bx;
  endcase

assign {RegSrc, ImmSrc, ALUSrc, MemtoReg,
  RegW, MemW, Branch, ALUOp} = controls;

// ALU Decoder
always_comb
  if (ALUOp) begin // which DP instr?
    case(Funct[4:1])
      4'b0100: ALUControl = 2'b00; // ADD
      4'b0010: ALUControl = 2'b01; // SUB
      4'b0000: ALUControl = 2'b10; // AND
      4'b1100: ALUControl = 2'b11; // ORR
      default: ALUControl = 2'bx; // unimplemented
    endcase
    // update flags if S bit is set (C & V only for arith)
    FlagW[1] = Funct[0];
    FlagW[0] = Funct[0] &
      (ALUControl == 2'b00 | ALUControl == 2'b01);
  end else begin
    ALUControl = 2'b00; // add for non-DP instructions
    FlagW = 2'b00; // don't update Flags
  end

// PC Logic
assign PCSrc = ((Rd == 4'b1111) & RegW) | Branch;

endmodule