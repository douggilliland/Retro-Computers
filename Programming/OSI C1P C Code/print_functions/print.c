/* Functions to print to the screen 				*/
/* There is no stdio support for the OSI C1P		*/
/* This provides standardish function for printing	*/

int cursorX;	/* global variables */
int cursorY;
unsigned int currentScreenAddress;
#define SCREEN_START_ADDRESS 0xd000
#define SCREEN_END_ADDRESS 0xd3ff

/* clearScreen - Fill the screen with spaces 	*/
void clearScreen(void)
{
	unsigned int screenAddress;
	char * screenPointer;
	for (screenAddress = SCREEN_START_ADDRESS; screenAddress <= SCREEN_END_ADDRESS; screenAddress += 1)
	{
		*screenPointer = ' ';
		screenPointer += 1;
	}
}

/* setCursor - Sets the cursor to the x,y position	*/
void setCursor(unsigned int x, unsigned int y)
{
	cursorX = x;
	cursorY = y;
	currentScreenAddress = SCREEN_START_ADDRESS + cursorX + (cursorY << 5);	/* fill in with the address */
}

/* printStringToScreen - prints the character to the screen	*/
void printCharToScreen(char charToPrint)
{
	char * screenPointer;
	screenPointer = (char *)currentScreenAddress;
	*screenPointer = charToPrint;
	currentScreenAddress += 1;
}

void printByteAsHexToScreen(unsigned char charToPrint)
{
	
}

void printByteToScreen(unsigned char charToPrint)
{
	
}

void printStringToScreen(char * stringToPrint)
{
	
}
