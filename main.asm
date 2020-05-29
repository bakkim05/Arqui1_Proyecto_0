%include "linux64.inc.asm"
	section .bss
		sConv		resq 1		;valor de convolucion de sharpen
		osConv		resq 3		;valor de convolucion de oversharpen
		temp 		resb 5		;bloque de memoria temporal
		lector		resb 3
		tamano		resq 1000 	;tamano de la matriz multiplicando filas y columnas
		finalPos	resq 1000 ;
		currentPos	resq 1000 ;
		num			resb 3
		
		dewidthbug 	resq  	0d		 ;existe un bug que hace que height sobre escriba el valor de width, esta es una solucion que encontra a ese problema (width en .data)
		height		resq 	0d		 ;height conseguido del archivo de size con buffer

	section .data
		sizefile db "images/nature_min_size.txt",0h		;este debe ser 1/2 inputs; guardar su file descriptor en r12
		matrixfile db "images/nature_min_matrix.txt",0h	;este debe ser 2/2 inputs; guardar su file descriptor en r12 (el de sizefile y matrixfile no estan abiertas simultaneamente)
		
		sharpenedfile db "images/sharpened.txt",0h
		osharpenedfile db "images/oversharpened.txt",0h

		width dq 0d			; width conseguido del archivo de size con buffer
		espacio db " ",0h	; utilizado para escribir un espacio entre cada numero de la matriz convolucionada

		contador db 0d		; contador para ciclos
	section .text
		global _start

_start:
	;procedimiento para abrir el archivo
	mov rax, 2
	mov rdx, 0 		;read parameter
	mov rdi, sizefile
	syscall
	mov r12, rax	;guardar file descriptor en r12


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
	add rax, 1			;para que comience (1,1) en vez de (0,0)
a:	mov [currentPos], rax ;declaracion de valor currentPos
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
	;sub rax, 1			;indices comienzan en 0
b:	mov [tamano], rax

	; posicion de inicio de currentPos
	mov rax, [currentPos]
	add rax, 1
	mov [currentPos], rax; se inicializa en el valor de width, por lo que bajo la logica utilizada se ocupa agregar solo 1
	
	; calcular posicionfinal de la matriz en finalPos
	mov rax, [width]		;.
	add rax, 2				;.<-era un 1
	mov rdi, rax			;.
	mov rax, [tamano]		;.		formula = tamano - (width + 1)
	sub rax, rdi			;.
	mov [finalPos], rax		;.
	

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
	
	
	;crear archivo para sharpened image
	xor rax, rax
	mov rax, 85
	mov rsi, 0777q
	mov rdi, sharpenedfile
	syscall
	mov r13, rax	;guardar en 13 el file descriptor de sharpenedfile (R13)
	
	
	;crear archivo para oversharpened image
	xor rax, rax
	mov rax, 85
	mov rsi, 0777q
	mov rdi, osharpenedfile
	syscall
	mov r15, rax	;guardar en 15 el file descriptor de oshaprenedfile (R15)
	

_cycle:					;cycle principal currentPos [?] finalPos
	xor rax, rax
	mov rax, [currentPos]
	mov rdi, [finalPos]
	cmp rax, rdi
	jg _closeFile		;jump greater	:	currentPos < finalPos
	push rax
	xor rax, rax
	mov [contador], rax
	pop rax
	call _cycle1		;else			:	currentPos >= finalPos

	
_cycle1:				;cycle contador [?] width -3
	xor rax, rax
	mov rax, [width]
	sub rax, 3
	mov rdi, rax
	xor rax, rax
	mov rax, [contador]
	cmp rax, rdi
	jg _cycle3			;jump greater	:	contador >= width - 2
	call _cycle2
	
	
_cycle2:
	call _posSetter		;
	call _escribirSF	;
	call _escribirOSF	;
	
	xor rax, rax
	mov [sConv], rax
	
	xor rax, rax
	mov [osConv], rax
	
	xor rax, rax
	mov rax, [contador]
	add rax, 1
	mov [contador], rax
	
	xor rax, rax
	mov rax, [currentPos]
	add rax, 1
	mov [currentPos], rax
	
	call _cycle1


_cycle3:
	xor rax, rax
	mov [contador], rax
	
	xor rax, rax
	mov rax, [currentPos]
	add rax, 2
	mov [currentPos], rax
	
	call _cycle



