# 6502 Monitor

[MOS 6502](https://en.wikipedia.org/wiki/MOS_Technology_6502) Monitor implemented in assembler for competiton [Jednodesková výzva](https://retrocip.cz/jednodeskova-vyzva-prvni-kolo/). Implemented and tested in [ASM80 IDE](http://www.asm80.com/)

![screenshot](https://github.com/VelkyVenik/6502-monitor/raw/master/screen.png)


# How To
1. Go to [ASM80 IDE](http://www.asm80.com/)
1. For file in (6502.emu, monitor.a65, serial.a65) { Create _New file_; Enter $file name; Copy&Paste file content }
1. Open monitor.a65 file
1. Start _Simulator [F10]_

## Device description
- CPU C6502
- 4kB ROM (f000h-ffffh)
- 1kB RAM (0000h-03ffh)
- 6850 ACIA UART chip (control 0xa000, data 0xa001)

## Useful Links
- [Assembler Tutorial in Czech](https://strojak.cz/category/assembler/6502/)
- [Another Tutorial](https://skilldrick.github.io/easy6502/)
- [Wiki](https://en.wikipedia.org/wiki/MOS_Technology_6502)
- [6502.org](http://6502.org)
- [Instruction set](http://www.6502.org/tutorials/6502opcodes.html)
- [Instruction set](http://www.obelisk.me.uk/6502/reference.html)
- [The Woz Monitor](http://www.sbprojects.net/projects/apple1/wozmon.php)
- [Daryl's Monitor](http://sbc.rictor.org/sbcos.html)
- [ASCII Table](http://www.asciitable.com)
