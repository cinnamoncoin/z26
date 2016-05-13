/*
** sdlsrv.c -- SDL service code
*/

/*
** z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


#ifdef WINDOWS
#include "winsrv.c"
#endif

#define NUM_COLORS 256

SDL_Surface *z26Icon;
SDL_Color z26IconColours[4];
db z26IconShape[1024]={
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,3,3,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,
        4,4,3,3,3,3,3,3,3,3,3,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,
        4,4,3,3,3,3,3,3,3,3,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,
        4,4,4,4,4,4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,
        4,4,4,4,4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,
        4,4,4,4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,
        4,4,4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,4,
        4,4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,4,4,
        4,4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,4,4,4,
        4,4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,4,4,4,4,
        4,4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,3,3,4,4,4,4,4,4,4,4,4,4,
        4,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,
        0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,
        0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,
        4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
};

db z26IconMask[128]={
        0xff,0xff,0xff,0xfc,
        0xff,0xff,0xff,0xfc,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0x3f,0xff,0xff,0xfe,
        0x3f,0xff,0xff,0xfc,
        0x00,0x7f,0xff,0xf8,
        0x00,0xff,0xff,0xf0,
        0x01,0xff,0xff,0xe0,
        0x03,0xff,0xff,0xc0,
        0x07,0xff,0xff,0x80,
        0x0f,0xff,0xff,0x00,
        0x1f,0xff,0xfe,0x00,
        0x3f,0xff,0xfc,0x00,
        0x7f,0xff,0xff,0xfc,
        0xff,0xff,0xff,0xfc,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0xff,0xff,0xff,0xff,
        0x3f,0xff,0xff,0xff,
        0x3f,0xff,0xff,0xff,
};

void srv_CreateIcon()
{
/*
        z26IconColours[0].r=96;         //turquise
        z26IconColours[0].g=192;
        z26IconColours[0].b=192;
        z26IconColours[1].r=0;          //blue
        z26IconColours[1].g=96;         
        z26IconColours[1].b=192;
*/
        z26IconColours[0].r=00;         //turquise
        z26IconColours[0].g=255;
        z26IconColours[0].b=255;
        z26IconColours[1].r=0;          //blue
        z26IconColours[1].g=0;         
        z26IconColours[1].b=255;
        z26IconColours[2].r=0;          //black
        z26IconColours[2].g=0;
        z26IconColours[2].b=0;
        z26IconColours[2].r=255;        //yellow (gets masked out)
        z26IconColours[2].g=255;
        z26IconColours[2].b=0;

        z26Icon = SDL_CreateRGBSurfaceFrom
                (z26IconShape, 32, 32, 8, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
        SDL_SetColors(z26Icon, z26IconColours, 0, 4);
//        SDL_SetColorKey(z26Icon, SDL_SRCCOLORKEY, 3);
}

SDL_Joystick *JoystickTable[16];

SDL_Surface *srv_screen;
Uint8 *srv_buffer;
dd srv_pitch;

dd Vert;
dd Horiz;
dd Real_Horiz;
dd width, height;
dd Real_width;

db *screen_pixels;
db *emu_pixels;
db *emu_pixels_prev;

db screen_buffer_count = 0;

db srv_done = 0;

void srv_print(char *msg)
{
#ifdef WINDOWS
	win_msg(msg);
#else
	printf("%s", msg);
#endif
}

const SDL_VideoInfo *srv_vin;

dd srv_colortab[128];
dd srv_bpp = 0;
dd srv_bypp = 0;

dd srv_average[128][128];

extern void FDoLinearCopy();
extern void DoLinearCopy();
extern void DoWideLinearCopy();

extern void CFDoLinearCopy();
extern void CDoLinearCopy();
extern void CDoWideLinearCopy();

#include "pixcopy.c"

void (*DrawScanLineLinear[][4])() = {
/*  1 bpp              2 bpp              3 bpp              4 bpp */
	{ FDoLinearCopy,     FDoPixelCopy2,     FDoPixelCopy3,     FDoPixelCopy4 }, /* single pixel routines */

	{ DoLinearCopy,      DoPixelCopy2,      DoPixelCopy3,      DoPixelCopy4 },		/* double pixel routines */

	{ DoTrPixelCopy1,    DoTrPixelCopy2,    DoTrPixelCopy3,    DoTrPixelCopy4 },	/* triple pixel routines */
	{ DoWideLinearCopy,  DoWidePixelCopy2,  DoWidePixelCopy3,  DoWidePixelCopy4 }	/* quad pixel routines */
};