f:	call _quit






;-----------implementando ciclos para moverse en la matriz-----------------------;
_closeFile:
	;cierra archivo de shaprenedfile
	xor rax, rax
	mov rax, 3
	mov rdi, sharpenedfile
	syscall

	;cierra archivo de osharpenedfile
	xor rax, rax
	mov rax, 3
	mov rdi, osharpenedfile
	syscall

	;cierra archivo de matrixfile
	xor rax, rax
	mov rax, 3
	mov rdi, matrixfile
	syscall
	
	ret


;--------------------------------------------------------------------------------;

	;-----------------esperando implementacion ------------------;
	; trabajando en la obtencion de datos alrededor de currentPos
	
	;HARD CODE POSICION 12 (DA VALOR 5) EN 	MATRIZ DE PRUEBA
	
_posSetter:
	;Convolucion en la posicion actual
	xor rax, rax
	mov rax, [currentPos]
	mov rsi, 5				;posicion (1,1) del kernel de sharpening
	mov r14, 9				;posicion (1,1) del kernel de over sharpening
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 1
	xor rax, rax
	mov	rax, [width]
	add rax, 1
	mov rdi, rax
	xor rax, rax
	mov rax, [currentPos]
	sub rax, rdi			;en rax esta la posicion a la cual se ocupa convolucionar
	mov rsi, 0				;posicion (0,0) del kernel de sharpening
	mov r14, 0				;posicion (0,0) del kernel de over sharpening
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 2
	xor rax, rax
	mov rax, [width]
	mov rdi, rax
	mov rax, [currentPos]
	sub rax, rdi
	mov rsi, -1				;posicion (0,1) del kernel de sharpening
	mov r14, -2				;posicion (0,1) del kernel de over sharpening
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 3
	xor rax, rax
	mov rax, [width]
	sub rax, 1
	mov rdi, rax
	mov rax, [currentPos]
	sub rax, rdi
	mov rsi, 0			;posicion (0,2) del kernel de sharpening
	mov r14, 0			;posicion (0,2) del kernel de over sharpening	
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 4
	xor rax, rax
	mov rax, [currentPos]
	sub rax, 1
	mov rsi, -1			;posicion (1,0) del kernel de sharpening
	mov r14, -2			;posicion (1,0) del kernel de over sharpening	
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 6
	xor rax, rax
	mov rax, [currentPos]
	add rax, 1
	mov rsi, -1			;posicion (1,2) del kernel de sharpening
	mov r14, -2			;posicion (1,2) del kernel de over sharpening	
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 7
	xor rax, rax
	mov rax, [width]
	sub rax, 1
	mov rdi, rax
	mov rax, [currentPos]
	add rax, rdi		
	mov rsi, 0			;posicion (2,0) del kernel de sharpening
	mov r14, 0			;posicion (2,0) del kernel de over sharpening
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	;Convolucion pos 8
	xor rax, rax
	mov rax, [width]
	mov rdi, rax
	mov rax, [currentPos]
	add rax, rdi
	mov rsi, -1			;posicion (2,1) del kernel de sharpening
	mov r14, -2			;posicion (2,1) del kernel de over sharpening	
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen

	; calcular valor pos9
	mov rax, [width]
	add rax, 1
	mov rdi, rax
	mov rax, [currentPos]
	add rax, rdi
	mov rsi, 0			;posicion (2,2) del kernel de sharpening
	mov r14, 0			;posicion (2,2) del kernel de over sharpening	
	call _valPos
	push rax
	call _Sharpen
	pop  rax
	call _OSharpen


	; limitar el valor de sharpen y oversharpen
	xor rax, rax
	mov rax, [sConv]
	call _limitador
	mov [sConv], rax

	xor rax, rax
	mov rax, [osConv]
	call _limitador
	mov [osConv], rax

	ret
	;----------------------------------------------------;


_valPos:
	;posicionar lseek en la posicion especificada en rax
	push rsi
	mov rdi, 3
	mul rdi		; multiplica por la cantidad necesaria para encontrar la informacion en el archivo
	mov rsi, rax; offset bytes
	xor rax, rax
	mov rdi, r12; matrix file
	mov rdx, 0	; comenzar al inicio del documento
	mov rax, 8	; lseek
	syscall

	;leer valor en lseek
	xor rax, rax
	mov rdx, 3
	mov rsi, lector
	mov rdi, r12
	mov rax, 0
	syscall ; lector ahora tiene el valor en '' del valor de la posicion

	;ascii to integer al valor leido
	xor rax, rax
	mov rax, lector
	call atoi
	pop rsi

	ret ; rax contiene el numero, rsi contiene la cantidad a multiplicar (signed)


