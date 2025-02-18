# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_IMM_OP( 1,  rsb, 0, 0, 0 );
  TEST_IMM_OP( 2,  rsb, 0, 1, 1 );
  TEST_IMM_OP( 3,  rsb, -2, 3, 1 );
  TEST_RR_OP( 4,  rsb, -0xF, 0xFF, 0xF0 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
