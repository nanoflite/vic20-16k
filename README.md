# CC65 ld65 configurations for the VIC20+16K

I'm trying to figure out how to create a VIC20 program with `ca65` that can run on a VIC20 + 16K expansion.

The memory layout would be something like:
  * 0x1200: BASIC START LINE
  * 0x2000: PROGRAM

I'm trying to create this with result the `ld65` linker, but have had no success...

## The program

Just a simple 'Hello' program....

I'm using 2 segments here BASIC and CODE.

```
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

text:
  .asciiz "HELLO"
```

Compile to `main.o`:

```
ca65 -I.  --cpu 6502 main.s

```


## Unexpanded VIC20 configuration

``` 
FEATURES {
    STARTADDRESS: default = $11FF;
}

MEMORY {
    ZP:    start = $0000, size = $0100, type = rw;
    RAM0:  start = $0400, size = $0C00, type = rw;
    RAM:   start = $11FF, size = $0E00, type = rw;
    RAM1:  start = $2000, size = $4000, type = rw;
}

SEGMENTS {
    ZEROPAGE: load = ZP,   type = zp,  optional = yes;
    BASIC:    load = RAM,  type = rw,  optional = no ;
    CODE:     load = RAM,  type = rw,  optional = yes;
    DATA:     load = RAM,  type = rw,  optional = yes;
    BSS:      load = RAM,  type = bss, optional = yes;
}

```

All segments are in RAM.

Link:

```
ld65  -Ln hello-1.lbl -m hello-1.map -C vic20-16k-asm-1.cfg -o hello-1.prg main.o

```

Result:

```
00000000: 0112 0b12 e407 9e34 3632 3100 0000 a200  .......4621.....
00000010: bd1c 12f0 0720 d2ff e818 90f4 6048 454c  ..... ......`HEL
00000020: 4c4f 00                                  LO.
```

## Expanded VIC20 (16K) configuration

```
FEATURES {
    STARTADDRESS: default = $11FF;
}

MEMORY {
    ZP:    start = $0000, size = $0100, type = rw;
    RAM0:  start = $0400, size = $0C00, type = rw;
    RAM:   start = $11FF, size = $0E00, type = rw;
    RAM1:  start = $2000, size = $4000, type = rw;
}

SEGMENTS {
    ZEROPAGE: load = ZP,   type = zp,  optional = yes;
    BASIC:    load = RAM,  type = rw,  optional = no ;
    CODE:     load = RAM1, type = rw,  optional = yes;
    DATA:     load = RAM1, type = rw,  optional = yes;
    BSS:      load = RAM1, type = bss, optional = yes;
}
```

BASIC segment is in RAM, CODE segment is in RAM1.

Link:

```
ld65  -Ln hello-1.lbl -m hello-1.map -C vic20-16k-asm-2.cfg -o hello-2.prg main.o
```

Result:

```
00000000: 0112 0b12 e407 9e38 3139 3200 0000 a200  .......8192.....
00000010: bd0f 20f0 0720 d2ff e818 90f4 6048 454c  .. .. ......`HEL
00000020: 4c4f 00                                  LO.
```

The result is the same... I had hoped that the linker would grow the program so that the code in the 'CODE' segment would live at location 0x2000.

```
00000000: 0112 0b12 e407 9e38 3139 3200 0000 0000
00000010: 0000 0000 0000 0000 0000 0000 0000 0000
...
xxxxxxxx: a200 bd0f 20f0 0720 d2ff e818 90f4 454c   <<-- Pointing at 0x02000
...
```

## Question

Why is this not the case and how do I solve this?

Thank you!
Johan
