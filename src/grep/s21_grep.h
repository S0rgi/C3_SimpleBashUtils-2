#ifndef S21_GREP_H
#define S21_GREP_H

#include <regex.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct {
  bool e;
  bool i;
  bool v;
  bool c;
  bool l;
  bool n;
  bool h;
  bool s;
  bool f;
  bool o;
} Flags;

// Прототипы функций
int flag_handler(char *argv[], const int argc, Flags *flags, char *patterns[],
                 int *pattern_count);
void print_lines(FILE *file, Flags flags, char *patterns[], int pattern_count,
                 const char *file_path, int multiple_files);
void print_matching_part(const char *line, char *patterns[], int pattern_count,
                         Flags flags, const char *file_pat, int multiple_files,
                         const int *line_number);
int count_matching_lines(FILE *file, Flags flags, char *patterns[],
                         int pattern_count);
bool template_in_string(const char *line, char *patterns[], int pattern_count,
                        Flags flags);
int process_files(const char *argv[], int argc, int optind_start,
                  char *patterns[], int pattern_count, Flags flags);
void process_count(FILE *file, Flags flags, char *patterns[],
                   int pattern_count);
void print_matching_line(const char *file_path, int multiple_files, Flags flags,
                         const char *line, const int *line_number,
                         char *patterns[], int pattern_count);
void pattern_from_file(const char *filename, char *patterns[],
                       int *pattern_count);
#endif  // S21_GREP_H
