blank:		.db	0		

		ld	3(P2)
		ld	@3(P2)


		ldi	#0x23
		xpal	p2
		ldi	#0x56
		xpah	p2

		ldi	#0x44
		xae
		ldi	#0xA8
		ore
		st	bob
		ldi	#0x80
		adi	#0x80
here:		jmp	here

bob:		.db	0