%include "linux64.inc.asm"

	section .bss

		temp resb 5		 	 ;bloque de memoria temporal
		sharpened 	resq 1000	 ;bloque de memoria reservado para crear imagen sharpened
		osharpened 	resq 1000 ;bloque de memoria reservado para crear imagen over sharpened
		lector		resb 3
		tamano		resq 1000 ;tamano de la matriz multiplicando filas y columnas
		finalPos	resq 1000 ;
		currentPos	resq 1000 ;
	
		
		dewidthbug 	resq  	0d		 ;existe un bug que hace que height sobre escriba el valor de width, esta es una solucion que encontra a ese problema (width en .data)
		height		resq 	0d		 ;height conseguido del archivo de size con buffer

		
		pivot resw 		1		;memoria reservada para los datos necesarios en la convolucion para sharpening e oversharpenning
		pos1 resw		1		; ^
		pos2 resw		1		; ^
		pos3 resw		1		; ^
		pos4 resw		1		; ^				estos valores van desde 0 a 255 por lo que solo utiliza un byte
		pos5 resw		1		; ^
		pos6 resw		1		; ^
		pos7 resw		1		; ^
		pos8 resw		1		; ^

		
		


	section .data
		;sizefile db "images/pngMade_size.txt",0h		;guardar su file descriptor en r12
		;matrixfile db "images/pngMade_matrix.txt",0h	;guardar su file descriptor en r12 (el de sizefile y matrixfile no estan abiertas simultaneamente)
		
		sizefile db "test_size.txt",0h		;prueba
		matrixfile db "test_matrix.txt",0h		;prueba
		
		;currentPos dq 0d			;posicion actual del pivot
		width dq 0d		; width conseguido del archivo de size con buffer

		;width 	db  	0d		 ;width conseguido del archivo de size con buffer
		;height db 	0d		 ;height conseguido del archivo de size con buffer

		;pivot db 0d		;memoria reservada para los datos necesarios en la convolucion para sharpening e oversharpenning
		;pos1 db 0d		; ^
		;pos2 db 0d		; ^
		;pos3 db 0d		; ^
		;pos4 db 0d		; ^				estos valores van desde 0 a 255 por lo que solo utiliza un byte
		;pos5 db 0d		; ^
		;pos6 db 0d		; ^
		;pos7 db 0d		; ^
		;pos8 db 0d		; ^


	section .text
		global _start

_start:
	;procedimiento para abrir el archivo
	mov rax, 2
	mov rdx, 0 ; read parameter
	mov rdi, sizefile
	syscall

	;guardar file descriptor en r12
	mov r12, rax



	;Encontrar valor de width con lseek
	mov rax, 8
	mov rdx, 0 ;al comienzo del file
	mov rdi, r12
	mov rsi, 0
	syscall

	mov rax, 0	;system read en el lugar de lseek
	mov rdx, 5 			;BUFFER!
	mov rsi, temp
	mov rdi, r12
	syscall

	mov rax, temp
	call atoi
	mov [width], rax	;width con buffer
	
	mov [currentPos], rax ;declaracion de valor currentPos
	mov [dewidthbug], rax ;esto esta aqui debido a un bug se esta logrando resolver, donde height sobreescribe el valor de width


	;Encontrar valor de height con lseek
	mov rax, 8
	mov rdx, 0 ;al comienzo del file
	mov rdi, r12
	mov rsi, 5 ;offset bytes
	syscall

	mov rax, 0	;system read en el lugar de lseek
	mov rdx, 5	;buffer #bytes
	mov rsi, temp
	mov rdi, r12
	syscall

	mov rax, temp
	call atoi
	mov [height], rax	;height con buffer
	
	; realizar multiplicacion de filas y columnas y guardarlo en tamano
	mov rax, [width]
	mov rdi, [height]
	mul rdi
	mov [tamano], rax

	; posicion de inicio de currentPos
	mov rax, [currentPos]
	add rax, 1
	mov [currentPos], rax; se inicializa en el valor de width, por lo que bajo la logica utilizada se ocupa agregar solo 1
	
	; calcular posicionfinal de la matriz en finalPos
	mov rax, [width]
	add rax, 2
	mov rdi, rax
	mov rax, [tamano]
	sub rax, rdi
	mov [finalPos], rax
	

	;cerrar archivo de size
	mov rax, 3
	mov rdi, r12
	syscall			;aqui se deja de utilizar r12
	

	;abrir archivo matrix
	mov rax, 2
	mov rsi, 0
	mov rdx, 0
	mov rdi, matrixfile
	syscall

	mov r12, rax	;file descriptor de matrixfile en r12
	
	
	
	
	;----------------------trabajando-------------------;
	; trabajando en la obtencion de datos alrededor de currentPos
	


	;---------------------------------------------------;
	


f:	call _quit

	
; funcion atoi convierte el ascii en RAX a int -------------------------------------------------------------
atoi:
    push    rbx             ; preserve ebx on the stack to be restored after function runs
    push    rcx             ; preserve ecx on the stack to be restored after function runs
    push    rdx             ; preserve edx on the stack to be restored after function runs
    push    rsi             ; preserve esi on the stack to be restored after function runs
    mov     rsi, rax        ; move pointer in eax into esi (our number to convert)
    mov     rax, 0          ; initialise eax with decimal value 0
    mov     rcx, 0          ; initialise ecx with decimal value 0
 
.multiplyLoop:
    xor     rbx, rbx        ; resets both lower and uppper bytes of ebx to be 0
    mov     bl, [rsi+rcx]   ; move a single byte into ebx register's lower half
    cmp     bl, 48          ; compare ebx register's lower half value against ascii value 48 (char value 0)
    jl      .finished       ; jump if less than to label finished
    cmp     bl, 57          ; compare ebx register's lower half value against ascii value 57 (char value 9)
    jg      .finished       ; jump if greater than to label finished
 
    sub     bl, 48          ; convert ebx register's lower half to decimal representation of ascii value
    add     rax, rbx        ; add ebx to our interger value in eax
    mov     rbx, 10         ; move decimal value 10 into ebx
    mul     rbx             ; multiply eax by ebx to get place value
    inc     rcx             ; increment ecx (our counter register)
    jmp     .multiplyLoop   ; continue multiply loop
 
.finished:
    mov     rbx, 10         ; move decimal value 10 into ebx
    div     rbx             ; divide eax by value in ebx (in this case 10)
    pop     rsi             ; restore esi from the value we pushed onto the stack at the start
    pop     rdx             ; restore edx from the value we pushed onto the stack at the start
    pop     rcx             ; restore ecx from the value we pushed onto the stack at the start
    pop     rbx             ; restore ebx from the value we pushed onto the stack at the start
    ret
;------------------------------------------------------------------------------------------------------------
	
_quit:
	;procedimiento para salir del programa
	mov rax, 60
	mov rdi, 0
	syscall

