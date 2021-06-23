
	.export __cpu_to_le32
	.export __le32_to_cpu
	.export __be32_to_cpu
	.export __cpu_to_be32

	.code

__cpu_to_le32:
__le32_to_cpu:
	; The argument is top of stack 3,s-6,s
	tsx
	ldaa 2,x
	ldab 3,x
	psha
	pshb
	ldaa 4,x
	ldab 5,x
	stab 2,x
	staa 3,x
	pulb
	pula
	staa 4,x
	stab 5,x
__cpu_to_be32:
__be32_to_cpu:
	jmp ret4
