# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_TST_IMM_OP( 1,  cmn, eq, 1, -1 );
  TEST_TST_IMM_OP( 2,  cmn, ge, 4, -1 );
  TEST_TST_IMM_OP( 3,  cmn, ne, 4, -1 );
  TEST_TST_IMM_OP( 4,  cmn, lt, 1, -4 );
  TEST_TST_IMM_OP( 5,  cmn, lt, -1, -4 );
  TEST_TST_IMM_OP( 6,  cmn, ge, 1, 4 );

  TEST_TST_OP( 7,  cmn, eq, 1, -1 );
  TEST_TST_OP( 8,  cmn, ge, 4, -1 );
  TEST_TST_OP( 9,  cmn, ne, 4, -1 );
  TEST_TST_OP( 10,  cmn, lt, 1, -4 );
  TEST_TST_OP( 11,  cmn, lt, -1, -4 );
  TEST_TST_OP( 12,  cmn, ge, 1, 4 );

  TEST_TST_OP( 13,  cmn, vs, 0x7fffffff, 4 );
  TEST_TST_OP( 14,  cmn, vc, 1, 4 );


  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
