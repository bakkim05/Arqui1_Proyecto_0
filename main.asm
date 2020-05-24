%include "linux64.inc.asm"

section		.data
			file	db "images/pngMadeMini_size.txt",0
			
section		.bss
			size	resb	10
			
section		.text
			global	_start
			
_start:
			mov		rax, SYS_OPEN
			mov 	rdi, file
			mov 	rsi, O_RDONLY
			mov		rdx, 0
			syscall
			
			push 	rax
			mov		rdi, rax
			mov		rax, SYS_READ
			mov		rsi, size
			mov		rdx, 17
			syscall
			
			mov		rax, SYS_CLOSE
			pop		rdi
			syscall
			
			print	size
			exit
