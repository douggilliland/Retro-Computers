#include <avr/io.h>

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

int main() {
	USARTInit(64); // 20 MHz / (16 * 19200 baud) - 1 = 64.104x

	while(1)
		USARTWriteChar(USARTReadChar()); // echo
	
	return 1;
}
