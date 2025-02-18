# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

/*
  TEST_IMM_OP( 1,  add, 0, 0, 0 );
  TEST_IMM_OP( 2,  add, 2, 1, 1 );
  TEST_RR_OP( 3,  add, 2, 1, 1 );
*/
  TEST_MV_IMM_OP( 1,  mvn, -1, 0 );
  TEST_MV_OP( 2,  mvn, 0x55555555, 0xAAAAAAAA );
  TEST_MV_SHIFT_OP( 3,  mvn, 0x0FFFFFFF, 0xF, ROR #4 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
