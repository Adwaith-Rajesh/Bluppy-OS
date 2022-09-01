ASM = nasm
BUILD_DIR = build
SRC_DIR = src
TOOLS_DIR = tools

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/boot.bin
	cp $< $@
	truncate -s 1440k $@

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	$(ASM) -f bin -o $@ $<


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*
