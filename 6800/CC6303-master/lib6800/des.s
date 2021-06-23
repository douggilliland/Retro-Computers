;
;	6800 stack manipulation can get ugly
;
		.export des12
		.export des11
		.export des10
		.export des9
		.export des8
		.export des7
		.export des6
		.export des5

		.code
des12:
		tsx
		ldx ,x
		stx @tmp
		des
do11:
		des
do10:
		des
do9:
		des
do8:
		des
do7:
		des
do6:
		des
do5:
		des
		des
		des
		des
		des
		jmp jmptmp

des11:
		tsx
		ldx ,x
		stx @tmp
		bra do11
des10:
		tsx
		ldx ,x
		stx @tmp
		bra do10
des9:
		tsx
		ldx ,x
		stx @tmp
		bra do9
des8:
		tsx
		ldx ,x
		stx @tmp
		bra do8
des7:
		tsx
		ldx ,x
		stx @tmp
		bra do7
des6:
		tsx
		ldx ,x
		stx @tmp
		bra do6
des5:
		tsx
		ldx ,x
		stx @tmp
		bra do5
