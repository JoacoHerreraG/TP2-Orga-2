section .rodata

    ALIGN 16

    Blanc: times 4 dd 0xFFFF_FFFF      ; Quiza en lugar de esto pueda hacerse 0 - 1, deberia dar FFFFF...  ; No.  No existe operacion decrementar o incrementar.
    Cinco_flot: times 4 dd 0x40a0_0000 ; 5 en formato de coma m'ovil (floating point) de 32 bit, empaquetado para xmm (es decir 4 apariciones).
    ;CincuentaYUno_32bit: times 4 dd 0x0000_0033 ; 51 en formato de entero de 32 bit, empaquetado para xmm (es decir 4 apariciones).
section .data

global Zigzag_asm

section .text

;void Zigzag_c(
;    uint8_t *src,      rdi
;    uint8_t *dst,      rsi
;    int width,         rdx
;    int height,        rcx
;    int src_row_size,  r8
;    int dst_row_size   r9  );

Zigzag_asm:
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

    %define src         rdi
    %define srcFila     r13
    %define dst         rsi
    %define dstFila     r14
    %define dstInval    rbx
    %define anchoBytes  r12
    %define difProxFila r15


    movdqa xmm15, [Blanc]
    pxor xmm14, xmm14
    pinsrq xmm14, [Blanc], 1    ; M'ascara borde izquierdo
    pxor xmm13, xmm13
    pinsrq xmm13, [Blanc], 0    ; M'ascara borde derecho

    pxor xmm12, xmm12           ; Ceros para usar de parte alta en desempaquetamientos.

    movaps xmm11, [Cinco_flot]       ; 5 para usar de divisor,  ingresado directo como comoa m'ovil ('punto flotante')
    ;movdqa xmm11, [CincuentaYUno_32bit]       ; 51 para usar de multiplicador.

    mov srcFila, src      ; srcFila apunta al pixel de imagen original
    mov dstFila, dst      ; dstFila apunta a fila de imagen destino, con Zigzag aplicado.


    mov anchoBytes, rdx       ; ancho en pixeles
    shl anchoBytes, 2         ; ancho en bytes  =  ancho en pixeles * 4 byte
    mov dstInval, anchoBytes
   imul dstInval, rcx         ; cantidad de pixeles  =  ancho en bytes * altura en pixeles
    add dstInval, dst         ; apunta a primera direcci'on inv'alida luego de matriz de destino.

    %define Despl        rcx


    mov difProxFila, anchoBytes
    shl difProxFila, 1           ; Diferencia para saltar de fila se duplica a 2 filas   (van a ser atendidas las pares primeramente, y antes llenar de blanco primeras 2 filas).
    sub dstInval, difProxFila    ; Las ultimas dos filas no nos interesan en los loops.



    ; Se escriben las primeras 2 filas con blanco.
    xor Despl, Despl
    .Filas0y1blancas:
        movdqa [dstFila+Despl], xmm15    ; Se escriben en destino 4 pixeles blancos.
        add Despl, 16                    ; Se avanza Desplazamiento para que en pr'oxima iteracion se levanten siguientes 4 pixeles (siguientes 16 byte).
        cmp Despl, difProxFila           ; Se comprueba si se lleg'o al final de las primeras 2 filas.
        jge .FinFilas0y1blancas
        jmp .Filas0y1blancas
    .FinFilas0y1blancas:




    add srcFila, difProxFila     ; Se incrementa srcFila desde fila 0 a fila 2
    add dstFila, difProxFila     ; Se incrementa dstFila desde fila 0 a fila 2




    ; A filas pares aplicar ''borroneo'' o ''desenfoque'' o ''blur''...



    sub anchoBytes, 16    ; Se achica el ancho de iteraci'on sobre fila, para tratar distinto los 'ultimos 4 p'ixeles (16 byte) que tienen 2 pixeles de marco blanco.


    .BorronearFilaPar:

        xor Despl, Despl                                               ; Se dejan todos los bits de Despl en 0.
        movdqa xmm1, [srcFila]               ; |  3 |  2 |  1 |  0 |   ; Se leen primeros 4 pixeles de la fila.

        ; Desempaquetado primeros 4 pixeles.
        movdqa    xmm2, xmm1
        punpckhbw xmm2, xmm12                ; |       3 |       2 |   ; Se desenpaqueta parte alta de xmm1   sobre xmm2.
        movdqa    xmm1, xmm1
        punpcklbw xmm1, xmm12                ; |       1 |       0 |   ; Se desenpaqueta parte baja de xmm1   sobre xmm1.

        ; Sumas de a pares.
        movdqa xmm5, xmm1
        paddw  xmm5, xmm2                    ; |     3+1 |     2+0 |

        movdqa xmm7, xmm15


        .Borronear4pix:
            movdqa xmm3, [srcFila+Despl+16]  ; |  7 |  6 |  5 |  4 |   ; Se leen los siguientes 4 pixeles.

            ; Desempaquetado siguientes 4 pixeles.
            movdqa    xmm4, xmm3
            punpckhbw xmm4, xmm12            ; |       7 |       6 |   ; Se desenpaqueta parte alta de xmm3   sobre xmm4.
            movdqa    xmm3, xmm3
            punpcklbw xmm3, xmm12            ; |       5 |       4 |   ; Se desenpaqueta parte baja de xmm3   sobre xmm3.

            ; Sumas de a pares.
            movdqa xmm6, xmm2
            paddw  xmm6, xmm3                ; |     5+3 |     4+2 |

            ; Se realizan sumas de a 5 y su divisi'on por 5
            ; para calcular 2do par de pixeles.
            ; Van a ser escritos en memoria en este ciclo,
            ; junto con el 1er par de pixeles que se calcul'o en el ciclo anterior.

            ; Sumas de a 5.
            movdqa xmm8, xmm5                ; |     3+1 |     2+0 |
            psrldq xmm8, 8                   ; |         |     3+1 |
            movdqa xmm9, xmm6                ; |     5+3 |     4+2 |
            pslldq xmm9, 8                   ; |     4+2 |         |
            pblendw xmm8, xmm9, 0xF0         ; |     4+2 |     3+1 |   ; Podr'ia usarse tambi'en:    paddw  xmm8,  xmm9     pero blend debe ser m'as eficiente.
            paddw  xmm8,  xmm6               ; | 5+4+3+2 | 4+3+2+1 |
            paddw  xmm8,  xmm1               ; |5+4+3+2+1|4+3+2+1+0|


            ; Divisi'ones por 5.
            ; No es posible convertir palabras a coma m'ovil (punto flotante),
            ; hay que desempaquetar nuevamente a dobles palabras.

            movdqa xmm10, xmm8               ; |5+4+3+2+1|4+3+2+1+0|
            punpcklwd xmm10, xmm12           ; |   4+3+2+1+0       |
            ;pmulld xmm10, xmm11
            ;psrld xmm10,8
            cvtdq2ps xmm10, xmm10            ; |   4+3+2+1+0       | FP
            divps xmm10, xmm11               ; | ( 4+3+2+1+0 ) / 5 | FP
            cvttps2dq xmm10, xmm10           ; | ( 4+3+2+1+0 ) / 5 |    ; Se convierte coma m'ovil en entero, redondeando con truncamiento
            packusdw xmm10, xmm12            ; |     |(4+3+2+1+0)/5|
            packuswb xmm10, xmm12            ; | | | |(4+3+2+1+0)/5|
            pslldq xmm10, 8                  ; | |(4+3+2+1+0)/5| | |

            psrldq xmm8, 8                   ; |         |5+4+3+2+1|
            punpcklwd xmm8, xmm12            ; |   5+4+3+2+1       |
            ;pmulld xmm8, xmm11
            ;psrld xmm8,8
            cvtdq2ps xmm8, xmm8              ; |   5+4+3+2+1       | FP
            divps xmm8, xmm11                ; | ( 5+4+3+2+1 ) / 5 | FP
            cvttps2dq xmm8, xmm8             ; | ( 5+4+3+2+1 ) / 5 |    ; Se convierte coma m'ovil en entero, redondeando con truncamiento
            packusdw xmm8, xmm12             ; |     |(5+4+3+2+1)/5|
            packuswb xmm8, xmm12             ; | | | |(5+4+3+2+1)/5|
            pslldq xmm8, 12                  ; |(5+4+3+2+1)/5| | | |

            ; El canal alfa de cada uno de los 2 pixeles era FF.
            ; Se sum'o FF 5 veces y luego de dividir por 5 vuelve a ser FF.

            ;paddw xmm10, xmm8               ; |(5+4+3+2+1)/5|(4+3+2+1+0)/5|                   |                   |  ;                          Convertido en comentario, debe ser mejor usar blend.
            pblendw xmm10, xmm8, 0xC0        ; |(5+4+3+2+1)/5|(4+3+2+1+0)/5|                   |                   |
            ;paddw xmm7, xmm10               ; |(5+4+3+2+1)/5|(4+3+2+1+0)/5|calculo ciclo ant 1|calculo ciclo ant 1|  ; Listo para ser guardado, convertido en comentario, debe ser mejor usar blend.
            pblendw xmm7, xmm10, 0xF0        ; |(5+4+3+2+1)/5|(4+3+2+1+0)/5|calculo ciclo ant 1|calculo ciclo ant 1|  ; Listo para ser guardado
            movdqa [dstFila+Despl], xmm7
            pxor xmm7, xmm7




            ; Se realizan sumas de a pares,
            ; sumas de a 5,   y su divisi'on por 5
            ; para calcular 1er par de pixeles.
            ; Van a ser escritos en memoria reci'en en el siguiente ciclo,
            ; junto con el 2do par de pixeles que se calcuar'a al principio del ciclo.

            ; Sumas de a pares.
            movdqa xmm5, xmm3
            paddw  xmm5, xmm4                ; |     7+5 |     6+4 |   ;

            ; Sumas de a 5.
            movdqa xmm8, xmm5                ; |     7+5 |     6+4 |
            pslldq xmm8, 8                   ; |     6+4 |         |
            movdqa xmm9, xmm6                ; |     5+3 |     4+2 |
            psrldq xmm9, 8                   ; |         |     5+3 |
            pblendw xmm8, xmm9, 0x0F         ; |     6+4 |     5+3 |   ; Podr'ia usarse tambi'en:    paddw  xmm8,  xmm9     pero blend debe ser m'as eficiente.
            paddw  xmm8,  xmm5               ; | 7+6+5+4 | 6+5+4+3 |
            paddw  xmm8,  xmm2               ; |7+6+5+4+3|6+5+4+3+2|


            ; Divisi'ones por 5.
            ; No es posible convertir palabras a coma m'ovil (punto flotante),
            ; hay que desempaquetar nuevamente a dobles palabras.

            movdqa xmm10, xmm8               ; |7+6+5+4+3|6+5+4+3+2|
            punpcklwd xmm10, xmm12           ; |   6+5+4+3+2       |
            ;pmulld xmm10, xmm11
            ;psrld xmm10,8
            cvtdq2ps xmm10, xmm10            ; |   6+5+4+3+2       | FP
            divps xmm10, xmm11               ; | ( 6+5+4+3+2 ) / 5 | FP
            cvttps2dq xmm10, xmm10           ; | ( 6+5+4+3+2 ) / 5 |    ; Se convierte coma m'ovil en entero, redondeando con truncamiento
            packusdw xmm10, xmm12            ; |     |(6+5+4+3+2)/5|
            packuswb xmm10, xmm12            ; | | | |(6+5+4+3+2)/5|
            ;pslldq xmm10, 0                 ; | | | |(6+5+4+3+2)/5|   ; No hace falta shiftear, ya est'a en lugar.

            psrldq xmm8, 8                   ; |         |7+6+5+4+3|
            punpcklwd xmm8, xmm12            ; |   7+6+5+4+3       |
            ;pmulld xmm8, xmm11
            ;psrld xmm8,8
            cvtdq2ps xmm8, xmm8              ; |   7+6+5+4+3       | FP
            divps xmm8, xmm11                ; | ( 7+6+5+4+3 ) / 5 | FP
            cvttps2dq xmm8, xmm8             ; | ( 7+6+5+4+3 ) / 5 |    ; Se convierte coma m'ovil en entero, redondeando con truncamiento
            packusdw xmm8, xmm12             ; |     |(7+6+5+4+3)/5|
            packuswb xmm8, xmm12             ; | | | |(7+6+5+4+3)/5|
            pslldq xmm8, 4                   ; | | |(7+6+5+4+3)/5| |

            ; El canal alfa de cada uno de los 2 pixeles era FF.
            ; Se sum'o FF 5 veces y luego de dividir por 5 vuelve a ser FF.

            paddw xmm10, xmm8                ; | | |(7+6+5+4+3)/5|(6+5+4+3+2)/5|  ;   REEMPLAZAR POR   BLEND  ?   DEBE SER MAS RAPIDO  (EVITA LA ALU)..
            movdqa xmm7, xmm10               ; | | |(7+6+5+4+3)/5|(6+5+4+3+2)/5|


            ; Movemos los segundos pixeles que hab'iamos desempaquetado
            ; para que sean tratados como 'primeros pixeles desempaquetados' en siguiente iteraci'on.
            movdqa xmm2, xmm4                ; |       7 |       6 |
            movdqa xmm1, xmm3                ; |       5 |       4 |

            add Despl, 16                    ; Se avanza Desplazamiento para que en pr'oxima iteracion se levanten siguientes 4 pixeles (siguientes 16 byte).
            cmp anchoBytes, Despl            ; Se comprueba si se lleg'o al final de la fila.
            jle .FinBorronear4pix
            jmp .Borronear4pix
        .FinBorronear4pix:

        ; Se escriben 'ultimos 4 pixeles de la fila incluyendo 2 pixeles del marco blanco.
        pblendw xmm10, xmm15, 0xF0        ; | FF FF FF FF | FF FF FF FF |(7+6+5+4+3)/5|(6+5+4+3+2)/5|
        movdqa [dstFila+Despl], xmm10

        add dstFila, difProxFila        ; Se incrementa dstFila a siguiente fila cong a 2 o 0 en m'odulo 4.
        cmp dstFila, dstInval           ; Se comprueba si se lleg'o a ultima fila.
        jge .FinBorronear
        add srcFila, difProxFila        ; Se incrementa srcFila a siguiente fila cong a 2 o 0 en m'odulo 4
        jmp .BorronearFilaPar
    .FinBorronear:




    add anchoBytes, 16                   ; Se restaura el ancho de imagen en bytes a su valor correcto.


    ; Se escriben las 'ultimas 2 filas con blanco.
    xor Despl, Despl
    .Filas2ultBlancas:
        movdqa [dstFila+Despl], xmm15    ; Se escriben en destino 4 pixeles blancos.
        add Despl, 16                    ; Se avanza Desplazamiento para que en pr'oxima iteracion se levanten siguientes 4 pixeles (siguientes 16 byte).
        cmp Despl, difProxFila           ; Se comprueba si se lleg'o al final de las primeras 2 filas.
        jge .FinFilas2ultBlancas
        jmp .Filas2ultBlancas
    .FinFilas2ultBlancas:



    shl difProxFila, 1   ; Diferencia para saltar filas se duplica a 4 filas.




    ; Filas cong a 1 en modulo 4.; Se desplazan p'ixeles 2 posiciones a derecha.
    mov srcFila, src
    add srcFila, difProxFila     ; Se mueve srcFila 4 filas m'as adelante.
    add srcFila, anchoBytes      ; Se mueve srcFila 1 fila  m'as adelante quedando cong a 1 en m'odulo 4.
    mov dstFila, dst
    add dstFila, difProxFila     ; Se mueve dstFila 4 filas m'as adelante.
    add dstFila, anchoBytes      ; Se mueve dstFila 1 fila  m'as adelante quedando cong a 1 en m'odulo 4.
    movdqa xmm1, [srcFila]       ; Se leen primeros 4 pixeles de primera fila.

    sub anchoBytes, 16           ; Se achica el ancho de iteraci'on sobre fila, para tratar distinto los 'ultimos 4 p'ixeles (16 byte) que tienen 2 pixeles de marco blanco.

    mov Despl, 16
    .DesplDerFilaMod1:

        ;Se completan los primeros 4 pixeles de la fila con 2 pixeles blancos
        movdqa xmm2, xmm1
        pslldq xmm2, 8
        pblendw xmm2, xmm15, 0x0F
        movdqa [dstFila], xmm2


        .DesplDer4pix:
            movdqa xmm2, [srcFila+Despl]     ; Se leen los siguientes 4 pixeles.
            ; Se combina informaci'on de 8 pixeles de src
            ; generando 4 a escribir en dst.
            movdqa xmm3, xmm2
            pslldq xmm3, 8                   ; Se desplaza xmm3 8 bytes (64 bit) hacia izquierda (interesan 64 bit bajos, que ahora quedan altos).
            psrldq xmm1, 8                   ; Se desplaza xmm1 8 bytes (64 bit) hacia derecha   (interesan 64 bit altos, que ahora quedan bajos).
            pblendw xmm1, xmm3, 0xF0         ; Se mantiene la parte baja de xmm1 y se toma la alta baja de xmm3.
            movdqa [dstFila+Despl], xmm1     ; Se escriben en destino 4 pixeles.    El resultado es que quedan desplazados 2 posiciones a derecha.
            movdqa xmm1, xmm2                ; Se mueven los 4 ultimos pixeles de src desde xmm2 a xmm1 y se van a levantar en siguiente iteracion sobre xmm2 los siguentes 4 pixeles.
            add Despl, 16                    ; Se avanza Desplazamiento para que en pr'oxima iteracion se levanten siguientes 4 pixeles (siguientes 16 byte).
            cmp Despl, anchoBytes            ; Se comprueba si se lleg'o al final-16 de la fila.
            jge .FinDesplDer4pix
            jmp .DesplDer4pix
        .FinDesplDer4pix:

        ; Se escriben 'ultimos 4 pixeles de la fila incluyendo 2 pixeles del marco blanco.
        psrldq xmm1, 8                   ; Se desplaza xmm1 8 bytes (64 bit) hacia derecha   (interesan 64 bit altos, que ahora quedan bajos).
        pblendw xmm1, xmm15, 0xF0        ; | FF FF FF FF | FF FF FF FF |(pixel despl)|(pixel despl)|
        movdqa [dstFila+Despl], xmm1

        add dstFila, difProxFila ; Se incrementa dstFila a siguiente fila cong a 1 en m'odulo 4.
        cmp dstFila, dstInval    ; Se comprueba si se lleg'o a ultima fila.
        jge .FinDesplDer
        add srcFila, difProxFila ; Se incrementa srcFila a siguiente fila cong a 1 en m'odulo 4.
        movdqa xmm1, [srcFila]   ; Se levantan primeros 4 p'ixeles de pr'oxima fila.
        mov Despl, 16
        jmp .DesplDerFilaMod1
    .FinDesplDer:

    add anchoBytes, 16           ; Se restaura el ancho de imagen en bytes a su valor correcto.




    ; Filas cong a 3 en modulo 4.; Se desplazan p'ixeles 2 posiciones a izqierda.
    mov srcFila, src
    add srcFila, anchoBytes      ; Se mueve srcFila 1 fila  m'as adelante
    add srcFila, anchoBytes      ; Se mueve srcFila 1 fila  m'as adelante
    add srcFila, anchoBytes      ; Se mueve srcFila 1 fila  m'as adelante quedando cong a 3 en m'odulo 4.
    mov dstFila, dst
    add dstFila, anchoBytes      ; Se mueve dstFila 1 fila  m'as adelante
    add dstFila, anchoBytes      ; Se mueve dstFila 1 fila  m'as adelante
    add dstFila, anchoBytes      ; Se mueve dstFila 1 fila  m'as adelante quedando cong a 3 en m'odulo 4.

    sub anchoBytes, 16           ; Se achica el ancho de iteraci'on sobre fila, para tratar distinto los 'ultimos 4 p'ixeles (16 byte) que tienen 2 pixeles de marco blanco.

    xor Despl, Despl             ; Se dejan todos los bits de Despl en 0.
    ;movdqa xmm1, xmm15          ; Se leen primeros 4 p'ixeles de primera fila. ; No hace falta ''movdqa xmm1, [srcFila]'' porque se tapa con columnas blancas.
    .DesplIzqFilaMod3:
        .DesplIzq4pix:
            movdqa xmm2, [srcFila+Despl+16] ; Se leen los siguientes 4 p'ixeles.
            ; Se combina informaci'on de 8 pixeles de src
            ; generando 4 a escribir en dst.
            movdqa xmm3, xmm2
            pslldq xmm3, 8                   ; Se desplaza xmm3 8 bytes (64 bit) hacia izquierda (interesan 64 bit bajos, que ahora quedan altos).
            psrldq xmm1, 8                   ; Se desplaza xmm1 8 bytes (64 bit) hacia derecha   (interesan 64 bit altos, que ahora quedan bajos).
            pblendw xmm1, xmm3, 0xF0         ; Se mantiene la parte baja de xmm1 y se toma la parte alta de xmm3.
            movdqa [dstFila+Despl], xmm1     ; Se escriben en destino 4 pixeles.    El resultado es que quedan desplazados 2 posiciones a izquierda.
            movdqa xmm1, xmm2                ; Se mueven los 4 ultimos pixeles de src desde xmm2 a xmm1, y se van a levantar en siguiente iteracion sobre xmm2 los siguentes 4 pixeles.
            add Despl, 16                    ; Se avanza Desplazamiento para que en proxima iteraci'on se levanten siguientes 4 p'ixeles (siguientes 16 byte).
            cmp Despl, anchoBytes            ; Se comprueba si se lleg'o al final-16 de la fila.
            jge .FinDesplIzq4pix
            jmp .DesplIzq4pix
        .FinDesplIzq4pix:

        ; Se escriben 'ultimos 4 pixeles (16 byte) de la fila incluyendo 2 pixeles del marco blanco.
        psrldq xmm1, 8                  ; Se desplaza xmm1 8 bytes (64 bit) hacia derecha   (interesan 64 bit altos, que ahora quedan bajos).
        pblendw xmm1, xmm15, 0xF0       ; | FF FF FF FF | FF FF FF FF |(pixel despl)|(pixel despl)|
        movdqa [dstFila+Despl], xmm1

        add dstFila, difProxFila ; Se incrementa dstFila a siguiente fila cong a 3 en m'odulo 4.
        cmp dstFila, dstInval    ; Se comprueba si se lleg'o a ultima fila.
        jge .FinDesplIzq
        add srcFila, difProxFila ; Se incrementa srcFila a siguiente fila cong a 3 en m'odulo 4.
        xor Despl, Despl         ; Se dejan todos los bits de Despl en 0.
        ;movdqa xmm1, [srcFila]   ; Se levantan primeros 4 pixeles de pr'oxima fila. ; No hace falta porque los 2 que supuestamente sobrevivirian el desplazamiento son tapados con marco blanco.
        jmp .DesplIzqFilaMod3
    .FinDesplIzq:



    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 8

    pop rbp
ret