void (*DrawScanLineCompare[][4])() = {
/*  1 bpp              2 bpp              3 bpp              4 bpp */
	{ CFDoLinearCopy,    CFDoPixelCopy2,    CFDoPixelCopy3,    CFDoPixelCopy4 },	/* single pixel routines */
	{ CDoLinearCopy,     CDoPixelCopy2,     CDoPixelCopy3,     CDoPixelCopy4 },	/* double pixel routines */
	{ CDoTrPixelCopy1,   CDoTrPixelCopy2,   CDoTrPixelCopy3,   CDoTrPixelCopy4 },	/* triple pixel routines */
	{ CDoWideLinearCopy, CDoWidePixelCopy2, CDoWidePixelCopy3, CDoWidePixelCopy4 }	/* quad pixel routines */
};

void (*DrawScanLineAverage[][4])() = {
/*  1 bpp              2 bpp              3 bpp              4 bpp */
	{ FDoLinearCopy,     FDoPixelAv2,       FDoPixelAv3,       FDoPixelAv4},		/* single pixel routines */
	{ DoLinearCopy,      DoPixelAv2,        DoPixelAv3,        DoPixelAv4},		/* double pixel routines */
	{ DoTrPixelCopy1,    DoTrPixelAv2,      DoTrPixelAv3,      DoTrPixelAv4},		/* triple pixel routines */
	{ DoWideLinearCopy,  DoWidePixelAv2,    DoWidePixelAv3,    DoWidePixelAv4}	/* quad pixel routines */
};



db srv_Phosphor(int c1, int c2)
{
	int i;

	if (c2 > c1)
	{
		i = c2;
		c2 = c1;
		c1 = i;
	}
	i = ((c1-c2)*Phosphor)/100 + c2;
	return i;
}

void srv_SetPalette()
{
	int i,j;
	db red, grn, blu;
	SDL_Color palette[NUM_COLORS];

	ClearScreenBuffers();

	GeneratePalette();
	for ( i=0; i<128; i++)
	{
		red = PCXPalette[3*i];
		grn = PCXPalette[3*i+1];
		blu = PCXPalette[3*i+2];

		palette[i].r = red;
		palette[i].g = grn;
		palette[i].b = blu;

		srv_colortab[i] = SDL_MapRGB(srv_vin->vfmt, red, grn, blu);
	}

	SDL_SetColors(srv_screen, palette, 0, NUM_COLORS);

	if (Phosphor && NoRetrace)
	{
		for ( i=0; i<128; i++)
		{
			for ( j=0; j<128; j++)
			{
			red = srv_Phosphor(PCXPalette[3*i], PCXPalette[3*j]);
			grn = srv_Phosphor(PCXPalette[3*i+1], PCXPalette[3*j+1]);
			blu = srv_Phosphor(PCXPalette[3*i+2], PCXPalette[3*j+2]);

			srv_average[i][j] = SDL_MapRGB(srv_vin->vfmt, red, grn, blu);
			}
		}
	}
}

void CreateScreen(Uint16 w, Uint16 h, Uint8 bpp, Uint32 flags)
{
	int sbpp;

	ClearScreenBuffers();

	sbpp=SDL_VideoModeOK(w, h, bpp, SDL_HWSURFACE);

	if(!sbpp){
  		srv_print("Mode not available.\n");
  		exit(-1);
	}

//	sprintf(msg, "SDL Recommends %d bpp.\n", sbpp);
//	srv_print(msg);

	if (((srv_bypp == 4) || (srv_bypp == 3) || (srv_bypp == 2)) && (TrueColor))
	{
		srv_screen = SDL_SetVideoMode(w, h, srv_bpp, flags);
	}
	else
	{
		srv_screen = SDL_SetVideoMode(w, h, bpp, flags);
	}
	srv_pitch = srv_screen->pitch;
	
	if ( srv_screen == NULL ) {
		sprintf(msg, "Couldn't set display mode: %s\n", SDL_GetError());
		srv_print(msg);
		return;
	}

//	SDL_WM_SetCaption(" z26"," z26");
	SDL_WM_SetCaption(FileName, FileName);
	
	if ((srv_screen->flags & SDL_FULLSCREEN) || MouseRude)
		SDL_ShowCursor(SDL_DISABLE);
	srv_SetPalette();
}

