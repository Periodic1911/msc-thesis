# test from Digital Design and Computer Architecture, RISC-V edition
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
  addi  x3, x3, 20;
  sub   x3, x3, x6;
  addi  x3, x3, 56;
end:
  sw    x3, 100(x0);

done:
  beq x2, x2, done;      # infinite loop
