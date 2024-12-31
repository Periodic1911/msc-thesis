# See LICENSE for license details.

#*****************************************************************************
# simple.S
#-----------------------------------------------------------------------------
#
# This is the most basic self checking test. If your simulator does not
# pass thiss then there is little chance that it will pass any of the
# more complicated self checking tests.
#

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

ARMTEST_PASS

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN

  TEST_DATA

ARMTEST_DATA_END
