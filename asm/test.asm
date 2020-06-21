		

		ld	counter
		ld	counter
		ldi	#10
		nop
		st	counter
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