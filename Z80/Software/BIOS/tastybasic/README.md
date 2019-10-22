# Tasty Basic

## Introduction
Tasty Basic is a basic interpreter for the SBC v2, based on the Z80 port of Palo Alto Tiny Basic
([Gabbard, 2017; Rauskolb, 1976; Wang, 1976](##References)).

## Tasty Basic Language
The Tasty Basic language is based on Palo Alto Tiny Basic, as described in the December 1976
issue of Interface Age ([Rauskolb, 1976](##References)). As such, Tasty Basic shares many of the
same limitations as Palo Alto Basic. All numbers are integers and must be less than or
equal to 32767, and support for only 26 variables denoted by letters A through Z. In addition
to Tiny Basic's `ABS(n)`, `RND(n)` and `SIZE` functions, however, Tasty Basic provides statements and functions
to read and write memory locations, and allows interaction with I/O ports.

### Statements
Tasty Basic provides two statements to write to memory and I/O ports:

`POKE m,n` Writes the value _n_ to address location _m_

`OUT m,n` Sends the value n to I/O port _m_

Additionally there are statements to define and read constant values:

`DATA m[,n[,...]]` Used to store constant values in the program code. Each DATA statement can define one or more constants separated by commas. Note that `DATA` statements *must* appear before any `READ` statements.

`READ m` Reads the next available data value and assigns it to variable _m_, starting with the left most value in the first `DATA` statement.

### Functions
Tasty Basic provides the following functions to read from and write to memory locations and I/O ports:

`IN(m)` Returns the byte value read from I/O port _m_

`PEEK(m)` Returns the byte value of address location _m_

`USR(i)`  Accepts a numeric expression _i_ , calls a user-defined machine language routine, and returns the resulting value.

### User defined machine language routines
The `USR(i)` function enables interaction with user defined machine routines.
The entry point for these routines is specified using a vector at $13FE/$13FF,
which by default points to $1400. The value _i_ is passed to the routine
in the `DE` register, which must also contain the result on return.

#### Example
The following example shows the bit summation for a given value:

```
0001   1400               .ORG 5120
0002   1400 06 00         LD B,0
0003   1402 7A            LD A,D
0004   1403 CD 0E 14      CALL COUNT
0005   1406 7B            LD A,E
0006   1407 CD 0E 14      CALL COUNT
0007   140A 58            LD E,B
0008   140B 16 00         LD D,0
0009   140D C9            RET
0010   140E             COUNT:
0011   140E FE 00         CP 0
0012   1410 C8            RET Z
0013   1411 CB 47         BIT 0,A
0014   1413 28 01         JR Z,NEXT
0015   1415 04            INC B
0016   1416             NEXT:
0017   1416 CB 3F         SRL A
0018   1418 18 F4         JR COUNT
0019   141A               .END
```

```
10 DATA 6,0,122,205,14,20,123,205,14,20,88,22,0,201
20 DATA 254,0,200,203,71,40,1,4,203,63,24,244
30 FOR I=0 TO 25
40 READ A
50 POKE 2560+I,A
60 NEXT I
70 INPUT P
80 Q=USR(P)
90 PRINT "THE BIT SUMMATION OF "#5,P," IS "#2,Q
100 GOTO 70
```


## Building the ROM image

Building the ROM image requires TASM (Telemark Assembler).

## Running in Z80 Emulator
Tasty Basic can be run in the Z80 Emulator ([Moore, 2015](##References)) when it is built with
the `-Dzemu` flag:

```tasm.exe -t80 -g3 -fFF -Dzemu tastybasic.asm tastybasic.bin tastybasic.lst```

Then load the resulting `tastybasic.bin` image in the emulator at address 0, bank 0.

Before running, ensure that the `TTY0` device is configured as following in the Z80 Emulator:

**I/O Devices**

| Device | CRT | TTY | COM | NET | Printer | Spooler |
|-------:|:---:|:---:|:---:|:---:|:-------:|:-------:|
| TTY 0  |     |  x  |     |     |         |         |

**I/O Properties for device 0**

|              | Bit | State | Status |
|--------------|:---:|:-----:|:------:|
| RxFull       | 1   | 1     | 00     |
| TxEmpty      | 0   | 1     |        
| RxFull IntE  | N/A |        
| TxEmpty IntE | N/A |         


## Example BASIC programs

A small number of example BASIC programs are included in the `examples` directory. Most of
these programs are from _BASIC COMPUTER GAMES_ ([Ahl, 1978](##References)), and have been
modified as required to make them work with Tasty Basic.


## License
In line with Wang's (1976) original Tiny Basic source listing and later derived works
by Rauskolb (1976) and Gabbard (2017), Tasty Basic is licensed under GPL v3.
For license details refer to the enclosed [LICENSE](../master/LICENSE) file.

## References
Ahl, D. H. (Ed.).(1978). _BASIC COMPUTER GAMES_. New York, NY: Workman Publishing  
b1ackmai1er (2018). _SBC V2_. Retrieved  October 6, 2018, from [https://www.retrobrewcomputers.org/doku.php?id=boards:sbc:sbc_v2:start](https://www.retrobrewcomputers.org/doku.php?id=boards:sbc:sbc_v2:start)  
Gabbard, D. (2017, October 10). _TinyBASIC for the z80 – TinyBASIC 2.0g._ Retrieved September 29, 2108, from [http://retrodepot.net/?p=274](http://retrodepot.net/?p=274)  
Moore, W. J. (2015). _Z80 Emulator_ [Computer software]. Retrieved October 6, 2018, from [https://amaus.org/static/S100/cromemco/emulator/latest.zemuemulator.rar](https://amaus.org/static/S100/cromemco/emulator/latest.zemuemulator.rar)  
Rauskolb, P. (1976, December). _DR. WANG'S PALO ALTO TINY BASIC._ Interface Age, (2)1, 92-108. Retrieved from [https://archive.org/stream/InterfaceAge197612/Interface%20Age%201976-12#page/n93/mode/1up](https://archive.org/stream/InterfaceAge197612/Interface%20Age%201976-12#page/n93/mode/1up)  
Wang, L-C. (1976). Palo Alto Tiny BASIC. In J. C. Warren Jr. (Ed.), _Dr. Dobb's Journal of COMPUTER Calisthenics & Orthodontia_ (pp. 129-142). Menlo Park, CA: People's Computer Company
