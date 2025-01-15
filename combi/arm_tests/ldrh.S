# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_CASE( 1, r1, 0xFFFFFFFF, ldr r2, =tdat; ldr r3, =0; ldrsb r1, [r2,r3]; );
  TEST_CASE( 2, r1, 0xFFFFFF82, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2,r3]; );
  TEST_CASE( 3, r1, 0xFFFFFF82, ldr r2, =tdat+8; ldr r3, =4; ldrsb r1, [r2,-r3]; );

  TEST_CASE( 4, r1, 0xFFFFFF82, ldr r2, =tdat; ldrsb r1, [r2,4]; );
  TEST_CASE( 5, r1, 0xFFFFFF82, ldr r2, =tdat+8; ldrsb r1, [r2,#-4]; );

  TEST_CASE(10, r1, 0xFFFFFFFF, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2],r3; );
  TEST_CASE(11, r2, tdat+4, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2],r3; );
  TEST_CASE(12, r2, tdat-4, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2],-r3; );
  TEST_CASE(13, r2, tdat-4, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2],#-4; );
  TEST_CASE(14, r1, 0xFFFFFFFF, ldr r2, =tdat; ldr r3, =4; ldrsb r1, [r2],#-4; );

  TEST_CASE(15, r1, 0x33333333, ldr r2, =tdat+8; ldr r3, =0xDEADBEEF; swp r1, r3, [r2]; ldr r2, [r2]; cmp r2, r3; bne fail; );
  TEST_CASE(16, r1, 0x44444444, ldr r2, =tdat+12; ldr r1, =0xF00DBABE; mov r3, r1; swp r1, r1, [r2]; ldr r2, [r2]; cmp r2, r3; bne fail; );
  TEST_CASE(17, r1, 0x000000BE, ldr r2, =tdat+12; ldr r3, =0xC007BAB5; swpb r1, r3, [r2]; ldr r2, [r2]; ldr r3, =0xF00DBAB5; cmp r2, r3; bne fail; );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN
tdat:
.word 0xDEADBEFF
.word 0x22222282
.word 0x33333333
.word 0x44444444

  TEST_DATA

ARMTEST_DATA_END
