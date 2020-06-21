// This file was generated with microcode.pl - DO NOT EDIT

// NEXTPC
`define	SZ_NEXTPC	8

`define	NEXTPC_NEXT	8'd1
// CONDM
`define	SZ_CONDM	1

`define	CONDM_NUL	1'd0
`define	CONDM_OP2	1'b1
// CONDX
`define	SZ_CONDX	1

`define	CONDX_NUL	1'd0
`define	CONDX_OP2	1'b0
// BUS
`define	SZ_BUS	7

`define	BUS_IX_WR	'd0
`define	BUS_IX_RD	'd1
`define	BUS_IX_ADS	'd2
`define	BUS_IX_FLG_R	'd3
`define	BUS_IX_FLG_I	'd4
`define	BUS_IX_FLG_D	'd5
`define	BUS_IX_FLG_H	'd6

`define	BUS_WR	7'b0000001
`define	BUS_RD	7'b0000010
`define	BUS_ADS	7'b0000100
`define	BUS_FLG_R	7'b0001000
`define	BUS_FLG_I	7'b0010000
`define	BUS_FLG_D	7'b0100000
`define	BUS_FLG_H	7'b1000000

`define	BUS_NUL	7'd0
`define	BUS_ADSOP	`BUS_ADS|`BUS_FLG_R|`BUS_FLG_I
`define	BUS_ADSRD	`BUS_ADS|`BUS_FLG_R
// LD_L
`define	SZ_LD_L	11

`define	LD_L_IX_P0	'd0
`define	LD_L_IX_P1	'd1
`define	LD_L_IX_P2	'd2
`define	LD_L_IX_P3	'd3
`define	LD_L_IX_ADDR	'd4
`define	LD_L_IX_ACC	'd5
`define	LD_L_IX_EXT	'd6
`define	LD_L_IX_STAT	'd7
`define	LD_L_IX_D	'd8
`define	LD_L_IX_OP	'd9
`define	LD_L_IX_ST_ALU	'd10

`define	LD_L_P0	11'b00000000001
`define	LD_L_P1	11'b00000000010
`define	LD_L_P2	11'b00000000100
`define	LD_L_P3	11'b00000001000
`define	LD_L_ADDR	11'b00000010000
`define	LD_L_ACC	11'b00000100000
`define	LD_L_EXT	11'b00001000000
`define	LD_L_STAT	11'b00010000000
`define	LD_L_D	11'b00100000000
`define	LD_L_OP	11'b01000000000
`define	LD_L_ST_ALU	11'b10000000000

`define	LD_L_NUL	11'd0
`define	LD_L_ADDR_PC	`LD_L_P0|`LD_L_ADDR
// LD_H
`define	SZ_LD_H	5

`define	LD_H_IX_P0	'd0
`define	LD_H_IX_P1	'd1
`define	LD_H_IX_P2	'd2
`define	LD_H_IX_P3	'd3
`define	LD_H_IX_ADDR	'd4

`define	LD_H_P0	5'b00001
`define	LD_H_P1	5'b00010
`define	LD_H_P2	5'b00100
`define	LD_H_P3	5'b01000
`define	LD_H_ADDR	5'b10000

`define	LD_H_NUL	5'd0
`define	LD_H_ADDR_PC	`LD_H_P0|`LD_H_ADDR
// RD_L
`define	SZ_RD_L	9

`define	RD_L_IX_P0	'd0
`define	RD_L_IX_P1	'd1
`define	RD_L_IX_P2	'd2
`define	RD_L_IX_P3	'd3
`define	RD_L_IX_ADDR	'd4
`define	RD_L_IX_ACC	'd5
`define	RD_L_IX_EXT	'd6
`define	RD_L_IX_STATUS	'd7
`define	RD_L_IX_D	'd8

`define	RD_L_P0	9'b000000001
`define	RD_L_P1	9'b000000010
`define	RD_L_P2	9'b000000100
`define	RD_L_P3	9'b000001000
`define	RD_L_ADDR	9'b000010000
`define	RD_L_ACC	9'b000100000
`define	RD_L_EXT	9'b001000000
`define	RD_L_STATUS	9'b010000000
`define	RD_L_D	9'b100000000
// RD_H
`define	SZ_RD_H	5

`define	RD_H_IX_P0	'd0
`define	RD_H_IX_P1	'd1
`define	RD_H_IX_P2	'd2
`define	RD_H_IX_P3	'd3
`define	RD_H_IX_ADDR	'd4

`define	RD_H_P0	5'b00001
`define	RD_H_P1	5'b00010
`define	RD_H_P2	5'b00100
`define	RD_H_P3	5'b01000
`define	RD_H_ADDR	5'b10000
// WR_L
`define	SZ_WR_L	3

`define	WR_L_IX_RD_H	'd0
`define	WR_L_IX_RD_L	'd1
`define	WR_L_IX_ALU	'd2

`define	WR_L_RD_H	3'b001
`define	WR_L_RD_L	3'b010
`define	WR_L_ALU	3'b100
// WR_H
`define	SZ_WR_H	3

`define	WR_H_IX_RD_H	'd0
`define	WR_H_IX_RD_L	'd1
`define	WR_H_IX_INCR4	'd2

`define	WR_H_RD_H	3'b001
`define	WR_H_RD_L	3'b010
`define	WR_H_INCR4	3'b100
// ALU_OP
`define	SZ_ALU_OP	4

`define	ALU_OP_NUL	4'b0000
`define	ALU_OP_NUL1	4'b0001
`define	ALU_OP_AND	4'b0010
`define	ALU_OP_OR	4'b0011
`define	ALU_OP_XOR	4'b0100
`define	ALU_OP_DA	4'b0101
`define	ALU_OP_ADD	4'b0110
`define	ALU_OP_CAD	4'b0111
`define	ALU_OP_SR	4'b1000
`define	ALU_OP_SRL	4'b1001
`define	ALU_OP_RR	4'b1010
`define	ALU_OP_RRL	4'b1011
`define	ALU_OP_INC	4'b1100
`define	ALU_OP_DEC	4'b1101
// CTL
`define	SZ_CTL	1

`define	CTL_IX_DECODE	'd0

`define	CTL_DECODE	1'b1

`define	CTL_NUL	1'd0

`define SZ_MCODE 58

`define UCLBL_RESET 8'd0
`define UCLBL_LDI 8'd8
`define UCLBL_FETCH 8'd0
`define UCLBL_LD 8'd8
`define UCLBL_DECODE 8'd7
