module extend(input logic arm,
              input logic [31:0] instr,
              input logic [1:0] immsrc,
              output logic [31:0] immext);

logic [31:7] rv_instr = instr[31:7];
logic [23:0] arm_instr = instr[23:0];

always_comb
  if(arm)
    case(immsrc)
      // 8-bit unsigned immediate
      2'b00: immext = {24'b0, instr[7:0]};
      // 12-bit unsigned immediate
      2'b01: immext = {20'b0, instr[11:0]};
      // 24-bit two's complement shifted branch
      2'b10: immext = {{6{instr[23]}}, instr[23:0], 2'b00};
      default: immext = 32'bx; // undefined
    endcase
  else
    case(immsrc)
      // I−type
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};
      // S−type (stores)
      2'b01: immext = {{20{instr[31]}}, instr[31:25],
      instr[11:7]};
      // B−type (branches)
      2'b10: immext = {{20{instr[31]}}, instr[7],
                       instr[30:25], instr[11:8], 1'b0};
      // J−type (jal)
      2'b11: immext = {{12{instr[31]}}, instr[19:12],
                       instr[20], instr[30:21], 1'b0};
      default: immext = 32'bx; // undefined
    endcase

endmodule
