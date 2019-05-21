	org 100h
	cpu 8086

	jmp start

; Variablen
divider		db 0
stunde 		db 0
minute		db 0
sekunde		db 0 

timerstatus	db 0		; 0 = uhr, 1 = timer
startstatus 	db 0		; 0 = Stop, 1 = Start
framestatus	db 0 		; 0 = aus , 1 = zwischenzeit gezogen

timerhundert	db 0
timersekunde	db 0
timerminute	db 0 

framehun	db 0
framesec 	db 0
framemin	db 0 

; Konstanten
tc	equ 18432		; Zeitkonstante (1,8432 MHz Takt)
intab	equ 20h			; Adresse Interrupttabelle PIT, K1
eoi	equ 20h			; End Of Interrupt (EOI)
clrscr	equ 0			; Clear Screen
ascii	equ 1			; Funktion ASCII-Zeichenausgabe
hexbyte	equ 4			; HEX-Byte Ausgabe
conin	equ 5			; Console IN
conout	equ 6			; Console OUT
pitc	equ 0a6h		; Steuerkanal PIT (Intervaltimer)
pit1	equ 0a2h		; Kanal 1 PIT
pic23	equ 0c0h		; PIC (Interruptcontroller), OCW2,3
pic1	equ 0c2h		; PIC (Interruptcontroller), OCW1

start:	


	;alles Null stellen

	mov ah, clrscr
	int conout	

	mov dl, 0		;displaystelle zur ausgabe erste stundenziffer
	mov al, 48		
	mov ah, ascii		
	int conout 		;int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	mov dl, 1		; zweite stundenziffer
	int conout
	
	mov al, 45		; ausgabe ascii ' - '
	mov dl, 2	
	int conout 

	mov dl, 3		;displaystelle zur ausgabe der ersten minutenziffer
	mov al, 48		; 
	mov ah, ascii		;ah ist ausgabemodus = ascii
	int conout 		;int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	mov dl, 4		;zweite minutenziffer
	int conout
	
	mov al, 45		; ascii ' - '
	mov dl, 5	
	int conout 

	mov dl, 6		;displaystelle zur ausgabe der ersten sekundenziffer
	mov al, 48		; 
	mov ah, ascii		;ah ist ausgabemodus = ascii 
	int conout 		;int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	mov dl, 7	
	int conout
	
	

	; stunden einlesen, speichern und ausgeben
in1h:
	mov ah, ascii 		;ah ist einlesemodus interrupt 5 = ascii(1)
	
	mov al, 48
	mov dl, 7
	int conout

	int conin
	cmp al, 2		; compare eingabe mit hex A 
	ja in1h			; wenn mehr als 9 (zugelassen), jmp erneut
	mov [stunde], al
	mov cl, 4	
	shl byte[stunde], cl	; byte als angabe, dass es sich um ein byte handelt
	call fAusH	

	mov ah, ascii		; da ah in fAusH benutzt wurde
	int conin
	cmp al, 9		; compare eingabe mit hexA	
	ja in1h			; wenn mehr als 9, jmp erneut 	
	or byte[stunde], al

	cmp byte [stunde], 23h
	ja in1h
	call fAusH
	
in1m:
	; minuten einlesen
	mov ah, ascii 
	mov al, 48
	mov dl, 4
	int conout

	mov ah, ascii 		;ah ist einlesemodus interrupt 5 = ascii(1)
	int conin
	cmp al, 5		; compare eingabe mit hex A 
	ja in1m			; wenn mehr als 9 (zugelassen), jmp erneut	
	mov [minute], al
	shl byte [minute], cl	; byte als angabe, dass es sich um ein byte handelt
	call fAusM

	mov ah, ascii		; da ah in fAusH benutzt wurde
	int conin
	cmp al, 9		; compare eingabe mit hex A 
	ja in1m			; wenn mehr als 9 (zugelassen), jmp erneut	
	add [minute], al
	call fAusM

in1s:
	;sekunden einlesen
	mov ah, ascii 
	mov al, 48
	mov dl, 1
	int conout
	
	mov ah, ascii 		;ah ist einlesemodus interrupt 5 = ascii(1)
	int conin
	cmp al, 5		; compare eingabe mit hex A 
	ja in1s			; wenn mehr als 9 (zugelassen), jmp erneut	
	mov [sekunde], al
	shl byte [sekunde], cl	; byte als angabe, dass es sich um ein byte handelt
	call fAusS
	
	mov ah, ascii		; da ah in fAusH benutzt wurde
	int conin
	cmp al, 9		; compare eingabe mit hex A 
	ja in1s			; wenn mehr als 9 (zugelassen), jmp erneut
	add [sekunde], al
	call fAusS
	

	call tinit		; Initialisierung PIT 8253 (Kanal 1)
				; und Interruptsystem


again:	

	mov ah, 1
	int conin
	cmp al, 12H		;Zwischenzeit: 13H, Mode: 12H, Start/Stopp: 11H , Reset: 10H
	je modeswitch
	
	cmp al, 11H  		;Taste "GO", Timer Starten/Stoppen
	je startstop

	cmp al, 10H		;Taste "ENTER", Timer Reset
	je resettimer 

	cmp al, 13H		;Taste "Trace", Zwischenzeit ziehen
	je timeframe
	
	jmp again

; Der hier einzufügende Programmcode wird immer dann ausgeführt, wenn
; die Interruptserviceroutine nicht läuft (Hintergrundprogramm).
; Das wäre z.B. die Abfrage der Tastatur und die Manipulation der Statusbits.

	


