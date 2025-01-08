# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_CASE( 1, r14, tdat+16, ldr r14, =tdat; ldmia r14!,{r0,r2,r5,r13} );
  TEST_CASE( 2, r14, tdat+16, ldr r14, =tdat; ldmib r14!,{r0,r2,r5,r13} );
  TEST_CASE( 3, r14, tdat, ldr r14, =tdat+16; ldmda r14!,{r0,r2,r5,r13} );
  TEST_CASE( 4, r14, tdat, ldr r14, =tdat+16; ldmdb r14!,{r0,r2,r5,r13} );
  TEST_CASE( 5, r14, tdat, ldr r14, =tdat;    ldmib r14,{r0,r2,r5,r13} );
  TEST_CASE( 6, r14, tdat+16, ldr r14, =tdat+16; ldmda r14,{r0,r2,r5,r13} );

  TEST_CASE(10, r0, 0x11111111, ldr r14, =tdat; ldmia r14!,{r0,r2,r5,r13} );
  TEST_CASE(11, r2, 0x22222222, ldr r14, =tdat; ldmia r14!,{r0,r2,r5,r13} );
  TEST_CASE(12, r5, 0x33333333, ldr r14, =tdat; ldmia r14!,{r0,r2,r5,r13} );
  TEST_CASE(13, r13, 0x44444444, ldr r14, =tdat; ldmia r14!,{r0,r2,r5,r13} );

  TEST_CASE(14, r0, 0x44444444, ldr r14, =tdat+12; ldmda r14!,{r0,r2,r5,r13} );
  TEST_CASE(15, r2, 0x33333333, ldr r14, =tdat+12; ldmda r14!,{r0,r2,r5,r13} );
  TEST_CASE(16, r5, 0x22222222, ldr r14, =tdat+12; ldmda r14!,{r0,r2,r5,r13} );
  TEST_CASE(17, r13, 0x11111111, ldr r14, =tdat+12; ldmda r14!,{r0,r2,r5,r13} );

  TEST_CASE(18, r0, 0x44444444, ldr r14, =tdat+16; ldmdb r14!,{r0,r2,r5,r13} );
  TEST_CASE(19, r2, 0x33333333, ldr r14, =tdat+16; ldmdb r14!,{r0,r2,r5,r13} );
  TEST_CASE(20, r5, 0x22222222, ldr r14, =tdat+16; ldmdb r14!,{r0,r2,r5,r13} );
  TEST_CASE(21, r13, 0x11111111, ldr r14, =tdat+16; ldmdb r14!,{r0,r2,r5,r13} );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN
tdat:
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444

  TEST_DATA

ARMTEST_DATA_END
