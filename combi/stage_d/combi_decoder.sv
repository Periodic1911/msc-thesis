module combi_decoder(input logic [31:0] instr,
                     input logic armIn,
                     input logic wasNotFlushed,
                     output logic RegWriteD,
                     output logic MemWriteD,
                     output logic [3:0] ALUControlD,
                     output logic BranchD,
                     output logic ALUSrcD,
                     output logic [2:0] ImmSrcD,

                     /* ARM only */
                     output logic PCSrcD,
                     output logic [1:0] FlagWriteD,
                     output logic [1:0] RegSrcD,

                     output logic [1:0] ResultSrcD, // bit 1 RISC-V only
`ifdef ARM `ifdef RISCV
                     output logic armD,
`endif `endif
                     output logic PCResD, // RISC-V only
                     output logic JumpD // RISC-V only
                     );
`ifndef ARM
logic armD;
`endif
`ifndef RISCV
logic armD;
`endif

/* RISC-V */
logic opb5, funct7b5;
logic [2:0] funct3;
logic [1:0] ALUOp;
logic [3:0] RV_ALUControl;
logic [6:0] RV_op;
logic [1:0] ResultSrc;
logic RV_MemWrite, RV_Branch, RV_ALUSrc, RV_RegWrite, Jump;
logic [2:0] RV_ImmSrc;
logic RV_mainValid, RV_ALUValid, RV_valid; //combi only

assign {opb5, funct7b5, funct3, RV_op} = {
  instr[5],
  instr[30],
  instr[14:12],
  instr[6:0] };

rv_aludec rv_adec(.*, .ALUControl(RV_ALUControl));
rv_maindec rv_mdec(.*, .op(RV_op), .MemWrite(RV_MemWrite), .Branch(RV_Branch), .RegWrite(RV_RegWrite), .ImmSrc(RV_ImmSrc), .ALUSrc(RV_ALUSrc) );

assign RV_valid = RV_mainValid & RV_ALUValid; // combi only

/* ARM */
logic [1:0] ARM_Op;
logic [5:0] Funct;
logic [3:0] Rd;
logic [1:0] FlagW;
logic PCSrc, ARM_RegWrite, ARM_MemWrite, MemtoReg, ARM_ALUSrc, ARM_Branch;
logic [1:0] ARM_ImmSrc, RegSrc, ARM_ALUControl;
logic ARM_valid; // combi only

assign {ARM_Op, Funct, Rd} = {
  instr[27:26],
  instr[25:20],
  instr[15:12] };

arm_decoder arm_dec(.*, .Op(ARM_Op), .RegW(ARM_RegWrite), .MemW(ARM_MemWrite), .ALUSrc(ARM_ALUSrc), .ImmSrc(ARM_ImmSrc), .ALUControl(ARM_ALUControl), .Branch(ARM_Branch) );

/* Combine RISC-V and ARM */
always_comb
  if(armD) begin
    /* Don't care about RISC-V outputs */
    ResultSrcD[1] = 1'bx;
    ImmSrcD[2] = 1'bx;
    JumpD = 1'bx;

    /* Shared */
    RegWriteD = ARM_RegWrite;
    MemWriteD = ARM_MemWrite;
    ALUControlD = {2'bxx, ARM_ALUControl};
    BranchD = ARM_Branch;
    ALUSrcD = ARM_ALUSrc;
    ImmSrcD[1:0] = ARM_ImmSrc;
    ResultSrcD[0] = MemtoReg;

    /* ARM Only */
    PCSrcD = PCSrc;
    FlagWriteD = FlagW;
    RegSrcD = RegSrc;

  end else begin /* RISC-V */
    /* Don't care about ARM outputs */
    PCSrcD = 1'bx;
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

/* decide instruction type */
always_comb
  casez({RV_valid, ARM_valid, wasNotFlushed})
    3'b001: armD = 1'bx; // ???
    3'b011: armD = 1'b1;
    3'b101: armD = 1'b0;
    3'b111: armD = armIn; // don't change if either is valid
    3'b??0: armD = armIn; // don't change on flush
  endcase

endmodule


module rv_aludec(input logic opb5,
                 input logic [2:0] funct3,
                 input logic funct7b5,
                 input logic [1:0] ALUOp,
                 output logic RV_ALUValid, // combi only
                 output logic [3:0] ALUControl);

logic RtypeSub;
assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract

always_comb begin
  RV_ALUValid = 1; // combi only
  case(ALUOp)
    2'b00: ALUControl = 4'b0000; // addition
    2'b01: ALUControl = 4'b0001; // subtraction
    default: case(funct3) // R–type or I–type ALU
      3'b000: if (RtypeSub)
                ALUControl = 4'b0001; // sub
              else
                ALUControl = 4'b0000; // add, addi
      3'b010:  ALUControl = 4'b0101; // slt, slti
      3'b100:  ALUControl = 4'b0100; // xor, xori
      3'b110:  ALUControl = 4'b0011; // or, ori
      3'b111:  ALUControl = 4'b0010; // and, andi
      default: begin
        ALUControl = 4'bxxxx; // ???
        RV_ALUValid = 0; // combi only
      end
    endcase
  endcase
end

endmodule

module rv_maindec(input logic [6:0] op,
                  output logic RV_mainValid, // combi only
                  output logic [1:0] ResultSrc,
                  output logic MemWrite,
                  output logic Branch, ALUSrc,
                  output logic RegWrite, PCResD, Jump,
                  output logic [2:0] ImmSrc,
                  output logic [1:0] ALUOp);

logic [12:0] controls;

assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
  ResultSrc, Branch, ALUOp, Jump, PCResD} = controls;

