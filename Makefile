all: convert frames rom

convert:
	bash frames.sh

frames:
	python frames.py

rom:
	sjasm -s main.asm main.rom

test: rom
	openmsx -machine msx1 -carta main.rom
