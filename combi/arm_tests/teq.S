# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_TST_IMM_OP( 1,  teq, eq, 1, 1 );
  TEST_TST_IMM_OP( 2,  teq, ne, 0, 1 );
  TEST_TST_OP( 3,  teq, eq, 1, 1 );
  TEST_TST_OP( 4,  teq, ne, 0, 1 );
  TEST_TST_OVERWRITE( 5,  teq, 4, 0, 1 );
  TEST_TST_SHIFT_OP( 6,  teq, eq, 8, 1, LSL #3 );
  TEST_TST_SHIFT_OP( 7,  teq, ne, 9, 1, LSL #3 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
