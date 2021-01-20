#!/usr/bin/python
import sys
import os

if len(sys.argv) < 2:
	print("Call: %s etos256xx.img" % sys.argv[0])
	exit(1)

with open(sys.argv[1], "r+b") as f:
	f.seek(0, os.SEEK_END)
	if f.tell() != 256*1024:
		print("Wrong file size")
		exit(1)
	f.seek(-8, os.SEEK_END)
	id = f.read(4)
	if id != b"\0\0\0\0":
		print("ID already set?")
		exit(1)
	f.seek(-8, os.SEEK_END)
	f.write(b"CLDY")