void srv_CreateScreen(void)
{
	Uint32 videoflags;
	/* int    done; */
	/* SDL_Event event; */
	int bpp;
	int i;

	if ( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0 ) 
	{
		sprintf(msg, "Couldn't initialize SDL: %s\n",SDL_GetError());
		srv_print(msg);
		exit(1);
	}

//	SDL_WM_SetIcon(SDL_LoadBMP("z26win.bmp"), NULL);
        srv_CreateIcon();
        SDL_WM_SetIcon(z26Icon, z26IconMask);

        if (JoystickEnabled)	/* joystick support not disabled with -iJ */
        {
                SDL_InitSubSystem(SDL_INIT_JOYSTICK);
                if ((SDL_NumJoysticks()>0)&&(SDL_NumJoysticks()<17))
                {
			for (i=0; i<SDL_NumJoysticks(); i++)
			{
				JoystickTable[i]=SDL_JoystickOpen(i);
				/* Stelladaptor only has 2 buttons and 2 axes */
				if ((SDL_JoystickNumAxes(JoystickTable[i]) == 2) &&
				    (SDL_JoystickNumButtons(JoystickTable[i]) == 2) &&
				    (SDL_JoystickNumHats(JoystickTable[i]) == 0) &&
				    (SDL_JoystickNumBalls(JoystickTable[i]) == 0) &&
				    (StelladaptorEnabled))
				{
					Stelladaptor[i] = 1;
				}
				else Stelladaptor[i] = 0;
			}
//	                SDL_JoystickEventState(SDL_ENABLE);
		}
		else JoystickEnabled = 0;	/* disable joystick polling */
        }

	if (srv_bpp == 0)
	{
		srv_vin = SDL_GetVideoInfo();
		srv_bpp = srv_vin->vfmt->BitsPerPixel;
		srv_bypp = srv_vin->vfmt->BytesPerPixel;
	}

        switch(VideoMode){
                case 0:
                        if (InWindow)
			{
				width = 330;  height = 280;  Vert = 10;  Horiz = 5;
				if (Effect == 1) width -= 160;
				if (Effect == 2) width -= 160;
			}
			else
			{
				width = 400;  height = 300;  Vert = 20;  Horiz = 40;
			}
                break;
                case 1:
                       if (InWindow)
			{
				width = 330;  height = 250;  Vert = 5;   Horiz = 5;
				if (Effect == 1) width -= 160;
				if (Effect == 2) width -= 160;
			}
			else
			{
				width = 320;  height = 240;  Vert = 0;   Horiz = 0;
			}
                break;
                case 2:
                       if (InWindow)
			{
				width = 330;  height = 210;  Vert = 5;   Horiz = 5;
				if (Effect == 1) width -= 160;
				if (Effect == 2) width -= 160;
			}
			else
			{
				width = 320;  height = 200;  Vert = 0;   Horiz = 0;
			}
                break;
                case 3:
                case 6:
                        if (InWindow)
			{
				width = 660;  height = 550;  Vert = 10;  Horiz = 10;
				if (Effect == 1) width -= 320;
				if (Effect == 2) width -= 160;
			}
			else
			{
	                        width = 800;  height = 600;  Vert = 40;  Horiz = 80;
			}
                break;
                case 4:
                case 7:
                        if (InWindow)
			{
				width = 660;  height = 500;  Vert = 10;   Horiz = 10;
				if (Effect == 1) width -= 320;
				if (Effect == 2) width -= 160;
			}
			else
			{
	                        width = 640;  height = 480;  Vert = 0;   Horiz = 0;
			}
                break;
                case 5:
                case 8:
                        if (InWindow)
			{
				width = 660;  height = 420;  Vert = 10;   Horiz = 10;
				if (Effect == 1) width -= 320;
				if (Effect == 2) width -= 160;
			}
			else
			{
	                        width = 640;  height = 400;  Vert = 0;   Horiz = 0;
			}
                break;
					 /*
					 case 9:
					 {
						 width = 1024; height = 768; Vert = 0; Horiz = 0;
					 }
					 */
                default:
                        if (InWindow)
			{
				width = 330;  height = 280;  Vert = 10;  Horiz = 5;
				if (Effect == 1) width -= 160;
				if (Effect == 2) width -= 160;
			}
			else
			{
				width = 400;  height = 300;  Vert = 20;  Horiz = 40;
			}
                break;
        };
	bpp = 8;
	videoflags = 0;
//	videoflags |= SDL_SWSURFACE;
	if (InWindow == 0)
		videoflags |= SDL_FULLSCREEN;
	videoflags |= SDL_HWSURFACE;

	if (NoRetrace == 0)
	{
		videoflags |= SDL_DOUBLEBUF;
	}

	CreateScreen(width, height, bpp, videoflags);

	if(GrabInput) {
		SDL_WM_GrabInput(SDL_GRAB_ON);
	}

	printf("width %d, height %d, Vert %d, Horiz %d\n",
			width, height, Vert, Horiz);
}


