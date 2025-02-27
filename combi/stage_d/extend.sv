module extend(input logic armD, // combi only
              input logic [31:0] instr,
              input logic [2:0] immsrc,
              output logic [31:0] immext);

logic [31:7] rv_instr = instr[31:7];
logic [23:0] arm_instr = instr[23:0];

always_comb
  if(armD)
    case(immsrc)
      // 8-bit unsigned immediate
      3'b000: immext = {24'b0, instr[7:0]};
      // 12-bit unsigned immediate
      3'b001: immext = {20'b0, instr[11:0]};
      // 24-bit two's complement shifted branch
      3'b010: immext = {{6{instr[23]}}, instr[23:0], 2'b00};
      // constant 4 for LDM
      3'b011: immext = 32'h00000004;
      // 8-bit unsigned immediate for ldrh/strh
      3'b100: immext = {24'b0, instr[11:8], instr[3:0]};
      default: immext = 32'bx; // undefined
    endcase
  else
    case(immsrc)
      // I−type
      3'b000: immext = {{20{instr[31]}}, instr[31:20]};
      // S−type (stores)
      3'b001: immext = {{20{instr[31]}}, instr[31:25],
      instr[11:7]};
      // B−type (branches)
      3'b010: immext = {{20{instr[31]}}, instr[7],
                       instr[30:25], instr[11:8], 1'b0};
      // J−type (jal)
      3'b011: immext = {{12{instr[31]}}, instr[19:12],
                       instr[20], instr[30:21], 1'b0};
      // U−type (lui, auipc)
      3'b111: immext = {instr[31:12], 12'b0};

      default: immext = 32'bx; // undefined
    endcase

endmodule
