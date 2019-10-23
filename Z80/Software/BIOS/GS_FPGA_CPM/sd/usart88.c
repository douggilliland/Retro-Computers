#include <avr/io.h>

void USARTInit(unsigned int ubrr_value) {
	//Set Baud rate
	UBRR0H = (unsigned char)(ubrr_value >> 8);  
	UBRR0L = (unsigned char)(ubrr_value & 255);
	// Frame Format: asynchronous, no parity, 1 stop bit, char size 8
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
	//Enable The receiver and transmitter
	UCSR0B = (1 << RXEN0) | (1 << TXEN0);
}

char USARTReadChar() { // blocking
	while(!(UCSR0A & (1<<RXC0))) {}
	return UDR0;
}

void USARTWriteChar(char data) { // blocking
	while(!(UCSR0A & (1<<UDRE0))) {}
	UDR0=data;
}

int main() {
	USARTInit(64); // 20 MHz / (16 * 19200 baud) - 1 = 64.104x

	while(1)
		USARTWriteChar(USARTReadChar()); // echo
	
	return 1;
}
