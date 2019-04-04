org 100h 
cpu 8086 

jmp START 

NUMB db 3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh, 7Dh, 07h, 7Fh, 6Fh, 77h, 7Ch, 39h, 5Eh, 79h, 71h	;7Segmente von 0 bis F 

LEVER 	equ 00h 		;Schalter
LED	equ 00h 		;LED Anzeige

SEVSEG1	equ 90h 		;Siebensegment 1
SEVSEG2	equ 92h 		;Siebensegment 2

START: 
	mov ax, 0x0000
	in al, LEVER 
	mov bl, al 
;Maskierung 
	and bl, 0x0F 		;Nibble 1
	and al, 0xF0 		;Nibble 2 
	
	mov cl, 4		;lade in cl Verschiebungsgröße
	SAR ax, cl 		;Shift Bitmuster al 4 rechts 

	sub al, bl		;Subtrahiere von al, bl 

	out LED, al 
	 
	jns POSITIV 		;Wenn SignFlag=0, Ergebnis positiv 
	js NEGATIV 		;Wenn SignFlag=1, Ergebnis negativ
	
POSITIV: 
	
	add ax, NUMB		;Addiere Adresse von Element 0 aus NUMB mit Ergebnis
	mov bx, ax		;Schreibe Wert in bx 
	mov ax, [bx]		;Nutze Wert von bx als Adresse 
	out SEVSEG1, al 
 
	mov al, 0x00		;Vorzeichen löschen 
	out SEVSEG2, al
	
jmp START

 
NEGATIV: 

	not al 			;Zweierkomplement	
	inc al 

	add ax, NUMB		;Siehe POSITIV	
	mov bx, ax
	mov al, [bx]
	out SEVSEG1, al 
 
	mov al, 0x40
	out SEVSEG2, al

jmp START 
