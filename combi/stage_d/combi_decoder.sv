module combi_decoder(input logic clk, rst,
                     input logic [31:0] instr,
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
                     input logic ldmStall,
                     input logic FlushE,
                     output logic PCSrcD,
                     output logic [1:0] FlagWriteD,
                     output logic [3:0] RegSrcD,
                     output logic [4:0] ShiftAmtD,
                     output logic [2:0] ShiftTypeD,
                     output logic StallFD,
                     output logic [1:0] FwdD,

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
logic opb5, funct7b5, funct7b0;
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

assign {opb5, funct7b5, funct7b0, funct3, RV_op} = {
  instr[5],
  instr[30],
  instr[25],
  instr[14:12],
  instr[6:0] };

rv_aludec rv_adec(.*, .ALUControl(RV_ALUControl));
rv_maindec rv_mdec(.*, .op(RV_op), .MemSigned(RV_MemSigned), .MemSize(RV_MemSize), .MemWrite(RV_MemWrite), .Branch(RV_Branch), .RegWrite(RV_RegWrite), .ImmSrc(RV_ImmSrc), .ALUSrc(RV_ALUSrc) );

assign RV_valid = RV_mainValid & RV_ALUValid; // combi only

/* ARM */
logic [2:0] ARM_Op;
logic [5:0] Funct;
logic [3:0] Rd;
logic [1:0] FlagW;
logic PCSrc, ARM_RegWrite, ARM_MemWrite, ARM_ALUSrc, ARM_Branch;
logic [1:0] ARM_ResultSrc;
logic [1:0] ARM_MemSize;
logic ARM_MemSigned;
logic [2:0] ARM_ImmSrc;
logic [3:0] RegSrc;
logic [4:0] ARM_ALUControl;
logic [7:0] Shift;
logic [4:0] ShiftAmt;
logic [2:0] ShiftType;
logic [1:0] uCnt;
logic ARM_StallF;
logic ARM_valid; // combi only

assign {ARM_Op, Funct, Rd, Shift} = {
  instr[27:25],
  instr[25:20],
  instr[15:12],
  instr[11:4] };

arm_decoder arm_dec(.*, .Op(ARM_Op), .ResultSrc(ARM_ResultSrc), .RegW(ARM_RegWrite), .MemSigned(ARM_MemSigned), .MemSize(ARM_MemSize), .MemW(ARM_MemWrite), .ALUSrc(ARM_ALUSrc), .ImmSrc(ARM_ImmSrc), .ALUControl(ARM_ALUControl), .Branch(ARM_Branch) );

/* Combine RISC-V and ARM */
always_comb
  if(armD) begin
    /* Don't care about RISC-V outputs */
    ResultSrcD[1] = 1'bx;

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
    ImmSrcD = ARM_ImmSrc;
    ResultSrcD = ARM_ResultSrc;
    CondD = instr[31:28];

    /* ARM Only */
    PCSrcD = PCSrc;
    FlagWriteD = FlagW;
    RegSrcD = RegSrc;
    StallFD = ARM_StallF;

  end else begin /* RISC-V */
    /* Don't care about ARM outputs */
    PCSrcD = 1'bx;
    FlagWriteD = 2'bx;
    RegSrcD = 4'b0;
    ShiftAmtD = 5'b0; // Don't want to shift operand2
    ShiftTypeD = 3'bx;
    StallFD = 1'b0; // Don't want to stall F stage

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
                 input logic funct7b5, funct7b0,
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
    2'b10:
      if(funct7b0 & opb5) // R-type mul
        case(funct3) // R–type or I–type ALU
        3'b000: ALUControl = 4'b1100; // mul
        3'b001: ALUControl = 4'b1111; // mulh
        3'b010: ALUControl = 4'b1110; // mulhsu
        3'b011: ALUControl = 4'b1101; // mulhu
        default: begin
          ALUControl = 4'bxxxx; // ???
        end
        endcase
      else case(funct3) // R–type or I–type ALU
        3'b000: if (RtypeSub)
                  ALUControl = 4'b0001; // sub
                else
                  ALUControl = 4'b0000; // add, addi
        3'b001:   ALUControl = 4'b1000; // sll, slli
        3'b101: if (funct7b5)
                  ALUControl = 4'b1010; // sra, srai
                else
                  ALUControl = 4'b1001; // srl, srli
        3'b010:   ALUControl = 4'b0101; // slt, slti
        3'b011:   ALUControl = 4'b0101; // sltu, sltiu
        3'b100:   ALUControl = 4'b0100; // xor, xori
        3'b110:   ALUControl = 4'b0011; // or, ori
        3'b111:   ALUControl = 4'b0010; // and, andi
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

module arm_decoder(input logic clk, rst,
                   input logic [31:0] instr,
                   input logic [2:0] Op,
                   input logic [5:0] Funct,
                   input logic [7:0] Shift,
                   input logic [3:0] Rd,
                   input logic ldmStall,
                   input logic FlushE,
                   output logic ARM_valid, // combi only
                   output logic Branch,
                   output logic [1:0] FlagW,
                   output logic PCSrc, RegW, MemW,
                   output logic ALUSrc,
                   output logic [1:0] ResultSrc,
                   output logic [1:0] MemSize,
                   output logic MemSigned,
                   output logic [2:0] ImmSrc,
                   output logic [3:0] RegSrc,
                   output logic [4:0] ShiftAmt,
                   output logic [2:0] ShiftType,
                   output logic ARM_StallF,
                   output logic [1:0] uCnt,
                   output logic [1:0] FwdD,
                   output logic [4:0] ALUControl);


logic [22:0] controls, ldmControls, ldControls, ldrhControls;
logic [2:0] ALUOp;
logic [1:0] DPShift;
logic mainValid, aluValid; // combi only

assign ARM_valid = mainValid & aluValid; // combi only

logic [1:0] uCnt_n;
flopenr #(2) microinst_reg(clk, rst, ~FlushE, uCnt_n, uCnt);

// Main Decoder
/*
  3'b000: begin
    ALUControl = 5'b00000; // add for non-DP instructions
    FlagW = 2'b00; // don't update Flags
  end
  3'b010: begin
    ALUControl = 5'b11111; // forward Op1
    FlagW = 2'b00; // don't update Flags
  end
  3'b011: begin
    ALUControl = 5'b00001; // sub
    FlagW = 2'b00; // don't update Flags
  end
  3'b100: begin
    ALUControl = 5'b00110; // forward Op2
    FlagW = 2'b00; // don't update Flags
  end
  3'b101: begin
    ALUControl = 5'b01100; // Multiply low
    FlagW = 2'b00; // don't update Flags
    // FlagW = {Funct[0], 1'b0}; // Set Z and N
  end
  3'b110: begin
    ALUControl = 5'b01101; // Multiply high
    FlagW = 2'b00; // don't update Flags
*/
// RegSrc_ImmSrc_ALUSrc_ResultSrc_RegW_MemW_Branch_ALUOp_DPShift_StallF_uCnt_FwdD
always_comb begin
  mainValid = 1; // combi only
  if(instr[27:21] == 7'b000000_0 && instr[7:4] == 4'b1001 ) // MUL
                                  controls = 23'b1011_000_0_00_1_0_0_101_00_0_00_00;
  else if(instr[27:21] == 7'b000000_1 && instr[7:4] == 4'b1001) // MLA
           if(uCnt == 2'b00)      controls = 23'b1011_000_0_00_0_0_0_101_00_1_01_00;
           else                   controls = 23'b1001_000_0_00_1_0_0_000_00_0_00_10;
  else if(instr[27:23] == 5'b00001 && instr[21] == 1'b0 && instr[7:4] == 4'b1001) // MULL
           if(uCnt == 2'b00)      controls = 23'b0011_000_0_00_1_0_0_101_00_1_01_00;
           else                   controls = 23'b1011_000_0_00_1_0_0_110_00_0_00_00;
  else if(instr[27:23] == 5'b00001 && instr[21] == 1'b1 && instr[7:4] == 4'b1001) // MLAL
           if(uCnt == 2'b00)      controls = 23'b1011_000_0_00_0_0_0_101_00_1_01_00;
           else if(uCnt == 2'b01) controls = 23'b0010_000_0_00_1_0_0_111_00_1_10_01; //TODO carry
           else if(uCnt == 2'b10) controls = 23'b1011_000_0_00_0_0_0_110_00_1_11_00;
           else                   controls = 23'b1000_000_0_00_1_0_0_111_00_0_00_10;
  else if(instr[27:25] == 3'b000 && instr[7:4] == 4'b1001 )
           // SWP
           if(uCnt == 2'b00)      controls = 23'b0000_000_0_01_1_0_0_010_00_1_01_00;
           else                   controls = 23'b0000_000_0_00_0_1_0_010_00_0_00_11;
  else if(instr[27:25] == 3'b000 && instr[4] == 1'b1 && instr[7] == 1'b1)
           // LDRH types
                          controls = ldrhControls;
  else
  casez(instr[27:25])
    3'b001:
           // Data-processing immediate
             if (Funct[4:3] == 2'b10) // TST, TEQ, CMP, CMN
                          controls = 23'b0000_000_1_00_0_0_0_001_10_0_00_00;
             else
                          controls = 23'b0000_000_1_00_1_0_0_001_10_0_00_00;
    3'b000:
           // Data-processing register
      if (instr[4]) begin // TODO: shift
        if(uCnt == 2'b00) controls = 23'b0011_000_0_00_0_0_0_100_11_1_01_00;
        else if (Funct[4:3] == 2'b10) // TST, TEQ, CMP, CMN
                          controls = 23'b0000_000_0_00_0_0_0_001_00_0_00_10;
        else
                          controls = 23'b0000_000_0_00_1_0_0_001_00_0_00_10;
    end else
             if (Funct[4:3] == 2'b10) // TST, TEQ, CMP, CMN
                          controls = 23'b0000_000_0_00_0_0_0_001_01_0_00_00;
             else
                          controls = 23'b0000_000_0_00_1_0_0_001_01_0_00_00;
           // STR/LDR
    3'b01?:               controls = ldControls;
    3'b101:
           // BL
            if(instr[24]) controls = 23'b0001_010_1_10_1_0_1_000_00_0_00_00;
           // B
            else          controls = 23'b0001_010_1_00_0_0_1_000_00_0_00_00;
           // LDM/STM
    3'b100:               controls = ldmControls;
    // Unimplemented
    default: begin
      controls = 23'bx;
      mainValid = 0; // combi only
    end
  endcase
end

// TODO add to decoder controls
//assign MemSigned = 0;

/**** LDR/STR ****/
// RegSrc_ImmSrc_ALUSrc_ResultSrc_RegW_MemW_Branch_ALUOp_DPShift_StallF_uCnt_FwdD
logic st = ~instr[20];
logic byteq = instr[22];
logic [2:0] addsubLD;
logic addLD = instr[23];
logic immLD = ~instr[25];
logic preLD = instr[24];
logic wbLD;
assign wbLD = instr[21] | ~preLD;
always_comb begin
  addsubLD = addLD ? 3'b000 : 3'b011;
  if(wbLD)
    if(preLD) // pre inc WB
      if(~uCnt[0])
        ldControls = {2'b00,st,4'b0_001,immLD,2'b01,~st,st,1'b0,addsubLD,1'b0,~immLD,5'b1_01_00};
      else
        ldControls = 23'b1000_001_0_00_1_0_0_010_00_0_00_01;
    else // post inc WB
      if(~uCnt[0])
        ldControls = {2'b00,st,4'b0_001,immLD,2'b01,~st,st,1'b0,3'b010,1'b0,~immLD,5'b1_01_00};
      else
        ldControls = {2'b10,st,4'b0_001,immLD,5'b00_1_0_0,addsubLD,1'b0,~immLD,5'b0_00_01};
  else
    if(preLD) // pre inc no WB
      ldControls = {2'b00,st,4'b0_001,immLD,2'b01,~st,st,1'b0,addsubLD,1'b0,~immLD,5'b0_00_00};
    else // post inc no WB (does not exist)
      ldControls = 23'bx;

  if(Op == 3'b100) begin // LDM/STM
    MemSize = 2'b10;
    MemSigned = 1'b0;
  end else if(Op[2:1] == 2'b01) begin // LDR/STR
    MemSize = byteq ? 2'b00 : 2'b10;
    MemSigned = 1'b0;
  end else begin
    case(instr[6:5])
      2'b00: begin
        MemSize = byteq ? 2'b00 : 2'b10; // SWP
        MemSigned = 1'b0;
      end
      2'b01: begin
        MemSize = 2'b01; // Unsigned HW
        MemSigned = 1'b0;
      end
      2'b10: begin
        MemSize = 2'b00; // Signed Byte
        MemSigned = 1'b1;
      end
       2'b11: begin
        MemSize = 2'b01; // Signed HW
        MemSigned = 1'b1;
      end
    endcase
  end
end

logic immLDRH = instr[22];
/**** LDRH/STRH/LDRSB/LDRSH/SWP ****/
// RegSrc_ImmSrc_ALUSrc_ResultSrc_RegW_MemW_Branch_ALUOp_DPShift_StallF_uCnt_FwdD
always_comb begin
  if(wbLD)
    if(preLD) // pre inc WB
      if(~uCnt[0])
        ldrhControls = {2'b00,st,4'b0_100,immLDRH,2'b01,~st,st,1'b0,addsubLD,1'b0,1'b0,5'b1_01_00};
      else
        ldrhControls = 23'b1000_100_0_00_1_0_0_010_00_0_00_01;
    else // post inc WB
      if(~uCnt[0])
        ldrhControls = {2'b00,st,4'b0_100,immLDRH,2'b01,~st,st,1'b0,3'b010,1'b0,1'b0,5'b1_01_00};
      else
        ldrhControls = {2'b10,st,4'b0_100,immLDRH,5'b00_1_0_0,addsubLD,1'b0,1'b0,5'b0_00_01};
  else
    if(preLD) // pre inc no WB
      ldrhControls = {2'b00,st,4'b0_100,immLDRH,2'b01,~st,st,1'b0,addsubLD,1'b0,1'b0,5'b0_00_00};
    else // post inc no WB (does not exist)
      ldrhControls = 23'bx;
end


/**** LDM/STM ****/
logic [2:0] addsub, add;
logic [1:0] ld;
logic isAdd, post, wb, load;
assign isAdd = instr[23];
assign post = ~instr[24];
assign wb = instr[21];
assign load = instr[20];

always_comb begin
  ld = load ? 2'b1_0 : 2'b0_1;

  addsub = isAdd ? 3'b000 : 3'b011;

  if(uCnt == 2'b00) add = post ? 3'b010 : addsub;
  else if(ldmStall) add = addsub;
  else              add = post ? addsub : 3'b010;

// RegSrc_ImmSrc_ALUSrc_ResultSrc_RegW_MemW_Branch_ALUOp_DPShift_StallF_uCnt_FwdD
  if(uCnt == 2'b00)
                ldmControls = {10'b0100_011_1_01,ld,  1'b0,add,7'b00_1_01_00};
  else if(ldmStall)
                ldmControls = {10'b0100_011_1_01,ld,  1'b0,add,7'b00_1_01_01};
  else
                ldmControls = {10'b1000_011_1_00,wb,2'b0_0,add,7'b00_0_00_01};
end

assign {RegSrc, ImmSrc, ALUSrc, ResultSrc,
  RegW, MemW, Branch, ALUOp, DPShift,
  ARM_StallF, uCnt_n, FwdD} = controls;

mux4 #(3)shtypemux(3'b1_00, // No shift
  {1'b1,Shift[2:1]},        // Shift by ShiftAmt
  3'b1_11,                  // Shift Immediate, type is always ROR
  {1'b0,Shift[2:1]},        // Shift by register
  DPShift, ShiftType);
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
  case(ALUOp)
  3'b001: begin
    case(Funct[4:1]) // which DP instr?
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
  end
  3'b000: begin
    ALUControl = 5'b00000; // add for non-DP instructions
    FlagW = 2'b00; // don't update Flags
  end
  3'b010: begin
    ALUControl = 5'b11111; // forward Op1
    FlagW = 2'b00; // don't update Flags
  end
  3'b011: begin
    ALUControl = 5'b00001; // sub
    FlagW = 2'b00; // don't update Flags
  end
  3'b100: begin
    ALUControl = 5'b00110; // forward Op2
    FlagW = 2'b00; // don't update Flags
  end
  3'b101: begin
    ALUControl = 5'b01100; // Multiply low
    FlagW = 2'b00; // don't update Flags
    // FlagW = {Funct[0], 1'b0}; // Set Z and N
  end
  3'b110: begin
    if (instr[22])
      ALUControl = 5'b01111; // Multiply high signed
    else
      ALUControl = 5'b01101; // Multiply high unsigned
    FlagW = 2'b00; // don't update Flags
    // FlagW = {Funct[0], 1'b0}; // Set Z and N
  end
  3'b111: begin
    if(uCnt == 2'b01) begin
      ALUControl = 5'b00000; // ADD
      FlagW = 2'b01; // set C and V
    end
    else begin
      ALUControl = 5'b10010; // ADC
      FlagW = 2'b00; // don't update Flags
      // FlagW = {Funct[0], 1'b0}; // Set Z and N
    end
  end
  default: begin
    ALUControl = 5'bx;
    FlagW = 2'bx;
  end
  endcase
end

// PC Logic
assign PCSrc = ((Rd == 4'b1111) & RegW & ~RegSrc[0]);

endmodule
