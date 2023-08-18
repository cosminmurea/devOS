
#ifndef MEMORY_H
#define MEMORY_H

uint8_t* memcpy(uint8_t* destination, const uint8_t* source, uint16_t size);

uint8_t* memset(uint8_t* destination, uint8_t value, uint16_t size);

uint16_t* memsetWord(uint16_t* destination, uint16_t value, uint16_t size);

#endif
