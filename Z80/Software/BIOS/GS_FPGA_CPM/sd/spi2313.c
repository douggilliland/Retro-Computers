#include <avr/io.h>

#define F_CPU 20000000L
#include <util/delay.h>

void USARTInit(unsigned int ubrr_value) {
	//Set Baud rate
	UBRRH = (unsigned char)(ubrr_value >> 8);  
	UBRRL = (unsigned char)(ubrr_value & 255);
	// Frame Format: asynchronous, no parity, 1 stop bit, char size 8
	UCSRC = (1 << UCSZ1) | (1 << UCSZ0);
	//Enable The receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
}

char USARTReadChar() { // blocking
	while(!(UCSRA & (1<<RXC))) {}
	return UDR;
}

void USARTWriteChar(char data) { // blocking
	while(!(UCSRA & (1<<UDRE))) {}
	UDR=data;
}

void uwrite_hex(unsigned char n) {
	if(((n>>4) & 15) < 10)
		USARTWriteChar('0' + ((n>>4)&15));
	else
		USARTWriteChar('A' + ((n>>4)&15) - 10);
	n <<= 4;
	if(((n>>4) & 15) < 10)
		USARTWriteChar('0' + ((n>>4)&15));
	else
		USARTWriteChar('A' + ((n>>4)&15) - 10);
}

void uwrite_str(char *str) {
	char i;
	
	for(i=0; str[i]; i++)
		USARTWriteChar(str[i]);
}

#define SPI_DDR DDRB
#define MOSI (1<<PB6)
#define MISO (1<<PB5)
#define SCK (1<<PB7)

#define CS_DDR DDRD
#define CS (1<<PD6) // PD6 used as circuit select
#define CS_ENABLE() (PORTD &= ~CS)
#define CS_DISABLE() (PORTD |= CS)

void SPI_init() {
	CS_DDR |= CS; // SD card circuit select as output
	SPI_DDR |= MOSI + SCK; // MOSI and SCK as outputs
}

// Transfer 1 byte both ways as SPI master device
unsigned char SPI_transfer(unsigned char ch) {
	USIDR = ch;
	USISR = (1<<USIOIF);
	
	do {
		// Three-wire mode | Software cl|ock strobe | Strobe
		USICR = (1<<USIWM0) | (1<<USICS1) | (1<<USICLK) | (1<<USITC);
		_delay_us(100); // decrease for higher clock rate
	} while((USISR & (1<<USIOIF)) == 0);
	
	return USIDR;
}

unsigned char SPI_write(unsigned char ch) {
	SPDR = ch;
	while(!(SPSR & (1<<SPIF))) {}	
	return SPDR;
}

void SD_command(unsigned char cmd, unsigned long arg, unsigned char crc, unsigned char read) {
	unsigned char i, buffer[8];
	
	uwrite_str("CMD ");
	uwrite_hex(cmd);
	
	CS_ENABLE();
	SPI_write(cmd);
	SPI_write(arg>>24);
	SPI_write(arg>>16);
	SPI_write(arg>>8);
	SPI_write(arg);
	SPI_write(crc);
		
	for(i=0; i<read; i++)
		buffer[i] = SPI_write(0xFF);
		
	CS_DISABLE();		
		
	for(i=0; i<read; i++) {
		USARTWriteChar(' ');
		uwrite_hex(buffer[i]);
	}
	
	uwrite_str("\r\n");
}

int main(int argc, char *argv[]) {
	char i;
	
	USARTInit(64); // 20 MHz / (16 * 19200 baud) - 1 = 64.104x
	SPI_init();

	// ]r:10
	CS_DISABLE();
	for(i=0; i<10; i++) // idle for 1 bytes / 80 clocks
		SPI_write(0xFF);
	
	while(1) {
		switch(USARTReadChar()) {
		case '1':
			SD_command(0x40, 0x00000000, 0x95, 8);
			break;
		case '2':
			SD_command(0x41, 0x00000000, 0xFF, 8);
			break;
		case '3':
			SD_command(0x50, 0x00000200, 0xFF, 8);
			break;
		}
	}	
	
	return 0;
}
