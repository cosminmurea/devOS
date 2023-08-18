
;-----------------------------------------------------------------------------------------------------------------------------------------
;setupPaging:
;	- stores the base address of PML4T in CR3 (control register 3)
;	- clears 16 KiB of space starting from memory address 0x1000 for the 4 translation tables
;	- creates one entry in each table so that they point to the next lower level table (PML4T[0] -> PDPT[0] -> PDT[0] -> PT[0])
;	- pointers stored in translation tables eg. PML4T[0] = 0x2003 end in 3 to set the present and writeable bits to 1 (0th & 1st bits)
;	- uses identity mapping to map the first 2 MiB = one Page Table starting at 0000:0000 = 0x00000003 (to set the 1st & 0th bits)
;-----------------------------------------------------------------------------------------------------------------------------------------

setupPaging:

	pushad

	mov edi, 0x1000						;EDI = 0x1000 = base address of the highest level translation table (PML4T)
	mov cr3, edi						;CR3 = base address of PM4LT

	xor eax, eax
	mov ecx, 4096						;ECX = number of iterations for the rep instruction
	rep stosd							;rep stosd => stores a double word from EAX (0) at the address in EDI (0x1000), ECX times (4096)

	mov edi, cr3						;restore the initial value of EDI (was changed by rep stosd)

	mov dword [edi], 0x2003				;first entry in PML4T points to the first entry in PDPT
	add edi, 0x1000
	mov dword [edi], 0x3003				;first entry in PDPT points to the first entry in PDT
	add edi, 0x1000
	mov dword [edi], 0x4003				;first entry in PDT points to the first entry in PT
	add edi, 0x1000

	mov ebx, 0x00000003					;identity mapping the first 2 MiB
	mov ecx, 512						;ECX = loop counter = number of entries in one Page Table

	.setPTEntry:
		mov dword [edi], ebx			;store the base address of the first Page (Frame) to PT[0]
		add ebx, 0x1000					;add 0x1000 (4 KiB) to point to the base address of the next Page 
		add edi, 8						;each entry is 8 bytes long => add 8 to point to the next entry in PT
		loop .setPTEntry				;loop ECX times (512)

	popad
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;setPAEBit:
;	- set the 5th bit of CR4 (control register 4) to 1 => enable Physical Address Extension (CR4.PAE Bit)
;-----------------------------------------------------------------------------------------------------------------------------------------

setPAEBit:

	pushad
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax
	popad
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;setProtectedModeBit:
;	- set the 0th bit of CR0 (control register 0) to 1 => enable Protected Mode (CR0.PE Bit)
;-----------------------------------------------------------------------------------------------------------------------------------------

setProtectedModeBit:

	pushad
	mov eax, cr0
	or eax, 1 << 0
	mov cr0, eax
	popad
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;setPagingBit:
;	- set the 31st bit of CR0 (control register 0) to 1 => enables Paging (CR0.PG Bit)
;-----------------------------------------------------------------------------------------------------------------------------------------

setPagingBit:

	pushad
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax
	popad
	ret
