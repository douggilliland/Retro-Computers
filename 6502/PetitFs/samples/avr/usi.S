;---------------------------------------------------------------------------;
; USI control functions
;---------------------------------------------------------------------------;

.nolist
#include <avr/io.h>	// Include device specific definitions.
.list


;---------------------------------------------------------------------------;
; Initialize USI
;
; void init_spi (void);

.global init_spi
.func init_spi
init_spi:
	ldi	r24, 0b00011000
	out	_SFR_IO_ADDR(USICR), r24
	ret
.endfunc


;---------------------------------------------------------------------------;
; Delay 100 microseconds
;
; void dly_100us (void);

.global dly_100us
.func dly_100us
dly_100us:
	ldi	r24, lo8(F_CPU / 100000)	/* Loop counter */
	ldi	r25, hi8(F_CPU / 100000)
1:	sbiw	r30, 1		/* 10 clocks a loop */
	sbiw	r30, 1
	sbiw	r30, 1
	sbiw	r24, 1
	brne	1b
	ret
.endfunc


;---------------------------------------------------------------------------;
; Receive a byte (28 clks)
;
; BYTE rcv_spi (void);

.global rcv_spi
.func rcv_spi
rcv_spi:
	ldi	r24, 0xFF	; Send 0xFF to receive data
	; Goto next function
.endfunc


;---------------------------------------------------------------------------;
; Transmit a byte (27 clks)
;
; void xmit_spi (BYTE);

.global xmit_spi
.func xmit_spi
xmit_spi:
	out	_SFR_IO_ADDR(USIDR), r24	; Put a byte to be transmit

	ldi	r24, 0b000100			; PB2(SCK)
	.rept 16
	out	_SFR_IO_ADDR(PINB), r24		; Toggle SCK 16 times
	.endr
	nop
	in	r24, _SFR_IO_ADDR(USIDR)	; Get received byte
	ret
.endfunc


