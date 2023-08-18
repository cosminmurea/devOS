
#include <stdint.h>
#include "ports.h"

/********************************************************************************************************************************************
*inbyte:
*   - Parameters: uint16_t port => address of the port from which to read;
*   - Return: uint8_t portData => the byte of data read from the port;
*   - Reads a byte of data from a given port using inline assembly (AT&T syntax);
********************************************************************************************************************************************/

uint8_t inbyte(uint16_t port) {

    uint8_t portData;

    asm volatile("inb %[port], %[portData]" : [portData] "=a"(portData) : [port] "Nd"(port));

    return portData;

}

/********************************************************************************************************************************************
*outbyte:
*   - Parameters:
*       - uint16_t port => address of the port to write at;
*       - uint8_t data => the byte of data to write;
*   - Writes a byte of data to a given port using inline assembly (AT&T syntax);
********************************************************************************************************************************************/

void outbyte(uint16_t port, uint8_t data) {

    asm volatile("outb %[data], %[port]" : : [data] "a"(data), [port] "Nd"(port));

}
