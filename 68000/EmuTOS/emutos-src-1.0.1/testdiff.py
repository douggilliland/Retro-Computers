#!/usr/bin/python
import os

with open("commits", "r") as c:
    for l in c:
        l = l.strip()
        with os.popen("git show -w --diff-algorithm=myers %s | wc" % l) as s:
            m = s.read().strip()
        with os.popen("git show -w --diff-algorithm=histogram %s | wc" % l) as s:
            h = s.read().strip()
        if (m != h):
            print(l,m,h)
