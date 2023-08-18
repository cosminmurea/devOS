
;-----------------------------------------------------------------------------------------------------------------------------------------
;testA20:
;	- test to check if the A20 line is enabled / disabled (check if memory wraps around)
;	- compare the bootsector identifier stored at [0x0000:0x7dfe] and the contents of memory address [0xffff:0x7e0e]
;	- 1st check: if AX = DX => return with AX = 0 (A20 is disabled) else jump to '.secondCheck'
;	- 2nd check: if AX = DX => return with AX = 0 (A20 is disabled) else jump to '.exit'
;	- exit: return with AX = 1 (A20 is enabled)
;-----------------------------------------------------------------------------------------------------------------------------------------

testA20:

	pusha
	mov ax, [0x7dfe]			;move [0x7c00 + 510] = [0x7dfe] in AX

	mov bx, 0xffff
	mov es, bx
	mov bx, 0x7e0e
	mov dx, [es:bx]				;move [0x0000:0x7dfe + 1MiB] = [0xffff:0x7e0e] to DX

	cmp ax, dx
	jne .secondCheck			;if AX != DX then check again else return with AX = 0 (a20 disabled)

	popa
	xor ax, ax
	ret

	.secondCheck:
		mov ax, [0x7dfe]		;move [0x7c00 + 510] = [0x7dfe] in AX / not needed
		rol ax, 8				;rotate AX left by 8 bits

		mov dx, [es:bx]			;move [0x0000:0x7dfe + 1MiB] = [0xffff:0x7e0e] to DX / not needed
		rol dx, 8				;rotate DX left by 8 bits

		cmp ax, dx
		jne .exit				;if AX != DX => return with AX = 1 (a20 enabled) else return with AX = 0 (a20 disabled)

		popa
		xor ax, ax
		ret

	.exit:
		popa
		mov ax, 1
		ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;disableA20:
;	- disable the A20 line using BIOS int 0x15 / AH = 0x2400
;	- will cause memory to wrap around at the 1MiB mark
;-----------------------------------------------------------------------------------------------------------------------------------------

disableA20:

	pusha
	mov ax, 0x2400
	int 0x15
	popa
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;enableA20:
;	- tries to enable the A20 line using 3 cascading methods
;	- if the first method fails to enable the A20 line then jump to the second method etc.
;	- 1st method - .biosA20: using BIOS interrupt 0x15 / AX = 0x2401
;	- 2nd method - .keyboardA20: by programming the 8042 Keyboard Controller
;	- 3rd method - .fastA20: by using port 0x92
;	- if ONE of the methods succeeded, print a success message and return
;	- if ALL methods failed, print an error message and halt
;-----------------------------------------------------------------------------------------------------------------------------------------

enableA20:

	pusha

	.biosA20:
		mov ax, 0x2401
		int 0x15

		call testA20
		cmp ax, 1
		je .done

	.keyboardA20:
		cli

		call .waitCommand		;wait for the keyboard controller (in case it is busy)
		mov al, 0xad			;AL = 0xad => command code for disabling the keyboard interface
		out 0x64, al			;send data from AL to port 0x64 (sending the command)

		call .waitCommand
		mov al, 0xd0			;AL = 0xd0 => command code for reading data from port 0x60
		out 0x64, al

		call .waitData			;wait for data from port 0x60 to be ready
		in al, 0x60				;read data from port 0x60 in AL
		push ax					;save AX on the stack

		call .waitCommand
		mov al, 0xd1			;AL = 0xd1 => command code for sending data to port 0x60
		out 0x64, al

		call .waitCommand
		pop ax					;restore AX from the stack
		or al, 2				;mask the second bit of AL - in order to enable the A20 line
		out 0x60, al			;send data from AL to port 0x60

		call .waitCommand
		mov al, 0xae			;AL = 0xae => command code for enabling the keyboard interface
		out 0x64, al

		call .waitCommand

		sti

		call testA20
		cmp ax, 1
		je .done

		jmp .fastA20

	.waitCommand:				;check if the keyboard controller is busy
		in al, 0x64
		test al, 2				;test the second bit of AL (test = bit comparison)
		jnz .waitCommand		;if it is 1 then the controller is busy
		ret						;if it is 0 then the controller is no longer busy

	.waitData:					;check if data is ready to be read from port 0x60
		in al, 0x64
		test al, 1				;test the first bit of AL
		jz .waitData			;if it is 0 then the data is not ready
		ret						;if it is 1 then the data is ready

	.fastA20:
		in al, 0x92				;read data from port 0x92 (on the chipset) in AL
		or al, 2				;maks the second bit of AL
		out 0x92, al			;send data from AL to port 0x92

		call testA20
		cmp ax, 1
		je .done

	.failed:
		mov si, a20ErrorMsg
		call printString
		jmp $

	.done:
		mov si, a20SuccessMsg
		call printString
		popa
		ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;Data:
;	- do NOT move! (at least for now)
;-----------------------------------------------------------------------------------------------------------------------------------------

a20ErrorMsg: db "Enabling A20 failed!", 0x0A, 0x0D, 0
a20SuccessMsg: db "Enabled A20!", 0x0A, 0x0D, 0
