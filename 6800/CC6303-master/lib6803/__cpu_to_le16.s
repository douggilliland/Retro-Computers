
	.export __cpu_to_le16
	.export __le16_to_cpu
	.export __be16_to_cpu
	.export __cpu_to_be16

	.setcpu 6803
	.code

__cpu_to_le16:
__le16_to_cpu:
	; The argument is top of stack 2,s-3,s
	tsx
	ldaa 3,x
	ldab 2,x
__cpu_to_be16:
__be16_to_cpu:
	rts
