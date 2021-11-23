package scmp_microcode_pak;
// This file was generated with microcode.pl - DO NOT EDIT

// NEXTPC
typedef logic signed[7:0] NEXTPC_t;
const	NEXTPC_t	NEXTPC_NEXT	= 8'd1;
// COND_MASK
typedef logic [4:0] COND_MASK_t;

const	COND_MASK_t	COND_MASK_NUL	= 5'd0;
const	COND_MASK_t	COND_MASK_OP2	= 5'b10000;
const	COND_MASK_t	COND_MASK_ADI	= 5'b01110;
const	COND_MASK_t	COND_MASK_JMP	= 5'b00001;
// COND_XOR
typedef logic [4:0] COND_XOR_t;

const	COND_XOR_t	COND_XOR_NUL	= 5'd0;
const	COND_XOR_t	COND_XOR_OP2	= 5'b00000;
const	COND_XOR_t	COND_XOR_ADI	= 5'b01000;
const	COND_XOR_t	COND_XOR_JMP	= 5'b00000;
// BUS
typedef enum {
	BUS_IX_WR	= 'd0,
	BUS_IX_RD	= 'd1,
	BUS_IX_ADS	= 'd2,
	BUS_IX_FLG_R	= 'd3,
	BUS_IX_FLG_I	= 'd4,
	BUS_IX_FLG_D	= 'd5,
	BUS_IX_FLG_H	= 'd6
} BUS_ix_t;
typedef logic [6:0] BUS_t;
const	BUS_t	BUS_WR	= 7'b0000001;
const	BUS_t	BUS_RD	= 7'b0000010;
const	BUS_t	BUS_ADS	= 7'b0000100;
const	BUS_t	BUS_FLG_R	= 7'b0001000;
const	BUS_t	BUS_FLG_I	= 7'b0010000;
const	BUS_t	BUS_FLG_D	= 7'b0100000;
const	BUS_t	BUS_FLG_H	= 7'b1000000;

const	BUS_t	BUS_NUL	= 7'd0;
const	BUS_t	BUS_ADSOP	= BUS_ADS|BUS_FLG_R|BUS_FLG_I;
const	BUS_t	BUS_ADSRD	= BUS_ADS|BUS_FLG_R;
const	BUS_t	BUS_ADSWR	= BUS_ADS;
// LD_L
typedef enum {
	LD_L_IX_P0	= 'd0,
	LD_L_IX_P1	= 'd1,
	LD_L_IX_P2	= 'd2,
	LD_L_IX_P3	= 'd3,
	LD_L_IX_ADDR	= 'd4,
	LD_L_IX_ACC	= 'd5,
	LD_L_IX_EXT	= 'd6,
	LD_L_IX_STAT	= 'd7,
	LD_L_IX_D	= 'd8,
	LD_L_IX_OP	= 'd9,
	LD_L_IX_ST_ALU	= 'd10,
	LD_L_IX_EA	= 'd11
} LD_L_ix_t;
typedef logic [11:0] LD_L_t;
const	LD_L_t	LD_L_P0	= 12'b000000000001;
const	LD_L_t	LD_L_P1	= 12'b000000000010;
const	LD_L_t	LD_L_P2	= 12'b000000000100;
const	LD_L_t	LD_L_P3	= 12'b000000001000;
const	LD_L_t	LD_L_ADDR	= 12'b000000010000;
const	LD_L_t	LD_L_ACC	= 12'b000000100000;
const	LD_L_t	LD_L_EXT	= 12'b000001000000;
const	LD_L_t	LD_L_STAT	= 12'b000010000000;
const	LD_L_t	LD_L_D	= 12'b000100000000;
const	LD_L_t	LD_L_OP	= 12'b001000000000;
const	LD_L_t	LD_L_ST_ALU	= 12'b010000000000;
const	LD_L_t	LD_L_EA	= 12'b100000000000;

const	LD_L_t	LD_L_NUL	= 12'd0;
const	LD_L_t	LD_L_ADDR_PC	= LD_L_P0|LD_L_ADDR;
const	LD_L_t	LD_L_D_ACC	= LD_L_D|LD_L_ACC;
const	LD_L_t	LD_L_ACC_STAT_ALU	= LD_L_ACC|LD_L_ST_ALU;
// LD_H
typedef enum {
	LD_H_IX_P0	= 'd0,
	LD_H_IX_P1	= 'd1,
	LD_H_IX_P2	= 'd2,
	LD_H_IX_P3	= 'd3,
	LD_H_IX_ADDR	= 'd4,
	LD_H_IX_EA	= 'd5
} LD_H_ix_t;
typedef logic [5:0] LD_H_t;
const	LD_H_t	LD_H_P0	= 6'b000001;
const	LD_H_t	LD_H_P1	= 6'b000010;
const	LD_H_t	LD_H_P2	= 6'b000100;
const	LD_H_t	LD_H_P3	= 6'b001000;
const	LD_H_t	LD_H_ADDR	= 6'b010000;
const	LD_H_t	LD_H_EA	= 6'b100000;

