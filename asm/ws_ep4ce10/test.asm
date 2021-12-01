blank:		.db	0		

		ldi	>callme-1
		xpah	P1
		ldi	<callme-1
		xpal	P1
		xppc	p1

		ccl
		ldi	#0x44
		dai	#0x66

		ccl
		ldi	#0x23
		dai	#0x99

		ccl
		ldi	#0x23
		dai	#0x76

		scl
		ldi	#0x23
		dai	#0x76

		ldi	#44
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

		ldi	#0
		dly	#0

		ldi	#5
		dly	#2

		ldi	#0x5A
		xae

here:		halt
		ldi	#40
		dly	#0
		sio

		jmp	here

callme:		ien
		dint
		ien
		ldi	#0
		cas
		csa
		ori	#0x83
		cas
		nop
		nop
		xppc	p1


bob:		.db	0