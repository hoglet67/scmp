blank:		.db	0		

		ldi	#0x44
		dai	#0x66
		xae

		ld	3(P2)
		ld	@3(P2)
		ld	@3(P2)
		ld	@3(P2)
		ld	@-128(P2)

		st	-8(P2)
		st	+8(P2)
		st	(P2)
		st	@9(P2)

		ild	(p2)
		ild	(p2)
		dld	(p2)		
		dld	(p2)

		ani	#0x8F
		ori	#0x20
		xri	#0x88



		ldi	#0x99
		xpal	p2
		ldi	#0x3F
		xpah	p2

		ld	@120(P2)


		ldi	#0xA8
		ore
		st	bob
		ldi	#0x80
		adi	#0x80
here:		jmp	here

bob:		.db	0