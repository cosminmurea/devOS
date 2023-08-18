
[org 0x7c00]							;the memory location where the bootloader starts (from 0x7c00 to 0x7e00)
[bits 16]								;16 bit REAL MODE

section .text

global start

;-----------------------------------------------------------------------------------------------------------------------------------------
;start:
;	- clears the segment registers + the direction flag and sets the stack pointer to point to the 'start' label
;	- calls resetDiskSystem so that (C, H, S) = (0, 0, 1)
;	- calls readDisk to read 1 sector starting from (0, 0, 2) where 1 sector = 512 bytes
;	- jumps to the 'secondSector' label
;	- jumps to current location (to be replaced by proper halting!!)
;-----------------------------------------------------------------------------------------------------------------------------------------

start:

	cli									;disable BIOS interrupts (clear interrupt flag)
	jmp 0x0000:SegInit					;use a far jump to 0x0000:SegInit to set CS = 0x0000

	SegInit: 							;clears the segment registers + the direction flag and sets the stack pointer
		xor ax, ax
		mov ss, ax
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax						;SS = DS = ES = FS = GS = 0 => clear segment registers
		mov sp, start					;SP = points to the memory location of the 'start' label (the stack grows downwards from SP)
		cld								;clear direction flag (string operations will increment SI / DI)

	sti									;enable BIOS interrupts (set interrupt flag)

	mov [driveNumber], dl				;save the drive number (DL) to the location of the 'driveNumber' label

	call resetDiskSystem				;set (C, H, S) = (0, 0, 1)

	mov al, 1							;AL contains the number of sectors to be read
	mov cl, 2							;CL contains the starting sector (sector 1 = bootloader => start from sector 2)
	xor bx, bx
	mov es, bx							;ES = BX = 0 (no segment needed)
	mov bx, [secondSectorOffset]		;BX = 0x7c00 + 512 = 0x7e00 => ES:BX = 0x000:0x7e00
	call readDisk						;read content is loaded at ES:BX = 0x0000:0x7e00 (after the bootloader)

	call setVideoMode

	mov si, greeting
	call printString

	jmp secondSector

	jmp $

;-----------------------------------------------------------------------------------------------------------------------------------------
;Files to be included:
;	- print.asm => print functions for strings and hexadecimal numbers
;	- disk.asm => disk functions (reset, read)
;	- a20.asm => functions for testing, enabling & disabling the A20 line
;	- gdt.asm => contains the Global Descriptor Table for Long Mode
;-----------------------------------------------------------------------------------------------------------------------------------------

%include "./print.asm"
%include "./disk.asm"
%include "./a20.asm"
%include "./gdt.asm"

;-----------------------------------------------------------------------------------------------------------------------------------------
;Data:
;	- do NOT move this to a '.data' section!
;	- do NOT move this before the 'start' label!
;	- declaring data after an infinite loop / halt to prevent it from being reached
;-----------------------------------------------------------------------------------------------------------------------------------------

driveNumber: db 0
secondSectorOffset: dw 0x7e00
kernelOffset: dw 0x9000
greeting: db 0x0A, 0x0D, "Welcome to devOS!", 0x0A, 0x0D, 0

;-----------------------------------------------------------------------------------------------------------------------------------------
;Padding & Magic Number:
;-----------------------------------------------------------------------------------------------------------------------------------------

times 510 - ($ - $$) db 0				;padding the bootloader with 0s to reach 510 bytes
dw 0xaa55								;last 2 bytes = magic number (identifies this as a bootloader)

;-----------------------------------------------------------------------------------------------------------------------------------------
;secondSector:
;	- calls testA20 to check if the A20 line is enabled
;	- calls enableA20 to enable the A20 line
;	- calls checkCPUID to check if the CPUID instruction is supported
;	- calls checkLM to check if Long Mode is supported
;	- calls setupPaging to setup the Page Tables and map the first 2 MiB starting at 0000:0000 (identity mapping)
;	- calls setPAEBit to set CR4.PAE to 1
;	- calls setLMBit to set EFER.LME to 1
;	- calls setPagingBit to set CR0.PG
;	- calls setProtectedModeBit to set CR0.PE
;	- loads the GDT using lgdt [gdt.pointer]
;	- executes a far jump to gdt.code:longMode such that CS = gdt.code
;-----------------------------------------------------------------------------------------------------------------------------------------

secondSector:

	mov al, 20
	mov cl, 3							;start from the third sector
	xor bx, bx
	mov es, bx							;ES = BX = 0 (no segment needed)
	mov bx, [kernelOffset]				;load read content at BX = 0x9000 => ES:BX = 0x0000:0x9000 = 0x9000
	call readDisk

	call disableA20

	call testA20
	mov dx, ax
	call printHex

	call enableA20

	call checkCPUID
	call checkLM	

	cli

	call setupPaging

	call setPAEBit
	call setLMBit
	call setPagingBit
	call setProtectedModeBit

	lgdt [gdt.pointer]
	jmp gdt.code:longMode

	jmp $

;-----------------------------------------------------------------------------------------------------------------------------------------
;Files to be included:
;	- checkLongMode.asm => functions for checking CPUID + Long Mode and for setting EFER.LME to 1
;	- paging.asm => functions for setting up PAE Paging and for setting CR0.PE, CR0.PG, CR4.PAE to 1
;-----------------------------------------------------------------------------------------------------------------------------------------

%include "./checkLongMode.asm"
%include "./paging.asm"

[bits 64]

;-----------------------------------------------------------------------------------------------------------------------------------------
;longMode:
;	- clear registers SS, DS, ES, FS and GS
;	- print OKAY to the screen
;	- halt
;-----------------------------------------------------------------------------------------------------------------------------------------

longMode:

	xor ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	jmp 0x00009000

	hlt

;-----------------------------------------------------------------------------------------------------------------------------------------
;Padding:
;-----------------------------------------------------------------------------------------------------------------------------------------

times 512 - ($ - $$ - 512) db 0
