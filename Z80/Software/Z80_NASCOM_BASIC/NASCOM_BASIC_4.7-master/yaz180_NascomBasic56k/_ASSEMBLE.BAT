tasm -80 -x3 -a7 -fff -c -l d:bas56k.asm d:bas56k.hex

zcc +z180 --no-crt -v -m --list -Ca-f0xFF @nascom56k.lst -o int56k
appmake +glue -b int56k --ihex --pad --filler 0xFF --recsize 24 --clean
