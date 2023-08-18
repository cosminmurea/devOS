
#include <stdint.h>
#include "memory.h"

/********************************************************************************************************************************************
*memcpy:
*   - Parameters:
*       - uint8_t* destination => pointer to the address at which to copy memory;
*       - uint8_t* source => pointer to the address from which to copy memory;
*		- uint16_t size => number of bytes to copy (max 65536 for uint16_t);
*	- Return: uint8_t* destination => pointer to the (start of the) copied contents;
*   - Copies from address in source to the address in destination a number of bytes (size);
********************************************************************************************************************************************/

uint8_t* memcpy(uint8_t* destination, const uint8_t* source, uint16_t size) {

	uint16_t byteIndex;

	for (byteIndex = 0; byteIndex < size; byteIndex++) {
		destination[byteIndex] = source[byteIndex];
	}

	return destination;

}

/********************************************************************************************************************************************
*memset:
*   - Parameters:
*       - uint8_t* destination => pointer to the address at which to set memory;
*       - uint8_t value => the value to set in memory (byte);
*		- uint16_t size => number of bytes to set (max 65536 for uint16_t);
*	- Return: uint8_t* destination => pointer to the (start of the) set contents;
*   - Sets from address in destination a number of bytes (size) to a byte value (value);
********************************************************************************************************************************************/

uint8_t* memset(uint8_t* destination, uint8_t value, uint16_t size) {

	uint16_t byteIndex;

	for (byteIndex = 0; byteIndex < size; byteIndex++) {
		destination[byteIndex] = value;
	}

	return destination;

}

/********************************************************************************************************************************************
*memsetWord:
*   - Parameters:
*       - uint8_t* destination => pointer to the address at which to set memory;
*       - uint16_t value => the value to set in memory (word = 2 bytes);
*		- uint16_t size => number of words to set (max 65536 for uint16_t);
*	- Return: uint8_t* destination => pointer to the (start of the) set contents;
*   - Sets from address in destination a number of words (size) to a word value (value);
********************************************************************************************************************************************/

uint16_t* memsetWord(uint16_t* destination, uint16_t value, uint16_t size) {

	uint16_t wordIndex;

	for (wordIndex = 0; wordIndex < size; wordIndex++) {
		destination[wordIndex] = value;
	}

	return destination;

}
