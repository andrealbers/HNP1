	org 100h
	cpu 8086

	jmp start

; Variablen

set       db 0 			; Bit zum Setzen der Uhr 
timermode db 0x04
minus	  db '-'

clockSec  db 0
clockMin  db 0 
clockH    db 0 

timerMSec db 0 
timerSec  db 0 
timerMin  db 0

holdMSec db 0 
holdSec  db 0 
holdMin  db 0 

clockset  db 0 
 
divider	  db 0

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

butF	equ 0Fh			;Taste für Uhr einstellen 
butA	equ 0Ah			;Taste für Switchen 

butB	equ 0Bh			;Taste für Start/Stop counter 
butC	equ 0Ch			;Taste für Stop counter 
butD	equ 0Dh			;Taste für Freez 
butE	equ 0Eh

start:	
	mov ah, 0h 		;Display loeschen
	int 6	

	mov ah, 1
	mov al, [minus]
	mov dl, 2
	INT 6 
	mov dl, 5
	int 6

	call tinit		; Initialisierung PIT 8253 (Kanal 1)
				; und Interruptsystem


again:	
	mov ah, 1 
	int 5  
	cmp al, butF 		;Wenn Taste F gedrückt, Uhr setzen 
	je ClockSet
	
	cmp al, butA 		;Wenn Taste A gedrückt, Modus wechseln 
	je modi   

	cmp al, butB		;Wenn Taste B gedrückt, Stopuhr starten oder stoppen 
	je countStartStop

	cmp al, butC		;Wenn Taste D gedrückt, Stopuhr einfrieren 
	je counthold

	cmp al, butD		;reset 
	je countreset
	
	jmp again

;------------------- Tastenoperationen ------------------- 
countStartStop: 
	xor byte[timermode], 0x01		;Toggle Start und Stop counter 
	jmp again 

counthold:
	xor byte [timermode], 0x02		;Timer wird weiter gezählt
			
	mov al, byte[timerMSec] 		;Store der Zeit 
	mov byte[holdMSec], al 	
	mov al, byte[timerSec]
 	mov byte[holdSec], al 
	mov al, byte[timerMin] 
	mov byte[holdMin],al 
	jmp again

countreset: 
	test byte[timermode], 0x01 
	jnz again 
	mov byte[timerMSec], 0x00		;Setze Timer zurück 
	mov byte[timerSec],  0x00
	mov byte[timerMin],  0x00
	jmp again




tinit:	
	cli			; Interrupts aus
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

isr:	
	push ax
	mov al, byte[timermode]
	out 0, al			
	
isrModus: 
	test byte[timermode], 0x04	
	jnz isrClock		;Anzeigemodus Uhr
	jmp isrTimer		;Anzeigemodus Stop-Uhr

isrClock: 			;!!!!!Clockcount immer an´s ENDE!!!
	test byte[set], 1	;Überspringe, wenn zählwerk aus 
	jnz isr1 
	call Anzeige
	test byte[timermode], 1	;Stopuhr = Start  
	jnz countTimer		;Erst Stopuhr zählen, dann Uhr 
	jmp Clockcount		;Uhr Zählen 
	

isrTimer:
	test byte[timermode], 0x02	
	jnz isrHoldtime	
	call AnzeigeCount	
	test byte[timermode], 0x01	;Wenn letztes Bit gesetzt, dann zähle zeit 
	jnz countTimer
	jmp Clockcount
	
isrHoldtime:
	call AnzeigeHold
	test byte[timermode], 0x01	;Wenn letztes Bit gesetzt, dann zähle zeit 
	jnz countTimer
	jmp Clockcount


isr1:	
	mov al, eoi		; EOI an PIC
	out pic23, al		; OCW
	pop ax
	iret


;------------------- Uhrzeit setzen -------------------
ClockSet: 
	test byte [timermode], 0x04
	jz again
	mov byte [set], 1 	;Zählwerk aus 

	mov ah, 1
	int 5  
	mov ah, 1
	mov al, [minus]
	mov dl, 2
	INT 6 
	mov dl, 5
	int 6

	
	call secset 
	call minset 
	call hrset	

	mov byte [set], 0
 	jmp again 


