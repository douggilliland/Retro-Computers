; ======================================================
; ZX81 ROM Loader
; 2018 Peter Hanratty
; -------------------------------------------------------
; Reads the 8K ZX81 ROM 
; from a 25AA1024 Serial EEPROM
; 
; Verifies the contents using 256 32-byte XOR checksums 
; stored in the data EEPROM of this device
; 
; Writes the contents to the AS6C1008 SRAM using the Z80 
; as an address counter by returning a NOP on the data 
; bus after each write
;
; Verifies the contents written to RAM using the same
; process as above
;
; Signals the following error conditions by repeatedly 
; flashing the power / status LED a number of times:
;
;    1: Could not communicate with serial EEPROM device
;    2: ROM verification failed (EEPROM contents corrupt)
;    3: Failure to detect Z80 M1 state
;    4: RAM verification failed (did not write to SRAM)
;    5: Same as 3 (check the reset circuit in this case)
; =======================================================

include f:\picprog\lib\pic16f88_reg.inc

; -------------------------------------------------------

; Variables (locations 70h+ common to all banks)

equ	spi_cmd		70h
equ	spi_addr2	71h
equ	spi_addr1	72h
equ	spi_addr0	73h
equ	spi_counter	74h
equ	spi_data	75h

equ	rom_chksum	76h
equ	rom_chkcount	77h
equ	rom_blkcount	78h

equ	error_code	79h
equ	error_count	7ah

equ	wait1		7bh
equ	wait2		7ch

equ	z80_counter	7dh

; =======================================================

; Reset and interrupt vectors

org	000h
goto	start
org	005h

; =======================================================

start:

; Set oscillator (INTOSC, 4 MHz)
movlw	20h
movwf	status		; Bank 1
movlw	60h
movwf	osccon
osc_wait:		; Wait for clock to stablise
btfss	osccon, 2
goto	osc_wait

; Init PORTA (output, RA5+RA3=digital input)
movlw	28h
movwf	trisa
clrf	ansel

; Init PORTB (input - default state when not writing to the bus)
movlw	ffh
movwf	trisb	

; Set initial port states
clrf	status		; Bank 0
movlw	c4h
movwf	porta

; Point to start of data EEPROM
movlw	60h
movwf	status		; Bank 3
bcf	eecon1, 7
bcf	status, 5	; Bank 2
clrf	eeadr
clrf	status		; Bank 0

; Initialise variables
clrf	spi_addr2
clrf	spi_addr1
clrf	spi_addr0
clrf	error_code

; -------------------------------------------------------

; Check ROM device

incf	error_code, f
movlw	abh		; RDID command
movwf	spi_cmd
bcf	porta, 2	; Pull CS low
call	spi_send
call	spi_recv
bsf	porta, 2	; Pull CS high
movlw	29h		; Manufacturers ID
xorwf	spi_data, w	
btfss	status, 2	; Z flag (equality)
goto	error_halt	

; -------------------------------------------------------

; Read ROM

incf	error_code, f
call	z80_reset
movlw	03h		; READ command
movwf	spi_cmd
bcf	porta, 2	; Pull CS low
call	spi_send

clrf	rom_blkcount	; 0 representing 256

rom_read_block:
movlw	20h		; 32 byte checksums
movwf	rom_chkcount
clrf	rom_chksum

rom_read_bytes:
call	spi_recv
movf	spi_data, w
xorwf	rom_chksum, f

call	z80_next_inst	; Wait for next Z80 instruction
bcf	porta, 6	; RAM write enable
bsf	status, 5	; Bank 1
clrf	trisb		; Set PORTB to output
clrf	status		; Bank 0
movf	spi_data, w
movwf	portb		; write data byte
bsf	porta, 6	; RAM write disable (and commit)
clrf	portb		; feed NOP to Z80
bcf	porta, 4	; Handle remaining T states for data in
bsf	porta, 4	
bcf	porta, 4	
bsf	porta, 4	
bsf	status, 5	; Bank 1
decf	trisb, f	; Set PORTB back to input/hi-Z (FFh)
clrf	status		; Bank 0
bcf	porta, 4	

decfsz	rom_chkcount, f
goto	rom_read_bytes

call	verify_checksum
decfsz	rom_blkcount, f
goto	rom_read_block

bsf	porta, 2	; Pull CS high

; -------------------------------------------------------

; Shut down Serial EEPROM device

movlw	b9h		; DPD command
movwf	spi_cmd
bcf	porta, 2	; Pull CS low
call	spi_send
bsf	porta, 2	; Pull CS high

; -------------------------------------------------------

; Verify RAM

incf	error_code, f
incf	error_code, f	; (Last section used 2 error codes)
call	z80_reset

