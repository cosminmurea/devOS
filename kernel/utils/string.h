
#ifndef STRING_H
#define STRING_H

size_t strlen(const uint8_t* string);

void strrev(uint8_t* string);

uint8_t* integerToString(int32_t integer, uint8_t* string, uint8_t base);

#endif
