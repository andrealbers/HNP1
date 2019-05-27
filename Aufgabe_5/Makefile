# Makefile zum Verlinken eines ASM-Moduls mit einem C-Programm
# HS Emden/Leer | C.Koch 
# 11.06.2012	initial version
# 11.12.2014	update 64-bit. Ubuntu 14.04 -> to compile 32-bit code on 64-bit environment:
#		$ sudo apt-get install gcc-multilib

# C-Quellcode kompilieren und mit ASM-Modul linken
addsub: stat.o addsub.o 	
	gcc -m32 -o addsub addsub.o  stat.o 	# linken

addsub.o: addsub.c
	gcc -m32 -c -o addsub.o addsub.c 	# compilieren 

# ASM-Modul assemblieren
stat.o: stat.asm
	nasm -f elf -o stat.o stat.asm

# Projekt aufraemen 
clean:
	@echo 'Ausgabedateien loeschen'
	rm -f addsub *.o *~





