;
;	Runtime support
;

	.zp
	.export zero
	.export one
	.export tmp
	.export tmp1
	.export tmp2
	.export tmp3
	.export tmp4
	.export sreg
	.export fp
	.export reg
	.export jmptmp

;
;	This occupies 23 bytes. On the 6303Y we have only 0x28 to 0x3F of
;	banked external memory in the direct page (ie 24 bytes).
;
zero:
	.byte 0		; Patterns that form a word 0
one:
	.byte 0		; And a word 1
	.byte 0		; patched to 1 by runtime
;
;	These we need to switch on interrupt
;
sreg:			; Upper 16bits of working long
	.word 0
	; Our runtime will scribble into the first byte of tmp in a couple
	; of cases for speed. It knows a tmp variable lives next to it so
	; don't fix anything
jmptmp:
	.byte 0x7E	; jmp extended
tmp:
	.word 0		; Temporaries used by compiler must be in order
tmp1:			; as sometimes used as a group
	.word 0
tmp2:
	.word 0
tmp3:
	.word 0
tmp4:
	.word 0
fp:
	.word 0		; frame pointer for varargs
reg:
	.word 0		; For now allow for 3 words of registers
	.word 0
	.word 0
