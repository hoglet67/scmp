blank:		.db	0		
		ldi	#0x44
		xae
		ldi	#0xA8
		ore
		st	bob
		ldi	#0x80
		adi	#0x80
here:		jmp	here

bob:		.db	0