always_comb begin
  RV_mainValid = 1; // combi only
  case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_PCRes
    7'b0000011: controls = 13'b1_000_1_0_01_0_00_0_0; // lw
    7'b0100011: controls = 13'b0_001_1_1_00_0_00_0_0; // sw
    7'b0110011: controls = 13'b1_0xx_0_0_00_0_10_0_0; // R–type
    7'b1100011: controls = 13'b0_010_0_0_00_1_01_0_0; // beq
    7'b0010011: controls = 13'b1_000_1_0_00_0_10_0_0; // I–type ALU
    7'b1101111: controls = 13'b1_011_0_0_10_0_00_1_0; // jal
    7'b0110111: controls = 13'b1_111_1_0_00_0_00_0_0; // lui
    7'b0010111: controls = 13'b1_111_1_0_10_0_00_0_1; // auipc
    default: begin
      controls = 13'bx_xxx_x_x_xx_x_xx_x_x; // ???
      RV_mainValid = 0; // combi only
    end
  endcase
end

endmodule

module arm_decoder(input logic [1:0] Op,
                   input logic [5:0] Funct,
                   input logic [3:0] Rd,
                   output logic ARM_valid, // combi only
                   output logic Branch,
                   output logic [1:0] FlagW,
                   output logic PCSrc, RegW, MemW,
                   output logic MemtoReg, ALUSrc,
                   output logic [1:0] ImmSrc, RegSrc, ALUControl);

logic [9:0] controls;
logic ALUOp;
logic mainValid, aluValid; // combi only

assign ARM_valid = mainValid & aluValid; // combi only

// Main Decoder
always_comb begin
  mainValid = 1; // combi only
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
    default: begin
      controls = 10'bx;
      mainValid = 0; // combi only
    end
  endcase
end

assign {RegSrc, ImmSrc, ALUSrc, MemtoReg,
  RegW, MemW, Branch, ALUOp} = controls;

// ALU Decoder
always_comb begin
  aluValid = 1; // combi only
  if (ALUOp) begin // which DP instr?
    case(Funct[4:1])
      4'b0100: ALUControl = 2'b00; // ADD
      4'b0010: ALUControl = 2'b01; // SUB
      4'b0000: ALUControl = 2'b10; // AND
      4'b1100: ALUControl = 2'b11; // ORR
      default: begin
        ALUControl = 2'bx; // unimplemented
        aluValid = 0; // combi only
      end
    endcase
    // update flags if S bit is set (C & V only for arith)
    FlagW[1] = Funct[0];
    FlagW[0] = Funct[0] &
      (ALUControl == 2'b00 | ALUControl == 2'b01);
  end else begin
    ALUControl = 2'b00; // add for non-DP instructions
    FlagW = 2'b00; // don't update Flags
  end
end

// PC Logic
assign PCSrc = ((Rd == 4'b1111) & RegW);

endmodule
