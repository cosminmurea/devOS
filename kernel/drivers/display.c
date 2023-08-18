
#include <stdint.h>
#include "../utils/memory.h"
#include "ports.h"
#include "display.h"

/********************************************************************************************************************************************
*setCursorPosition:
*   - Parameters: uint16_t memoryOffset => offset into VGA memory at which to place the cursor;
*   - Set the cursor position using VGA ports 0x3D4 (CRTC Address Register) & 0x3D5 (CRTC Data Register);
*   - Use 0x3D4 to choose an index then send a byte to 0x3D5;
*   - The cursor position is an index from 0 to the end of VGA memory but it can be translated to a (column, row) position;
*   - To set the lower 8 bits we use 0x0F and 0x0E to set the higher 8 bits;
********************************************************************************************************************************************/

void setCursorPosition(uint16_t memoryOffset) {

    uint16_t cursorOffset = memoryOffset / 2;

    uint8_t lowerByte = (uint8_t)(cursorOffset & 0xFF);                     // extract the lower 8 bits and cast them to uint8_t
    uint8_t higherByte = (uint8_t)((cursorOffset >> 8) & 0xFF);             // extract the higher 8 bits and cast them to uint8_t

    outbyte(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);                             // index 0x0F = cursor location low register (lower 8 bits)
    outbyte(VGA_DATA_REGISTER, lowerByte);
    outbyte(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);                            // index 0x0F = cursor location high register (higher 8 bits)
    outbyte(VGA_DATA_REGISTER, higherByte);

}

/********************************************************************************************************************************************
*getCursorPosition:
*   - Return: uint16_t memoryOffset => offset into VGA memory at which the cursor is located;
*   - Get the cursor position using VGA ports 0x3D4 (CRTC Address Register) & 0x3D5 (CRTC Data Register);
*   - To get the lower 8 bits we use 0x0F and 0x0E to get the higher 8 bits;
********************************************************************************************************************************************/

