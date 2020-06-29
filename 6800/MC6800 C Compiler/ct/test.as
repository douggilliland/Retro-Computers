 name printf.c
 text
 global _printf
_printf pshs u,y,x
 leay 4,s
* Auto 4 args
* Enter block 2 
* Register 1 ap
* Auto -6 c
* Auto -8 s
* Auto -10 af
* Auto -12 p
* Auto -14 f
* Auto -16 sfout
* Begin expression - 42 
*    ( 1 )  " &O" p-int Var aut -int 4 
*    ( 2 )  " = " p-int Var reg p-int 1  - Node 1 
* Begin expression - 43 
*    ( 1 )  " *O" -int Var reg p-int 1 
*    ( 2 )  " = " -int Var aut -int -14  - Node 1 
* Begin expression - 44 
*    ( 1 )  " = " -int Var aut -int -16  - Con -int -1 
* Begin expression - 45 
*    ( 1 )  "CVC" -xxx Var aut -int -14 
*    ( 2 )  "CVI" -int Node 1 
*    ( 3 )  " < " -int Node 2  - Con -int 20 
* Cbranch 0 L3 
* Enter block 0 
* Begin expression - 46 
*    ( 1 )  "++O" p-int Var reg p-int 1 
* Begin expression - 47 
*    ( 1 )  " !=" -int Var aut -int -14  - Var ext -int _fout
* Cbranch 0 L4 
* Enter block 0 
* Begin expression - 48 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "CAL" -int Var ext f-int _flush
* Begin expression - 49 
*    ( 1 )  " = " -int Var aut -int -16  - Var ext -int _fout
* Begin expression - 50 
*    ( 1 )  " = " -int Var ext -int _fout - Var aut -int -14 
* End block 0 0 2 
L4 
* End block 0 0 1 
L3 
* Begin expression - 53 
*    ( 1 )  "O++" p-int Var reg p-int 1 
*    ( 2 )  " *O" -int Node 1 
*    ( 3 )  "CVC" -xxx Node 2 
*    ( 4 )  "CVP" p-chr Node 3 
*    ( 5 )  " = " p-chr Var aut p-chr -10  - Node 4 
L5 
* Cbranch 1 L6 
* Enter block 0 
L8 
* Begin expression - 55 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
*    ( 5 )  " !=" -int Node 4  - Con -int 37 
* Cbranch 0 L9 
* Enter block 0 
* Begin expression - 56 
*    ( 1 )  " ! " -int Var aut -int -6 
* Cbranch 0 L10 
 lbra L9 
L10 
* Begin expression - 58 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Var aut -int -6 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* End block 0 0 2 
 lbra L8 
L9 
* Begin expression - 60 
*    ( 1 )  " ==" -int Var aut -int -6  - Con -int 0 
* Cbranch 0 L11 
 lbra L6 
L11 
* Begin expression - 62 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
* Begin expression - 63 
*    ( 1 )  " = " -int Var aut -int -12  - Con -int 0 
* Begin expression - 64 
*    ( 1 )  " = " -int Var aut -int -14  - Con -int 0 
* Begin expression - 65 
*    ( 1 )  " ==" -int Var aut -int -6  - Con -int 45 
* Cbranch 0 L12 
* Enter block 0 
* Begin expression - 66 
*    ( 1 )  " |=" -int Var aut -int -14  - Con -int 4 
* Begin expression - 67 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
* End block 0 0 2 
L12 
* Begin expression - 69 
*    ( 1 )  " ==" -int Var aut -int -6  - Con -int 48 
* Cbranch 0 L13 
* Enter block 0 
* Begin expression - 70 
*    ( 1 )  " |=" -int Var aut -int -14  - Con -int 1 
* Begin expression - 71 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
* End block 0 0 2 
L13 
L14 
* Begin expression - 73 
*    ( 1 )  " <=" -int Con -int 48  - Var aut -int -6 
*    ( 2 )  "ANB" -xxx Node 1 
*    ( 3 )  " <=" -int Var aut -int -6  - Con -int 57 
*    ( 4 )  "ANE" -xxx 
* Cbranch 0 L15 
* Enter block 0 
* Begin expression - 74 
*    ( 1 )  " * " -int Var aut -int -12  - Con -int 10 
*    ( 2 )  " + " -int Node 1  - Var aut -int -6 
*    ( 3 )  " - " -int Node 2  - Con -int 48 
*    ( 4 )  " = " -int Var aut -int -12  - Node 3 
* Begin expression - 75 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
* End block 0 0 2 
 lbra L14 
