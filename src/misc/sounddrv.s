;
; Sound driver
;
; Wraps the content of famitone so it could be included in other case (multi-bank?)
; if necessary. 
;
; Note: this is some tentative code while restarting to be make nes deving again.
;

    ; Defined in config file
	.import __DMC_START__

    ; Global variables
	.importzp NTSC_MODE

    ; C runtime related
    .import popa

    .export _init_music_data,_init_sound_data
	.export _music_play,_music_stop,_music_pause
	.export _sfx_play,_sample_play
	.export FamiToneUpdate

FT_DPCM_OFF = __DMC_START__			;set in the linker CFG file via MEMORY/DMC section

.segment "SOUNDRV"

;void __fastcall__ init_music_data(const char *music);
_init_music_data:

	pha   ; Save A for later
	txa   ; Tranfert X (hight byte)
	tay   ; to Y
	pla   ; Retrieve A
	tax   ; and save in X (low byte)
	lda NTSC_MODE
	jsr FamiToneInit

    rts


;void __fastcall__ init_sound_data(const char *sounds);
_init_sound_data:

.if(FT_SFX_ENABLE)
	pha   ; Save A for later
	txa   ; Tranfert X (hight byte)
	tay   ; to Y
	pla   ; Retrieve A
	tax   ; and save in X (low byte)
	jsr FamiToneSfxInit
.endif

    rts


;void __fastcall__ music_play(unsigned char song);
_music_play=FamiToneMusicPlay


;void __fastcall__ music_stop(void);
_music_stop=FamiToneMusicStop


;void __fastcall__ music_pause(unsigned char pause);
_music_pause=FamiToneMusicPause


;void __fastcall__ sfx_play(unsigned char sound,unsigned char channel);
_sfx_play:

.if(FT_SFX_ENABLE)

	and #$03
	tax
	lda @sfxPriority,x
	tax
	jsr popa
	jmp FamiToneSfxPlay

@sfxPriority:

	.byte FT_SFX_CH0, FT_SFX_CH1, FT_SFX_CH2, FT_SFX_CH3
	
.else
	rts
.endif


;void __fastcall__ sample_play(unsigned char sample);
.if(FT_DPCM_ENABLE)
_sample_play=FamiToneSamplePlay
.else
_sample_play:
	rts
.endif

; Using the famitone library
    .include "famitone2.s"

; Note: defined at the end because of include order issue
.segment "ZEROPAGE"
FT_TEMP:		.res FT_TEMP_SIZE

; NOTE: FT_BASE_ZIZE is not accurate.. it defines $180 when it should be more like $1C0. Something
;       is missing. Figure out someday why some values are outside the range.
.segment "SOUNDRV_RAM"
FT_BASE_ADR:	.res FT_BASE_SIZE	