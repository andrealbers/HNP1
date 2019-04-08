org 100h 
cpu 8086 

jmp START 

NUMB db 3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh, 7Dh, 07h, 7Fh, 6Fh, 77h, 7Ch, 39h, 5Eh, 79h, 71h	;7Segmente von 0 bis F 

LEVER 	equ 00h 		;Schalter
LED	equ 00h 		;LED Anzeige

SEVSEG1	equ 90h 		;Siebensegment 1
SEVSEG2	equ 92h 		;Siebensegment 2

START: 
	xor ax, ax		;ax löschen
	in al, LEVER 
	mov bl, al 
;Maskierung 
	and bl, 0x0F 		;Nibble 1
	and al, 0xF0 		;Nibble 2 
	
	mov cl, 4		;lade in cl Verschiebungsgröße
	SHR ax, cl 		;Shift Bitmuster al 4 rechts 

	sub al, bl		;Subtrahiere von al, bl 

	out LED, al 

	mov cl, al		;Nibble 1 kopieren 
	shr cx, 1		;Ergebnis shiften 
	shr cx, 1
	shr cx, 1
	shr cx, 1

	and al, 0x0F		;Ausgabe Ergebnis 1 	
	add ax, NUMB		
	mov bx, ax
	mov al, [bx]
	out SEVSEG1, al 
	
	
	mov bx, NUMB		;Ausgabe Ergebnis 2
	mov al, cl
	xlat
	out SEVSEG2, al 
	
	jmp START 
