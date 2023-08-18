OUTPUT_FORMAT
(
	binary
)

ENTRY
(
	_start
)

INPUT
(
	kernelEntry.o
	kernel.o
	memory.o
	string.o
	ports.o
	display.o
)

OUTPUT
(
	kernel.bin
)

SECTIONS
{
	. = 0x9000;

	.text : ALIGN(0x1000)
	{
		*(.text)
	}

	.data : ALIGN(0x1000)
	{
		*(.data)
	}

	.rodata : ALIGN(0x1000)
	{
		*(.rodata)
	}

	.bss : ALIGN(0x1000)
	{
		*(COMMON)
		*(.bss)
	}
}
