#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {
    char *line = 0;
    size_t line_size = 0;
    size_t size;

    while ((size = getline(&line, &line_size, stdin)) != -1) {
        size_t len = strlen(line);
        if (len > 0 && line[len - 1] == '\n')
            line[--len] = 0;
        if (*line == '*') {
            printf("; %s\n", line);
            continue;
        }
        if (len >= 24) {
            const char *p = line + 23;
            if (isprint(*p) && isspace(p[-1])) {
                printf("%.23s; %s\n", line, p);
                continue;
            }
            while (*p && !isspace(*p))
                p++;
            if (*p) {
                printf("%.*s ;%s\n", p - line, line, p);
                continue;
            }
        }
        printf("%s\n", line);
    }
    free(line);
    return 0;
}
