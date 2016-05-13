/*
** z26 -- an Atari 2600 emulator
*/

/*
** z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

/* moved these here from sdlsrv.c */
#include "SDL.h"
#include "SDL_audio.h"

/* moved these here from globals.c */

typedef unsigned int	dd;
typedef unsigned short int	dw;
typedef unsigned char  		db;

#include "z26.h"

/* #include "config.h" */ /* handled by make system now */
#include "chkconfig.h"

#include "globals.c"
#include "ct.c"
#include "carts.c"
#include "cli.c"
#include "trace.c"
#include "kidvid.c"
#include "palette.c"

#include "sdlsrv.c"
#include "text.c"
#include "pcx.c"
#include "controls.c"

#ifndef WINDOWS
#include "usage.h"
#endif

#ifdef GUI
#include "gui.c"
#endif

#include "c_core.c"

char *default_arg[] = { "z26", "-r100000", "-f5000", "demonatk.bin" };

extern void emulator();

Uint32 total_ticks;
double seconds;

int main(int argc, char *argv[])
{
	def_LoadDefaults();

	ClearScreenBuffers();

	ScreenBuffer = RealScreenBuffer1;
	ScreenBufferPrev = RealScreenBuffer2;

	if (argc == 1)
	{
		srv_print("Version " Z26_VERSION "\n");
#ifndef WINDOWS
		/* don't printf() on Windows, it just ends up in stdout.txt
			and the user won't see it anyway */
		printf(usage_message);
#endif
		exit(1);
	}
	else
	{
		cli_CommandLine(argc, argv);
	}

	/*
#ifdef UNIX_TIMING
	gettimeofday(&start_tv, NULL);
#endif
*/

	emulator();		   /* call emulator -- (main.asm) */

	if(GrabInput)
		SDL_WM_GrabInput(SDL_GRAB_OFF);

#ifdef C_INITDATA
		cleanup();
#endif

	switch(MessageCode) {
		case 1:
			sprintf(msg, "Unable to find load %02x\n", SC_ControlByte);
			srv_print(msg);
			break;
		case 2:
			sprintf(msg, "Starpath call @ %04x\n", cpu_pc);
			srv_print(msg);
			break;
		case 3:
			sprintf(msg, "JAM instruction %02x @ %04x\n", cpu_a, cpu_pc);
			srv_print(msg);
			break;
		default:
#ifdef UNIX_TIMING
			total_ticks = get_uticks() - (start_tv.tv_sec * 1000000 + start_tv.tv_usec);
			seconds = total_ticks / 1000000.0f;
			printf("Total frames: %d, avg FPS: %f\n", Flips-20, (Flips-20)/seconds);
#endif
			break;
       		}

	if(TraceEnabled && (zlog != NULL)) {
		fprintf(zlog, "Exiting emulator with status %d\n", MessageCode);
		fflush(zlog);
		fclose(zlog);
	}

	return MessageCode;

}                                                         

/*
 * $Log: z26.c,v $
 * Revision 1.9  2004/05/23 21:34:00  urchlay
 *
 * partial reimplementation of main.asm in C. Not complete, just checking
 * in the work in progress.
 *
 * Revision 1.8  2004/05/15 18:53:37  urchlay
 *
 * Made -t (trace mode) work again. Added -tt option (trace mode on, but
 * disabled until the user presses F11).
 *
 * Revision 1.7  2004/05/14 18:17:51  urchlay
 *
 * FPS calculation no longer takes into account the first 20 frames of
 * emulation, since they're generally not valid frames anyway due to the
 * auto-adjustment.
 *
 * Revision 1.6  2004/05/09 21:31:10  urchlay
 *
 * Added -G option to grab keyboard/mouse events with SDL_WM_GrabInput().
 * I need this so I can switch video modes while z26 is running (normally,
 * Alt-1 through Alt-9 in my environment are used to switch virtual
 * desktops, and z26 never sees these keystrokes). This might also
 * disable the Windows keys if you use it on Windows (not tested yet),
 * which could be good or bad, depending on whether you hit the Win keys
 * more often on purpose or by accident :)
 *
 * Revision 1.5  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
