# See LICENSE for license details.

#*****************************************************************************
# shift.S
#-----------------------------------------------------------------------------

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

/*
  TEST_IMM_OP( 1,  add, 0, 0, 0 );
  TEST_IMM_OP( 2,  add, 2, 1, 1 );
  TEST_RR_OP( 3,  add, 2, 1, 1 );
*/
  TEST_RR_SHIFT_OP( 1,  add, 3, 1, 1, LSL #1 );
  TEST_RR_SHIFT_OP( 2,  add, 0x80000011, 0x11, 1, ROR #1 );
  TEST_RR_SHIFT_OP( 3,  orr, 0xFF000000, 0x00000000, 0xF0000000, ASR #4 );
  TEST_RR_SHIFT_OP( 4,  orr, 0x0F000000, 0x00000000, 0xF0000000, LSR #4 );
  TEST_RR_SHIFT_OP( 5,  add, 0x9000, 0x5000, 4, LSL #12 );
  TEST_RR_SHIFT_OP( 6,  add, 0x13, 0x11, 1, ROR #31 );
  TEST_RR_SHIFT_OP( 7,  and, 0x000000FF, 0x000000FF, 0x80000000, ASR #31 );
  TEST_RR_SHIFT_OP( 8,  orr, 0x0000F000, 0x00000000, 0xF0000000, LSR #16 );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
