# 65C02-Monitor

This is a 65C02 monitor developed for my 65C02 board. It contains a 65C02, 6551(ACIA), 6522(VIA) and the usual ROM (27C256), RAM decoding etc. It can be ported onto any 65C02 based computer with some minor modifications eg: KIM-1,Apple, C64,ViC20. 

After searching the net I didn’t like many if not all the 6502 OS/Monitors. In my opinion I liked bits of them. So I decided to create my own. I began with little care about space, more functionality, but in the end, i was forced to keep it real tight. 

My goal was for it to be a development machine/ bench top computer. Able to paste code to the terminal, compile it, dump, decode it, edit it etc. Some of this code had been inspired by many before me - the A1 Assembler by San Bergmans https://www.sbprojects.net/whoami/index.php.  

I liked the front editor but didn’t come with a dissembler. It’s 2 pass assembler and felt solid - but mostly written for an Apple.  
With his permission i used his front end, but i ended up re-writing allot of it and certianly went over every line. 

On the other hand The KRUSADER by Ken Wessen had the super-efficient dissembler that I’ve seen before (probably created by MOS and used by Apple) and it was tackling the additional 65C02 instructions. Didnt like the editor. 

The old DOS debug command is how i wanted the console to feel like, in other words, mistyping something means hitting the backspace not having to retype the whole line again as many of these monitors have you do – nuts.

So this is a full 2 pass assembler, with local and global labels, directives, the lot. I’ve also added a 65C02 dissembler, step by step debugging aka tracing, memory dump, ascii dump, fill, delete, block move, intel hex loader.  

I’ve tested this on a real N65C02 computer. I’ve also included LCD 16x2 code - again also tested on real hardware.  
Its currently takes just over 3.2KB



