ASM = nasm
BUILD_DIR = build
SRC_DIR = src
TOOLS_DIR = tools

.PHONY: bootloader floppy kernel always

floppy: $(BUILD_DIR)/main_floppy.img
$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "BLUPPYOS" $@
	dd if=$(BUILD_DIR)/bootloader.bin of=$@ conv=notrunc
	mcopy -i $@ $(BUILD_DIR)/kernel.bin "::kernel.bin"


bootloader: $(BUILD_DIR)/bootloader.bin
$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader/boot.asm always
	$(ASM) -f bin -o $@ $<


kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel/main.asm always
	$(ASM) -f bin -o $@ $<


.PHONY: qemu
qemu:
	qemu-system-x86_64 -fda build/main_floppy.img

.PHONY: bochs
bochs:
	bochs -f bochs_config

always:
	mkdir -p $(BUILD_DIR)


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*
