#include "s21_cat.h"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s [options] file_path...\n", argv[0]);
  } else {
    Flags flags = {0};
    flag_handler(argv, argc, &flags);

    // Loop through each file
    int line_number = 0;
    for (int i = optind; i < argc; i++) {
      const char *file_path = argv[i];
      FILE *file = fopen(file_path, "r");
      if (file == NULL) {
        fprintf(stderr, "Unable to open file: %s\n", file_path);
      } else {
        print_lines(file, flags, &line_number);
        fclose(file);
      }
    }
  }
  return 0;
}

void flag_handler(char *argv[], const int argc, Flags *flags) {
  int opt;
  struct option long_options[] = {{"number-nonblank", no_argument, 0, 'b'},
                                  {"number", no_argument, 0, 'n'},
                                  {"show-ends", no_argument, 0, 'E'},
                                  {"show-nonprint", no_argument, 0, 'v'},
                                  {"squeeze-blank", no_argument, 0, 's'},
                                  {"show-tabs", no_argument, 0, 'T'},
                                  {0, 0, 0, 0}};

  while ((opt = getopt_long(argc, argv, "bnveEtTs", long_options, NULL)) !=
         -1) {
    switch (opt) {
      case 'b':
        flags->b = true;
        break;
      case 'n':
        flags->n = true;
        break;
      case 'v':
        flags->v = true;
        break;
      case 'E':
        flags->E = true;
        break;
      case 'e':
        flags->E = flags->v = true;
        break;
      case 't':
        flags->T = flags->v = true;
        break;
      case 'T':
        flags->T = true;
        break;
      case 's':
        flags->s = true;
        break;
      default:
        fprintf(stderr, "Unknown option: %c\n", opt);
        break;
    }
  }
}

void print_lines(FILE *file, Flags flags, int *line_number) {
  char *line = NULL;
  size_t capacity = 0;
  size_t length = 0;
  char ch;
  int prev_empty = 0;
  bool flag = true;

  while (flag && (ch = fgetc(file)) != EOF) {
    if (length + 3 >= capacity) {
      capacity = (capacity == 0) ? 128 : capacity * 2;
      char *new_line = realloc(line, capacity * sizeof(char));
      if (new_line == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        flag = false;
      } else {
        line = new_line;
      }
    }

    if (flag) invisible_chars(line, &length, ch, flags);

    if (flag && ch == '\n') {
      if (!(prev_empty && length < (flags.E ? 3 : 2) && flags.s)) {
        flag_numbers(flags, line_number, length);
        line[length] = '\0';
        fwrite(line, sizeof(char), length, stdout);
      }
      prev_empty = (length < (flags.E ? 3 : 2)) ? 1 : 0;
      length = 0;
    }
  }

  // Print the last line if it wasn't terminated with a newline
  if (length > 0) {
    if (!(prev_empty && length < (flags.E ? 3 : 2) && flags.s)) {
      flag_numbers(flags, line_number, length);
      line[length] = '\0';
      fwrite(line, sizeof(char), length, stdout);
    }
  }

  free(line);
}

void invisible_chars(char *line, size_t *length, unsigned char ch,
                     Flags flags) {
  if (flags.T && ch == '\t') {
    line[(*length)++] = '^';
    line[(*length)++] = 'I';
  } else if (flags.E && ch == '\n') {
    line[(*length)++] = '$';
    line[(*length)++] = '\n';
  } else if (flags.v &&
             ((ch < 32 && ch != '\n' && ch != '\t') || ch == 127 || ch > 127)) {
    if (ch == 127) {
      line[(*length)++] = '^';
      line[(*length)++] = '?';
    } else if (ch > 127) {
      line[(*length)++] = 'M';
      line[(*length)++] = '-';
      ch -= 128;
      if (ch < 32) {
        line[(*length)++] = '^';
        line[(*length)++] = ch + 64;
      } else {
        line[(*length)++] = ch;
      }
    } else {
      line[(*length)++] = '^';
      line[(*length)++] = ch + 64;
    }
  } else {
    line[(*length)++] = ch;
  }
}

void flag_numbers(Flags flags, int *line_number, int length) {
  if (flags.b) {
    if (length > (flags.E ? 2 : 1)) {
      printf("%6d\t", ++(*line_number));
    }
  } else if (flags.n && !flags.b) {
    printf("%6d\t", ++(*line_number));
  }
}