uint16_t getCursorPosition(void) {

    uint16_t cursorOffset = 0;
    uint16_t memoryOffset = 0;

    outbyte(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
    cursorOffset |= inbyte(VGA_DATA_REGISTER);
    outbyte(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);
    cursorOffset |= inbyte(VGA_DATA_REGISTER) << 8;

    memoryOffset = cursorOffset * 2;

    return memoryOffset;

}

/********************************************************************************************************************************************
*getOffsetFromCoords:
*   - Parameters: uint8_t col (0 <= col <= 79) and uint8_t row (0 <= row <= 24);
*   - Return: uint16_t memoryOffset => offset into VGA memory;
*   - Computes an offset into VGA memory from coordinates (column, row); 
********************************************************************************************************************************************/

uint16_t getOffsetFromCoords(uint8_t col, uint8_t row) {

    uint16_t memoryOffset = 2 * (row * VGA_COLUMNS + col);
    return memoryOffset;

}

/********************************************************************************************************************************************
*getRowFromOffset:
*   - Parameters: uint16_t memoryOffset => offset into VGA memory;
*   - Return: uint8_t row (0 <= row <= 24);
*   - Computes the row coordinate from an offset into VGA memory;
********************************************************************************************************************************************/

uint8_t getRowFromOffset(uint16_t memoryOffset) {

    uint8_t row = memoryOffset / (2 * VGA_COLUMNS);
    return row;

}

/********************************************************************************************************************************************
*getColFromOffset:
*   - Parameters: uint16_t memoryOffset => offset into VGA memory;
*   - Return: uint8_t col (0 <= col <= 79);
*   - Computes the column coordinate from an offset into VGA memory;
********************************************************************************************************************************************/

uint8_t getColFromOffset(uint16_t memoryOffset) {

    uint8_t col = (memoryOffset - (getRowFromOffset(memoryOffset) * 2 * VGA_COLUMNS)) / 2;
    return col;

}

/********************************************************************************************************************************************
*clearScreen:
*   - Set the entire video memory to VGA_DEFAULT_BLANK (space character on black background with light-grey foreground);
*   - Set the cursor position to (0, 0);
********************************************************************************************************************************************/

void clearScreen() {

    memsetWord((uint16_t*)VGA_MEM_ADDR, VGA_DEFAULT_BLANK, VGA_COLUMNS * VGA_ROWS);

    setCursorPosition(getOffsetFromCoords(0, 0));

}

/********************************************************************************************************************************************
*scroll:
*   - Parameters: uint16_t memoryOffset => initial location of the cursor;
*   - Return: uint16_t memoryOffset => cursor location after scrolling (the cursor is located at the start of the last row);
*   - Copy from (0, 1) to (0, 0) => shifts every row upwards by one (contents of the first row are lost);
*   - Set the entire last row to VGA_DEFAULT_BLANK;
********************************************************************************************************************************************/

uint16_t scroll(uint16_t memoryOffset) {

    uint8_t* copySource = (uint8_t*)(getOffsetFromCoords(0, 1) + VGA_MEM_ADDR);
    uint16_t* setDestination = (uint16_t*)(getOffsetFromCoords(0, VGA_ROWS - 1) + VGA_MEM_ADDR);

    memcpy((uint8_t*)VGA_MEM_ADDR, copySource, VGA_COLUMNS * (VGA_ROWS - 1) * 2);

    memsetWord(setDestination, VGA_DEFAULT_BLANK, VGA_COLUMNS);

    return memoryOffset - (2 * VGA_COLUMNS);

}

/********************************************************************************************************************************************
*kPrintChar:
*   - Parameters:
*       - uint16_t memoryOffset => offset into VGA memory at which to print the character;
*       - uint8_t character => the character to print;
*   - Sets videoMemory to VGA_MEM_ADDR (0xB8000);
*   - Sets the attribute byte to black background with light-grey foreground;
*   - Puts the character in VGA memory at offset memoryOffset and the attribute byte at memoryOffset + 1;
********************************************************************************************************************************************/

void kPrintChar(uint8_t character, uint16_t memoryOffset) {

    volatile uint8_t* videoMemory = VGA_MEM_ADDR;
    uint8_t attributeByte = (LIGHT_GREY | BLACK << 4);

    videoMemory[memoryOffset] = character;
    videoMemory[memoryOffset + 1] = attributeByte;

}

/********************************************************************************************************************************************
*kPrint:
*   - Parameters: const uint8_t* string => pointer to the null-terminated string to be printed;
*   - Scrolls if the memoryOffset is out of bounds;
*   - Checks for special characters: newline (\n), backspace (\b), tab (\t) and carriage return (\r);
*   - Prints the string at the current location of the cursor using kPrintChar();
*   - Sets the new cursor position after printing the string;
********************************************************************************************************************************************/

void kPrint(const uint8_t* string) {

    uint16_t memoryOffset = getCursorPosition();
    uint16_t charIndex = 0;

    while (string[charIndex] != 0) {
        if (memoryOffset >= VGA_COLUMNS * VGA_ROWS * 2) {
            memoryOffset = scroll(memoryOffset);
        }

        switch (string[charIndex]) {
            case '\n':
                // newline => move cursor to the start of next row;
                memoryOffset = getOffsetFromCoords(0, getRowFromOffset(memoryOffset) + 1); 
                break;

            case '\b':
                if (getColFromOffset(memoryOffset) != 0) {
                    // backspace => move cursor back one space;
                    memoryOffset = getOffsetFromCoords(getColFromOffset(memoryOffset) - 1, getRowFromOffset(memoryOffset));
                }
                break;

            case '\t':
                // tab => move cursor forwards until the cursor column is a multiple of 8;
                memoryOffset = getOffsetFromCoords((getColFromOffset(memoryOffset) + 8) & ~(8 - 1), getRowFromOffset(memoryOffset));
                break;

            case '\r':
                // carriage return => move cursor to the start of the current row;
                memoryOffset = getOffsetFromCoords(0, getRowFromOffset(memoryOffset));
                break;

            default:
                kPrintChar(string[charIndex], memoryOffset);
                memoryOffset += 2;
                break;
        }

        charIndex++;
    }

    setCursorPosition(memoryOffset);

}