void srv_DestroyScreen()
{
	SDL_Quit();
}


void srv_WindowScreen()
{
	InWindow = !InWindow;
	if (InWindow && (NoRetrace == 0))
	{
		OriginalNoRetrace = NoRetrace;
		NoRetrace = -1;
	}
	if (!InWindow)
	{
		NoRetrace = OriginalNoRetrace;
	}
	srv_CreateScreen();
}

double CurrentFPS = 0;
Uint32 LastFlips = 0;
Uint32 Ticks = 0;
Uint32 ThisFlipTime = 0;
Uint32 LastFlipTime = 0;
Uint32 FirstFlipTime = 0;

Uint32 ThisFlips = 0;

#ifdef UNIX_TIMING

/* proto for select(), needed for -T2 */
#ifdef __BEOS__
#include <net/socket.h> /* Weird place to keep select(), shrug. */
#else
#include <sys/select.h>
#endif

Uint32 get_uticks() {
	struct timeval tv;

	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000000 + tv.tv_usec;
}

int tickadj = 0;
int waits = -1; // expressed in 1/8192 of a second units.

#ifdef LINUX_RTC_TIMING

/* This is used for -T4 mode. */

#include <unistd.h>
#include <linux/rtc.h>
#include <sys/ioctl.h>
#include <sys/fcntl.h>

int then = 0;
int now;

int rtc_fd = -1; // file descriptor for /dev/rtc

void setup_rtc() {
	if( (rtc_fd = open("/dev/rtc", O_RDONLY)) < 0 ) {
		perror("Can't open /dev/rtc");
	} else if(ioctl(rtc_fd, RTC_IRQP_SET, 8192)<0) {
		perror("Can't set /dev/rtc to 8192 interrupts/sec");
		fprintf(stderr,
				"You should run the following command as root:\n\n"
				"\techo 8192 > /proc/sys/dev/rtc/max-user-freq\n\n"
				"You may want to add this command to /etc/rc.d/rc.local\n\n"
				"*** DO NOT RUN z26 AS root! ***\n\n"
				);
		rtc_fd = -1;
	} else if(ioctl(rtc_fd, RTC_PIE_ON, 0) < 0) {
		perror("Can't enable periodic interrupts on /dev/rtc");
		close(rtc_fd);
		rtc_fd = -1;
	} else {
		printf("Initialized Linux /dev/rtc timing\n");
	}
	/* Phew */
}

/* delay until next $waits * 1/8192 seconds.
 * rtc_delay() *must* be the *only* reader from rtc_fd!
 */
void rtc_delay() {
	int interrupts = 0;
	int got;

	if(rtc_fd == -1) setup_rtc();
	if(rtc_fd < 0) {
		flipType = FLIP_CPUHOG;
		printf("Falling back on CPU hog (-T3) timing\n");
		return;
	}

	do {
		read(rtc_fd, &got, sizeof(got));
		interrupts += (got >> 8);
	} while(interrupts < waits);
}

void srv_Flip_rtc() {
	if(then==0) then = get_uticks();

	if(NoRetrace == 0) { // -r0 (disabled)
		SDL_Flip(srv_screen);
		return;
	} else if(NoRetrace != -1) { // -rN
		waits = 8192/NoRetrace;
	} else { // default: autosync based on scanlines in frame & palette
		if(PaletteNumber == 1 || PaletteNumber == 2)
			waits = LinesInFrame * 8192/15584; // was 15680 (50.26)
		else
			waits = LinesInFrame * 8192/15666; // was 15781 (60.24)
	}

	// debugging:
	//	printf("LinesInFrame %d, waits %d\n", LinesInFrame, waits);

	rtc_delay();

	if(Flips++ % 20 == 0) {
		// calculate actual framerate every 20 frames
		now = get_uticks();
		CurrentFPS = (1000000.0*(Flips - LastFlips))/(now - then);
		then = now;
		LastFlips = Flips;
	}
	SDL_UpdateRect(srv_screen, Real_Horiz, Vert, Real_width, height-2*Vert);
}

#endif // defined(LINUX_RTC_TIMING)

