
;-----------------------------------------------------------------------------------------------------------------------------------------
;printString:
;	- print a null terminated string to the screen using BIOS int 0x10 / AH = 0x0e
;	- @param: SI points to the first character of the string
;-----------------------------------------------------------------------------------------------------------------------------------------

printString:

	pusha
	mov ah, 0x0e
	xor bh, bh							;BH = page number = 0

	.printLoop:
		mov al, [si]
		cmp al, 0						;check for end of string (AL = 0)
		jne .printChar
		popa
		ret

	.printChar:
		int 0x10
		inc si
		jmp .printLoop

;-----------------------------------------------------------------------------------------------------------------------------------------
;printHex:
;	- print a hexadecimal value using 'printString'
;	- @param: DX contains the hexadecimal value to be printed
;-----------------------------------------------------------------------------------------------------------------------------------------

printHex:

	pusha
	mov cl, 12							;shift right by CL bits (12, 8, 4, 0)
	mov di, 2							;DI = index register for hexPattern

	.printLoop:
		mov bx, dx
		shr bx, cl						;shift right to obtain the first, first two, three and four hex digits
		and bx, 0x000f					;masking the first 12 bits (3 hex digits)
		mov bx, [hexTable + bx]			;map to a valid ASCII character using hexTable
		mov [hexPattern + di], bl		;move contents of BL to byte DI in hexPattern
		sub cl, 4
		inc di

		cmp di, 6						;if DI = 6 => all hex characters have been printed
		je .exit
		jmp .printLoop

	.exit:
		mov si, hexPattern
		call printString
		popa
		ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;setVideoMode:
;	- sets the video mode using int 0x10 / AH = 0x00
;	- uses video mode AL = 0x03 => type: text / resolution: 80x25 / buffer address: 0xb8000
;-----------------------------------------------------------------------------------------------------------------------------------------

setVideoMode:

	pusha
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	popa
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;Data:
;	- do NOT move! (at least for now)
;-----------------------------------------------------------------------------------------------------------------------------------------

hexPattern: db "0x****", 0x0A, 0x0D, 0
hexTable: db "0123456789abcdef"
