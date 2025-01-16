# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  b around;
  b fail;
coolfunc:
  add r0,#3
  mov pc, r14;
  b fail;
around:
  mov TESTNUM, #1;
  sub r0, r0, r0;
  bl coolfunc;
  add r0,#8;
  cmp r0,#11;
  bne fail;

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