bsf	status, 6	; Bank 2
clrf	eeadr		
clrf	status		; Bank 0
clrf	rom_blkcount	; 0 representing 256

ram_read_block:
movlw	20h		; 32 byte checksums
movwf	rom_chkcount
clrf	rom_chksum

ram_read_bytes:
call	z80_next_inst	; Wait for next Z80 instruction
bcf	porta, 4	; Go to second half of T2
bsf	porta, 4	
bcf	porta, 4	
movf	portb, w	; Read RAM byte
xorwf	rom_chksum, f	
bsf	status, 5	; Bank 1
clrf	trisb		; Set PORTB to output
clrf	status		; Bank 0
clrf	portb		; feed NOP to Z80
bsf	porta, 4	; on the rising edge of T3
bsf	status, 5	; Bank 1
decf	trisb, f	; Set PORTB back to input/hi-Z (FFh)
clrf	status		; Bank 0
bcf	porta, 4	; End of T3

decfsz	rom_chkcount, f
goto	ram_read_bytes

call	verify_checksum	
decfsz	rom_blkcount, f
goto	ram_read_block 

; -------------------------------------------------------

; Shut down the PIC and start the ZX81

bcf	porta, 7	; Reset Z80
bsf	status, 5	; Bank 1
movlw	ffh
movwf	trisa		; Set PORTA to input/hi-Z
sleep			; Shut down PIC

stop_loop:		; Just in case program continues
nop
goto	stop_loop

; =======================================================

z80_reset:

bcf	porta, 7	; Reset Z80
movlw	10h
movwf	z80_counter	; Wait a few clock cycles
z80_reset_loop:
bsf	porta, 4
bcf	porta, 4
decfsz	z80_counter, f
goto	z80_reset_loop
bsf	porta, 7
bcf	porta, 7	; Cycle flipflop back to manual clock
bsf	porta, 7
call	wait		; Allow time for Z80 reset RC
call	wait

return

; =======================================================

z80_next_inst:		; Wait for Z80 M1 low

clrf	z80_counter	; Wait a max of 256T

z80_wait_m1:
bsf	porta, 4	; Z80 clock high
btfss	porta, 5	; Look for M1 low
return

bcf	porta, 4	; Z80 clock low
decfsz	z80_counter, f
goto	z80_wait_m1

incf	error_code, f
goto	error_halt

; =======================================================

verify_checksum:
; Compare 32 byte checksum with stored version

movlw	60h
movwf	status		; Bank 3
bsf	eecon1, 0
bcf	status, 5	; Bank 2
movf	eedata, w
incf	eeadr, f
clrf	status		; Bank 0
xorwf	rom_chksum, w
btfss	status, 2	; Z flag (equality)
goto	error_halt

return

; =======================================================

spi_send:		; Send a 4 byte SPI command

movlw	20h
movwf	status		; Bank 1
movlw	spi_cmd
movwf	fsr
clrf	status		; Bank 0

call	spi_send_byte	
call	spi_send_byte
call	spi_send_byte

spi_send_byte:		
movlw	8
movwf	spi_counter

spi_send_loop:
bcf	porta, 0	; Load data bit
btfsc	indf, 7
bsf	porta, 0
bsf	porta, 1	; Clock goes high
bcf	porta, 1	; Clock goes low
rlf	indf, f
decfsz	spi_counter, f
goto	spi_send_loop
bsf	status, 5	; Bank 1
incf	fsr, f
clrf	status		; Bank 0

return

; =======================================================

spi_recv:		; Receive 1 byte of SPI data

movlw	8
movwf	spi_counter

spi_recv_loop:
rlf	spi_data, f
bcf	spi_data, 0
bsf	porta, 1	; Clock goes high
btfsc	porta, 3
bsf	spi_data, 0
bcf	porta, 1	; Clock goes low
decfsz	spi_counter, f
goto	spi_recv_loop

return

; =======================================================

error_halt:		; Flash LED according to error code

clrf	status		; Ensure bank 0 selected
movlw	c4h		
movwf	porta		; Return control pins to initial state

error_flash:		
movf	error_code, w
movwf	error_count

error_flashing:
bcf	porta, 7
call	wait
bsf	porta, 7	; Toggle clock select back to manual
bcf	porta, 7
bsf	porta, 7
call	wait
decfsz	error_count, f
goto	error_flashing
bcf	porta, 7
call	wait
call	wait
goto	error_flash

; -------------------------------------------------------

wait:

clrf	wait1
clrf	wait2

wait_loop:

decfsz	wait1, f
goto	wait_loop

decfsz	wait2, f
goto	wait_loop

return

; =======================================================
