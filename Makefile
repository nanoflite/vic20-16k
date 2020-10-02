ASRCS := main.s
NAME := hello
PRG1 := $(NAME)-1.prg
PRG2 := $(NAME)-2.prg
PRG3 := $(NAME)-3.prg

OBJS = $(ASRCS:.s=.o)

AS := ca65 -I.
CC := cc65
LD := ld65 

VIC := xvic -memory 16k
CPU := 6502
CFG1 := vic20-16k-asm-1.cfg
CFG2 := vic20-16k-asm-2.cfg
CFG3 := vic20-16k-asm-3.cfg

.PHONY: all run1 run2 run3 debug1 debug2 debug3 dump1 dump2 dump3 clean

all: $(PRG1) $(PRG2) $(PRG3)

$(PRG1): $(OBJS) $(CFG1)
	$(LD) -Ln $(NAME)-1.lbl -m $(NAME)-1.map -C $(CFG1) -o $(PRG1) $(OBJS)

$(PRG2): $(OBJS) $(CFG2)
	$(LD) -Ln $(NAME)-2.lbl -m $(NAME)-2.map -C $(CFG2) -o $(PRG2) $(OBJS)

$(PRG3): $(OBJS) $(CFG3)
	$(LD) -Ln $(NAME)-3.lbl -m $(NAME)-3.map -C $(CFG3) -o $(PRG3) $(OBJS)

run1: all
	$(VIC) $(PRG1)

run2: all
	$(VIC) $(PRG2)

run3: all
	$(VIC) $(PRG3)

debug1: all
	$(VIC) -remotemonitor -moncommands $(NAME).mon $(PRG1)

debug2: all
	$(VIC) -remotemonitor -moncommands $(NAME).mon $(PRG2)

debug3: all
	$(VIC) -remotemonitor -moncommands $(NAME).mon $(PRG3)

dump1: all
	xxd $(PRG1) | less

dump2: all
	xxd $(PRG2) | less

dump3: all
	xxd $(PRG3) | less

clean:
	-rm -rf *.o *.prg *.map *.lbl

%.o: %.s
	$(AS) $(AFLAGS) --cpu $(CPU) $<
