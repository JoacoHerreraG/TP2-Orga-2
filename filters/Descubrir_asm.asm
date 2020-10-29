section .rodata

    ALIGN 16

    mask_bitsRGB1y0: times 4 dd 0x0003_0303

    mask_BN2: times 4 dd 0x0000_0008
    mask_BN3: times 4 dd 0x0000_0800
    mask_BN4: times 4 dd 0x0008_0000
    mask_BN5: times 4 dd 0x0000_0004
    mask_BN6: times 4 dd 0x0000_0400
    mask_BN7: times 4 dd 0x0004_0000

    mask_bitsFF: times 4 dd 0xFF00_0000

    pshufb_a_gris1: dq 0x0F_0C_0C_0C_0F_08_08_08
    pshufb_a_gris0: dq 0x0F_04_04_04_0F_00_00_00

section .data
    global Descubrir_asm

section .text

;void Descubrir_c(
;    uint8_t *src,      rdi
;    uint8_t *dst,      rsi
;    int width,         rdx
;    int height,        rcx
;    int src_row_size,  r8
;    int dst_row_size   r9  );

Descubrir_asm:
    push rbp
    mov rbp, rsp

    ; Como no llamamos a funciones de C System V,
    ; en lugar de armar marco en pila (stackframe)
    ; se podr'ian usar variables que no nos importa si se conservan o no...

    push rbx
    push r12
    push r13
    push r14

    %define src r13
    %define dst r14
    %define src_Espejo r12

    mov src, rdi    ; src  apunta al pixel           de la imagen original con imagen oculta.
    mov dst, rsi    ; dst  apunta al pixel           de la imagen destino final con imagen que estaba oculta, desocultada.

    mov rbx, rdx
    imul rbx, rcx  ; En rbx se van a contar los p'ixeles que restan ser procesados.

    ; Cada iteraci'on el cuerpo del ciclo procesa 4 p'ixeles (128 bit) a la vez.

    ; Se calcula la direccion de los 'ultimos 128 bits de la imagen.
    mov src_Espejo, rbx    ; Cantidad de pixeles
    shl src_Espejo, 2      ; Cantidad de bytes ocupados = cantidad de pixeles * 4 byte
    sub src_Espejo, 16     ; Se retrocede 4 pixeles (16 byte) para apuntar a los 'ultimos 4 pixeles.
    add src_Espejo, src    ; src_Espejo apunta al pixel especular de la imagen original que queda visible.

    ; Se preparan las m'ascaras y
    ; patrones de reordenamiento (o de shuffle).

    movdqa xmm9, [mask_bitsRGB1y0]

    movdqa xmm10, [mask_BN2]
    movdqa xmm11, [mask_BN3]
    movdqa xmm12, [mask_BN4]
    movdqa xmm13, [mask_BN5]
    movdqa xmm14, [mask_BN6]
    movdqa xmm15, [mask_BN7]

    movdqa xmm7, [mask_bitsFF]

    pinsrq xmm8, [pshufb_a_gris1], 1
    pinsrq xmm8, [pshufb_a_gris0], 0

    .ciclo:

        ; Se traen 4 pixeles desde src y sus correspondientes 4 pixeles especulares para XORear entre bits espec'ificos.

          movdqa xmm1, [src]           ; Se traen 4 pixeles desde src.
          pand xmm1, xmm9              ; Se extraen los bits 1 y 0 de cada byte RGB.
          pslld xmm1, 2                ; Se desplaza 2 bit a izquierda.
          movdqa xmm2, [src_Espejo]    ; Se traen los 4 correspondientes pixeles especulares desde src.
          pshufd xmm2, xmm2, 27        ; Reordenamiento (o shuffle) de xmm2 con valor inmediato 27 para espejar 4 dobles palabras.    0 1 2 3  =  0001 1011  =  0x1B  =  27
          pxor xmm2, xmm1              ; En xmm2 quedan 4 veces 6 bit de un pixel de la imagen en blanco y negro oculta,   particularmente en los bits 3 y 2 de los byte R, G y B.

        ; Se extraen uno a uno los 6 bit de la imagen en blanco y negro oculta.

          movdqa xmm3, xmm10           ; mask_BN2
          pand xmm3, xmm2
          pslld xmm3, 1
          movdqa xmm4, xmm3            ; Primer bit 'descubierto' se pasa con 'movdqa' sobre xmm4 para pisar la basura preexistente. Los pr'oximos bits descubiertos son combinados sobre xmm4 con 'por'.

          movdqa xmm3, xmm11           ; mask_BN3
          pand xmm3, xmm2
          psrld xmm3, 8
          por xmm4, xmm3

          movdqa xmm3, xmm12           ; mask_BN4
          pand xmm3, xmm2
          psrld xmm3, 17
          por xmm4, xmm3

          movdqa xmm3, xmm13           ; mask_BN5
          pand xmm3, xmm2
          pslld xmm3, 5
          por xmm4, xmm3

          movdqa xmm3, xmm14           ; mask_BN6
          pand xmm3, xmm2
          psrld xmm3, 4
          por xmm4, xmm3

          movdqa xmm3, xmm15           ; mask_BN7
          pand xmm3, xmm2
          psrld xmm3, 13
          por xmm4, xmm3

        ; Se escribe FF en bytes A.
          por xmm4, xmm7

        ; Se replica lo calculado en byte G sobre bytes B y R (para obtener gris, no verde).
          pshufb xmm4, xmm8

        ; Se guarda en destino
          movdqa [dst], xmm4

        add dst, 16        ; Se avanza     128 bit el puntero a                       la imagen destino final procesada.
        add src, 16        ; Se avanza     128 bit el puntero a                       la imagen visible
        sub src_Espejo, 16 ; Se decrementa 128 bit el puntero a la parte especular de la imagen visible.
        sub rbx, 4
        cmp rbx, 0
        jle .finCiclo
        jmp .ciclo
    .finCiclo:


    pop r14
    pop r13
    pop r12
    pop rbx

    pop rbp
ret