_escribirSF:	
	;lseek al final del arhivo sharpenedfile
	xor rax, rax
	mov rax, 8
	mov rsi, 0
	mov rdx, 2
	mov rdi, r13
	syscall

	;escribir en el archivo sharpened
	xor rax, rax
	mov rax, [sConv]
	call _limitador				;entrada: rax, salida: rax

	mov rdi, sConv
	mov rsi, rax
	call itoa

	;escribir en la posicion de lseek
	mov rdx, rax
	mov rsi, sConv
	mov rdi, r13

	xor rax, rax
	mov rax, 1
	syscall

	;lseek al final del arhivo sharpenedfile
	xor rax, rax
	mov rax, 8
	mov rsi, 0
	mov rdx, 2
	mov rdi, r13
	syscall

	;escribir en la posicion de lseek
	mov rdx, 1
	mov rsi, espacio
	mov rdi, r13

	xor rax, rax
	mov rax, 1
	syscall
	ret	

	
_escribirOSF:
	;lseek al final del arhivo osharpenedfile
	xor rax, rax
	mov rax, 8
	mov rsi, 0
	mov rdx, 2
	mov rdi, r15
	syscall

	;escribir en el archivo osharpened
	xor rax, rax
	mov rax, [osConv]
	call _limitador				;entrada: rax, salida: rax

	mov rdi, osConv
	mov rsi, rax
	call itoa

	;escribir en la posicion de lseek
	mov rdx, rax
	mov rsi, osConv
	mov rdi, r15

	xor rax, rax
	mov rax, 1
	syscall

	;lseek al final del arhivo sharpenedfile
	xor rax, rax
	mov rax, 8
	mov rsi, 0
	mov rdx, 2
	mov rdi, r15
	syscall

	;escribir en la posicion de lseek
	mov rdx, 1
	mov rsi, espacio
	mov rdi, r15
	
	xor rax, rax
	mov rax, 1
	syscall
	ret			


_Sharpen:
	; tiene al valor en la posicion en rax y valor del kernel en rsi
	imul rax, rsi  ; multiplica rax y rsi
	add rax, [sConv] ; suma el valor almacenado del sharpening a sConv
	mov [sConv], rax ; guarda el valor sumado a sConv
	xor rax, rax ; rax = 0	
	ret	


_OSharpen:
	; tiene al valor de la posicion en rax y valor del kernel en r14
	imul rax, r14
	add rax, [osConv]
	mov [osConv], rax
	xor rax, rax
	ret


_quit:
	;procedimiento para salir del programa
	mov rax, 60
	mov rdi, 0
	syscall


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

; funcion para limitar numeros de 0 a 255-------------------------------;
	
; limita el rango del numero entre los valores de 0 a 255
; tanto la salida como la entrada se encuentra en RAX
_limitador:
	cmp rax, 0
	jl	.negativo
	cmp rax, 255
	jg	.sobrepositivo
	ret ; si llega aqui significa que rax esta en el rango de 0 a 255
	
.negativo:
	xor rax, rax ;esto convierte a rax en 0
	ret
	
.sobrepositivo:
	mov rax, 255 ;convertir a rax a 255
	ret

;----------------------------------------------------------------------;


;itoa (buffer,n) -> # bytes written
;rdi: buffer
;rsi: n

itoa:
	mov rax, rsi
	mov rsi, 0
	mov r10, 10
	
itoa_loop:
	;do a division
	mov rdx, 0
	div r10
	add rdx, '0'
	mov [rdi + rsi], dl
	inc rsi
	cmp rax, 0
	jg itoa_loop
	
	;reverse the string
	mov rdx, rdi
	lea rcx, [rdi + rsi -1]
	jmp itoa_reverse_test
	
itoa_reverse_loop:
	mov al, [rdx]
	mov ah, [rcx]
	mov [rcx], al
	mov [rdx], ah
	inc rdx
	dec rcx
	
itoa_reverse_test:
	cmp rdx, rcx
	jl itoa_reverse_loop
	mov rax, rsi
	
	ret
