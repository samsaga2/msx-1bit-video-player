all: test

video:
	bash frames.sh

convert:
	python frames.py

msx1:
	sjasm -s msx1.asm msx1.rom
	openmsx -machine msx1 -carta msx1.rom

turbor:
	sjasm -s turbor.asm turbor.rom
	openmsx -machine turbor -carta turbor.rom
