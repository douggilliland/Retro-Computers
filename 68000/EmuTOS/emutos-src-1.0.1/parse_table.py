import sys
import re

symbol_defined = dict()
symbol_used = dict()

for line in sys.stdin:
	
	line = line.strip()
	x = re.match("obj/(.*?\.o)", line)
	if x:
		currentfile = x.group(1)

	x = re.match("[0-9a-f]{8} (.)\s+(\S+) \d+ \d+ \d+ (.*)$", line)
	if x:
		if (x.group(1) == "g"):
			symbol_defined[x.group(3)] = currentfile
		if (x.group(2) == "*UND*"):
			symbol_used[x.group(3)] = currentfile

for symbol in symbol_defined:
	if symbol not in symbol_used:
		print "Potentionally unused global %s (in %s)" % (symbol, symbol_defined[symbol])

