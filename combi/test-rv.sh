#!/bin/bash

arm_files="arm_tests/DDCA.S"
files=$(ls rv_tests/*.S)

for f in $arm_files $files; do
  basename=${f%.S}
  echo -ne "$basename\t"
  nodir=${basename#rv_tests/}
  nodir=${nodir#arm_tests/}
  [[ ${basename#arm} == $basename ]] && \
    { make $nodir.hex > /dev/null 2> /dev/null && echo OK || echo ERROR; } \
  || \
    { make $nodir.arm.hex > /dev/null 2> /dev/null && echo OK || echo ERROR; }
done | tee test_result

echo "      NEW RESULTS     |      OLD RESULTS     "
echo "----------------------|----------------------"
diff -y -W 50 --suppress-common-lines test_result expected_result
