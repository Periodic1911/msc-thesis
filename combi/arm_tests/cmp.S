# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_TST_IMM_OP( 1,  cmp, eq, 1, 1 );
  TEST_TST_IMM_OP( 2,  cmp, ge, 4, 1 );
  TEST_TST_IMM_OP( 3,  cmp, ne, 4, 1 );
  TEST_TST_IMM_OP( 4,  cmp, lt, 1, 4 );
  TEST_TST_IMM_OP( 5,  cmp, lt, -1, 4 );
  TEST_TST_IMM_OP( 6,  cmp, ge, 1, -4 );

  TEST_TST_OP( 7,  cmp, eq, 1, 1 );
  TEST_TST_OP( 8,  cmp, ge, 4, 1 );
  TEST_TST_OP( 9,  cmp, ne, 4, 1 );
  TEST_TST_OP( 10,  cmp, lt, 1, 4 );
  TEST_TST_OP( 11,  cmp, lt, -1, 4 );
  TEST_TST_OP( 12,  cmp, ge, 1, -4 );

  TEST_TST_OP( 13,  cmp, vs, -0x80000000, 4 );
  TEST_TST_OP( 14,  cmp, vc, 1, 4 );


  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
