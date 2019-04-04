org 100h
cpu 8086

jmp START 

SEG_PORT equ 90h
LEV_PORT equ 0h
ZER equ 3Fh	
ONE equ 06h 
TWO equ 5Bh
THR equ 4Fh
FOR equ 66h
FIF equ 6Dh
SIX equ 7Dh
SEV equ 07h
EIG equ 7Fh
NIN equ 8Fh
A   equ 77h
B   equ 00h
C   equ 39h
D   equ 7Dh
E   equ 79h
F   equ 00h



START: 	
	in al, LEV_PORT
	
	

	out SEG_PORT, al 

	jmp START



