# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_CASE( 1, r1, 0xDEADBEFF, ldr r2, =tdat; ldr r1, [r2]; );
  TEST_CASE( 2, r1, 0xFF, ldr r2, =tdat; ldrb r1, [r2]; );

  TEST_CASE( 3, r3, 0x11111111, ldr r2, =tdat; ldr r1, =0x11111111; str r1, [r2]; ldr r3, [r2]; );
  TEST_CASE( 4, r3, 0x111111FF, ldr r2, =tdat; ldr r1, =0xDEADBEFF; strb r1, [r2]; ldr r3, [r2] );

  TEST_CASE( 5, r1, 0x22222282, ldr r2, =tdat; ldr r1, [r2,4]; );
  TEST_CASE( 6, r1, 0x82, ldr r2, =tdat; ldrb r1, [r2,4]; );
  TEST_CASE( 7, r1, 0x22222282, ldr r2, =tdat+8; ldr r1, [r2,#-4]; );
  TEST_CASE( 8, r1, 0x82, ldr r2, =tdat+8; ldrb r1, [r2,#-4]; );

  ldr r3, =4;
  TEST_CASE( 9, r1, 0x22222282, ldr r2, =tdat; ldr r1, [r2,+r3]; );
  TEST_CASE(10, r1, 0x82, ldr r2, =tdat; ldrb r1, [r2,+r3]; );
  TEST_CASE(11, r1, 0x22222282, ldr r2, =tdat+8; ldr r1, [r2,-r3]; );
  TEST_CASE(12, r1, 0x82, ldr r2, =tdat+8; ldrb r1, [r2,-r3]; );

  // shifts
  ldr r3, =1;
  TEST_CASE(13, r1, 0x22222282, ldr r2, =tdat; ldr r1, [r2,+r3,LSL#2]; );
  ldr r3, =32;
  TEST_CASE(14, r1, 0x82, ldr r2, =tdat; ldrb r1, [r2,+r3, LSR#3]; );
  ldr r3, =1;
  TEST_CASE(15, r1, 0x22222282, ldr r2, =tdat+8; ldr r1, [r2,-r3, ROR#30]; );
  TEST_CASE(16, r1, 0x82, ldr r2, =tdat+8; ldrb r1, [r2,-r3, LSL#2]; );

  ldr r3, =1;
  TEST_CASE(17, r2, tdat+4, ldr r2, =tdat+8; ldrb r1, [r2,-r3, LSL#2]!; );
  TEST_CASE(19, r2, tdat+12, ldr r2, =tdat+16; ldr r1, [r2,-r3, ROR#30]!; );

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
