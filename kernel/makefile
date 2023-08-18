
paddedKernel.bin: kernel.bin padding.bin
	cat kernel.bin padding.bin > ../bin/paddedKernel.bin

kernel.bin: kernelEntry.o kernel.o memory.o string.o ports.o display.o
	x86_64-elf-ld -T linkerScript.ld

kernelEntry.o: kernelEntry.asm
	nasm -f elf64 kernelEntry.asm -o kernelEntry.o

kernel.o: kernel.c
	x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c kernel.c -o kernel.o

memory.o: ./utils/memory.c
	x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c ./utils/memory.c -o memory.o

string.o: ./utils/string.c
	x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c ./utils/string.c -o string.o

ports.o: ./drivers/ports.c
	x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c ./drivers/ports.c -o ports.o

display.o: ./drivers/display.c
	x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c ./drivers/display.c -o display.o

padding.bin: padding.asm
	nasm -f bin padding.asm -o padding.bin