/* -T2 mode: */
int diff;
void srv_Flip_unix()
{
	static int start_ticks = 0;
	int Rate;
	int NextTick;
	int Now;
	int sleeptime;
	struct timeval tv;

	if(start_ticks == 0) start_ticks = get_uticks();

	Now = get_uticks() - start_ticks;

	

	//	++Flips;
	if (++Flips == FrameExit/20) FirstFlipTime = Now;

	if (Flips % 20 == 0)
	{
		ThisFlipTime = Now;
		ThisFlips = Flips;
		CurrentFPS = (1000000.0*(ThisFlips - LastFlips))/(ThisFlipTime - LastFlipTime);


		LastFlipTime = ThisFlipTime;
		LastFlips = ThisFlips;
	}

	if (NoRetrace == 0) {
		SDL_Flip(srv_screen);
	} else {
		if (NoRetrace != -1)	{
			Rate = 1000000/NoRetrace;
		} else {
			/* The constants here are derived mathematically, based
				on 60Hz for 262 scanlines and 50Hz for 312. */

			if ((PaletteNumber==1)||(PaletteNumber==2)) /* PAL/SECAM */
				Rate = LinesInFrame*1000000/15600; // was 15556
			else    Rate = LinesInFrame*1000000/15720; // was 15700
		}

		// make rate a little fast to force sync with audio stream
		if (SyncToSoundBuffer) Rate = LinesInFrame*1000000/16000;

		NextTick = Ticks+Rate;

		sleeptime = NextTick-Now+tickadj;
		if (sleeptime > 0)
		{
			/* usleep(sleeptime); // James says select() is better, he's right */
			tv.tv_sec = 0;
			tv.tv_usec = sleeptime;
			select(0, NULL, NULL, NULL, &tv);
		}

		Ticks = get_uticks() - start_ticks;
		diff = Ticks - (Now + sleeptime);

		SDL_UpdateRect(srv_screen, Real_Horiz, Vert, Real_width, height-2*Vert);
	}

}

/* -T3 mode: */
void srv_Flip_cpuhog()
{
	static int Now = 0;
	static int start_ticks = 0;
	int Rate;
	int NextTick;

	if(start_ticks == 0) {
	  	start_ticks = get_uticks();
	}


	if (++Flips == FrameExit/20) FirstFlipTime = Now;

	if (Flips % 20 == 0)
	{
		ThisFlipTime = Now;
		ThisFlips = Flips;
		CurrentFPS = (1000000.0*(ThisFlips - LastFlips))/(ThisFlipTime - LastFlipTime);

		LastFlipTime = ThisFlipTime;
		LastFlips = ThisFlips;
	}

	if (NoRetrace == 0) {
		SDL_Flip(srv_screen);
	} else {
		if (NoRetrace != -1)	{
			Rate = 1000000/NoRetrace;
		} else {
			if ((PaletteNumber==1)||(PaletteNumber==2)) /* PAL/SECAM */
				Rate = LinesInFrame*1000000/15600;
			else    Rate = LinesInFrame*1000000/15720;
		}

		// make rate a little fast to force sync with audio stream
		if (SyncToSoundBuffer) Rate = LinesInFrame*1000000/16000;

		NextTick = Now+Rate+start_ticks;
		//	printf("%lu %lu %d\n", Now, NextTick, Rate);

		while(get_uticks() < NextTick) {
			/* spin */
		}

		/*
		sleeptime = NextTick-Now;
		if (sleeptime > 0)
		{
			tv.tv_sec = 0;
			tv.tv_usec = sleeptime;
			select(0, NULL, NULL, NULL, &tv);
		}
		*/

		Ticks = get_uticks() - start_ticks;
		Now = Ticks;

		SDL_UpdateRect(srv_screen, Real_Horiz, Vert, Real_width, height-2*Vert);
	}

}


#endif


/* Remember, LINUX_RTC_TIMING is only defined if UNIX_TIMING
	is also defined. This function is called srv_Flip() if
	neither is defined, because it's the only flipper we have.
	Otherwise, this is just one of 2 or 3 versions
*/
	
#ifdef UNIX_TIMING
void srv_Flip_sdldelay()
#else
void srv_Flip()
#endif
{
	int Rate;
	int NextTick;
	int Now;

	if (++Flips == FrameExit/20) FirstFlipTime = SDL_GetTicks();

	if (Flips % 20 == 0)
	{
		if ((SDL_GetTicks() - LastFlipTime) > 1000)
		{
			ThisFlipTime = SDL_GetTicks();
			ThisFlips = Flips;
			CurrentFPS = (1000.0*(ThisFlips - LastFlips))/(ThisFlipTime - LastFlipTime);
			LastFlipTime = ThisFlipTime;
			LastFlips = ThisFlips;
		}
	}

	if (fast || NoRetrace == 0)
	{
		SDL_Flip(srv_screen);
	}
	else
	{
		if (NoRetrace != -1)	Rate = 1000/NoRetrace;
                else
                        if ((PaletteNumber==1)||(PaletteNumber==2)) /* PAL/SECAM */
                                Rate = LinesInFrame*1000/15556;
                        else    Rate = LinesInFrame*1000/15700;

// make rate a little fast to force sync with audio stream

                if (SyncToSoundBuffer) Rate = LinesInFrame*1000/16000;

		NextTick = Ticks+Rate;
		Now = SDL_GetTicks();

		//	NextTick = Ticks + Rate; /* is this right? -BKW
		if ((NextTick-Now) > 0)
			SDL_Delay(NextTick-Now);
		Ticks = SDL_GetTicks();

//                SDL_UpdateRect(srv_screen, 0, 0, 0, 0);
                SDL_UpdateRect(srv_screen, Real_Horiz, Vert, Real_width, height-2*Vert);
	}

}

