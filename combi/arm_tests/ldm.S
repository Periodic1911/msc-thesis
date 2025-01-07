# See LICENSE for license details.

#include "arm_test.h"
#include "test_macros.h"

ARMTEST_ARMV4
ARMTEST_CODE_BEGIN

  TEST_CASE( 1, r14, tdat+16, ldr r14, =tdat; ldmfd r14!,{r0,r2,r5,r13} );

  TEST_PASSFAIL;

ARMTEST_CODE_END

  .data
ARMTEST_DATA_BEGIN
tdat:
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444

  TEST_DATA

ARMTEST_DATA_END