L15 
* Begin expression - 77 
*    ( 1 )  " ==" -int Var aut -int -6  - Con -int 46 
* Cbranch 0 L16 
* Enter block 0 
* Begin expression - 78 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
L17 
* Begin expression - 79 
*    ( 1 )  " <=" -int Con -int 48  - Var aut -int -6 
*    ( 2 )  "ANB" -xxx Node 1 
*    ( 3 )  " <=" -int Var aut -int -6  - Con -int 57 
*    ( 4 )  "ANE" -xxx 
* Cbranch 0 L18 
* Begin expression - 80 
*    ( 1 )  "O++" p-chr Var aut p-chr -10 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
 lbra L17 
L18 
* End block 0 0 2 
L16 
* Begin expression - 82 
*    ( 1 )  " ==" -int Var aut -int -6  - Con -int 0 
* Cbranch 0 L19 
 lbra L6 
L19 
* Begin expression - 84 
*    ( 1 )  "LOD" -int Var aut -int -6 
 lbra L21 
* Enter block 0 
L22 
* Begin expression - 86 
*    ( 1 )  " |=" -int Var aut -int -14  - Con -int 2 
L23 
L24 
* Begin expression - 89 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 10 
 lbra L25 
L26 
* Begin expression - 92 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 8 
 lbra L25 
L27 
* Begin expression - 95 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 2 
 lbra L25 
L28 
L29 
* Begin expression - 99 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 16 
L25 
* Begin expression - 100 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "O++" p-int Var reg p-int 1 
*    ( 4 )  " *O" -int Node 3 
*    ( 5 )  "PSH" -int Node 4 
*    ( 6 )  "SPR" -xxx 
*    ( 7 )  "PSH" -int Var aut -int -6 
*    ( 8 )  "SPR" -xxx 
*    ( 9 )  "PSH" -int Var aut -int -12 
*    ( 10 )  "SPR" -xxx 
*    ( 11 )  "PSH" -int Var aut -int -14 
*    ( 12 )  "CAL" -int Var ext f-int __num
 lbra L7 
L30 
* Begin expression - 103 
*    ( 1 )  "O++" p-int Var reg p-int 1 
*    ( 2 )  " *O" -int Node 1 
*    ( 3 )  " & " -int Node 2  - Con -int 127 
*    ( 4 )  " = " -int Var aut -int -6  - Node 3 
* Begin expression - 104 
*    ( 1 )  " & " -int Var aut -int -14  - Con -int 1 
* Cbranch 0 L31 
* Begin expression - 105 
*    ( 1 )  " < " -int Var aut -int -6  - Con -int 32 
*    ( 2 )  "ORB" -xxx Node 1 
*    ( 3 )  " ==" -int Var aut -int -6  - Con -int 127 
*    ( 4 )  "ORE" -xxx 
* Cbranch 0 L32 
* Enter block 0 
* Begin expression - 106 
*    ( 1 )  "LOD" -int Var aut -int -6 
 lbra L34 
* Enter block 0 
L35 
* Begin expression - 108 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 109 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 110 
 lbra L33 
L36 
* Begin expression - 112 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 113 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 114 
 lbra L33 
L37 
* Begin expression - 116 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 117 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 98 
 lbra L33 
L38 
* Begin expression - 120 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 121 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 102 
 lbra L33 
L39 
* Begin expression - 124 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 125 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 116 
 lbra L33 
L40 
* Begin expression - 128 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 92 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 129 
*    ( 1 )  " = " -int Var aut -int -6  - Con -int 101 
 lbra L33 
L41 
* Begin expression - 132 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 94 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 133 
*    ( 1 )  " ^=" -int Var aut -int -6  - Con -int 64 
* End block 0 0 4 
 lbra L33 
L34 
 data
* Switch 106  41 
  35 ,10 
  36 ,13 
  37 ,8 
  38 ,12 
  39 ,9 
  40 ,27 
 text
L33 
* Begin expression - 135 
*    ( 1 )  "--O" -int Var aut -int -12 
* End block 0 0 3 
L32 
L31 
* Begin expression - 137 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Var aut -int -6 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 138 
*    ( 1 )  "--O" -int Var aut -int -12 
L42 
* Begin expression - 139 
*    ( 1 )  "--O" -int Var aut -int -12 
*    ( 2 )  " >=" -int Node 1  - Con -int 0 
* Cbranch 0 L43 
* Begin expression - 140 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 32 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
 lbra L42 
L43 
 lbra L7 
