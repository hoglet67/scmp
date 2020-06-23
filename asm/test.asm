blank:		.db	0		
		ld	counter
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


testinst:	ld		0
		ldi		0
		lde
		and		0
		adi		0
		ade