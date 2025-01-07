# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_RR_CARRY( 1,  rsc, -1, 0, 0 );
  TEST_RR_CARRY( 2,  rsc, -1, 1, 1 );
  TEST_RR_CARRY( 3,  rsc, -3, 3, 1 );
  TEST_RR_OP( 4,  rsc, -0xF, 0xFF, 0xF0 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
