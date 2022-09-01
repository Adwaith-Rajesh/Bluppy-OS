ASM = nasm
BUILD_DIR = build
SRC_DIR = src
TOOLS_DIR = tools

.PHONY: bootloader floppy

floppy: $(BUILD_DIR)/main_floppy.img
bootloader: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/boot.bin
	cp $< $@
	truncate -s 1440k $@

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	$(ASM) -f bin -o $@ $<


.PHONY: qemu
qemu:
	qemu-system-x86_64 -fda build/main_floppy.img

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*
