These files are from Leventhal's 6809 subroutines book.

Leventhal's books were the starting point for many people entering the world of assembly-language programming.
His books for more popular processors were printed in great numbers and are easily and cheaply available.
They've even been uploaded to archive.org, as historically significant documents worth preserving.
The 6809 was never as popular as the Z80 and 6502, and although the assembly language programming book is still affordable, the subroutines book has just about gone extinct in the wild. Internet pricing robots have spotted the rarity and the last copies to appear were insanely expensive. I managed to buy a copy, and immediately scanned it.

I felt the subroutines might be useful to the 6809 community but typing them into source files would be a big chore and prone to human error multiplied by the number of typists. So I decided to convert them using OCR followed by hand editing.

There was a lot of editing to do, because the OCR used (Google docs) tries to be clever and spot columns of text. 
There are the usual OCR errors too.

This was a big job, especially for the longer routines

The book itself could be OCR'd but the source code is higher priority. 
Humans can read scanned pages, but assemblers need text.

Routines have been assembled using the online assembler here:

https://www.asm80.com

This assembles several common 8-bit machines and to make life easier it tries to use a common syntax for all. 
Motorola liked to use * to indicate comments, but most assemblers use semicolon. 
Hence the subroutines have been edited to use a semicolon too.

The asm80 online assembler is available to anyone with net access, and is not confined to an operating system.

I have not tested the routines, as this will require someone to write a test suite.
Firstly to check they give the same results as the book shows, but ideally to test extreme conditions to be more confident across a range of values.

The routines might not be the most efficient, but they are documented and explained.
These routines simply give people code to do things without having to write and debug their own routines. 


