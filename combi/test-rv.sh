#!/bin/bash

files=$(ls rv_tests/*.S)

for f in $files; do
  basename=${f%.S}
  echo -ne "$basename\t"
  make ${basename#rv_tests/}.hex > /dev/null 2> /dev/null && echo OK || echo ERROR
done | tee test_result

echo "      NEW RESULTS     |      OLD RESULTS     "
echo "----------------------|----------------------"
diff -y -W 50 --suppress-common-lines test_result expected_result
