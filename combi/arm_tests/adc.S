# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_RR_CARRY( 1,  adc, 1, 0, 0 );
  TEST_RR_CARRY( 2,  adc, 4, 2, 1 );
  TEST_RR_CARRY( 3,  adc, 5, 3, 1 );
  TEST_RR_OP( 4,  adc, 0x10F, 0xFF, 0x10 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