#ifdef UNIX_TIMING
/* Decide which timing method to use and use it */
void srv_Flip() {
	if(Flips == 20)
		gettimeofday(&start_tv, NULL);

	if(fast) {
		srv_Flip_sdldelay();
		return;
	}

	switch(flipType) {
#  ifdef LINUX_RTC_TIMING
		case FLIP_LINUX_RTC:
			srv_Flip_rtc();
			break;
#  endif
		case FLIP_CPUHOG:
			srv_Flip_cpuhog();
			break;

		case FLIP_UNIX:
			srv_Flip_unix();
			break;

		default:
		case FLIP_SDL_DELAY:
			srv_Flip_sdldelay();
			break;
	}
}
#endif

void srv_CopyLoop( void (*copy)(), int sp_inc)
{
	int i;

	for (i=0; i<MaxLines; ++i)
        {
        	(*copy)();
                emu_pixels += 160;
		emu_pixels_prev += 160;
                screen_pixels += sp_inc;
        }
}

void srv_CopyDouble( void (*copy)(), int sp_inc)
{
	int i;

	for (i=0; i<MaxLines; ++i)
        {
        	(*copy)();
		screen_pixels += sp_inc;
		(*copy)();
                emu_pixels += 160;
		emu_pixels_prev += 160;
                screen_pixels += sp_inc;
        }
}

int odd = 0;

void srv_PixelLogic()
{
	void (*wide)();
	void (*medium)();
	void (*narrow)();
	void (*triple)();

	int bpp = srv_screen->format->BytesPerPixel;

	if (Phosphor && NoRetrace && !DoInterlace)
	{
		wide =   DrawScanLineAverage[3][bpp-1];
		triple = DrawScanLineAverage[2][bpp-1];
		medium = DrawScanLineAverage[1][bpp-1];
		narrow = DrawScanLineAverage[0][bpp-1];

	}
        else if ((DisableCompareCopy!=0)||((Flips & 0x7)==0x7))
	{
		wide =   DrawScanLineLinear[3][bpp-1];
		triple = DrawScanLineLinear[2][bpp-1];
		medium = DrawScanLineLinear[1][bpp-1];
		narrow = DrawScanLineLinear[0][bpp-1];
	}
	else
	{
		wide =   DrawScanLineCompare[3][bpp-1];
		triple = DrawScanLineCompare[2][bpp-1];
		medium = DrawScanLineCompare[1][bpp-1];
		narrow = DrawScanLineCompare[0][bpp-1];
	}

	screen_pixels = srv_buffer + Horiz*bpp + (Vert)*srv_pitch;

	if (Effect == 1)
	{
		wide = medium;
		medium = narrow;
		if (InWindow)
		{
			Real_Horiz = Horiz;
			Real_width = width-Real_Horiz*2;
		}
		else
		{
			screen_pixels += (srv_screen->w/4)*bpp;
			Real_Horiz = Horiz+srv_screen->w/4;
			Real_width = width-Real_Horiz*2;
		}
	}
	else if (Effect == 2)
	{
		wide = triple;
		medium = narrow;
		if (InWindow)
		{
			Real_Horiz = Horiz;
			Real_width = width-Real_Horiz*2;
		}
		else
		{
			if (width <= 400)
			{
				screen_pixels += (srv_screen->w/4)*bpp;
				Real_Horiz = Horiz+srv_screen->w/4;
				Real_width = width-Real_Horiz*2;
			}
			else
			{
				screen_pixels += (srv_screen->w/8)*bpp;
				Real_Horiz = Horiz+srv_screen->w/8;
				Real_width = width-Real_Horiz*2;
			}
		}
	}
	else
	{
		Real_Horiz = Horiz;
		Real_width = width-Real_Horiz*2;
	}

	switch(VideoMode)
	{
	case 3: 
	case 4: 
	case 5:
                if ((DoInterlace) && (odd & 1)) screen_pixels += srv_pitch;
		srv_CopyLoop(wide, 2*srv_pitch);
		break;

	case 6: 
	case 7: 
	case 8:
	//	case 9:
		srv_CopyDouble(wide, srv_pitch);
		break;

	default:
		srv_CopyLoop(medium, srv_pitch);
		break;
	}
}

