		

		ldi	#10
		nop
		st	counter
loop:		dld	counter
		jnz	loop
here:		jmp	here


counter:	.db 0