const	LD_H_t	LD_H_NUL	= 6'd0;
const	LD_H_t	LD_H_ADDR_PC	= LD_H_P0|LD_H_ADDR;
// RD_L
typedef enum {
	RD_L_IX_P0	= 'd0,
	RD_L_IX_P1	= 'd1,
	RD_L_IX_P2	= 'd2,
	RD_L_IX_P3	= 'd3,
	RD_L_IX_ADDR	= 'd4,
	RD_L_IX_ACC	= 'd5,
	RD_L_IX_EXT	= 'd6,
	RD_L_IX_STATUS	= 'd7,
	RD_L_IX_D	= 'd8,
	RD_L_IX_EA	= 'd9
} RD_L_ix_t;
typedef enum logic [9:0] {
	RD_L_P0	= 10'b0000000001,
	RD_L_P1	= 10'b0000000010,
	RD_L_P2	= 10'b0000000100,
	RD_L_P3	= 10'b0000001000,
	RD_L_ADDR	= 10'b0000010000,
	RD_L_ACC	= 10'b0000100000,
	RD_L_EXT	= 10'b0001000000,
	RD_L_STATUS	= 10'b0010000000,
	RD_L_D	= 10'b0100000000,
	RD_L_EA	= 10'b1000000000
} RD_L_t;
// RD_H
typedef enum {
	RD_H_IX_P0	= 'd0,
	RD_H_IX_P1	= 'd1,
	RD_H_IX_P2	= 'd2,
	RD_H_IX_P3	= 'd3,
	RD_H_IX_ADDR	= 'd4,
	RD_H_IX_EA	= 'd5
} RD_H_ix_t;
typedef enum logic [5:0] {
	RD_H_P0	= 6'b000001,
	RD_H_P1	= 6'b000010,
	RD_H_P2	= 6'b000100,
	RD_H_P3	= 6'b001000,
	RD_H_ADDR	= 6'b010000,
	RD_H_EA	= 6'b100000
} RD_H_t;
// WR_L
typedef enum {
	WR_L_IX_RD_H	= 'd0,
	WR_L_IX_RD_L	= 'd1,
	WR_L_IX_ALU	= 'd2
} WR_L_ix_t;
typedef enum logic [2:0] {
	WR_L_RD_H	= 3'b001,
	WR_L_RD_L	= 3'b010,
	WR_L_ALU	= 3'b100
} WR_L_t;
// WR_H
typedef enum {
	WR_H_IX_RD_H	= 'd0,
	WR_H_IX_RD_L	= 'd1,
	WR_H_IX_INCR4	= 'd2
} WR_H_ix_t;
typedef enum logic [2:0] {
	WR_H_RD_H	= 3'b001,
	WR_H_RD_L	= 3'b010,
	WR_H_INCR4	= 3'b100
} WR_H_t;
// ALU_OP
typedef logic [3:0] ALU_OP_t;
const	ALU_OP_t	ALU_OP_NUL	= 4'b0000;
const	ALU_OP_t	ALU_OP_NUL1	= 4'b0001;
const	ALU_OP_t	ALU_OP_AND	= 4'b0010;
const	ALU_OP_t	ALU_OP_OR	= 4'b0011;
const	ALU_OP_t	ALU_OP_XOR	= 4'b0100;
const	ALU_OP_t	ALU_OP_DA	= 4'b0101;
const	ALU_OP_t	ALU_OP_ADD	= 4'b0110;
const	ALU_OP_t	ALU_OP_CAD	= 4'b0111;
const	ALU_OP_t	ALU_OP_SR	= 4'b1000;
const	ALU_OP_t	ALU_OP_SRL	= 4'b1001;
const	ALU_OP_t	ALU_OP_RR	= 4'b1010;
const	ALU_OP_t	ALU_OP_RRL	= 4'b1011;
const	ALU_OP_t	ALU_OP_INC	= 4'b1100;
const	ALU_OP_t	ALU_OP_DEC	= 4'b1101;
const	ALU_OP_t	ALU_OP_ADD_NOCARRYIN	= 4'b1110;
// CTL
typedef enum {
	CTL_IX_DECODE	= 'd0,
	CTL_IX_LOGICOP	= 'd1
} CTL_ix_t;
typedef logic [1:0] CTL_t;
const	CTL_t	CTL_DECODE	= 2'b01;
const	CTL_t	CTL_LOGICOP	= 2'b10;

const	CTL_t	CTL_NUL	= 2'd0;

typedef struct packed {
	NEXTPC_t	nextpc;
	COND_MASK_t	cond_mask;
	COND_XOR_t	cond_xor;
	BUS_t	bus;
	LD_L_t	ld_l;
	LD_H_t	ld_h;
	RD_L_t	rd_l;
	RD_H_t	rd_h;
	WR_L_t	wr_l;
	WR_H_t	wr_h;
	ALU_OP_t	alu_op;
	CTL_t	ctl;
} MCODE_t;

typedef logic [7:0] MCODE_IX_t;
const MCODE_IX_t UCLBL_ST = 7'd14;
const MCODE_IX_t UCLBL_DLD = 7'd17;
const MCODE_IX_t UCLBL_DECODE = 7'd7;
const MCODE_IX_t UCLBL_LDE = 7'd13;
const MCODE_IX_t UCLBL_FETCH = 7'd0;
const MCODE_IX_t UCLBL_RESET = 7'd0;
const MCODE_IX_t UCLBL_JMP = 7'd29;
const MCODE_IX_t UCLBL_LD = 7'd8;
const MCODE_IX_t UCLBL_XAE = 7'd31;
const MCODE_IX_t UCLBL_LDI = 7'd12;
const MCODE_IX_t UCLBL_ILD = 7'd23;
typedef logic [6:0] MCODE_PC_t;
endpackage