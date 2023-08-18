
[bits 64]

[extern main]

global _start

_start:

	call main

;cli??
halt:
	hlt
	jmp halt
