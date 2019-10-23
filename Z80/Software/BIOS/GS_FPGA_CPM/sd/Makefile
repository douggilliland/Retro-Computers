CC = avr-gcc
OBJCOPY = avr-objcopy
DUDE = avrdude

MCU=atmega88

CFLAGS = -Os -mmcu=$(MCU)
OBJFLAGS = -j .text -j .data -O ihex
DUDEFLAGS = -p $(MCU) -c usbtiny -q -B 1

%.flash: %.hex
	$(DUDE) $(DUDEFLAGS) -U flash:w:$*.hex

%.hex: %.elf
	$(OBJCOPY) $(OBJFLAGS) $< $@
	
fat88.elf: fat88.o fat16.o
	$(CC) $(CFLAGS) $^ -o $@

test_spi.elf: test_spi.o fat16.o
	$(CC) $(CFLAGS) $^ -o $@
	
%.elf: %.o
	$(CC) $(CFLAGS) $< -o $@
	
%.o: %.c	
	$(CC) $(CFLAGS) -c $< -o $@
	
%.o: %.S	
	$(CC) $(CFLAGS) -c $< -o $@