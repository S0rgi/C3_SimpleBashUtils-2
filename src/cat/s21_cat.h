
#ifndef S21_CAT_H
#define S21_CAT_H

#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
typedef struct {
  bool b;
  bool n;
  bool v;
  bool E;
  bool T;
  bool s;
} Flags;

void flag_handler(char *argv[], const int argc, Flags *flags);
void print_lines(FILE *file, Flags flags, int *line_number);
void flag_numbers(Flags flags, int *line_number, int length);
void invisible_chars(char *line, size_t *length, unsigned char ch, Flags flags);
#endif