L44 
* Begin expression - 143 
*    ( 1 )  "O++" p-int Var reg p-int 1 
*    ( 2 )  " *O" -int Node 1 
*    ( 3 )  "CVC" -xxx Node 2 
*    ( 4 )  "CVP" p-chr Node 3 
*    ( 5 )  " = " p-chr Var aut p-chr -8  - Node 4 
L45 
* Begin expression - 144 
*    ( 1 )  " *O" -chr Var aut p-chr -8 
* Cbranch 0 L46 
* Enter block 0 
* Begin expression - 145 
*    ( 1 )  "O++" p-chr Var aut p-chr -8 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVI" -int Node 2 
*    ( 4 )  " & " -int Node 3  - Con -int 127 
*    ( 5 )  " = " -int Var aut -int -6  - Node 4 
* Begin expression - 146 
*    ( 1 )  " & " -int Var aut -int -14  - Con -int 1 
* Cbranch 0 L47 
* Begin expression - 147 
*    ( 1 )  " < " -int Var aut -int -6  - Con -int 32 
*    ( 2 )  "ORB" -xxx Node 1 
*    ( 3 )  " ==" -int Var aut -int -6  - Con -int 127 
*    ( 4 )  "ORE" -xxx 
* Cbranch 0 L48 
* Enter block 0 
* Begin expression - 148 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 94 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 149 
*    ( 1 )  "LOD" -int Var aut -int -12 
*    ( 2 )  "ANB" -xxx Node 1 
*    ( 3 )  "--O" -int Var aut -int -12 
*    ( 4 )  " <=" -int Node 3  - Con -int 0 
*    ( 5 )  "ANE" -xxx 
* Cbranch 0 L49 
 lbra L46 
L49 
* Begin expression - 151 
*    ( 1 )  " ^=" -int Var aut -int -6  - Con -int 64 
* End block 0 0 4 
L48 
L47 
* Begin expression - 153 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Var aut -int -6 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* Begin expression - 154 
*    ( 1 )  "LOD" -int Var aut -int -12 
*    ( 2 )  "ANB" -xxx Node 1 
*    ( 3 )  "--O" -int Var aut -int -12 
*    ( 4 )  " <=" -int Node 3  - Con -int 0 
*    ( 5 )  "ANE" -xxx 
* Cbranch 0 L50 
 lbra L46 
L50 
* End block 0 0 3 
 lbra L45 
L46 
L51 
* Begin expression - 157 
*    ( 1 )  "--O" -int Var aut -int -12 
*    ( 2 )  " >=" -int Node 1  - Con -int 0 
* Cbranch 0 L52 
* Begin expression - 158 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Con -int 32 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
 lbra L51 
L52 
 lbra L7 
* End block 0 0 2 
 lbra L20 
L21 
 data
* Switch 84  0 
  22 ,100 
  23 ,108 
  24 ,117 
  26 ,111 
  27 ,98 
  28 ,104 
  29 ,120 
  30 ,99 
  44 ,115 
 text
L20 
* Begin expression - 161 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -int Var aut -int -6 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
* End block 0 0 1 
L7 
 lbra L5 
L6 
* Begin expression - 163 
*    ( 1 )  " >=" -int Var aut -int -16  - Con -int 0 
* Cbranch 0 L53 
* Enter block 0 
* Begin expression - 164 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "CAL" -int Var ext f-int _flush
* Begin expression - 165 
*    ( 1 )  " = " -int Var ext -int _fout - Var aut -int -16 
* End block 0 0 1 
L53 
* End block 2 14 0 
L1 
 leas -4,y
 puls x,y,u,pc
__num pshs u,y,x
 leay 4,s
* Auto 4 an
* Auto 6 ab
* Auto 8 ap
* Auto 10 af
* Enter block 55 
* Auto -6 n
* Auto -8 b
* Register 1 p
* Auto -10 neg
* Auto -27 buf
* Begin expression - 175 
*    ( 1 )  " * " -con Con -int 1  - Con -int 17 
*    ( 2 )  " + " a-chr Var aut a-chr -27  - Node 1 
*    ( 3 )  " *O" -chr Node 2 
*    ( 4 )  " &O" p-chr Node 3 
*    ( 5 )  " = " p-chr Var reg p-chr 1  - Node 4 
* Begin expression - 176 
*    ( 1 )  "CVU" -uns Var aut -int 4 
*    ( 2 )  " = " -uns Var aut -uns -6  - Node 1 
* Begin expression - 177 
*    ( 1 )  "CVU" -uns Var aut -int 6 
*    ( 2 )  " = " -uns Var aut -uns -8  - Node 1 
* Begin expression - 178 
*    ( 1 )  " = " -int Var aut -int -10  - Con -int 0 
* Begin expression - 179 
*    ( 1 )  " & " -int Var aut -int 10  - Con -int 2 
*    ( 2 )  "ANB" -xxx Node 1 
*    ( 3 )  " < " -int Var aut -int 4  - Con -int 0 
*    ( 4 )  "ANE" -xxx 
* Cbranch 0 L56 
* Enter block 0 
* Begin expression - 180 
*    ( 1 )  "O++" -int Var aut -int -10 
* Begin expression - 181 
*    ( 1 )  " -O" -uns Var aut -uns -6 
*    ( 2 )  " = " -uns Var aut -uns -6  - Node 1 
* Begin expression - 182 
*    ( 1 )  "--O" -int Var aut -int 8 
* End block 0 0 1 
L56 
* Begin expression - 184 
*    ( 1 )  "--O" p-chr Var reg p-chr 1 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVC" -chr Con -int 0 
*    ( 4 )  " = " -chr Node 2  - Node 3 
L57 
* Enter block 0 
* Begin expression - 186 
*    ( 1 )  "--O" p-chr Var reg p-chr 1 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  " % " -uns Var aut -uns -6  - Var aut -uns -8 
*    ( 4 )  " * " -uns Con -int 1  - Node 3 
*    ( 5 )  " + " a-chr Var stc a-chr 60  - Node 4 
*    ( 6 )  " *O" -chr Node 5 
*    ( 7 )  " = " -chr Node 2  - Node 6 
 data
