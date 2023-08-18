
#include <stdint.h>
#include <stddef.h>
#include "string.h"

/********************************************************************************************************************************************
*strlen:
*   - Parameters: const uint8_t* string => pointer to a null-terminated string;
*   - Return: size_t strLength => the length of the parameter string;
*   - Computes the length of a null-terminated string without including the null (\0) character;
********************************************************************************************************************************************/

size_t strlen(const uint8_t* string) {

    size_t strLength = 0;

    while (string[strLength] != 0) {
        strLength++;
    }

    return strLength;

}

/********************************************************************************************************************************************
*strrev:
*   - Parameters: uint8_t* string => pointer to a null-terminated string;
*   - Reverses a string in place by using pointers;
********************************************************************************************************************************************/

void strrev(uint8_t* string) {

    uint8_t* start = string;
    uint8_t* end = start + strlen(string) - 1;
    uint8_t temp;

    if (string == 0) {
        return;
    }

    if (strlen(string) == 0) {
        return;
    }

    while (end > start) {
        temp = *start;
        *start = *end;
        *end = temp;

        start++;
        end--;
    }

}

/********************************************************************************************************************************************
*integerToString:
*   - Parameters:
*       - int32_t integer => integer to convert;
*       - uint8_t* string => buffer to store the converted integer (string of digit characters);
*       - uint8_t base => the base for conversion (2, 10 & 16);
*   - Return: uint8_t* string => pointer to the string version of the parameter integer;
********************************************************************************************************************************************/

uint8_t* integerToString(int32_t integer, uint8_t* string, uint8_t base) {

    uint16_t index = 0;
    int32_t tempInteger;

    // Handle invalid base;
    if (base < 2 || base > 32) {
        string[0] = '\0';
        return string;
    }

    if (integer == 0) {
        string[0] = '0';
        string[1] = '\0';
        return string;
    }

    // Use the absolute value of 'integer';
    tempInteger = (integer >= 0) ? integer : (integer * (-1));

    while (tempInteger) {
        int remainder = tempInteger % base;

        if (remainder >= 10) {
            string[index++] = 65 + (remainder - 10);
        } else {
            string[index++] = 48 + remainder;
        }

        tempInteger = tempInteger / base;
    }

    // Handle negative decimal numbers (all other bases are considered unsigned);
    if (integer < 0 && base == 10) {
        string[index++] = '-';
    }

    // Reverse string before NULL-terminating
    strrev(string);

    string[index] = '\0';

    return string;

}
