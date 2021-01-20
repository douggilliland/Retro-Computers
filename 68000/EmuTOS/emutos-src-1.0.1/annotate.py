import re
import sys

if len(sys.argv) != 3:
    print("Usage: %s c-file gcc-output" % sys.argv[0])
    quit()

lds = dict()
det = dict()

with open(sys.argv[2], "r") as dump:
    for l in dump:
        m = re.match("\s*\[.*?\.c\s*:\s*(\d+):.*?\]\s+# VUSE", l) # only .c files!
        if m:
            no = int(m.group(1))
            if no in lds:
                lds[no] = lds[no] + 1
                det[no] = det[no]+" "+dump.readline().rstrip()
            else:
                lds[no] = 1
                det[no] = dump.readline().rstrip()

with open(sys.argv[1], "r") as src:
    cnt = 0
    for l in src:
        cnt = cnt + 1
        if cnt in lds:
            print("%d %-90.90s\t////%s" % (lds[cnt], l.rstrip(), det[cnt]))
        else:
            print("  %s" % l.rstrip())
