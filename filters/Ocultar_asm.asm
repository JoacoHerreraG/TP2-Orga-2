section .rodata

    ALIGN 16

    mask_G3: times 4 dd 0x0000_0008
    mask_G2: times 4 dd 0x0000_0040

    mask_B3: times 4 dd 0x0000_0010
    mask_B2: times 4 dd 0x0000_0080

    mask_R3: times 4 dd 0x0000_0004
    mask_R2: times 4 dd 0x0000_0020

    pshufb_suma01: dq 0x80_0D_80_0C_80_09_80_08
    pshufb_suma00: dq 0x80_05_80_04_80_01_80_00

    pshufb_suma11: dq 0x80_0D_80_0E_80_09_80_0A
    pshufb_suma10: dq 0x80_05_80_06_80_01_80_02



    pshufb_debug_gris_0: dq 0x80_05_80_06_80_01_80_02
    pshufb_debug_gris_1: dq 0x80_05_80_06_80_01_80_02

;    mask_dw2: dq 0x0000_0000_FFFF_FFFF   ; m'as adelante levantamos esta quadrupalabra (q) y la shifteamos 4 bytes a izqierda para generar dobre cuadrupalabra (dq) 0x0000_0000_FFFF_FFFF_0000_0000_0000_0000
              ;dq 0x0000_0000_0000_0000  ; MERJORAR:  Levantar doblecu'adruplepalabra directamente

;    mask_dw1: dq 0xFFFF_FFFF_0000_0000    ; ddq 0x0000_0000_0000_0000_FFFF_FFFF_0000_0000       ; Se levanta a registro xmm de 128 bit y los 64 bit superiores se van a completar con ceros.

    mask_RGB_6bit_sup: dq 0xFFFC_FCFC_FFFC_FCFC
                       dq 0xFFFC_FCFC_FFFC_FCFC

    mask_RGB_bits3y2: dq 0x000C_0C0C_000C_0C0C
                      dq 0x000C_0C0C_000C_0C0C




section .data

    global Ocultar_asm

section .text

; void Ocultar_asm( uint8_t *src,      rdi
;                   uint8_t *src2,     rsi
;                   uint8_t *dst,      rdx
;                   int width,         rcx
;                   int height,        r8
;                   int src_row_size,  r9
;                   int dst_row_size   [rbp+16]  (pasado por pila)    );

Ocultar_asm:
    push rbp
    mov rbp, rsp

    ; Como no llamamos a funciones de C System V,
    ; en lugar de armar marco en pila (stackframe)
    ; se podr'ian usar variables que no nos importa si se conservan o no...

    sub rsp, 8
    push rbx
    push r12
    push r13
    push r14
    push r15

    %define src  r13
    %define src2 r15
    %define dst r14
    %define src_Espejo r12

    mov src,  rdi    ; src  apunta al pixel           de la imagen original que queda visible.
    mov dst,  rdx    ; dst  apunta al pixel           de la imagen destino final procesada
    mov src2, rsi    ; src2 apunta al pixel           de la imagen a ser ocultada

    mov rbx, rcx
   imul rbx, r8  ; En rbx se van a contar los p'ixeles que restan ser procesados.

    ; En cada iteraci'on el cuerpo del ciclo procesa 4 p'ixeles (128 bit) a la vez.

    ; Se calcula la direccion de los 'ultimos 128 bits de la imagen.
    mov src_Espejo, 4      ; Cada pixel ocupa 4 byte
   imul src_Espejo, rbx    ; 4 byte  *  cantidad de pixeles  =  cantidad de bytes ocupados
    sub src_Espejo, 16     ; Se retrocede 4 pixeles (16 byte) para apuntar a los 'ultimos 4 pixeles.
    add src_Espejo, src    ; src_Espejo apunta al pixel especular de la imagen original que queda visible.


    ; Se preparan las m'ascaras

    movdqa xmm6,  [mask_RGB_bits3y2]

    movdqa xmm7,  [mask_G3]
    movdqa xmm8,  [mask_G2]

    movdqa xmm9,  [mask_B3]
    movdqa xmm10, [mask_B2]

    movdqa xmm11, [mask_R3]
    movdqa xmm12, [mask_R2]

    pinsrq xmm13, [pshufb_suma01], 1
    pinsrq xmm13, [pshufb_suma00], 0

    pinsrq xmm14, [pshufb_suma11], 1
    pinsrq xmm14, [pshufb_suma10], 0

