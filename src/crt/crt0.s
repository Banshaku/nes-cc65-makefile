; startup code for cc65 and neslib
; based on code by Groepaz/Hitmen <groepaz@gmx.net>, Ullrich von Bassewitz <uz@cc65.org>

;v20180608

    .export __STARTUP__:absolute=1

	; Linker generated symbols
	.import __RAM_START__ ,__RAM_SIZE__, __STARTUP_LOAD__

	; C Runtime related methods
	.import _main, copydata

	; From neslib
	.import nmi, irq
	.import _ppu_off, _oam_clear, _pal_clear, _pal_bright	

	; ZP variable from neslib
	.importzp NTSC_MODE
	.importzp FRAME_CNT1
	.importzp PPU_CTRL_VAR, PPU_MASK_VAR
	.importzp RAND_SEED

	; Defined inside cc65 cfg file
	.importzp NES_MAPPER,NES_PRG_BANKS,NES_CHR_BANKS,NES_MIRRORING	

    .include "zeropage.inc"
	.include "NES.inc"


.segment "HEADER"

    .byte $4e,$45,$53,$1a
	.byte NES_PRG_BANKS
	.byte NES_CHR_BANKS
	.byte NES_MIRRORING|(NES_MAPPER<<4)
	.byte NES_MAPPER&$f0
	.res 8,0


; Global ZP variable used by all modules
.segment "ZEROPAGE"
; nothing defined yet


.segment "STARTUP"

	sei
	ldx #$ff
	txs
	inx
	stx PPU_MASK
	stx DMC_FREQ
	stx PPU_CTRL		;no NMI

initPPU:

	bit PPU_STATUS
@1:
	bit PPU_STATUS
	bpl @1
@2:
	bit PPU_STATUS
	bpl @2

clearPalette:

	lda #$3f
	sta PPU_ADDR
	stx PPU_ADDR
	lda #$0f
	ldx #$20
@1:
	sta PPU_DATA
	dex
	bne @1

clearVRAM:

	txa
	ldy #$20
	sty PPU_ADDR
	sta PPU_ADDR
	ldy #$10
@1:
	sta PPU_DATA
	inx
	bne @1
	dey
	bne @1

clearRAM:

	txa

@1:
	sta $000,x  ; ZP
	sta $100,x	; Hardware stack. shared with famitone for now
	sta $200,x	; OAM 
	sta $300,x	; Start of ram, shared with C stack
	sta $400,x
	sta $500,x  ; start of C stack, 300$ in size
	sta $600,x
	sta $700,x
	inx
	bne @1

	lda #4

	; Note: if change to own palette way those call will not be necessary anymore
	; This set a default palette for spr/bg (#4)
	jsr _pal_bright
	; This set all color for bf/spr to $0f and request an update
	jsr _pal_clear

	; Copy the default values of variables from rom. 
	; Note: If no default variable values (always 0) then not necessary.
	jsr	copydata

	; Prepare software stack pointer for C runtime
	lda #<(__RAM_START__+__RAM_SIZE__)
 	sta sp
	lda #>(__RAM_START__+__RAM_SIZE__)
	sta sp+1            ; Set argument stack ptr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; TODO: document until jmp _main
	lda #%10000000
	sta PPU_CTRL_VAR
	sta PPU_CTRL		;enable NMI
	lda #%00000110
	sta PPU_MASK_VAR

waitSync3:
	lda FRAME_CNT1
@1:
	cmp FRAME_CNT1
	beq @1

detectNTSC:
	ldx #52				;blargg's code
	ldy #24
@1:
	dex
	bne @1
	dey
	bne @1

	lda PPU_STATUS
	and #$80
	sta NTSC_MODE

	jsr _ppu_off

	lda #$fd
	sta RAND_SEED
	sta RAND_SEED+1

	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL			
	sta PPU_OAM_ADDR

	jmp _main	;no parameters


.segment "VECTORS"

	.word nmi		  	   ; $fffa vblank nmi
	.word __STARTUP_LOAD__ ; $fffc reset
   	.word irq	           ;$fffe irq / brk
