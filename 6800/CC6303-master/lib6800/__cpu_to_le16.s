
	.export __cpu_to_le16
	.export __le16_to_cpu
	.export __be16_to_cpu
	.export __cpu_to_be16

	.code

__cpu_to_le16:
__le16_to_cpu:
	tsx
	ldx 1,x
	ins
	ins
	pulb
	pula
	jmp ,x
__cpu_to_be16:
__be16_to_cpu:
	jmp ret2