secset: 
	mov ah, 3 
	mov dl, 1
	int 5 
	mov byte [clockSec], al 
	cmp al, 59h
	ja secset
	mov ah, 0 
	shl ax, 1
	shl ax, 1
	shl ax, 1
	shl ax, 1
	out 0, ax
	cmp al, 0xA0	
	jae secset 
	cmp ah, 0x0A  	
	jae secset 
	ret 

minset: 
	mov ah, 3	
	mov dl, 4
	int 5	
	mov byte [clockMin], al
	cmp al, 59h
	ja minset 
	mov ah, 0 
	shl ax, 1
	shl ax, 1
	shl ax, 1
	shl ax, 1
	out 0, ax
	cmp al, 0xA0	
	jae minset 
	cmp ah, 0x0A  	
	jae minset 
	ret 

hrset: 
	mov ah, 3 
	mov dl, 7
	int 5	
	mov byte [clockH], al
	
	cmp al, 23h
	ja hrset 
	mov ah, 0 
	shl ax, 1
	shl ax, 1
	shl ax, 1
	shl ax, 1
	out 0, ax
	cmp al, 0xA0	
	jae hrset 
	cmp ah, 0x0A  	
	jae hrset 
	ret 	


;------------------- counter zählen  ------------------- 
countTimer:
	mov al, [timerMSec] 
	inc al
	daa
	mov byte [timerMSec], al 
	cmp byte [timerMSec], 00h

	jne Clockcount 
	mov byte [timerMSec], 0 

	mov al, [timerSec] 
	inc al
	daa
	mov byte [timerSec], al 
	cmp byte [timerSec], 60h

	jne Clockcount  
	mov byte [timerSec], 0 

	mov al, [timerMin] 
	inc al
	daa
	mov byte [timerMin], al 
	cmp byte [timerMin], 60h

	jne Clockcount  
	mov byte [timerMin], 0
	jmp Clockcount  

;------------------- Anzeige Hold-Stop-Uhr ------------------- 
AnzeigeHold: 	
	mov ah, 4
	mov bl, [holdMSec] 
	mov dl, 1
	INT 6 

	mov ah, 4
	mov bl, [holdSec] 
	mov dl, 4
	INT 6 

	mov ah, 4
	mov bl, [holdMin] 
	mov dl, 7
	INT 6 

	ret 

;------------------- Anzeige Stop-Uhr ------------------- 
AnzeigeCount: 	
	mov ah, 4
	mov bl, [timerMSec] 
	mov dl, 1
	INT 6 

	mov ah, 4
	mov bl, [timerSec] 
	mov dl, 4
	INT 6 

	mov ah, 4
	mov bl, [timerMin] 
	mov dl, 7
	INT 6 

	ret 

;------------------- Uhrzeit zählen ------------------- 
Clockcount:
	inc byte [divider]	; Vorteiler durch 100
	cmp byte [divider], 100	; fertig?
	jne isr1
	mov byte [divider], 0	; von vorne
	
	mov al, [clockSec] 
	inc al
	daa
	mov byte [clockSec], al 
	cmp byte [clockSec], 60h
	jne isr1 
	mov byte [clockSec], 0 

	mov al, [clockMin] 
	inc al
	daa
	mov byte [clockMin], al 
	cmp byte [clockMin], 60h

	jne isr1  
	mov byte [clockMin], 0 

	mov al, [clockH] 
	inc al
	daa
	mov byte [clockH], al 
	cmp byte [clockH], 24h

	jne isr1  
	mov byte [clockH], 0
	jmp isr1  

;------------------- Anzeige Uhr ------------------- 
Anzeige: 	
	mov ah, 4
	mov bl, [clockSec] 
	mov dl, 1
	INT 6 

	mov ah, 4
	mov bl, [clockMin] 
	mov dl, 4
	INT 6 

	mov ah, 4
	mov bl, [clockH] 
	mov dl, 7
	INT 6 

	ret 

;------------------- Modus wechseln ------------------- 
modi: 
	xor byte [timermode], 0x04
	jmp again 


	
