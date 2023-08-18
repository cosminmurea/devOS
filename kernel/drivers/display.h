
#ifndef DISPLAY_H
#define DISPLAY_H

#define VGA_MEM_ADDR (volatile uint8_t* )0xB8000
#define VGA_COLUMNS 80
#define VGA_ROWS 25
#define VGA_DEFAULT_BLANK 0x20 | ((LIGHT_GREY | BLACK << 4) << 8)

#define VGA_CTRL_REGISTER 0x3D4
#define VGA_DATA_REGISTER 0x3D5
#define VGA_OFFSET_LOW 0x0F
#define VGA_OFFSET_HIGH 0x0E

enum vgaColors {
    BLACK = 0x00,
    BLUE = 0x01,
    GREEN = 0x02,
    CYAN = 0x03,
    RED = 0x04,
    MAGENTA = 0x05,
    BROWN = 0x06,
    LIGHT_GREY = 0x07,
    DARK_GREY = 0x08,
    LIGHT_BLUE = 0x09,
    LIGHT_GREEN = 0x0A,
    LIGHT_CYAN = 0x0B,
	LIGHT_RED = 0x0C,
	LIGHT_MAGENTA = 0x0D,
	LIGHT_BROWN = 0x0E,
	WHITE = 0x0F,
};

void setCursorPosition(uint16_t memoryOffset);                      // this should be PRIVATE

uint16_t getCursorPosition(void);                                   // this should be PRIVATE

uint16_t getOffsetFromCoords(uint8_t col, uint8_t row);             // this should be PRIVATE

uint8_t getRowFromOffset(uint16_t memoryOffset);                    // this should be PRIVATE

uint8_t getColFromOffset(uint16_t memoryOffset);                    // this should be PRIVATE

void clearScreen();                                                 // this should be PUBLIC

uint16_t scroll(uint16_t memoryOffset);                             // this should be PRIVATE ?

void kPrintChar(uint8_t character, uint16_t memoryOffset);          // this should be PUBLIC

void kPrint(const uint8_t *string);                                 // this should be PUBLIC

#endif
