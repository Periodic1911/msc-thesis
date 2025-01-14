# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  ldr r14, =tdat;
  ldmia r14,{r0,r2,r5,r13}
  TEST_CASE( 1, r14, tdat+16, ldr r14, =tdat; stmia r14!,{r0,r2,r5,r13} );
  TEST_CASE( 2, r14, tdat+16, ldr r14, =tdat; stmib r14!,{r0,r2,r5,r13} );
  TEST_CASE( 3, r14, tdat, ldr r14, =tdat+16; stmda r14!,{r0,r2,r5,r13} );
  TEST_CASE( 4, r14, tdat, ldr r14, =tdat+16; stmdb r14!,{r0,r2,r5,r13} );
  TEST_CASE( 5, r14, tdat, ldr r14, =tdat;    stmib r14,{r0,r2,r5,r13} );
  TEST_CASE( 6, r14, tdat+16, ldr r14, =tdat+16; stmda r14,{r0,r2,r5,r13} );

  ldr r14, =tdat2;
  stmia r14!,{r0,r2,r5,r13};
  TEST_CASE(10, r1, 0x11111111, ldr r3, =tdat2; ldr r1, [r3]; );
  TEST_CASE(11, r1, 0x22222222, ldr r3, =tdat2+4; ldr r1, [r3]; );
  TEST_CASE(12, r1, 0x33333333, ldr r3, =tdat2+8; ldr r1, [r3]; );
  TEST_CASE(13, r1, 0x44444444, ldr r3, =tdat2+12; ldr r1, [r3]; );

  ldr r14, =tdat2+12;
  stmda r14!,{r0,r2,r5,r13};
  TEST_CASE(14, r1, 0x44444444, ldr r3, =tdat2; ldr r1, [r3]; );
  TEST_CASE(15, r1, 0x33333333, ldr r3, =tdat2+4; ldr r1, [r3]; );
  TEST_CASE(16, r1, 0x22222222, ldr r3, =tdat2+8; ldr r1, [r3]; );
  TEST_CASE(17, r1, 0x11111111, ldr r3, =tdat2+12; ldr r1, [r3]; );

  ldr r14, =tdat2+16;
  stmdb r14!,{r0,r2,r5,r13};
  TEST_CASE(18, r1, 0x44444444, ldr r3, =tdat2; ldr r1, [r3]; );
  TEST_CASE(19, r1, 0x33333333, ldr r3, =tdat2+4; ldr r1, [r3]; );
  TEST_CASE(20, r1, 0x22222222, ldr r3, =tdat2+8; ldr r1, [r3]; );
  TEST_CASE(21, r1, 0x11111111, ldr r3, =tdat2+12; ldr r1, [r3]; );

  ldr r14, =tdat2-4;
  stmib r14!,{r0,r2,r5,r13};
  TEST_CASE(22, r1, 0x11111111, ldr r3, =tdat2; ldr r1, [r3]; );
  TEST_CASE(23, r1, 0x22222222, ldr r3, =tdat2+4; ldr r1, [r3]; );
  TEST_CASE(24, r1, 0x33333333, ldr r3, =tdat2+8; ldr r1, [r3]; );
  TEST_CASE(25, r1, 0x44444444, ldr r3, =tdat2+12; ldr r1, [r3]; );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN
tdat:
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
tdat2:
.word 0
.word 0
.word 0
.word 0

  TEST_DATA

ARMTEST_DATA_END
