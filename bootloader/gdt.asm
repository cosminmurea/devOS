
;-----------------------------------------------------------------------------------------------------------------------------------------
;Global Descriptor Table:
;
;	- Relevant bits for Long Mode:
;		- Code: bit 43 = executable / bit 44 = descriptor type / bit 47 = present / bit 53 = long mode are all set
;		- Data: bit 47 = present is set
;
;	- Null Descriptor:
;		- bits 0 - 63 = all 64 bits are cleared
;
;	- Code Descriptor in Long Mode:
;		- bits 0 - 15 = segment limit => bits 0 - 15
;		- bits 16 - 31 = segment base address => bits 0 - 15
;		- bits 32 - 39 = segment base address => bits 16 - 23
;		- bits 40 - 47 = access byte => bits 43, 44 & 47 are set and the other 5 bits are cleared (ring 0 => bits 45 & 46 = 00)
;		- bits 48 - 51 = segment limit => bits 16 - 19
;		- bits 52 - 55 = flags => bit 53 is set (long mode flag) the other 3 are cleared
;		- bits 56 - 63 = segment base address => bits 24 - 31
;
;	- Data Descriptor in Long Mode:
;		- bits 0 - 15 = segment limit => bits 0 - 15
;		- bits 16 - 31 = segment base address => bits 0 - 15
;		- bits 32 - 39 = segment base address => bits 16 - 23
;		- bits 40 - 47 = access byte => bit 47 is set, the rest are cleared
;		- bits 48 - 51 = segment limit => bits 16 - 19
;		- bits 52 - 55 = flags => all bits are cleared
;		- bits 56 - 63 = segment base address => bits 24 - 31
;
;	- GDT Pointer:
;		- bits 0 - 15 = size of the Global Descriptor Table = $ - gdt - 1
;		- bits 16 - 79 = base address of the Global Descriptor Table
;-----------------------------------------------------------------------------------------------------------------------------------------

gdt:

	.null: equ $ - gdt

		dw 0
		dw 0
		db 0
		db 0
		db 0
		db 0

	.code: equ $ - gdt

		dw 0
		dw 0
		db 0
		db 10011000b
		db 00100000b
		db 0

	.data: equ $ - gdt

		dw 0
		dw 0
		db 0
		db 10000000b
		db 0
		db 0

	.pointer:

		dw $ - gdt - 1
		dq gdt
