
	.export __cpu_to_le32
	.export __le32_to_cpu
	.export __be32_to_cpu
	.export __cpu_to_be32

	.setcpu 6803
	.code

__cpu_to_le32:
__le32_to_cpu:
	; The argument is top of stack 2,s-5,s
	tsx
	ldx 2,x
	pshx
	ldd 4,x
	stab 2,x
	staa 3,x
	pulb
	pula
	std 4,x
__cpu_to_be32:
__be32_to_cpu:
	rts
