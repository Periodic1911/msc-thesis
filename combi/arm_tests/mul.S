# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_RR_OP( 1,  mul, 45, 5, 9);
  //TEST_TST_OP( 2,  muls, nz, 1, 1 );
  TEST_CASE( 2, r4, 64, ldr r0, =5; ldr r1, =9; ldr r2, =19; mla r4,r0,r1,r2 );
  ldr r1, =0x55000000
  ldr r2, =0x30000001
  umull r3,r4, r1,r2
  TEST_CASE( 3, r4, 0x0ff00000, );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
