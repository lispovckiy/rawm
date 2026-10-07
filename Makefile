NASM = nasm
LD = ld

TARGET = rawm
SOURCE = rawm.asm
OBJECT = rawm.o

NASMFLAGS = -f elf64 -Wall -w-reloc-rel-dword
LDFLAGS = -m elf_x86_64

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECT)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJECT): $(SOURCE)
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJECT) $(TARGET)
