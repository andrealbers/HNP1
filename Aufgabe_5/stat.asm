; **** Code-Segment ****
section .text

global _stat

_stat: 
	push ebp				; neuer Stackframe: BasePointer retten
	mov ebp,esp				; Stackpointer zum neuen BasePointer machen

	sub esp, 4				; Schiebe Stackpointer auf nächstes Element (32Bit) 

jump: 
	cmp byte [ebp+16], '+'	;Operationsabfrage 
	je addi
	jmp subt
	
addi: 						;Addition der Werte aus dem Stack an Stelle 2(Wert1) & 3(Wert2) 
	mov ax,  [ebp+8] 
	add ax, [ebp+12] 
	jmp flag
	
subt: 						;Subtraktion der Werte aus dem Stack an Stelle 2(Wert1) & 3(Wert2) 
	mov ax,  [ebp+8] 
	sub ax,  [ebp+12] 
	jmp flag
	
flag:				
 	pushfd 					;Holen der Flags 
	pop edx					;Schreiben der Flags in das Datenregister
	mov ebx, [ebp+20]		;Holen der Adresse des Pointers 
	mov [ebx], edx 			;Schreiben der Flags in den Pointer
	

	mov esp, ebp			; Stackpointer auf Ret Adresse  
    pop ebp					; BP wiederherstellen
    ret						; um die Uebergabeparameter kuemmert sich
							; das rufende Programm (add esp, 16)		


; **** Daten-Segment ****
section .data

