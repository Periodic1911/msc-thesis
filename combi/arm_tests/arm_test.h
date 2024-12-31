#ifndef _ENV_ARMV4_TEST_H
#define _ENV_ARMV4_TEST_H

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define ARMTEST_ARMV4
#define TESTNUM r12

/*
MOV RD, #IMM WEIRDNESS
0x10000000 > e3a02201 > rot 4  const 01
0x08000000 > e3a02302 > rot 6  const 02
0x04000000 > e3a02301 > rot 6  const 01
0x00000200 > e3a02c02 > rot 24 const 02

CONCLUSION:
rotate amount is 2*op[11:8]
rotate is RIGHT, not left
*/


#define ARMTEST_CODE_BEGIN		\
	.text;				\
  ldr r0, =.test_name; \
  ldr r2, =0x10000000; \
.prname_next: \
  ldr r1, [r0]; \
  ands r1, r1, r1; \
  beq .prname_done; \
  str r1, [r2]; \
  add r0, r0, 1; \
  b .prname_next; \
.prname_done: \
  mov r1, $'.'; \
  str r1, [r2]; \
  str r1, [r2]; \
.test_name: \
  .ascii TEST_FUNC_TXT; \
  .byte 0x00; \
  .balign 4,0;

#define ARMTEST_PASS			\
  ldr r0, =0x10000000; \
  mov r1, $'O'; \
  mov r2, $'K'; \
  mov r3, $'\n'; \
  str r1, [r0]; \
  str r2, [r0]; \
  str r3, [r0]; \
  b   TEST_FUNC_RET;

#define ARMTEST_FAIL			\
  ldr r0, =0x10000000; \
  mov r1, $'E'; \
  mov r2, $'R'; \
  mov r3, $'O'; \
  mov r4, $'\n'; \
  str r1, [r0]; \
  str r2, [r0]; \
  str r2, [r0]; \
  str r3, [r0]; \
  str r2, [r0]; \
  str r4, [r0]; \
ARMTEST_FAIL_LOOP: \
	b   ARMTEST_FAIL_LOOP;

#define ARMTEST_CODE_END \
TEST_FUNC_RET: \
  mov r1, $7; \
  mov r0, $100; \
  str r1, [r0]; \
  b TEST_FUNC_RET;

#define ARMTEST_DATA_BEGIN .balign 4;
#define ARMTEST_DATA_END

#endif
