# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_TST_IMM_OP( 1,  tst, ne, 1, 1 );
  TEST_TST_IMM_OP( 2,  tst, eq, 0, 1 );
  TEST_TST_OP( 3,  tst, ne, 1, 1 );
  TEST_TST_OP( 4,  tst, eq, 0, 1 );
  TEST_TST_OVERWRITE( 5,  tst, 4, 0, 1 );
  TEST_TST_SHIFT_OP( 6,  tst, ne, 8, 1, LSL #3 );
  TEST_TST_SHIFT_OP( 7,  tst, eq, 9, 1, LSL #3 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
