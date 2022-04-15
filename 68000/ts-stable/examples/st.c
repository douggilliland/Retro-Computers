#include <stdio.h>
int y, z = 1, w = 1, i, v, m, r, p = 0, n, mx, s, f, st[2000];
char t = 0, c, u, a, k = 0, pr[2000];
main(argc, argv) int argc;
char* argv[];
{
    FILE* be;
    if (!(be = fopen(argv[1], "rb"))) {
        putc('?', stdout);
        exit(1);
    }
    while ((c = fgetc(be)) != 255) {
        pr[p++] = c;
    }
    fclose(be);
    mx = p;
    i = 1999;
    while (i--) {
        st[i] = 0;
    }
    for (i = 0; i < argc; i++)
        if (i > 1)
            st[i - 2] = atoi(argv[i]);
    p = 0;
    r = 60;
    s = 100;
    while (p <= mx) {
        u = pr[p];
        if (u == '}') {
            p = st[r];
            r--;
        }
        if ((u >= 'A') && (u <= 'Z')) {
            r++;
            st[r] = p;
            p = st[u - 35];
            u = pr[p];
        }
        if (u == '{') {
            f = pr[p + 1] - 35;
            st[f] = p + 2;
            while (u != '}') {
                p++;
                u = pr[p];
            }
            goto nx;
        }
        if (u == '=') {
            if (st[s] == st[s - 1]) {
                st[s] = -1;
            } else {
                st[s] = 0;
            }
        }
        if (u == '>') {
            if (st[s] < st[s - 1]) {
                st[s] = -1;
            } else {
                st[s] = 0;
            }
        }
        if (u == '<') {
            if (st[s] > st[s - 1]) {
                st[s] = -1;
            } else {
                st[s] = 0;
            }
        }
        if (u == '[') {
            r++;
            st[r] = p;
            if (st[s] == 0) {
                p++;
                u = pr[p];
                while (u != ']') {
                    p++;
                    u = pr[p];
                }
            }
        }
        if (u == '(') {
            if (st[s] == 0) {
                s--;
                p++;
                u = pr[p];
                while (u != ')') {
                    p++;
                    u = pr[p];
                }
            } else {
                s--;
            }
        }
        if (u == '_') {
            st[s] = -st[s];
        }
        if (u == '&') {
            st[s - 1] &= st[s];
            s--;
        }
        if (u == '|') {
            st[s - 1] |= st[s];
            s--;
        }
        if (u == '~') {
            st[s] = ~st[s];
        }
        if (u == '+') {
            if (k == 0) {
                st[s - 1] += st[s];
                s--;
            } else {
                st[v]++;
            }
        }
        if (u == '-') {
            if (k == 0) {
                st[s - 1] -= st[s];
                s--;
            } else {
                st[v]--;
            }
        }
        if (u == '*') {
            st[s - 1] *= st[s];
            s--;
        }
        if (u == '/') {
            st[s - 1] /= st[s];
            s--;
        }
        if (u == '%') {
            st[s - 1] %= st[s];
            s--;
        }
        if (u == '#') {
            s++;
            st[s] = st[s - 1];
        }
        if (u == '\\') {
            s--;
        }
        if (u == '$') {
            i = st[s];
            st[s] = st[s - 1];
            st[s - 1] = i;
        }
        if (u == '@') {
            st[s + 1] = st[s - 1];
            s++;
        }
        if (u == '^') {
            c = getc(stdin);
            if (c == 255 || c == 96) {
                exit(0);
            } else {
                s++;
                st[s] = c;
            }
        }
        if (u == '.') {
            printf("%d", st[s]);
            s--;
        }
        if (u == ',') {
            putc(st[s], stdout);
            s--;
        }
        k = 0;
        if (u >= 'a' && u <= 'z') {
            k = 1;
            v = u - 97;
        }
        if (u == ':') {
            st[v] = st[s];
            s--;
        }
        if (u == ';') {
            s++;
            st[s] = st[v];
        }
        if (u == '?') {
            s++;
            st[s] = st[st[v]];
        }
        if (u == '!') {
            st[st[v]] = st[s];
            s--;
        }
        if (u > 47 && u < 58) {
            i = 0;
            while (u > 47 && u < 58) {
                i = i * 10 + u - 48;
                p++;
                u = pr[p];
            }
            s++;
            st[s] = i;
            p--;
        }
        if (u == '\"') {
            p++;
            u = pr[p];
            while (u != '\"') {
                putc(u, stdout);
                p++;
                u = pr[p];
            }
        }
        if (u == ')') {
            ;
        }
        if (u == ']') {
            if (st[s] != 0)
                p = st[r];
            else
                r--;
            s--;
        }
        if (u == '\'') {
            p++;
            u = pr[p];
            while (u != '\'') {
                s++;
                st[s] = u;
                p++;
                u = pr[p];
            }
        }
    nx:
        p++;
    }
}
