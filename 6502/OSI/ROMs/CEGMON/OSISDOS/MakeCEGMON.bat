"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\6502\CC65\bin\ca65.exe" cegmon.s -l cegmon.lst
"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\6502\RetroAssembler\retroassembler.exe" cegmon.s -O=bin
"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\PC Tools\srecord\srec_cat.exe" cegmon.bin -Binary -o cegmon.mif -MIF
"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\6502\RetroAssembler\retroassembler.exe" -d cegmon.bin cegmonDis.asm
