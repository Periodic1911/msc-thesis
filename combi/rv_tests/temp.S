# basic test for all instructions
begin:
  addi  x2, x0, -1;      # x2 = -1
  addi  x3, x0,  5;      # x3 = 5
  addi  x4, x0,  7;      # x4 = 9
  and   x3, x4, x3;      # x3 = (9 and 5) = 1
  srl   x4, x2, x4;      # x4 = -1 >> 9  = 0x001FFFFF
  lui   x5, 0xC000;      # x5 = 0xC000 << 12 = 0x0C000000
  or    x4, x4, x5;      # x4 = 0x0C000000 or 0x001FFFFF = 0x0C1FFFFF
  xori  x6, x3,  5;      # x6 = 5 xor 5 = 0
loop:
  beq   x6, x0, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
  bne   x6, x0, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
  blt   x2, x0, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
  bgeu  x2, x0, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
  bge   x3, x2, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
  bltu  x3, x2, loop_end; # should be taken
  addi  x3, x0, 0;        # shouldn't execute
loop_end:
  addi  x6, x6, 8;       # x6 += 8
  jalr  x8, x6, 32;      # jump to loop + x6
loop_exit:
  sw    x4, 91(x3);      # [96] = 0x0C1FFFFF
  lh    x7, 91(x3);      # x7 = [96] = -1
  lhu   x8, 96(x0);      # x8 = [96] = 0xFFFF
  lb    x9, 94(x3);      # x9 = [99] = 12
  lbu   x10, 96(x0);     # x10 = [96] = 0xFF
  slli  x9, x9, 28;      # x9 = 0xC << 28 = 0xC0000000
  srai  x9, x9, 28;      # x9 = 0xC0000000 >> 28 = 0xFFFFFFFC
  xor   x9, x9, x2       # x9 = 0xFFFFFFFC ^ 0xFFFFFFFF = 3
  sw    x4, 92(x0)       # [96] = x4 >> 16 = 0x0C1F0C1F
  sh    x7, 95(x0)       # [96] = x2 >> 8  = 0x0C1F0CFF
  lbu   x4, 96(x0)       # x4 = [96] = 0xFF
  lbu   x9, 97(x0)       # x9 = [97] = 0x0C
auipc_label:
  auipc x2, 56           # x2 = 56 << 12 + pc
  srli  x5, x2, 12       # x5 = x2 >> 12 = 56
  andi  x2, x2, 2047     # x2 = x2 & 0x7FF = 0x88:
  jal   x7, jal_skip     # x7 = 0x98
  addi  x3, x0, 0;       # shouldn't execute
jal_skip:
  sub   x2, x2, x7       # x2 = 0x88 - 0x98 = -16
  add   x5, x5, x6       # x5 = 56 + 56 = 112
  sub   x5, x5, x9       # x5 = 112-12 = 100
  sub   x3, x3, x2       # x3 = 5 - (-16) = 21
  addi  x3, x3, 4        # x3 = 21 + 4 = 25
end:
  sw    x3, 100(x0);

done:
  beq x2, x2, done;      # infinite loop