tinit:	cli			; Interrupts aus
	mov al, 01110110b	; Kanal 1, Mode 3, 16-Bit ZK
	out pitc, al		; Steuerkanal
	mov al, tc & 0ffh	; Low-Teil Zeitkonstante
	out pit1, al
	mov al, tc >> 8		; High-Teil Zeitkonstante
	out pit1, al
	mov al, 11111110b	; Kanal 0 am PIC demaskieren
	out pic1, al
	mov word [intab], isr	; Interrupttabelle initialisieren
	mov [intab + 2], cs
	sti			; ab jetzt Interrupts
	ret

isr:	push ax
	
	cmp byte[startstatus], 1	;Wenn Start gedrueckt 
	jne isr_uhr_count		;Wenn Status = Stop -> Uhrzeit weiterzaehlen

	mov al, [timerhundert]
	add al, 1 
	daa 
	mov [timerhundert], al
	cmp byte[timerhundert], 99h
	jne isr_uhr_count
	mov byte[timerhundert], 0
	
	mov al, [timersekunde]
	add al, 1 
	daa 
	mov [timersekunde], al
	cmp byte[timersekunde], 60h
	jne isr_uhr_count
	mov byte[timersekunde], 0	

	mov al, [timerminute]
	add al, 1 
	daa 
	mov [timerminute], al
	cmp byte[timerminute], 99h
	jne isr_uhr_count
	mov byte[timerminute], 0	

	

isr_uhr_count:

	inc byte [divider]	; Vorteiler durch 100
	cmp byte [divider], 100	; fertig?
	jne isr_decision
	mov byte [divider], 0	; von vorne

	mov al, [sekunde]
	add al, 1 
	daa 
	mov [sekunde], al
	cmp byte[sekunde], 60h
	jne isr_decision
	mov byte[sekunde], 0
	
	mov al, [minute]
	add al, 1 
	daa 
	mov [minute], al
	cmp byte[minute], 60h
	jne isr_decision
	mov byte[minute], 0	

	mov al, [stunde]
	add al, 1 
	daa 
	mov [stunde], al
	cmp byte[stunde], 24h
	jne isr_decision
	mov byte[stunde], 0	

isr_decision:	
	
	cmp byte[timerstatus], 0x01
	je display_count
	
	jmp display_uhr


display_uhr: 
	
	call fAusH
	call fAusM
	call fAusS
	jmp isr1	

display_count: 
	cmp byte[framestatus], 1 ;Wenn Zwischenzeit gezogen
	je frameout			
	
	call fAustM
	call fAustS
	call fAustH


isr1:	mov al, eoi		; EOI an PIC
	out pic23, al		; OCW
	pop ax
	iret



; - - UNTERPROGRAMME - - ;

fAusH: 	
	mov dl, 7		;displaystelle zur ausgabe der ersten stundenziffer
	mov bl, [stunde]	;stundenbyte in ausgaberegister(bl) schieben 
	mov ah, hexbyte		;ah ist ausgabemodus = hexbyte 
	int conout 		; int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	ret 

fAustM:
	mov dl, 7	
	mov bl, [timerminute]	
	mov ah, hexbyte		 
	int conout 	

	ret

;---;

fAusM:		
	mov dl, 4		;displaystelle zur ausgabe der ersten minutenziffer
	mov bl, [minute]	;minutenbyte in ausgaberegister(bl) schieben 
	mov ah, hexbyte		;ah ist ausgabemodus = hexbyte 
	int conout 		; int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	ret

fAustS:	
	mov dl, 4	
	mov bl, [timersekunde]	
	mov ah, hexbyte		 
	int conout 	

	ret

;--;

fAusS:		
	mov dl, 1		;displaystelle zur ausgabe der ersten sekundenziffer
	mov bl, [sekunde]	;sekundenbyte in ausgaberegister(bl) schieben 
	mov ah, hexbyte		;ah ist ausgabemodus = hexbyte 
	int conout 		; int 6 ausgabe ( an 4. stelle(dl), ein hexbyte(ah), hexbyte = (bl)
	
	ret

fAustH:	
	mov dl, 1	
	mov bl, [timerhundert]	
	mov ah, hexbyte		 
	int conout 	

	ret

;--;

modeswitch: 	
	xor byte [timerstatus], 0x01
	jmp again	
	
startstop:
	xor byte[startstatus], 0x01
	jmp again
	
resettimer:
	cmp byte[startstatus], 0	;Wenn Timer gestoppt
	jne again
	mov byte[timerhundert], 0
	mov byte[timersekunde], 0
	mov byte[timerminute], 0
	jmp again
	
timeframe: 
	cmp byte[startstatus], 0
	je again

	xor byte[framestatus], 1
	
	mov al, byte[timerhundert]
	mov byte[framehun], al

	mov al, byte[timersekunde]
	mov byte[framesec], al

	mov al, byte[timerminute]	
	mov byte[framemin], al

	
	jmp again

frameout:
	mov dl, 7	
	mov bl, [framemin]	
	mov ah, hexbyte		 
	int conout 	

	mov dl, 4	
	mov bl, [framesec]	
	mov ah, hexbyte		 
	int conout 	
	
	mov dl, 1	
	mov bl, [framehun]	
	mov ah, hexbyte		 
	int conout 	

	jmp isr1

			
		






