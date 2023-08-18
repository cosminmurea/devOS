
;-----------------------------------------------------------------------------------------------------------------------------------------
;checkCPUID:
;	- checks if the CPUID instruction is supported by attempting to flip the 21st bit of the EFLAGS register
;	- if this bit can be flipped => CPUID is supported
;-----------------------------------------------------------------------------------------------------------------------------------------

checkCPUID:

	pushad

	pushfd							;save the EFLAGS register on the stack
	pop eax							;pop the last value on the stack (EFLAGS) in EAX
	mov ecx, eax					;copy the value of EFLAGS to ECX via EAX

	xor eax, 1 << 21				;attempt to flip the 21st bit of EAX (if it's equal to 0)

	push eax
	popfd							;copy the value in EAX to the EFLAGS register using the stack

	pushfd
	pop eax							;copy the value in EFLAGS to EAX (the 21st bit will be flipped if CPUID is supported)

	push ecx
	popfd							;restore the initial value of EFLAGS

	xor eax, ecx					;compare EAX and ECX
	jz .noCPUID						;if EAX = ECX then CPUID is not supported

	mov si, cpuidSuccessMsg
	call printString

	popad
	ret

	.noCPUID:
		mov si, cpuidErrorMsg
		call printString
		jmp $

;-----------------------------------------------------------------------------------------------------------------------------------------
;checkLM:
;	- checks for the highest extended function implemented using CPUID 0x80000000
;	- if 0x80000001 is not implemented => long mode is not supported
;	- else it executes 0x80000001 => returns extended processor info and feature bits in EDX and ECX
;	- checks the 29th bit of EDX, long mode is supported only if this bit is set to 1
;-----------------------------------------------------------------------------------------------------------------------------------------

checkLM:

	pushad

	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001				;check if EAX (highest extended function implemented) >= 0x80000001
	jb .noLongMode					;since 32 bit registers are unsigned by default => jump below instead of jump less

	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .noLongMode					;if the 29th bit of EDX is 0 => long mode is not supported

	mov si, longModeSuccessMsg
	call printString

	popad
	ret

	.noLongMode:
		mov si, longModeErrorMsg
		call printString
		jmp $

;-----------------------------------------------------------------------------------------------------------------------------------------
;setLMBit:
;	- set the 8th bit of the Extended Feature Enable Register (EFER) to 1 => enables Long Mode (EFER.LME Bit)
;	- the model specific register (MSR) number for the EFER is 0xC0000080
;-----------------------------------------------------------------------------------------------------------------------------------------

setLMBit:

	pushad
	mov ecx, 0xC0000080
	rdmsr							;rdmsr (read MSR) loads the MSR specified by ECX in EDX:EAX
	or eax, 1 << 8					;set the 8th bit of EFER to 1, this enables long mode
	wrmsr							;wrmsr (write MSR) writes the updated version in the MSR specified by ECX
	popad
	ret

;-----------------------------------------------------------------------------------------------------------------------------------------
;Data:
;	- do NOT move! (at least for now)
;-----------------------------------------------------------------------------------------------------------------------------------------

cpuidErrorMsg: db "CPUID is not supported!", 0x0A, 0x0D, 0
cpuidSuccessMsg: db "CPUID is supported!", 0x0A, 0x0D, 0
longModeErrorMsg: db "LM is not supported!", 0x0A, 0x0D, 0
longModeSuccessMsg: db "LM is supported!", 0x0A, 0x0D, 0
