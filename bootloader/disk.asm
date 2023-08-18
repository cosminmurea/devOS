
;-----------------------------------------------------------------------------------------------------------------------------------------
;resetDiskSystem:
;	- reset the disk system using BIOS int 0x13 / AH = 0x00
;	- DL contains the drive number (0x00 = floppy disk / 0x80 = hard disk)
;	- after reseting the disk system (C, H, S) = (0, 0, 1)
;-----------------------------------------------------------------------------------------------------------------------------------------

resetDiskSystem:

	pusha
	xor ax, ax
	mov dl, [driveNumber]
	int 0x13
	popa
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;readDisk:
;	- read sectors from a disk using BIOS int 0x13 / AH = 0x02
;	- @param: AL contains the number of sectors to be read
;	- @param: CL contains the starting sector
;	- @param: ES:BX is the memory address in RAM where the read sectors will be loaded
;	- DL contains the drive number (0x00 = floppy disk / 0x80 = hard disk)
;	- CH contains the starting cylinder (cylinder = 0)
;	- DH contains the starting head (head = 0)
;	- double check using the carry flag and the return value of AL (number of sectors loaded in memory)
;-----------------------------------------------------------------------------------------------------------------------------------------

readDisk:

	pusha
	mov ah, 0x02
	mov dl, [driveNumber]
	mov ch, 0
	mov dh, 0

	mov [sectorsToRead], al

	int 0x13

	jc .diskError						;if the carry flag is set then there was an error

	cmp al, [sectorsToRead]				;AL = number of sectors actually transferred to memory
	jne .diskError						;check if [sectorsToRead] = AL else an error occurred

	popa
	ret

	.diskError:
		mov si, diskErrorMsg
		call printString
		jmp $

;-----------------------------------------------------------------------------------------------------------------------------------------
;Data:
;	- do NOT move! (at least for now)
;-----------------------------------------------------------------------------------------------------------------------------------------

diskErrorMsg: db "Disk Error!", 0x0A, 0x0D, 0
sectorsToRead: db 0