;   movq xmm13, [mask_dw2]
;   pslldq xmm13, 8     ; MERJORAR:  Levantar doblecu'adruplepalabra directamente en lugar de shiftear.

    movdqa xmm15, [mask_RGB_6bit_sup]


    .ciclo:
        movdqa xmm0, [src2]  ;|  A  |  R   |  G  |  B  |  ...  ; Se bajan a xmm0 16 bytes (4 p'ixeles) de la imagen a ocultar, desde memoria alineada.
        movdqa xmm1, xmm0

        ; Para calcular B+2G+R se va primero
        ; reordenar para poder sumar de a palabras (de 16 bit)
        ; y no perder los acarreos (carrys).

        ;pshufb_suma01: dq 0x80_0D_80_0C_80_09_80_08
        ;pshufb_suma00: dq 0x80_05_80_04_80_01_80_00
        pshufb xmm0, xmm13  ;|        G   |        B  |  ...  ; Se reordenan bytes de xmm0 mediante instrucci'on pshufb.

        ;pshufb_suma11: dq 0x80_0D_80_0E_80_09_80_0A
        ;pshufb_suma10: dq 0x80_05_80_06_80_01_80_02
        pshufb xmm1, xmm14  ;|        G   |        R  |  ...  ; Se reordenan bytes de xmm1 mediante instrucci'on pshufb (un Blend podr'ia ser m'as ediciente me parece).

        paddusw xmm1, xmm0  ;|      2*G   |      B+R  |  ...  ; Se suman palabras en xmm1 y xmm0 dejando resultado en xmm1. ; Si se quiere saturar se usa paddusb. ; Si no se quiere saturar se usa paddb.
        movdqa xmm2, xmm1                                     ; Se copia xmm1 sobre xmm2.
        psrld xmm2, 16      ;|        ?   |      2*G  |  ...  ; Se desplazan las dobles palabras en xmm2 16 bit hacia derecha en modo l'ogico.
        paddusw xmm2, xmm1; ;|        ?   |  B+2*G+R  |  ...  ; Se suman palabras en xmm2 y xmm1 dejando resultado en xmm2. ; Si se quiere saturar se usa paddusb. ; Si no se quiere saturar se usa paddb.

        psrlw xmm2, 2       ;|        ?  |  (B+2G+R)/4|  ...  ; Desplazando hacia derecha 2 bit se divide por 4. El resto de divisi'on queda truncado.



        ; Para debuguear que salga bien la imagen en gris: ....
        ; pshufb xmm2, xmm14  ;|  00  |B+2G+R/4|B+2G+R/4|B+2G+R/4|  ...  ; Imagen en gris solo para debuguear.


        ; Para debuguear:  si se quiere chequear que funcione bien el espejo   descomentar esta instrucci'on   y   encomentar todo lo que sigue.
        ; movdqa [dst], xmm2






        ; Se calcul'o el byte con el color de gris
        ; para 4 p'ixeles seguidos.

        ; Se usan mascaras para extraer 6 bit cada uno por separado

        movdqa xmm3, xmm7       ; 0x0000_0008  (x4 veces) ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 3 del byte verde del pixel especular).
        pand xmm3, xmm2
        pslld xmm3, 8
        movdqa xmm4, xmm3       ; Primer bit a ocultar se pasa con 'movdqa' a xmm4 para pisar la basura preexistente. Los pr'oximos bits son combinados sobre xmm4 con 'por'.

        movdqa xmm3, xmm8       ; 0x0000_0040  (x4 veces)  ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 2 del byte verde del pixel especular).
        pand xmm3, xmm2
        pslld xmm3, 4
        por xmm4, xmm3

        movdqa xmm3, xmm9       ; 0x0000_0010  (x4 veces)  ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 3 del byte azul  del pixel especular).
        pand xmm3, xmm2
        psrld xmm3, 1
        por xmm4, xmm3

        movdqa xmm3, xmm10       ; 0x0000_0080  (x4 veces)  ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 2 del byte azul  del pixel especular).
        pand xmm3, xmm2
        psrld xmm3, 5
        por xmm4, xmm3

        movdqa xmm3, xmm11       ; 0x0000_0004  (x4 veces)  ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 3 del byte rojo  del pixel especular).
        pand xmm3, xmm2
        pslld xmm3, 17
        por xmm4, xmm3

        movdqa xmm3, xmm12       ; 0x0000_0020  (x4 veces)  ; M'ascara para filtrar pixel (a ser comparado luego mediante 'o exclusivo' con bit 2 del byte rojo  del pixel especular).
        pand xmm3, xmm2
        pslld xmm3, 13
        por xmm4, xmm3

        ;pand xmm4, xmm6          ; 0x000C_0C0C  (x4 veces)  ; M'ascara para filtrar bits 3 y 2.   No hace falta se supone que es todo lo que hay.

        ; En xmm4 ya est'an todos los bits ''grises'' reubicados en bits 3 y dos de cada Byte RGB.
        ; Falta traer los 4 p'ixeles especulares, reordenar los mismos para XORearlos con xmm4.


        movdqa xmm3, [src_Espejo]     ; 4 pixeles especulares. Se encuentran en orden inverso.

        ; Se reordenan los p'ixeles especulares de xmm3 que vinieron en orden inverso
        ; mediante shifts y ORs, dej'andolos reordenados en xmm0.

        pshufd xmm3, xmm3, 27        ; Reordenamiento (o shuffle) de xmm3 con inmediato 27 para espejar 4 dobles palabras.    0 1 2 3  =  0001 1011  =  0x1B  =  27

         ;movdqa [dst], xmm3 ; Para debuguear:  si se quiere chequear que funcione bien el espejo   descomentar esta instrucci'on   y   encomentar todo lo que sigue.

        ;             Todo lo que sigue es lo mismo que hace     pshufd xmm3, xmm3, 27   pero en varias instrucciones y con m'ascaras,   antes de conocer esa instrucci'on.
        ;             De todas formas el c'odigo podr'ia ser usado para experimentos y ver qu'e es màs r'apido...    si PSHUFD o la lista larga de instucciones.

        ;                movdqa xmm5, xmm3
        ;                pslldq xmm5, 12          ; Desplazamiento de 12 byte (96 bit) hacia izquierda.
        ;                movdqa xmm0, xmm5        ; El dw xmm3[0] queda en dw xmm0[3].

        ;                movdqa xmm5, xmm3
        ;                psrldq xmm5, 12          ; Desplazamiento de 12 byte (96 bit) hacia derecha.
        ;                por xmm0, xmm5           ; El dw xmm3[3] queda en dw xmm0[0],  sin pisar xmm0[3].

        ;                movdqa xmm5, xmm3
        ;                pslldq xmm5, 4           ; Desplazamiento de 4 byte (32 bit) hacia izquierda
        ;                pand xmm5, xmm13         ; M'ascara para filtrar doble palabra (dw) 2.
        ;                por xmm0, xmm5           ; El dw xmm3[1] queda en dw xmm0[2],  sin pisar xmm0[0] ni xmm0[3].

        ;                movdqa xmm5, xmm3
        ;                psrldq xmm5, 4           ; Desplazamiento de 4 byte (32 bit) hacia derecha.
        ;                pand xmm5, xmm14         ; M'ascara para filtrar doble palabra (dw) 1.
        ;                por xmm0, xmm5           ; El dw xmm3[2] queda en dw xmm0[1],  sin pisar xmm0[0], ni xmm0[2], ni xmm0[3].

        ;                movdqa [dst], xmm0 ; Para debuguear si se quiere chequear que funcione bien el espejo,   descomentar esta instrucci'on y encomentar todo lo que sigue

        ; pand xmm3, xmm6        ; 0x000C_0C0C  (x4 veces)  ; M'ascara para filtrar bits 3 y 2.

        pxor xmm3, xmm4          ; XOR   de los bits 3 y 2   de los bytes RGB

        pand xmm3, xmm6          ; 0x000C_0C0C  (x4 veces)  ; M'ascara para filtrar bits 3 y 2.

        psrld xmm3, 2            ; Bits de informaci'on a ocultar ya se encuentran ubicados en los 'ultimos 2 bit de cada byte RGB, en su lugar final.

        movdqa xmm0, [src]       ; Se traen 4 pixeles de la imagen visible ''debajo'' de la cual se van a ocultar.
        pand xmm0, xmm15         ; 0xFFFC_FCFC  (x4 veces)  ; M'ascara para filtrar los 6 bit superiores de cada byte RGB

        por xmm0, xmm3           ; Se combinan 6 bit superiores de cada byte RGB de imagen visible,    con 2 bit inferiores de cada byte RGB con informaci'on de imagen en escala de grises oculta.

        movdqa [dst], xmm0

        add src2, 16       ; Se avanza     128 bit el puntero a                       la imagen a ser ocultada.
        add dst, 16        ; Se avanza     128 bit el puntero a                       la imagen destino final procesada.
        add src, 16        ; Se avanza     128 bit el puntero a                       la imagen visible
        sub src_Espejo, 16 ; Se decrementa 128 bit el puntero a la parte especular de la imagen visible.
        sub rbx, 4
        cmp rbx, 0
        jle .finCiclo
        jmp .ciclo
    .finCiclo:

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 8

    pop rbp
ret
