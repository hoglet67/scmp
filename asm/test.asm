		
		
		ldi	#10
		st	counter
loop:		dld	counter
		jnz	loop
here:		jmp	here


counter:	.db 0