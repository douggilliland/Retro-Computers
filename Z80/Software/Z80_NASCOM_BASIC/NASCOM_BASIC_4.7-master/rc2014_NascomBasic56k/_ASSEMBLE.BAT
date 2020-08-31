tasm -80 -a7 -fff -c -l d:bas56k.asm d:basic.hex
tasm -80 -a7 -fff -c -l d:int56k.asm d:int56k.hex

# OR

zcc +z80 --no-crt -v -m --list -Ca-f0xFF @nascom56k.lst -o int56k
appmake +glue -b int56k --ihex --pad --filler 0xFF --recsize 24 --clean
