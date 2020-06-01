`ifndef _scmp_microcode_h_
`define _scmp_microcode_h_

`include "scmp_alu.vh"

//register load signals array indexes and constants


`define SZ_COND		1

//==condition masks and xors==

//2 byte opcocde
`define CONDM_OP2	1'b1
`define CONDX_OP2	1'b0

`define COND_OP2	`CONDM_OP2, `CONDX_OP2

`define CONDM_NUL	1'b0
`define CONDX_NUL	1'b0

`define COND_NUL	`CONDM_NUL, `CONDX_NUL

`define SZ_NEXT		8
	//goto 0
`define	NEXTPC_START	`SZ_NEXT'b00000000
	//add 1
`define	NEXTPC_NEXT	`SZ_NEXT'b00000001	

//	
`define SZ_BUS		7
`define	BUS_NUL		7'b0000000
`define BUS_FLG_H	7'b1000000
`define BUS_FLG_D	7'b0100000
`define BUS_FLG_I	7'b0010000
`define BUS_FLG_R	7'b0001000
`define BUS_ADS		7'b0000100
`define BUS_RD		7'b0000010
`define BUS_WR		7`b0000001

`define BUS_ADSOP	`BUS_ADS | `BUS_FLG_R | `BUS_FLG_I
`define BUS_ADSRD	`BUS_ADS | `BUS_FLG_R


`define 	SZ_LD_H		5

`define 	LD_H_IX_P0	'd0
`define 	LD_H_IX_P1	'd1
`define 	LD_H_IX_P2	'd2
`define 	LD_H_IX_P3	'd3
`define 	LD_H_IX_ADDR	'd4

`define 	LD_H_NONE 	5'b00000
`define 	LD_H_P0 	5'b00001
`define 	LD_H_P1 	5'b00010
`define 	LD_H_P2 	5'b00100
`define 	LD_H_P3 	5'b01000
`define 	LD_H_ADDR 	5'b10000

`define 	LD_H_ADDR_PC	`LD_H_ADDR + `LD_H_P0


`define 	SZ_LD_L		11

`define 	LD_L_IX_P0	'd0
`define 	LD_L_IX_P1	'd1
`define 	LD_L_IX_P2	'd2
`define 	LD_L_IX_P3	'd3
`define 	LD_L_IX_ADDR	'd4
`define 	LD_L_IX_ACC	'd5
`define 	LD_L_IX_EXT	'd6
`define 	LD_L_IX_STAT	'd7
`define 	LD_L_IX_D	'd8
`define 	LD_L_IX_OP	'd9
`define 	LD_L_IX_ST_ALU	'd10


`define		LD_L_NONE	11'b00000000000
`define		LD_L_P0		11'b00000000001
`define		LD_L_P1		11'b00000000010
`define		LD_L_P2		11'b00000000100
`define		LD_L_P3		11'b00000001000
`define		LD_L_ADDR	11'b00000010000
`define		LD_L_ACC	11'b00000100000
`define		LD_L_EXT	11'b00001000000
`define		LD_L_STAT	11'b00010000000
`define		LD_L_D		11'b00100000000
`define		LD_L_OP		11'b01000000000
`define 	LD_L_ST_ALU	11'b10000000000

`define 	LD_L_ADDR_PC	`LD_L_ADDR + `LD_L_P0

`define 	SZ_RD_L			9
`define 	RD_L_IX_PO	'd0
`define 	RD_L_IX_P1	'd1
`define 	RD_L_IX_P2	'd2
`define 	RD_L_IX_P3	'd3
`define 	RD_L_IX_ADDR	'd4
`define 	RD_L_IX_ACC	'd5
`define 	RD_L_IX_EXT	'd6
`define 	RD_L_IX_STATUS	'd7
`define 	RD_L_IX_D	'd8

`define 	RD_L_P0		9'b000000001
`define 	RD_L_P1		9'b000000010
`define 	RD_L_P2		9'b000000100
`define 	RD_L_P3		9'b000001000
`define 	RD_L_ADDR	9'b000010000
`define 	RD_L_ACC	9'b000100000
`define 	RD_L_EXT	9'b001000000
`define 	RD_L_STATUS	9'b010000000
`define 	RD_L_D		9'b100000000
`define 	RD_L_NONE	9'b000000000

`define 	SZ_RD_H		5

`define 	RD_H_IX_P0	'd0
`define 	RD_H_IX_P1	'd1
`define 	RD_H_IX_P2	'd2
`define 	RD_H_IX_P3	'd3
`define 	RD_H_IX_ADDR	'd4

`define 	RD_H_NONE 	5'b00000
`define 	RD_H_P0 	5'b00001
`define 	RD_H_P1 	5'b00010
`define 	RD_H_P2 	5'b00100
`define 	RD_H_P3 	5'b01000
`define 	RD_H_ADDR 	5'b10000

`define 	SZ_WR_L		3
`define 	WR_L_IX_RD_H	'd0
`define 	WR_L_IX_RD_L	'd1
`define 	WR_L_IX_ALU	'd2

`define		WR_L_RD_H	3'b001
`define		WR_L_RD_L	3'b010
`define		WR_L_ALU	3'b100
`define 	WR_L_NUL	`WR_L_RD_H

`define 	SZ_WR_H		3
`define 	WR_H_IX_RD_H	'd0
`define 	WR_H_IX_RD_INC4	'd1
`define 	WR_H_IX_RD_L	'd2

`define 	WR_H_RD_H	3'b001
`define 	WR_H_INCR4	3'b010
`define 	WR_H_RD_L	3'b100
`define 	WR_H_NUL	`WR_L_RD_H

`define 	SZ_MCODE	`SZ_NEXT + `SZ_COND + `SZ_COND + `SZ_BUS + `SZ_LD_L + `SZ_LD_H + `SZ_RD_L + `SZ_RD_H + `SZ_WR_L + `SZ_WR_H + `SZ_ALU_OP


`endif