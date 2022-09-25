// Little program to generate the compressed mnemonic values for my
// disassembler.  This has a list of opcodes; for each opcode it will
// output a single line which can be placed into dis.asm.
//
// The values compressed by subtracting '?' from each ASCII character,
// and since there are only upper case characters, 5 bits is easy to
// hold all legal characters.  Compress three bytes into 16 bits to
// conserve space.  First character is in the lowest five bits.
// Pretty common practice.
//
// So, LDA is:
//
//    'L' - '?' = $0D = 01101
//    'D' - '?' = $05 = 00101
//    'A' - '?' = $02 = 00010
//
// Resulting in the 16 bit value of 00010 00101 01101 or $08AD
//
// 09/24/2021 - Bob Applegate, bob@corshamtech.com

#include <stdio.h>
#include <string.h>
#include <ctype.h>

// The list of opcodes...

const char *opcodes[] =
{
	"ADC", "AND", "ASL", "BBR", "BBS", "BCC", "BCS", "BEQ",
	"BIT", "BMI", "BNE", "BPL", "BRA", "BRK", "BVC", "BVS",
	"CLC", "CLD", "CLI", "CLV", "CMP", "CPX", "CPY", "DEC",
	"DEX", "DEY", "EOR", "INC", "INX", "INY", "JMP", "JSR",
	"LDA", "LDX", "LDY", "LSR", "NOP", "ORA", "PHA", "PHP",
	"PHX", "PHY", "PLA", "PLP", "PLX", "PLY", "RMB", "ROL",
	"ROR", "RTI", "RTS", "SBC", "SEC", "SED", "SEI", "SMB",
	"STA", "STP", "STX", "STY", "STZ", "TAX", "TAY", "TRB",
	"TSB", "TSX", "TXA", "TXS", "TYA", "WAI"
};

int main(int argc, char **argv)
{
	char buffer[20];

	for (int i = 0; i < sizeof(opcodes) / sizeof(char *); i++)
	{
		strcpy(buffer, opcodes[i]);

		char *cptr;

		if (strlen(buffer) == 3)
		{
			// Make sure it is upper case

			buffer[0] = toupper(buffer[0]);
			buffer[1] = toupper(buffer[1]);
			buffer[2] = toupper(buffer[2]);

			unsigned int result;
			result = (buffer[2] - '?') << 10;
			result |= (buffer[1] - '?') << 5;
			result |= buffer[0] - '?';

			// Output a line that the assembler can directly
			// work with.  Ie, copy/paste each line.

			printf("MNEM_%s\tdw\t$%04x\n", buffer, result);
		}
		else
		{
			printf("Opcode has wrong length: %s\n", opcodes[i]);
		}
	}
}


