blank:		.db	0		
		ldi	#0x44
		st	pok
		ld	counter
		ani	#0xAA	
		or	pok
		adi	#0x31
		ld	counter
		ldi	#10
		st	counter
		st	blank
		nop
		ld	counter
loop:		dld	counter
		jnz	loop
here:		jmp	here


counter:	.db 	0xA5
pok:		.db	0


testinst:	ld		0
		ldi		0
		lde
		and		0
		adi		0
		ade