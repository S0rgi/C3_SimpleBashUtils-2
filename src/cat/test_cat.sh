#!/bin/bash

COUNTER_SUCCESS=0
COUNTER_FAIL=0
DIFF_RES=""
echo "" > log.txt
if [ "$1" == "val" ]; then
  echo "" > val_log.txt
  echo "Testing with valgrind"
fi
if [ "$1" == "leaks" ]; then
  echo "" >leak_log.txt
  echo "Testing with leaks"
fi


OPTIONS=('' -b -e -n -s -t -v -E -T "--number-nonblank" "--number" "--squeeze-blank")
FILES=("bytes.txt" "bytes2.txt" "bytes.txt bytes2.txt")

for var in "${OPTIONS[@]}"
do
  for var2 in "${OPTIONS[@]}"
  do
    for var3 in "${OPTIONS[@]}"
    do
      if [[ "$var" != "$var2" || -z "$var" ]] && \
         [[ "$var2" != "$var3" || -z "$var2" ]] && \
         [[ "$var" != "$var3" || -z "$var" ]]
      then
        for TEST_FILE in "${FILES[@]}"
        do
          TEST="$var $var2 $var3 $TEST_FILE"
          echo "$TEST"
          ./s21_cat $TEST > s21_cat.txt 2>/dev/null
          cat $TEST > cat.txt 2>/dev/null
          DIFF_RES="$(diff -s s21_cat.txt cat.txt)"
          if [ "$1" == "val" ]; then
            echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt
            valgrind --tool=memcheck --leak-check=full --track-origins=yes -s ./s21_cat $TEST |& grep -a -e "ERROR SUMMARY:" |& grep -v -e "0 errors from 0 contexts (suppressed: 0 from 0)" >> val_log.txt
          fi
          if [ "$1" == "leaks" ]; then
            echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt
            leaks -atExit -- ./s21_cat $TEST |& grep -a -e "total leaked bytes"  >> leak_log.txt
          fi
          if [[ "$DIFF_RES" == "Files s21_cat.txt and cat.txt are identical" ]]
          then
            (( COUNTER_SUCCESS++ ))
          else
            echo "FAIL: $TEST" >> log.txt
            (( COUNTER_FAIL++ ))
          fi
          rm -f s21_cat.txt cat.txt
        done
      fi
    done
  done
done

echo "SUCCESS: $COUNTER_SUCCESS"
echo "FAIL: $COUNTER_FAIL"
RESULT=$((COUNTER_SUCCESS * 100 / (COUNTER_SUCCESS + COUNTER_FAIL)))
echo "RESULT - $RESULT%"
if [ "$1" == "val" ]; then
    echo "valgrind result"
    echo "all test  : $(grep -c "ERROR SUMMARY:" val_log.txt)"
    echo "good test : $(grep -c "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)" val_log.txt)"
fi