* String 60  "0123456789ABCDEF"
 text
* Begin expression - 187 
*    ( 1 )  "--O" -int Var aut -int 8 
* End block 0 0 1 
L58 
* Begin expression - 188 
*    ( 1 )  " /=" -uns Var aut -uns -6  - Var aut -uns -8 
* Cbranch 1 L57 
L59 
* Begin expression - 189 
*    ( 1 )  "CVU" -uns Con -int 32 
*    ( 2 )  " = " -uns Var aut -uns -6  - Node 1 
* Begin expression - 190 
*    ( 1 )  " & " -int Var aut -int 10  - Con -int 5 
*    ( 2 )  " ==" -int Node 1  - Con -int 1 
* Cbranch 0 L61 
* Begin expression - 191 
*    ( 1 )  "CVU" -uns Con -int 48 
*    ( 2 )  " = " -uns Var aut -uns -6  - Node 1 
 lbra L62 
L61 
* Begin expression - 192 
*    ( 1 )  "LOD" -int Var aut -int -10 
* Cbranch 0 L63 
* Enter block 0 
* Begin expression - 193 
*    ( 1 )  "--O" p-chr Var reg p-chr 1 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVC" -chr Con -int 45 
*    ( 4 )  " = " -chr Node 2  - Node 3 
* Begin expression - 194 
*    ( 1 )  " = " -int Var aut -int -10  - Con -int 0 
* End block 0 0 1 
L63 
L62 
* Begin expression - 196 
*    ( 1 )  " & " -int Var aut -int 10  - Con -int 4 
*    ( 2 )  " ==" -int Node 1  - Con -int 0 
* Cbranch 0 L64 
L65 
* Begin expression - 197 
*    ( 1 )  "--O" -int Var aut -int 8 
*    ( 2 )  " >=" -int Node 1  - Con -int 0 
* Cbranch 0 L66 
* Begin expression - 198 
*    ( 1 )  "--O" p-chr Var reg p-chr 1 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVC" -chr Var aut -uns -6 
*    ( 4 )  " = " -chr Node 2  - Node 3 
 lbra L65 
L66 
L64 
* Begin expression - 199 
*    ( 1 )  "LOD" -int Var aut -int -10 
* Cbranch 0 L67 
* Begin expression - 200 
*    ( 1 )  "--O" p-chr Var reg p-chr 1 
*    ( 2 )  " *O" -chr Node 1 
*    ( 3 )  "CVC" -chr Con -int 45 
*    ( 4 )  " = " -chr Node 2  - Node 3 
L67 
L68 
* Begin expression - 201 
*    ( 1 )  " *O" -chr Var reg p-chr 1 
* Cbranch 0 L69 
* Begin expression - 202 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "O++" p-chr Var reg p-chr 1 
*    ( 4 )  " *O" -chr Node 3 
*    ( 5 )  "PSH" -chr Node 4 
*    ( 6 )  "CAL" -int Var ext f-int _putchar
 lbra L68 
L69 
L70 
* Begin expression - 203 
*    ( 1 )  "--O" -int Var aut -int 8 
*    ( 2 )  " >=" -int Node 1  - Con -int 0 
* Cbranch 0 L71 
* Begin expression - 204 
*    ( 1 )  "SPL" -xxx 
*    ( 2 )  "SPR" -xxx 
*    ( 3 )  "PSH" -uns Var aut -uns -6 
*    ( 4 )  "CAL" -int Var ext f-int _putchar
 lbra L70 
L71 
* End block 55 25 0 
L54 
 leas -4,y
 puls x,y,u,pc
 end
