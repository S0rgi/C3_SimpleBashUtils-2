COUNTER_SUCCESS=0
COUNTER_FAIL=0
DIFF_RES=""
TEST_FILE1="s21_grep.c"
TEST_FILE2="Makefile"
PATTERN_FILE="reg_exmpl.txt"
GREP_FILE="./s21_grep"
arguments=(-i -v -c -l -n -h -o -s)
echo "" > log.txt
echo "" > val_log.txt
TEST1="grep $TEST_FILE1"
#echo "GREP TEST 1: $TEST1"
$GREP_FILE $TEST1 > s21_grep.txt
grep $TEST1 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST1 |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt

DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST1" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

TEST2="-e grep $TEST_FILE1"
#echo "GREP TEST 2: $TEST2"
$GREP_FILE $TEST2 > s21_grep.txt
grep $TEST2 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST2  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
                echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
                echo "FAIL: $TEST2" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

TEST3="-e grep$ -e grep$ $TEST_FILE1"
#echo "GREP TEST 3: $TEST3"
$GREP_FILE $TEST3 > s21_grep.txt
grep $TEST3 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST3  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "FAIL: $TEST3" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

TEST4="-e grep$ -e grep$ $TEST_FILE1 $TEST_FILE2"
#echo "GREP TEST 4: $TEST4"
$GREP_FILE $TEST4 > s21_grep.txt
grep $TEST4 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt
valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST4  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST4" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

for var in ${arguments[@]}
do
          TEST5="$var grep $TEST_FILE1"
          #echo "GREP TEST 5 $TEST5"
          $GREP_FILE $TEST5 > s21_grep.txt
          grep $TEST5 > grep.txt
          echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

          valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST5  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
          DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
              (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST5" >> log.txt
              (( COUNTER_FAIL++ ))
          fi
done

TEST6="-e -$ -e grep$ $TEST_FILE1 $TEST_FILE2 ../nofile.txt"
#echo "GREP TEST 6: $TEST6"
$GREP_FILE $TEST6 1> s21_grep.txt 2>/dev/null
grep $TEST6 1> grep.txt 2>/dev/null
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST6  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
                echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
                echo "FAIL: $TEST6" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

TEST7="-e cat$ -e grep$ -g $TEST_FILE1 $TEST_FILE2"
#echo "GREP TEST 7: $TEST7"
$GREP_FILE $TEST7 2> s21_grep.txt
grep $TEST7 2> grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST7  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
                echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
                echo "FAIL: $TEST7" >> log.txt 
              (( COUNTER_FAIL++ ))
          fi

TEST8="-f $PATTERN_FILE $TEST_FILE1 $TEST_FILE2"
#echo "GREP TEST 8: $TEST8"
$GREP_FILE $TEST8 > s21_grep.txt
grep $TEST8 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST8  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST8" >> log.txt
              (( COUNTER_FAIL++ ))
          fi

for var in ${arguments[@]}
do
          TEST9="$var -e less -e grep $TEST_FILE1 $TEST_FILE2"
          #echo "GREP TEST 9 $TEST9"
          $GREP_FILE $TEST9 > s21_grep.txt
          grep $TEST9 > grep.txt
          echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

          valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST9  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
          DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST9" >> log.txt
              (( COUNTER_FAIL++ ))
          fi
done

TEST10="less -l $TEST_FILE1 $TEST_FILE2"
#echo "GREP TEST 10: $TEST10"
$GREP_FILE $TEST10 > s21_grep.txt
grep $TEST10 > grep.txt
echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >> val_log.txt

valgrind valgrind --tool=memcheck --leak-check=full --track-origins=yes -s $GREP_FILE $TEST10  |& grep -e "ERROR SUMMARY:" -e "total heap usage:">> val_log.txt
DIFF_RES="$(diff -s s21_grep.txt grep.txt)"
          if [ "$DIFF_RES" == "Files s21_grep.txt and grep.txt are identical" ]
            then
      		    (( COUNTER_SUCCESS++ ))
            else
              echo "$((COUNTER_SUCCESS + COUNTER_FAIL + 1)):" >>log.txt
              echo "FAIL: $TEST10" >> log.txt
              (( COUNTER_FAIL++ ))
          fi
#rm s21_grep.txt grep.txt
echo "SUCCESS: $COUNTER_SUCCESS"
echo "FAIL: $COUNTER_FAIL"
