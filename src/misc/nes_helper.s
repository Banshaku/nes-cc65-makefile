;
; Wrapper for neslib
;
    ; For now, minimum export (mostly for CRT0)
    .exportzp NTSC_MODE
    .exportzp FRAME_CNT1
    .exportzp PPU_CTRL_VAR, PPU_MASK_VAR
    .exportzp RAND_SEED

	; Used in crt0 (for now)
	.export irq, nmi

	; C runtime related
	.import popax, popa
	.importzp sp

	; For NMI
	.import FamiToneUpdate    

    ; For common constants
    .include "NES.inc"

.segment "BSS"
pal_buffer:         .res 32  ; allocate space for buffer

.segment "OAM_BUFFER"
oam_buffer:         .res 255  ; allocate buffer for OAM dma transfer

.segment "ZEROPAGE"

NTSC_MODE: 			.res 1
FRAME_CNT1: 		.res 1   ; find a way to remove it
FRAME_CNT2: 		.res 1
VRAM_UPDATE: 		.res 1
NAME_UPD_ADR: 		.res 2
NAME_UPD_ENABLE: 	.res 1
PAL_UPDATE: 		.res 1
PAL_BG_PTR: 		.res 2
PAL_SPR_PTR: 		.res 2
SCROLL_X: 			.res 1
SCROLL_Y: 			.res 1
SCROLL_X1: 			.res 1
;SCROLL_Y1: 			.res 1 ; not used
PAD_STATE: 			.res 2		;one byte per controller
PAD_STATEP: 		.res 2
PAD_STATET: 		.res 2
PPU_CTRL_VAR: 		.res 1
PPU_CTRL_VAR1: 		.res 1
PPU_MASK_VAR: 		.res 1
RAND_SEED: 			.res 2
TEMP: 				.res 12     ; Temp shared by all. Added 1 extra value

    ; Define specific alias for neslib
OAM_BUF				= oam_buffer ;$0200
; moved in BSS for now
PAL_BUF				= pal_buffer 

PAD_BUF				=TEMP+10 ; Changed to 10, just in case it could be mixed up with PTR

PTR					=TEMP	;word
LEN					=TEMP+2	;word
SCRX				=TEMP+4
SCRY				=TEMP+5
SRC					=TEMP+6	;word
DST					=TEMP+8	;word

RLE_LOW				=TEMP
RLE_HIGH			=TEMP+1
RLE_TAG				=TEMP+2
RLE_BYTE			=TEMP+3


.segment "CODE"

    .include "neslib.s"