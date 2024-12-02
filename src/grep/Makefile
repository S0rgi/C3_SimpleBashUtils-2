CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c11 -D_POSIX_C_SOURCE=200809L  -lm -pedantic
VAL = valgrind --tool=memcheck --leak-check=yes
OBJECT = s21_grep
all:clang $(OBJECT)	

$(OBJECT): s21_grep.c
	$(CC) $(CFLAGS) $^ -o $(OBJECT)
clean:
	rm -rf $(OBJECT) log.txt val_log.txt grep.txt s21_grep.txt
rebuild: clean all
clang:
	cp ../../materials/linters/.clang-format ./
	clang-format -n *.c *.h
	clang-format -i *.c *.h
	rm -rf .clang-format		
cpp:
	cppcheck --enable=all --suppress=checkersReport --suppress=missingIncludeSystem *.c
val:$(OBJECT)
	bash tets_grep.sh val
t_bash:$(OBJECT)
	bash tets_grep.sh
lint:
	s21lint *.c *.h
all_tests:s21_grep clang cpp val t_bash
.PHONY: all clean