#!/bin/bash

DIFF_RES=""
COUNTER_SUCCESS=0
COUNTER_FAIL=0

echo "" > log.txt
GREEN='\033[32m'
RED='\033[31m'
NORMAL='\033[0m'
echo -e $GREEN "TESTS for GREP"
OPTIONS=('' -i -v -c -l -h -n -s -o)
FILES=("Makefile" "s21_grep.c" "Makefile s21_grep.c")
PATTERNS=("-e while" "ss" "-e ss -e handler" "-f reg_exmpl.txt")
if [ "$1" == "val" ]; then
  echo "" > val_log.txt
  echo "Testing with valgrind"
fi
for var1 in "${OPTIONS[@]}"
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
        for TEST_PATTERN in "${PATTERNS[@]}"
        do
            TEST0=" $var1 $var2 $var3 $TEST_PATTERN $TEST_FILE "
            ./s21_grep $TEST0 > s21_grep.txt
            # leaks -atExit -- ./s21_grep $TEST0 >> RESULT_VALGRIND.txt
            grep $TEST0 > grep.txt
            DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
            if [ "$1" == "val" ]; then
            echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt
            valgrind --tool=memcheck --leak-check=full --track-origins=yes -s ./s21_grep $TEST0 |& grep -a -e "ERROR SUMMARY:" -e "total heap usage:" >> val_log.txt
            fi
            if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
                then
                    echo -e $NORMAL TEST $((COUNTER_SUCCESS+COUNTER_FAIL+1)) "$TEST0" $GREEN "\tSUCCESS"
                    (( COUNTER_SUCCESS++ ))
                else
                    echo -e $NORMAL TEST $((COUNTER_SUCCESS+COUNTER_FAIL+1)) "$TEST0" $RED "\tFAIL"
                    echo "$TEST0" >> log.txt
                    (( COUNTER_FAIL++ ))
                fi

            rm s21_grep.txt grep.txt
            done
            done
            fi
        done
    done
done

for var5 in "${OPTIONS[@]}"
do  
    for var6 in i c l n h s o v
    do
        for TEST_FILE in "${FILES[@]}"
        do
            for TEST_PATTERN in "${PATTERNS[@]}"
            do
            TEST0="$var5$var6 $TEST_PATTERN $TEST_FILE"
            # leaks -atExit -- ./s21_grep $TEST0 >> RESULT_VALGRIND.txt
            ./s21_grep $TEST0 > s21_grep.txt
            grep $TEST0 > grep.txt
            if [ "$1" == "val" ]; then
            echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt
            valgrind --tool=memcheck --leak-check=full --track-origins=yes -s ./s21_grep $TEST0 |& grep -a -e "ERROR SUMMARY:" -e "total heap usage:" >> val_log.txt
            fi
            DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
            if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
                echo -e $NORMAL TEST $((COUNTER_SUCCESS+COUNTER_FAIL+1)) "$TEST0" $GREEN "\tSUCCESS"
                (( COUNTER_SUCCESS++ ))
            else
                echo -e $NORMAL TEST $((COUNTER_SUCCESS+COUNTER_FAIL+1)) "$TEST0" $RED "\tFAIL"
                echo "$TEST0" >> log.txt
                (( COUNTER_FAIL++ ))
            fi
            rm s21_grep.txt grep.txt
            done
        done
    done
done

echo -e $GREEN SUCCESS $COUNTER_SUCCESS
echo -e $RED FAIL $COUNTER_FAIL
if [ "$1" == "val" ]; then
    echo -e $NORMAL valgrind result
    echo   all test  : $(grep -c "ERROR SUMMARY:" val_log.txt)
    echo -e $GREEN good test : $(grep -c "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)" val_log.txt)
fi