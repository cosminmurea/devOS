
devOS: bootsector.bin paddedKernel.bin
	cat bootsector.bin paddedKernel.bin > devOS.bin

paddedKernel.bin:
	cd ../kernel/ && $(MAKE)

bootsector.bin:
	cd ../bootloader/ && $(MAKE)

run:
	qemu-system-x86_64 devOS.bin

.PHONY: clean

clean:
	cd ../kernel/ && rm *.o *.bin
	rm *.bin
