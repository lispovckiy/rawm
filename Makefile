NASM = nasm
LD = ld

TARGET = rawm
SOURCE = rawm.asm
OBJECT = rawm.o
DEPS   = $(wildcard src/*.asm src/*.inc)

NASMFLAGS = -f elf64 -Wall -w-reloc-rel-dword
LDFLAGS = -m elf_x86_64 -z noseparate-code -s

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECT)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJECT): $(SOURCE) $(DEPS)
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJECT) $(TARGET)
