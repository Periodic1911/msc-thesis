module combi_decoder(input logic [31:0] instr,
                     input logic armIn,
                     input logic wasNotFlushed,
                     output logic RegWriteD,
                     output logic MemWriteD,
                     output logic [1:0] MemSizeD,
                     output logic MemSignedD,
                     output logic [4:0] ALUControlD,
                     output logic [1:0] BranchD, // bit 0 RISC-V only
                     output logic [1:0] ALUSrcD,
                     output logic [2:0] ImmSrcD,
                     output logic [3:0] CondD,

                     /* ARM only */
                     output logic PCSrcD,
                     output logic [1:0] FlagWriteD,
                     output logic [1:0] RegSrcD,
                     output logic [4:0] ShiftAmtD,
                     output logic [2:0] ShiftTypeD,

`ifdef ARM `ifdef RISCV
                     output logic armD,
`endif `endif
                     output logic [1:0] ResultSrcD // bit 1 RISC-V only
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
logic RV_MemWrite, RV_RegWrite;
logic [1:0] RV_ALUSrc;
logic [1:0] RV_Branch;
logic [1:0] RV_MemSize;
logic RV_MemSigned;
logic [2:0] RV_ImmSrc;
logic RV_mainValid, RV_ALUValid, RV_valid; //combi only
logic [3:0] RV_Cond;

assign {opb5, funct7b5, funct3, RV_op} = {
  instr[5],
  instr[30],
  instr[14:12],
  instr[6:0] };

rv_aludec rv_adec(.*, .ALUControl(RV_ALUControl));
rv_maindec rv_mdec(.*, .op(RV_op), .MemSigned(RV_MemSigned), .MemSize(RV_MemSize), .MemWrite(RV_MemWrite), .Branch(RV_Branch), .RegWrite(RV_RegWrite), .ImmSrc(RV_ImmSrc), .ALUSrc(RV_ALUSrc) );

assign RV_valid = RV_mainValid & RV_ALUValid; // combi only

/* ARM */
logic [1:0] ARM_Op;
logic [5:0] Funct;
logic [3:0] Rd;
logic [1:0] FlagW;
logic PCSrc, ARM_RegWrite, ARM_MemWrite, MemtoReg, ARM_ALUSrc, ARM_Branch;
logic [1:0] ARM_MemSize;
logic ARM_MemSigned;
logic [1:0] ARM_ImmSrc, RegSrc;
logic [4:0] ARM_ALUControl;
logic [7:0] Shift;
logic [4:0] ShiftAmt;
logic [2:0] ShiftType;
logic ARM_valid; // combi only

assign {ARM_Op, Funct, Rd, Shift} = {
  instr[27:26],
  instr[25:20],
  instr[15:12],
  instr[11:4] };

arm_decoder arm_dec(.*, .Op(ARM_Op), .RegW(ARM_RegWrite), .MemSigned(ARM_MemSigned), .MemSize(ARM_MemSize), .MemW(ARM_MemWrite), .ALUSrc(ARM_ALUSrc), .ImmSrc(ARM_ImmSrc), .ALUControl(ARM_ALUControl), .Branch(ARM_Branch) );

/* Combine RISC-V and ARM */
always_comb
  if(armD) begin
    /* Don't care about RISC-V outputs */
    ResultSrcD[1] = 1'bx;
    ImmSrcD[2] = 1'bx;

    /* Shared */
    RegWriteD = ARM_RegWrite;
    MemWriteD = ARM_MemWrite;
    MemSizeD = ARM_MemSize;
    MemSignedD = ARM_MemSigned;
    ALUControlD = ARM_ALUControl;
    ShiftAmtD = ShiftAmt;
    ShiftTypeD = ShiftType;
    BranchD = {ARM_Branch, 1'b0};
    ALUSrcD = {1'b0, ARM_ALUSrc};
    ImmSrcD[1:0] = ARM_ImmSrc;
    ResultSrcD[0] = MemtoReg;
    CondD = instr[31:28];

    /* ARM Only */
    PCSrcD = PCSrc;
    FlagWriteD = FlagW;
    RegSrcD = RegSrc;

  end else begin /* RISC-V */
    /* Don't care about ARM outputs */
    PCSrcD = 1'bx;
    FlagWriteD = 2'bx;
    RegSrcD = 2'bx;
    ShiftAmtD = 5'b0; // Don't want to shift operand2
    ShiftTypeD = 3'bx;

    /* Shared */
    RegWriteD = RV_RegWrite;
    MemWriteD = RV_MemWrite;
    MemSizeD = RV_MemSize;
    MemSignedD = RV_MemSigned;
    ALUControlD = {1'b0, RV_ALUControl};
    BranchD = RV_Branch;
    ALUSrcD = RV_ALUSrc;
    ImmSrcD = RV_ImmSrc;
    CondD = RV_Cond;

    /* RISC-V */
    ResultSrcD = ResultSrc;
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
                 output logic [3:0] RV_Cond,
                 output logic RV_ALUValid, // combi only
                 output logic [3:0] ALUControl);

logic RtypeSub;
assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract

always_comb begin
  RV_ALUValid = 1; // combi only
  case(ALUOp)
    2'b00: ALUControl = 4'b0000; // addition
    2'b01: ALUControl = 4'b0001; // subtraction
    2'b11: ALUControl = 4'b0110; // lui
    2'b10: case(funct3) // R–type or I–type ALU
      3'b000: if (RtypeSub)
                ALUControl = 4'b0001; // sub
              else
                ALUControl = 4'b0000; // add, addi
      3'b001:  ALUControl = 4'b1000; // sll, slli
      3'b101: if (funct7b5)
                ALUControl = 4'b1010; // sra, srai
              else
                ALUControl = 4'b1001; // srl, srli
      3'b010:  ALUControl = 4'b0101; // slt, slti
      3'b011:  ALUControl = 4'b0101; // sltu, sltiu
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

/* branch signals */
always_comb
  if(ALUOp == 2'b01) // ALUOp subtract is only used for branch
    case(funct3)
      3'b000: RV_Cond = 4'b0000; // beq
      3'b001: RV_Cond = 4'b0001; // bne
      3'b100: RV_Cond = 4'b1011; // blt
      3'b101: RV_Cond = 4'b1010; // bge
      3'b110: RV_Cond = 4'b0010; // bltu
      3'b111: RV_Cond = 4'b0011; // bgeu
      default: RV_Cond = 4'bx; // undefined
    endcase
  else
    RV_Cond = 4'b1110; // Always execute

endmodule

module rv_maindec(input logic [6:0] op,
                  input logic [2:0] funct3,
                  output logic RV_mainValid, // combi only
                  output logic [1:0] ResultSrc,
                  output logic MemWrite,
                  output logic [1:0] MemSize,
                  output logic MemSigned,
                  output logic [1:0] Branch,
                  output logic [1:0] ALUSrc,
                  output logic RegWrite,
                  output logic [2:0] ImmSrc,
                  output logic [1:0] ALUOp);

assign MemSigned = 0;
logic [15:0] controls;

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, MemSigned, MemSize,
  ResultSrc, Branch, ALUOp} = controls;

always_comb begin
  RV_mainValid = 1; // combi only
  case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_MemSigned_MemSize_ResultSrc_Branch_ALUOp
    7'b0000011: // load
      case(funct3)
        3'b000: controls = 16'b1_000_01_0_1_00_01_00_00; // lb
        3'b001: controls = 16'b1_000_01_0_1_01_01_00_00; // lh
        3'b010: controls = 16'b1_000_01_0_x_10_01_00_00; // lw
        3'b100: controls = 16'b1_000_01_0_0_00_01_00_00; // lbu
        3'b101: controls = 16'b1_000_01_0_0_01_01_00_00; // lhu
        default: begin
          controls = 16'b0_xxx_0x_0_x_xx_10_00_00; // ???
          RV_mainValid = 0; // combi only
        end
      endcase
    7'b0100011: // store
      case(funct3)
        3'b000: controls = 16'b0_001_01_1_x_00_00_00_00; // sb
        3'b001: controls = 16'b0_001_01_1_x_01_00_00_00; // sh
        3'b010: controls = 16'b0_001_01_1_x_10_00_00_00; // sw
        default: begin
          controls = 16'b0_xxx_0x_0_x_xx_10_00_00; // ???
          RV_mainValid = 0; // combi only
        end
      endcase
    7'b0110011: controls = 16'b1_xxx_00_0_x_xx_00_00_10; // R–type
    7'b1100011: controls = 16'b0_010_00_0_x_xx_00_01_01; // B-type
    7'b0010011: controls = 16'b1_000_01_0_x_xx_00_00_10; // I–type ALU
    7'b1101111: controls = 16'b1_011_10_0_x_xx_10_01_00; // jal

    7'b1100111: controls = 16'b1_000_01_0_x_xx_10_10_00; // jalr
    7'b0110111: controls = 16'b1_111_01_0_x_xx_00_00_11; // lui
    7'b0010111: controls = 16'b1_111_11_0_x_xx_00_00_00; // auipc
    default: begin
      controls = 16'b0_xxx_0x_0_x_xx_10_00_00; // ???
      RV_mainValid = 0; // combi only
    end
  endcase
end

endmodule

module arm_decoder(input logic [1:0] Op,
                   input logic [5:0] Funct,
                   input logic [7:0] Shift,
                   input logic [3:0] Rd,
                   output logic ARM_valid, // combi only
                   output logic Branch,
                   output logic [1:0] FlagW,
                   output logic PCSrc, RegW, MemW,
                   output logic MemtoReg, ALUSrc,
                   output logic [1:0] MemSize,
                   output logic MemSigned,
                   output logic [1:0] ImmSrc, RegSrc,
                   output logic [4:0] ShiftAmt,
                   output logic [2:0] ShiftType,
                   output logic [4:0] ALUControl);

// TODO add to decoder controls
assign MemSigned = 0;
assign MemSize = 2'b10;

logic [11:0] controls;
logic ALUOp;
logic [1:0] DPShift;
logic mainValid, aluValid; // combi only

assign ARM_valid = mainValid & aluValid; // combi only

// Main Decoder
// RegSrc_ImmSrc_ALUSrc_MemtoReg_RegW_MemW_Branch_ALUOp_DPShift
always_comb begin
  mainValid = 1; // combi only
  case(Op)
           // Data-processing immediate
    2'b00: if (Funct[5])
             if (Funct[4:3] == 2'b10) // TST, TEQ, CMP, CMN
                         controls = 12'b00_00_1_0_0_0_0_1_10;
             else
                         controls = 12'b00_00_1_0_1_0_0_1_10;
           // Data-processing register
           else
             if (Funct[4:3] == 2'b10) // TST, TEQ, CMP, CMN
                         controls = 12'b00_00_0_0_0_0_0_1_01;
             else
                         controls = 12'b00_00_0_0_1_0_0_1_01;
           // LDR
    2'b01: if (Funct[0]) controls = 12'b00_01_1_1_1_0_0_0_00;
           // STR
           else          controls = 12'b10_01_1_1_0_1_0_0_00;
           // B
    2'b10:               controls = 12'b01_10_1_0_0_0_1_0_00;
    // Unimplemented
    default: begin
      controls = 12'bx;
      mainValid = 0; // combi only
    end
  endcase
end

assign {RegSrc, ImmSrc, ALUSrc, MemtoReg,
  RegW, MemW, Branch, ALUOp, DPShift} = controls;

mux3 #(3)shtypemux(3'b1_00, {1'b1,Shift[2:1]}, 3'b1_11, DPShift, ShiftType);
//assign ShiftType = ImmShift ? 3'b1_11 : {1'b1,Shift[2:1]};

mux3 #(5)shamtmux(5'b00000, Shift[7:3], {Shift[7:4], 1'b0}, DPShift, ShiftAmt);
//assign ShiftAmt = ImmShift ? {Shift[7:4], 1'b0} : Shift[7:3];

// ALU Decoder
/*
      4'b0010: ALUControl = 5'b00001; // SUB
      4'b0011: ALUControl = 5'b10100; // RSB
      4'b0100: ALUControl = 5'b00000; // ADD
      4'b0101: ALUControl = 5'b10010; // ADC
      4'b0110: ALUControl = 5'b10011; // SBC
      4'b0111: ALUControl = 5'b10110; // RSC
*/
always_comb begin
  aluValid = 1; // combi only
  if (ALUOp) begin // which DP instr?
    case(Funct[4:1])
      4'b0000: ALUControl = 5'b00010; // AND
      4'b0001: ALUControl = 5'b00100; // EOR
      4'b0010: ALUControl = 5'b00001; // SUB
      4'b0011: ALUControl = 5'b10100; // RSB
      4'b0100: ALUControl = 5'b00000; // ADD
      4'b0101: ALUControl = 5'b10010; // ADC
      4'b0110: ALUControl = 5'b10011; // SBC
      4'b0111: ALUControl = 5'b10110; // RSC
      4'b1000: ALUControl = 5'b00010; // TST (AND)
      4'b1001: ALUControl = 5'b00100; // TEQ (EOR)
      4'b1010: ALUControl = 5'b00001; // CMP (SUB)
      4'b1011: ALUControl = 5'b00000; // CMN (ADD)
      4'b1100: ALUControl = 5'b00011; // ORR
      4'b1101: ALUControl = 5'b00110; // MOV
      4'b1110: ALUControl = 5'b10000; // BIC
      4'b1111: ALUControl = 5'b10111; // MVN
      default: begin
        ALUControl = 5'bx; // unimplemented
        aluValid = 0; // combi only
      end
    endcase
    // update flags if S bit is set (C & V only for arith)
    FlagW[1] = Funct[0];
    FlagW[0] = Funct[0] &
      (ALUControl == 5'b00000 | ALUControl == 5'b00001);
  end else begin
    ALUControl = 5'b00000; // add for non-DP instructions
    FlagW = 2'b00; // don't update Flags
  end
end

// PC Logic
assign PCSrc = ((Rd == 4'b1111) & RegW);

endmodule
