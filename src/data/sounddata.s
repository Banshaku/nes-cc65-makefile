;
; This files just include the music, soundfx etc data in their proper segments
;

    .export _music_data, _sounds_data

.segment "RODATA"

_music_data:
	.include "music.s"

.if(FT_SFX_ENABLE)
_sounds_data:
	.include "sounds.s"
.endif

.segment "SAMPLES"

.if(FT_DPCM_ENABLE)
	.incbin "music.dmc"
.endif