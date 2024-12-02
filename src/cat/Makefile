CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c11 -D_POSIX_C_SOURCE=200809L  -lm -pedantic
VAL = valgrind --tool=memcheck --leak-check=yes
OBJECT = s21_cat
all:clang s21_cat	

$(OBJECT): s21_cat.c
	$(CC) $(CFLAGS) $^ -o $(OBJECT)
clean:
		rm -rf $(OBJECT) log.txt val_log.txt cat.txt s21_cat.txt leak_log.txt
rebuild: clean all
clang:
	cp ../../materials/linters/.clang-format ./
	clang-format -n *.c *.h
	clang-format -i *.c *.h
	rm -rf .clang-format		
cpp:
	cppcheck --enable=all --suppress=checkersReport --suppress=missingIncludeSystem *.c
val: $(OBJECT)
	bash test_cat.sh val
t_bash:$(OBJECT)
	bash test_cat.sh
lint:
	s21lint *.c *.h
all_tests:$(OBJECT) clang cpp lint val t_bash 
.PHONY: all clean rebuild clang cpp val t_bash all_tests