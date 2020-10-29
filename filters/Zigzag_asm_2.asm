section .rodata



section .data

	global Zigzag_asm

section .text

;void Zigzag_asm ( uint8_t *src,		rdi
;				   uint8_t *dst,		rsi
;				   int width,			rdx
;				   int height,			rcx
;				   int src_row_size,	r8
;				   int dst_row_size		r9 )
;	r8 y r9 son 4 * width, por los cuatro bytes de cada pixel (ARGB)
;	cada posicion de memoria contiene 1 byte. pasar de un pixel a otro son 4 bytes

%define src rbx
%define dst r12
%define width r13
%define height r14

Zigzag_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	;la imagen inicia en el pixel (0,0) y tengo que recorrerla dejando un borde de 2 pixeles 
	;de esta forma, la imagen a modificar va a ser de width-4 y height-4

	mov src, rdi
	mov dst, rsi
	mov width, rdx
	mov height, rcx
	;preservo los parametros de entrada para poder reutilizar los registros

	mov r10, height
	sub r10, 4	;resto 4 por los 2 pixeles de borde blanco
	shr r10, 1	;divido por dos porque voy a tener dos casos dentro del ciclo
	sub r9, 16	;en r9 guardo la cantidad de pixeles por fila a modificar

	lea rdi, [src + width*2 + 2]	;muevo rdi a la posicion (2,2)
	lea rsi, [dst + width*2 + 2]	;muevo rsi a la posicion (2,2)

	xor rdx, rdx	;rdx va a servir como indice dentro de una fila
	xor rcx, rcx	;rcx va a servir como contador de filas a recorrer
	xor r11, r11
	;en el ciclo voy a tener dos casos. uno donde fila % 4 = 2 y otro donde fila % 4 = 0
	;si fila % 4 = 2, fila+1 % 4 = 3. esto se ejecuta en el ciclo.
	;si fila % 4 = 0, fila+1 % 4 = 1. esto se ejecuta en el cicloMod1.

	.ciclo:
	;cargo la informacion de 8 pixeles en dos xmm
	;rdi apunta al pixel (src + rdi)

	;pmovsxbw xmm2, xmm0 -> pasa de bytes a words
	;phaddw para sumar los pixeles
	movdqu xmm0, [rdi+rdx-8]	;xmm0 = | rdx+04 | rdx+00 | rdx-04 | rdx-08 |
	movdqu xmm1, [rdi+rdx+8]	;xmm1 = | rdx+20 | rdx+16 | rdx+12 | rdx+08 |
	punpcklwd xmm2, xmm0		;xmm2 = |     rdx-04      |     rdx-08      |
	punpckhwd xmm3, xmm0		;xmm3 = |     rdx+00      |     rdx+04      |
	punpcklwd xmm4, xmm1		;xmm4 = |     rdx+12      |     rdx+08      |
	punpckhwd xmm5, xmm1		;xmm5 = |     rdx+20      |     rdx+16      |



	test rcx, 0x1	;me fijo si estoy en indice % 4 = 1 o 3
	jnp .cicloMod1
	;indiceFila % 4 = 3

	;xmm15 = | rdx+20 | rdx+16 | rdx+12 | rdx+08 |
	xor r11, r11
	lea r11, [rdx+width]
	add r11, 8
	movdqu xmm15, [rdi+r11]
	lea r11, [rdx+width]
	movdqu [rsi+r11], xmm15

	jmp .avanzar

	.cicloMod1:
	;indiceFila % 4 = 1

	;xmm15 = | rdx+04 | rdx+00 | rdx-04 | rdx-08 |
	xor r11, r11
	lea r11, [rdx+width]
	sub r11, 8
	movdqu xmm15, [rdi+r11]
	lea r11, [rdx+width]
	movdqu [rsi+r11], xmm15


	.avanzar:
	add rdx, 16
	cmp rdx, r9
	jl .ciclo	;si rdx >= r9, termine de recorrer la fila y avanzo a la siguiente

	xor rdx, rdx
	lea rdi, [rdi+r8*2]		;avanzo dos lineas
	lea rsi, [rsi+r8*2]		;avanzo dos lineas
	
	inc rcx
	cmp rcx, r10
	je .bordeBlanco		;si rcx = r10, termine de recorrer la imagen

	jmp .ciclo


	.bordeBlanco:
	xor rcx, rcx
	mov rdi, dst
	lea rdi, [rdi+r8]
	mov rsi, dst
	mov rdx, r8
	lea r10, [height-2]
	imul rdx, r10
	lea rsi, [rsi+rdx]
	lea rdx, [rsi+r8]

	.blancoHorizontal:
	mov qword [dst+rcx], 0xFFFFFFFFFFFFFFFF		;dst esta ubicado en la primer linea
	mov qword [rdi+rcx], 0xFFFFFFFFFFFFFFFF		;rdi esta ubicado en la segunda linea
	mov qword [rsi+rcx], 0xFFFFFFFFFFFFFFFF		;rsi esta ubicado en la anteultima linea
	mov qword [rdx+rcx], 0xFFFFFFFFFFFFFFFF		;rdx esta ubicado en la ultima linea
	add rcx, 8
	cmp rcx, r8			;r8 es el ancho en bytes de la fila
	je .blancoVertical
	jmp .blancoHorizontal

	.blancoVertical:
	xor rcx, rcx
	mov r10, height
	imul r10, r8
	lea rdi, [dst+4]
	lea rsi, [dst+r9]
	add rsi, 8
	lea rdx, [rsi+4]

	.loopVertical:
	mov qword [dst+rcx], 0xFFFFFFFFFFFFFFFF		;dst esta ubicado en la primer columna
	mov qword [rsi+rcx], 0xFFFFFFFFFFFFFFFF		;rsi esta ubicado en la anteultima columna
	add rcx, r8
	cmp rcx, r10		;r10 es el alto en bytes de la columna
	je .fin
	jmp .loopVertical

	.fin:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret
