//
// Sound driver header file
//

// Set the location for the music 

void __fastcall__ init_music_data(const char *music);

// set the location for the soundfx

void __fastcall__ init_sound_data(const char *sounds);

//play a music in FamiTone format

void __fastcall__ music_play(unsigned char song);

//stop music

void __fastcall__ music_stop(void);

//pause and unpause music

void __fastcall__ music_pause(unsigned char pause);

//play FamiTone sound effect on channel 0..3

void __fastcall__ sfx_play(unsigned char sound,unsigned char channel);

//play a DPCM sam1..63

void __fastcall__ sample_play(unsigned char sample);
