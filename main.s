; vim: set syntax=asm_ca65:

  .debuginfo +

  .segment "BASIC"
 
        .word load
load:   .word @end
        .word 2020
        .byte $9e
        .byte .lobyte(main/1000 .mod 10) + $30
        .byte .lobyte(main/100 .mod 10) + $30
        .byte .lobyte(main/10 .mod 10) + $30
        .byte .lobyte(main/1 .mod 10) + $30
        .byte 0 
@end:   .word 0  

  .segment "CODE"

main:   ldx #0
:       lda text,x
        beq end
        jsr $ffd2
        inx
        clc
        bcc :-
end:    rts

text:   .asciiz "HELLO"
