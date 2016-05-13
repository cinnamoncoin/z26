
/* Usage message

	To be displayed if z26 is called with no arguments.

	Currently, this has to be manually maintained. At some point
	it'd be nice to generate this file from the pod documentation,
	since that's where I'm looking as I type this anyway.
*/

char *usage_message =
	"usage: z26 <options> romfile\n\n"
	"Only the most often used options are given here. To see the \n"
	"full list, see `man z26' or the README.TXT that came with z26.\n\n"
	"   -cN -- color palette (N=0 -- NTSC  N=1 -- PAL  N=2 -- SECAM)\n"
	"   -iC -- inactivate PC-controller\n"
	"          (C = K -- keyboard, M -- mouse, J -- joystick, S -- Stelladaptor)\n"
	"   -fN -- enable phosphorescent effect (N=0 through N=100, 77=default)\n"
	"          Requires > 256 colors (use -v2N option)\n"
	"    -n -- show scanline count and FPS on game display\n"
	"   -MN -- enable mouse capture in a window. N=0 off, N=1 on. Default on\n"
	"   -mN -- paddle to emulate with mouse (N=0 to 3)\n"
	"    -q -- quiet (no audio)\n"
	"   -sN -- -sN -- specifies the size of the sound queue\n"
	"   -rN -- run at N frames per second.\n"
	"   -vN -- start game in video mode N full screen, 256 color. N ranges 0 to 8\n"
	"  -v1N -- start game in video mode N in a window\n"
	"  -v2N -- start game in video mode N full screen, at your current color depth.\n"
	"          The -f option requires > 256 colors.\n"
	"    -S -- OSS Sound hack - try if audio is missing or too quiet\n"
	"   -TN -- Select timing mode. N is 1-3 (1-4 on Linux).\n"
	"          Higher numbers are more accurate. -T2 is default on BeOS,\n"
	"          -T4 is default on Linux, -T3 is default on other UNIX.\n"
	"\n"
	"During emulation, use mouse, joystick, or arrow+control keys for\n"
	"player 1 controls, for most games.\n"
	"Other controls:\n"
	"   F1=Reset, F2=Select, F3=B/W, F4=Color, F5-F8=Difficulty\n"
	"   Esc to exit the emulator\n"

	"\n";


/*
 * $Log: usage.h,v $
 * Revision 1.2  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