void srv_CopyScreen()
{
	/* int i,j;*/
	/* db *p;*/
	/* db *q;*/
	/* db ch; */
	/* int bpp = srv_screen->format->BytesPerPixel; */

        odd++;                  // alternate startline for interlaced display

	if ( SDL_LockSurface(srv_screen) < 0 ) 
	{
		sprintf(msg, "Couldn't lock display surface: %s\n\nExiting...", SDL_GetError());
		srv_print(msg);
		exit(1);
		return;
	}

	srv_buffer = srv_screen->pixels;
	srv_pitch = srv_screen->pitch;

	emu_pixels = ScreenBuffer;
        emu_pixels_prev = ScreenBufferPrev;

	srv_PixelLogic();

	if((NoRetrace == 0) || (DoInterlace && (VideoMode >= 3) && (VideoMode <= 5)))
        {
                screen_buffer_count = (screen_buffer_count + 1) & 0x03;

                switch(screen_buffer_count)
                {
                        case 0:
                                ScreenBuffer = RealScreenBuffer1;
                                ScreenBufferPrev = RealScreenBuffer2;
                        break;
                        case 1:
                                ScreenBuffer = RealScreenBuffer3;
                                ScreenBufferPrev = RealScreenBuffer4;
                        break;
                        case 2:
                                ScreenBuffer = RealScreenBuffer2;
                                ScreenBufferPrev = RealScreenBuffer1;
                        break;
                        case 3:
                                ScreenBuffer = RealScreenBuffer4;
                                ScreenBufferPrev = RealScreenBuffer3;
                        break;
                }
        }
        else
        {
                screen_buffer_count = (screen_buffer_count + 1) & 0x01;

                switch(screen_buffer_count)
                {
                        case 0:
                                ScreenBuffer = RealScreenBuffer1;
                                ScreenBufferPrev = RealScreenBuffer2;
                        break;
                        case 1:
                                ScreenBuffer = RealScreenBuffer2;
                                ScreenBufferPrev = RealScreenBuffer1;
                        break;
                }
        }

	if (ShowLineCount)
	{
		show_scanlines();
//		show_FPS();
	}

	SDL_UnlockSurface(srv_screen);
//        SDL_UpdateRect(srv_screen, 0, 0, 0, 0);
}

/*
** sound stuff
*/

/*
extern Tia_process();
*/

void srv_lock_audio()
{
	SDL_LockAudio();
}



void srv_unlock_audio()
{
	SDL_UnlockAudio();
}

Uint8   *DMABuf;
int	bufsize;

void fillerup(void *unused, Uint8 *stream, int len)
{
	int i;

	/* These 2 vars used by Tia_process() */
	DMABuf = stream;
	bufsize = len;

	Tia_process();

	/* This implements the -S flag */
	if(signed_audio) {
		for(i=0; i<len; i++) {
			/* altering stream or DMABuf here seems to
				cause segfaults. SDL thread issue.
				Unfortunately z26 wasn't originally written with
				thread safety in mind... */
			*(stream + i) ^= 128;
		}
	}
}

void srv_sound_on()
{
	SDL_AudioSpec spec;
#ifdef DEBUG_AUDIO_SPEC
	SDL_AudioSpec got_spec;
#endif

	if (quiet==0)
	{
                if ( SDL_InitSubSystem(SDL_INIT_AUDIO) < 0 ) 
		{
			sprintf(msg, "Couldn't initialize SDL: %s\n",SDL_GetError());
			srv_print(msg);
			exit(1);
		}

		spec.callback = fillerup;
                if((PaletteNumber==1)||(PaletteNumber==2)) spec.freq = 31113;
                                                /* PAL or SECAM */
                else spec.freq = 31400;         /* NTSC */
		//	spec.format = signed_audio ? AUDIO_S8 : AUDIO_U8;

		spec.format = AUDIO_U8;
		spec.channels = 1;
		spec.samples = SQ_Max/3;	/* 1536 */

#ifdef DEBUG_AUDIO_SPEC
		if ( SDL_OpenAudio(&spec, &got_spec) < 0 ) 
#else
		if ( SDL_OpenAudio(&spec, NULL) < 0 ) 
#endif
		{
			sprintf(msg, "Couldn't open audio: %s\n", SDL_GetError());
			srv_print(msg);
			exit(2);
		}
#ifdef DEBUG_AUDIO_SPEC
		fprintf(stderr, "Wanted   ");
		dump_audio_spec(spec);
		fprintf(stderr, "Got      ");
		dump_audio_spec(got_spec);
#endif

		SDL_PauseAudio(0);
	}
}

