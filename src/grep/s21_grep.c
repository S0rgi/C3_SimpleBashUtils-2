#include "s21_grep.h"
int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr,
            "Usage: grep [OPTION]... PATTERNS [FILE]...\nTry 'grep --help' for "
            "more information.\n");
  } else {
    Flags flags = {0};
    char *patterns[100];
    int pattern_count = 0;

    int optind_start =
        flag_handler(argv, argc, &flags, patterns, &pattern_count);

    if (pattern_count == 0 && !flags.f) {
      patterns[pattern_count++] = strdup(argv[optind_start]);
      optind_start++;
    }

    if (pattern_count == 0) {
      fprintf(stderr, "Pattern must be provided\n");
    } else {
      process_files((const char **)argv, argc, optind_start, patterns,
                    pattern_count, flags);
      for (int i = 0; i < pattern_count; i++) {
        free(patterns[i]);
      }
    }
  }
  return 0;
}

int process_files(const char *argv[], int argc, int optind_start,
                  char *patterns[], int pattern_count, Flags flags) {
  int return_code = 0;
  int multiple_files = argc - optind_start > 1;
  int file_not_found = 0;

  for (int i = optind_start; i < argc; i++) {
    const char *file_path = argv[i];
    FILE *file = fopen(file_path, "r");

    if (file == NULL) {
      if (!flags.s) {
        fprintf(stderr, "grep: %s: No such file or directory\n", file_path);
      }
      file_not_found = 1;
    } else {
      print_lines(file, flags, patterns, pattern_count, file_path,
                  multiple_files);
      fclose(file);
    }
  }

  if (file_not_found) {
    return_code = 1;
  }

  return return_code;
}

void print_lines(FILE *file, Flags flags, char *patterns[], int pattern_count,
                 const char *file_path, int multiple_files) {
  char *line = NULL;
  size_t length = 0;
  int line_number = 0;
  int match_count = 0;
  int flag = 1;

  while (getline(&line, &length, file) != -1 && flag) {
    line_number++;
    if (template_in_string(line, patterns, pattern_count, flags)) {
      match_count++;
      if (!flags.c && !flags.l) {
        print_matching_line(file_path, multiple_files, flags, line,
                            &line_number, patterns, pattern_count);
      }
    }
  }
  if (flag && flags.l && match_count != 0)
    printf("%s\n", file_path);
  else if (flag && flags.c && !flags.l) {
    if (multiple_files && !flags.h) printf("%s:", file_path);
    printf("%d\n", match_count);
  }

  free(line);
}

void print_matching_line(const char *file_path, int multiple_files, Flags flags,
                         const char *line, const int *line_number,
                         char *patterns[], int pattern_count) {
  if (multiple_files && !flags.h && !flags.o) printf("%s:", file_path);

  if (flags.n && !flags.o) printf("%d:", (*line_number));

  if (flags.o)
    print_matching_part(line, patterns, pattern_count, flags, file_path,
                        multiple_files, line_number);
  else {
    printf("%s", line);
    if (line[strlen(line) - 1] != '\n') {
      printf("\n");
    }
  }
}

void print_matching_part(const char *line, char *patterns[], int pattern_count,
                         Flags flags, const char *file_path, int multiple_files,
                         const int *line_number) {
  regex_t regex;
  regmatch_t pmatch[1];

  int cflags = REG_EXTENDED | (flags.i ? REG_ICASE : 0);

  for (int i = 0; i < pattern_count; i++) {
    int reti = regcomp(&regex, patterns[i], cflags);

    if (reti) {
      fprintf(stderr, "Could not compile regex\n");
      return;
    }

    const char *cursor = line;

    while (regexec(&regex, cursor, 1, pmatch, 0) == 0) {
      if (multiple_files && !flags.h) printf("%s:", file_path);
      if (flags.n) printf("%d:", (*line_number));
      printf("%.*s\n", (int)(pmatch[0].rm_eo - pmatch[0].rm_so),
             cursor + pmatch[0].rm_so);
      cursor += pmatch[0].rm_eo;
    }

    regfree(&regex);
  }
}

bool template_in_string(const char *line, char *patterns[], int pattern_count,
                        Flags flags) {
  bool flag = true;
  bool result = false;
  if (patterns == NULL || line == NULL) {
    flag = false;
  }

  regex_t regex;

  int cflags = REG_EXTENDED | (flags.i ? REG_ICASE : 0);
  bool match_found = false;
  char msg[100];

  int i = 0;

  while (flag && i < pattern_count && !match_found && patterns[i] != NULL) {
    int reti = regcomp(&regex, patterns[i], cflags);

    if (reti != 0) {
      regerror(reti, &regex, msg, sizeof(msg));
      fprintf(stderr, "Regex compilation failed: %s\n", msg);
      result = false;
      match_found = true;
    } else {
      reti = regexec(&regex, line, 0, NULL, 0);
      regfree(&regex);

      if (reti == 0) {
        result = !flags.v;
        match_found = true;
      } else if (reti == REG_NOMATCH) {
        result = flags.v;
      }
    }

    i++;
  }

  return result;
}

int flag_handler(char *argv[], const int argc, Flags *flags, char *patterns[],
                 int *pattern_count) {
  int opt;
  while ((opt = getopt(argc, argv, "e:ivclnhsof:")) != -1) {
    switch (opt) {
      case 'e':
        patterns[(*pattern_count)++] = strdup(optarg);
        flags->e = true;
        break;
      case 'i':
        flags->i = true;
        break;
      case 'v':
        flags->v = true;
        break;
      case 'c':
        flags->c = true;
        break;
      case 'l':
        flags->l = true;
        break;
      case 'n':
        flags->n = true;
        break;
      case 'h':
        flags->h = true;
        break;
      case 's':
        flags->s = true;
        break;
      case 'f':
        flags->f = true;
        pattern_from_file(optarg, patterns, pattern_count);
        break;
      case 'o':
        flags->o = true;
        break;
      default:
        fprintf(stderr,
                "Usage: grep [OPTION]... PATTERNS [FILE]...\nTry 'grep --help' "
                "for more information.\n");
        break;
    }
  }

  return optind;
}

void pattern_from_file(const char *filename, char *patterns[],
                       int *pattern_count) {
  FILE *file = fopen(filename, "r");
  if (!file) {
    fprintf(stderr, "grep: %s: No such file or directory\n", filename);
  } else {
    char *line = NULL;
    size_t len = 0;
    while (getline(&line, &len, file) != -1) {
      size_t line_len = strlen(line);
      if (line_len > 0 && line[line_len - 1] == '\n') {
        line[line_len - 1] = '\0';
      }
      patterns[(*pattern_count)++] = strdup(line);
    }
    free(line);
    fclose(file);
  }
}