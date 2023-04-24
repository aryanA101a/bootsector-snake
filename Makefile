all:
	fasm snake.asm
run:
	qemu-system-x86_64 -drive format=raw,file=snake.bin