void srv_sound_off()
{
	if (quiet==0)
	{
		SDL_CloseAudio();
	}
}


/*
** mouse stuff
*/

db srv_mouse_button;
int srv_micky_x, srv_micky_y;
int srv_mouse_x, srv_mouse_y;

db srv_crap_button;
int srv_crap_x, srv_crap_y;

/*
void srv_get_mouse_button_status()
{
	srv_mouse_button = SDL_GetMouseState(&srv_mouse_x, &srv_mouse_y);
}
*/

void srv_get_mouse_movement()
{
	srv_mouse_button = SDL_GetRelativeMouseState(&srv_micky_x, &srv_micky_y);
	if (MouseRude)
	{
		SDL_WarpMouse(width/2,height/2);
		srv_Events();
		srv_crap_button = SDL_GetRelativeMouseState(&srv_crap_x, &srv_crap_y);
	}
}


/*
** event handler
*/

void srv_Events()
{
	SDL_Event event;
	dd sc;

//	static int i=0;
//
//	if (++i%10 != 0) return;

	if (JoystickEnabled) SDL_JoystickUpdate();	/* poll joysticks once per frame */

	while ( SDL_PollEvent(&event) ) {
		switch (event.type) {

			case SDL_KEYDOWN:
#ifdef NEW_KEYBOARD
				sc = event.key.keysym.sym;
#else
				sc = event.key.keysym.scancode & 0x7f;
#endif
				KeyTable[sc] = 0x80;
				break;

			case SDL_KEYUP:
#ifdef NEW_KEYBOARD
				sc = event.key.keysym.sym;
#else
				sc = event.key.keysym.scancode & 0x7f;
#endif
				KeyTable[sc] = 0;
				break;

			case SDL_QUIT:
				srv_done = 1;
				break;

			case SDL_JOYBUTTONDOWN:
				if (event.jbutton.which < 17)
					JoystickButton[event.jbutton.which][event.jbutton.button] = 0x80;
				break;
				
			case SDL_JOYBUTTONUP:
				if (event.jbutton.which < 17)
					JoystickButton[event.jbutton.which][event.jbutton.button] = 0;
				break;

			case SDL_JOYAXISMOTION:
				if (event.jaxis.which < 17)
					JoystickAxis[event.jaxis.which][event.jaxis.axis] = event.jaxis.value;
				break;
			default:
				break;
		}
	}
}

#ifdef DEBUG_AUDIO_SPEC
void dump_audio_spec(SDL_AudioSpec spec) {
	char *fmt;

	switch(spec.format) {
		case AUDIO_U8:
			fmt = "Unsigned 8-bit";
			break;

		case AUDIO_S8:
			fmt = "Signed 8-bit";
			break;

		case AUDIO_U16:
			fmt = "Unsigned 16-bit";
			break;

		case AUDIO_S16:
			fmt = "Signed 16-bit";
			break;

		default:
			fmt = "Unknown";
			break;
	}

	fprintf(stderr,
			"%s %dHz %d channels, silence %d, buffer %d bytes\n",
			fmt, spec.freq, spec.channels, spec.silence, spec.size);

}
#endif


/*
 * $Log: sdlsrv.c,v $
 * Revision 1.6  2004/05/23 21:34:00  urchlay
 *
 * partial reimplementation of main.asm in C. Not complete, just checking
 * in the work in progress.
 *
 * Revision 1.5  2004/05/14 18:17:51  urchlay
 *
 * FPS calculation no longer takes into account the first 20 frames of
 * emulation, since they're generally not valid frames anyway due to the
 * auto-adjustment.
 *
 * Revision 1.4  2004/05/09 21:31:10  urchlay
 *
 * Added -G option to grab keyboard/mouse events with SDL_WM_GrabInput().
 * I need this so I can switch video modes while z26 is running (normally,
 * Alt-1 through Alt-9 in my environment are used to switch virtual
 * desktops, and z26 never sees these keystrokes). This might also
 * disable the Windows keys if you use it on Windows (not tested yet),
 * which could be good or bad, depending on whether you hit the Win keys
 * more often on purpose or by accident :)
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
 * Revision 1.2  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
