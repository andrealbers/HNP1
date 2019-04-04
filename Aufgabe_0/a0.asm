	org 100h
	cpu 8086

START:	mov al, -1
	mov bl, -1
	XOR al, bl
	jmp START

