
/* ANSI function prototypes, and a few defines. */

#ifndef _Z26_H

#define _Z26_H 1

#ifdef WINDOWS
#define DEFAULT_SQ_MAX 2048
#else
#define DEFAULT_SQ_MAX 1024
#endif

/* asm code: */
void QueueSoundBytes();
void Tia_process();
void Init_CPU();
void Init_CPUhand();
void Init_TIA();
void Init_Riot();
void Init_P2();
void Init_Starpath();
void Init_Tiasnd();
void position_game();


/* c_core.c: */
void InitData();
void cleanup();
void Init_Service();
void TIAGraphicMode();
void Init_SoundQ();
void RandomizeRIOTTimer();

/* sdlsrv.c: */
void srv_sound_on();
void srv_sound_off();
void srv_lock_audio();
void srv_unlock_audio();
void srv_print();
void srv_get_mouse_movement();
void srv_Events();


/* text.c: */
void draw_char(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg);
void draw_char4(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg);
void draw_char2(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg);
void draw_char3(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg);
void show_scanlines();

#ifdef GUI
void gui();
#endif

#endif


/*
 * $Log: z26.h,v $
 * Revision 1.4  2004/05/23 21:34:00  urchlay
 *
 * partial reimplementation of main.asm in C. Not complete, just checking
 * in the work in progress.
 *
 * Revision 1.3  2004/05/09 00:38:29  urchlay
 *
 * Ported a few more functions to C. Tia_process() is still acting weird.
 *
 * Moved the C core defines to conf/c_core.mak, so we only have one place
 * to modify them, no matter which target we're building for. Used
 * `sinclude' to include it, which won't give an error if the file is
 * missing entirely. It'll just not define any of the C core stuff.
 *
 * Revision 1.2  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
