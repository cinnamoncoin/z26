

/*
	This is where we'll put functions that we convert from asm to C,
	for now.

	Later on, we may want to move these into more appropriate files, or
	break them up into new files of their own.
*/

#ifdef C_INITDATA
/* asm version in init.asm */
Uint8 RiotRam[128]; /* RIOT RAM (must be zero initially) */
Uint8 TIA[64];      /* TIA registers (also zeroed) */
Uint8 Ram[2048];    /* Extra RAM (used or not depends on bankswitch scheme) */

Uint32 Frame = 0;     /* Frame counter */
Uint32 PrevFrame = 0; /* Previous value of frame counter */

Uint32 VBlanking = 0; /* 0 if vblanking, -1 otherwise */
Uint8  VBlank = 0;    /* VBlank flag */
Uint8  VSyncFlag = 0; /* VSync flag */

Uint32 ScanLine = 0;  /* Current scan line */
Uint32 OurBailoutLine = 0; /* Initial bailout line (fine tune if exceeded) */

Uint8  WByte = 0;     /* Byte to write */

char *DisplayPointer = 0; // should init to RealScreenBuffer



void InitData() {
	int i;

	OurBailoutLine = 1000;
	ScanLine = 1;
	VBlanking = 1;

	for(i=0; i<sizeof(RiotRam); i++)
		RiotRam[i] = 0;

	for(i=0; i<sizeof(TIA); i++)
		TIA[i] = 0;

	for(i=0; i<sizeof(Ram); i++)
		Ram[i] = 0;

	DisplayPointer = ScreenBuffer;

	InitCVars();
	Init_CPU();
	Init_CPUhand();
	Init_TIA();
	Init_Riot();
	Init_P2();
	Init_Starpath();
	Init_Tiasnd();
	Init_SoundQ();

	RandomizeRIOTTimer();
}

void cleanup() {
	kv_CloseSampleFile();
	srv_sound_off();
	srv_DestroyScreen();
}
#endif

/*------------------------------------------------------------*/

#ifdef C_INITSERV
/* x86 asm version in service.asm */
void Init_Service() {
	srv_sound_on();
	TIAGraphicMode();
}
#endif

/*------------------------------------------------------------*/

#ifdef C_TIAGRAPH
/* x86 asm version in service.asm */
void TIAGraphicMode() {
	/* If user gave a valid video mode, use it, or else use default of 0 */
	if(VideoMode > 8) VideoMode = 0;

	position_game(); /* set game's vertical position */
	srv_CreateScreen(); /* set up the SDL display */
	ClearScreenBuffers(); /* clear the 4 buffers for screen comparing */
}
#endif

/*------------------------------------------------------------*/

/*
#ifdef C_BLANKBUF
// service.asm (this C version not complete!)
	// this one is ugly, and probably will introduce assumptions
	// about pointer size.
void BlankBufferEnd() {
	char *p = DisplayPointer;
	Uint32 max = MaxLines * 160;

	if(p > (ScreenBuffer + max)) return;

	p = 
#endif
}
*/

/*------------------------------------------------------------*/

#ifdef C_SQVARS
/* x86 asm version in soundq.asm */
Uint32 SQ_Count;
char *SQ_Input;  /* pointer to next available byte for storing */
char *SQ_Output; /* pointer to next available byte for fetching */
char *SQ_Top;
#else
extern Uint32 SQ_Count;
extern char *SQ_Input;
extern char *SQ_Output;
extern char *SQ_Top;
#endif

/*------------------------------------------------------------*/

#ifdef C_INITSQ
/* x86 asm version in soundq.asm */

/* Initialize sound queue */
void Init_SoundQ() {
	SQ_Input = SoundQ;
	SQ_Output = SoundQ;
	SQ_Count = 0;
	SQ_Top = SoundQ + SQ_Max + 1;
}
#endif

/*------------------------------------------------------------*/

#ifdef C_SQTEST
/* x86 asm version in soundq.asm */

	/*
	*
	* routine to get status of sound queue
	*
	* returns:
	*
	*    -1 if sound queue full and no room for more output
	*     0 if there's too much room      (less than 1/2 full)
	*     1 if there's just enough room   (more than 1/2 full)
	*
	*/

int SQ_Test() {
	/* if not doing sound at all, pretend the queue is *just right* */
	if(quiet) return 1;

	if(SQ_Count >= SQ_Max) return -1; /* already full? */
	if(SQ_Count <= SQ_Max/2) return 0; /* less than 1/2 full? */
	return 1; /* else it's just right */
}
#endif

/*------------------------------------------------------------*/

#ifdef C_SQSTORE
/* x86 asm version in soundq.asm */

void SQ_Store(char sample) {
	if(quiet) return;

	/* SQ_Store() gets called from the audio callback.
		The SDL spec says we aren't supposed to lock the audio
		during the callback.
		But not doing so causes hangs on SMP machines (Win and Linux both).
		So we protect it with a #define, in case we need to easily get rid
		of these calls later.
	*/
#ifdef LOCK_AUDIO_SQ
	srv_lock_audio();
#endif

	*SQ_Input++ = sample;
	SQ_Count++;

	if(SQ_Input >= SQ_Top)
		SQ_Input = SoundQ;

#ifdef LOCK_AUDIO_SQ
	srv_unlock_audio();
#endif

}
#endif

/*------------------------------------------------------------*/

#ifdef C_QSBYTES
/* x86 asm version in soundq.asm */

/* Put sound bytes into buffer.
	Called once per scan line.
*/
void QueueSoundBytes() {
	do {
		QueueSoundByte();
		QueueSoundByte();
	} while(SQ_Test() == 0);
}

#endif

/*------------------------------------------------------------*/

#ifdef C_QSBYTE

#  ifndef C_SQSTORE
#    error C_QSBYTE requires C_SQSTORE to be defined as well.
#  endif

/* x86 asm version in soundq.asm */

/* Put a byte in the sound queue.
	Called by QueueSoundBytes()

	Unfortunately, it's easy to confuse these 2 names:
	QueueSoundByte() and QueueSoundBytes().
*/

void QueueSoundByte() {
	while(1)
	{
		if (SQ_Test() != -1) break;
		if(!SyncToSoundBuffer) return;
		srv_Events();
	}
	kv_GetNextSampleByte();		/* this routine puts byte into SampleByte */
	SQ_Store((TIA_Sound_Byte() + SampleByte) >> 1);
}

#endif

/*------------------------------------------------------------*/

#ifdef C_TIAPROC
/* x86 asm version in soundq.asm */

/* Routine to put sound in the sound buffer.
	This gets called by the callback fillerup() in sdlsrv.c
	Since it's called by the callback, it *runs in a separate thread*.
	This means I have to go through every function Tia_process() calls,
	note all the variables it uses, then put an audio lock around all
	*other* uses of those variables. Ouch.

	This isn't specific to C: the asm version should have been written
	this way, too.

Functions:
Tia_process
QueueSoundBytes
QueueSoundByte
SQ_Store
SQ_Test
KidVid_Sound_Byte
TIA_Sound_Byte
ShiftRegister9
Clock_Pitfall2
kv_GetNextSampleByte
kv_SetNextSong

Vars:
bufsize
DMABuf
SyncToSoundBuffer - maybe not needed (doesn't change during run)
SQ_Input
SQ_Count
SoundQ
SQ_Top
SQ_Output
sreg

Ugh. Until I get this figured out, here's a band-aid:
 */
#  ifndef C_SQSTORE
#    error C_TIAPROC requires C_SQSTORE to be defined as well.
#  endif

/* There's no good reason why, but that stops the segfaults for me.
	It's not the *correct* solution I don't think. */

void Tia_process() {
	db al_reg;
	char *esi_reg; /* TODO: rename these to something meaningful */
	char *edi_reg;
	int ecx_reg;

	/* If not enough sound is available, we queue some up. */
	if(SQ_Count < bufsize) { /* shouldn't this be < instead of <= ? -bkw */
		QueueSoundBytes();
	}

	ecx_reg = bufsize; /* number of bytes */
	edi_reg = DMABuf;
	esi_reg = SQ_Output;

	while(ecx_reg) {
		al_reg = *esi_reg++;

		/* Implement circular buffer */
		if(esi_reg >= SQ_Top)
			esi_reg = SoundQ;

		*edi_reg++ = al_reg;

		ecx_reg--;
	}

	SQ_Count -= bufsize;
	SQ_Output = esi_reg;

}
#endif

/*------------------------------------------------------------*/

#ifdef C_RANDRIOT
/* x86 asm version in riot.asm */
Uint32 Timer;

void RandomizeRIOTTimer() {
	/* Seconds gets set in globals.c, see riot.asm for details */
	Timer = ((Seconds & 0xff) << 10);
}
#endif

/*------------------------------------------------------------*/

#ifdef C_POSGAME
/* x86 asm version in position.asm */
Uint32 TopLine = 0;    /* top line of display */
Uint32 BottomLine = 0; /* bottom line of display */

dd StartLineTable[] = {
/* NTSC, PAL, SECAM */
	28,   28,   28,      /*  400x300  */
	22,   42,   42,      /*  320x240  */
	42,   58,   58,      /*  320x200  */
	28,   28,   28,      /*  800x600  */
	22,   42,   42,      /*  640x480  */
	42,   58,   58,      /*  640x400  */
	28,   28,   28,      /*  800x600  */
	22,   42,   42,      /*  640x480  */
	42,   58,   58       /*  640x400  */
};

dd MaxLineTable[] = {
	266, /* 400x300 */
	240, /* 320x240 */
	200, /* 320x200 */
	266, /* 800x600 */
	240, /* 640x480 */
	200, /* 640x400 */
	266, /* 800x600 */
	240, /* 640x480 */
	200  /* 640x400 */
};

void position_game() {
	/* Set up max # of lines to display based on video mode */
	/* VideoMode had better be 0-8, we don't check */
	if(MaxLines > MaxLineTable[VideoMode])
		MaxLines = MaxLineTable[VideoMode];

	CFirst = UserCFirst;
	if(UserCFirst == 0xffff) {
		/* user didn't pick a line number */
		CFirst = DefaultCFirst;

		/* does game have recommended starting line? */
		if(DefaultCFirst == 0xffff) {
			/* no. */

			/* Ensure valid palette (default to NTSC if invalid) */
			if(PaletteNumber > 2)
				PaletteNumber = 0;
			
			CFirst = StartLineTable[VideoMode * 3 + PaletteNumber];
		}
	}

	/* at this point, CFirst is valid (I hope) */
	/* Now, adjust it based on video mode size */

	if(MaxLines >= 400) {
		if (CFirst != 0) /* frogpond or pharcrs? */
			CFirst = 1; /* no, this is ultimate reality mode */
	}

	OldCFirst = CFirst; /* remember starting line for homing display */
	TopLine = CFirst; /* set up in case there's no vsync (like bowg_tw.bin) */
	BottomLine = CFirst + MaxLines;
}
#endif

#ifdef C_TIASND /* reimplementation of tiasnd.asm - BROKEN */
#include "tiasnd.c"
#endif

#ifdef C_BANKVARS /* vars from banks.asm (except jump tables) */

dd RomBank = 0; /* Rom bank pointer for F8 & F16 */

/* Parker Brother's ROM Slices */

dd PBSlice0	= 0;
dd PBSlice1	= 1*0x400;
dd PBSlice2	= 2*0x400;
dd PBSlice3	= 7*0x400; /* points to 1K bank #7 - this one doesn't change */

/* Tigervision ROM Slices */

dd TVSlice0 = 0;
dd TVSlice1 = 3*0x800; /* points to 2K bank #3 - this one doesn't change */

/* Tigervision 32 ROM Slices */

dd TVSlice032 = 0;
dd TVSlice132 = 15*0x800; /* points to 2K bank #15 - this one doesn't change */

/* M-Network ROM Slices */

dd MNSlice0	= 0;
dd MNSlice1	= 7*0x800; /* points to 2K bank #7 - this one doesn't change */

/* M-Network RAM Slices */

dd MNRamSlice = 0; /* which 256 byte ram slice */

/* CompuMate RAM state */

dd CMRamState= 0x10; /*  RAM enabled - read/write state */

#endif /* defined(C_BANKVARS) */

#ifdef C_SETUPBANKS /* code from banks.asm */

#  ifndef C_INITDATA
extern db *Ram;
#  endif

extern void SetPitfallII();
extern db Pitfall2;
extern db Starpath;

void DetectBySize();
void SetupCommaVidRam();
void SetStarpath();

#  ifndef C_BANKVARS /* if we didn't include the C versions, use the asm */

extern dd RomBank;
extern dd PBSlice0;
extern dd PBSlice1;
extern dd PBSlice2;
extern dd PBSlice3;
extern dd TVSlice0;
extern dd TVSlice1;
extern dd TVSlice032;
extern dd TVSlice132;
extern dd MNSlice0;
extern dd MNSlice1;
extern dd MNRamSlice;
extern dd CMRamState;

#  endif

/* setup bank switching scheme */
void SetupBanks() {
	RomBank = 0;
	PBSlice0 = 0;
	PBSlice1 = 1 * 0x400;
	PBSlice2 = 2 * 0x400;
	PBSlice3 = 7 * 0x400;
	TVSlice0 = 0;
	TVSlice1 = 3 * 0x800;
	TVSlice032 = 0;
	MNSlice0 = 0;
	MNSlice1 = 7 * 0x800;
	MNRamSlice = 0;
	Pitfall2 = 0;
	Starpath = 0;

	/* make last 2k bank fixed for 3F games: */
	TVSlice132 = CartSize - 2048;

	if( BSType == 0 )
		DetectBySize();
	else if( BSType == 1 )
		SetupCommaVidRam();
	else if( BSType == 10 ) {
		RomBank = 0x3000;
		InitCompuMate();
	}
}

void DetectBySize() {

	if( CartSize % 8448 == 0 ) { /* multiple of 8448 bytes? */
		SetStarpath(); /* Supercharger image */
		return;
	}

	if( CartSize > 0x10000 ) {
		BSType = 11; /* large TigerVision game */
		return;
	}

	switch(CartSize) {
		case 0x2000: /* 8k cart */
			{
				RomBank = 0x1000; /* need this for moonsweep and lancelot */
				BSType = 20;
				break;
			}

		case 0x3000: /* 12k cart */
			{
				BSType = 19;
				break;
			}

		case 0x4000: /* 16k cart */
			{
				BSType = 16;
				break;
			}

		case 0x8000: /* 32k cart */
			{
				BSType = 17;
				break;
			}

		case 0x28ff: /* Pitfall II cart */
			{
				SetPitfallII();
				break;
			}

		case 0x10000: /* Megaboy 64k cart */
			{
				BSType = 18;
				break;
			}

		case 6144: /* Supercharger image */
			{
				SetStarpath();
				break;
			}

		default: /* 4k (non bank-switched)? */
			break;
	}
}

void SetupCommaVidRam() {
	int i;

	for(i=0; i<2048; i++)
		Ram[i] = CartRom[i];
}


#endif

			 
#ifdef C_INITCPUH /* vars from cpuhand.asm plus Init_CPUhand() */

dd TIACollide = 0;
dd RT_Reg = 0;
dd RetWd = 0;

void Init_CPUhand() {
	InputLatch[0] = InputLatch[1] = 0x80;
	TIACollide = 0;
	RT_Reg = 0;
	RetWd = 0;
}

#endif

#ifdef C_INITSPATH /* vars from starpath.asm plus Init_Starpath() */

dd SP_Scheme[] = { /* table of bankswitch schemes */
	2 * 0x800,	3 * 0x800,
	0 * 0x800,	3 * 0x800,
	2 * 0x800,	0 * 0x800,
	0 * 0x800,	2 * 0x800,
	2 * 0x800,	3 * 0x800,
	1 * 0x800,	3 * 0x800,
	2 * 0x800,	1 * 0x800,
	1 * 0x800,	2 * 0x800
};

dd SPSlice0 = 0;
dd SPSlice1 = 3 * 0x800;

dd SP_PrevAdr = 0;

/* byte(s) to write to RAM: */
dd SP_RamWord = 0; /* asm code uses individual bytes: PLATFORM DEPENDENT! */

db Starpath = 0;
db SP_WriteEnable = 0;
db SP_PulseDelay = 7;

void Init_Starpath() {
	SPSlice0 = 0;
	SPSlice0 = 3*0x800;
	Starpath = 0;
	SP_WriteEnable = 0;
	SP_RamWord = 0;
	SP_PulseDelay = 7;
	SP_PrevAdr = 0;
}

#endif

#ifdef C_MAINLOOP /* original code in main.asm */

/* THIS DOESN'T WORK YET */

void ScanFrame();

void emulator() {
	/* omit business about ModuleSP, as the compiler handles such
		things for us */

	InitData();
	RecognizeCart();
	SetupBanks();
	Reset();
	Init_Service();
	Controls();

	/* ExitEmulator gets set by Controls() if the user presses
		Escape */
	while( !ExitEmulator ) {
		VSync();
		srv_CopyScreen();
		ScanFrame();
		Controls();

		while(GamePaused) {
			Controls();
		}
	}

}

void ScanFrame() {

	/* Reset display pointer */
	ScreenBuffer = DisplayPointer;

	do {
		/* Generate a raster line */
		nTIALineTo();

		ScanLine++;

		/* adjust RClock for next line */
		RClock -= 76;

		/* if charging capacitors... */
		if( !(VBlank & 0x80) )
			/* and if not fully charged... */
			if(ChargeCounter < 0x80000000)
				/* add some charge. */
				ChargeCounter++;

		if( ScanLine >= OurBailoutLine) {
			BailoutLine = OurBailoutLine;
			PrevLinesInFrame = LinesInFrame;
			LinesInFrame = ScanLine-1;

			Frame++;
			ScanLine = 1;
		}

	} while (Frame == PrevFrame); /* Frame gets updated by tiawrite.asm */

	/* Done with frame. Blank rest of screen buffer, update PrevFrame,
		and return to caller. */
	BlankBufferEnd();
	Frame = PrevFrame;

}

#endif

/*
 * $Log: c_core.c,v $
 * Revision 1.13  2004/05/23 21:34:00  urchlay
 *
 * partial reimplementation of main.asm in C. Not complete, just checking
 * in the work in progress.
 *
 * Revision 1.12  2004/05/19 01:16:56  urchlay
 *
 * Fixed C code from banks.asm so you can compile with both -DC_BANKVARS
 * and -DC_SETUPBANKS
 *
 * Revision 1.10  2004/05/18 04:56:11  urchlay
 *
 * More variable and initialization code migration.
 *
 * Revision 1.9  2004/05/18 02:17:16  urchlay
 *
 * Great Variable Migration from asm to C, partly complete.
 *
 * Revision 1.8  2004/05/15 17:00:45  urchlay
 *
 * Initial incomplete implementation of TIA sound code in C. This isn't
 * done yet, but at least compiles, and you can play Pitfall with it (but
 * not Pitfall II).
 *
 * Revision 1.7  2004/05/09 05:00:16  tazenda
 * fix C version of QueueSoundByte
 *
 * Revision 1.6  2004/05/09 00:38:29  urchlay
 *
 * Ported a few more functions to C. Tia_process() is still acting weird.
 *
 * Moved the C core defines to conf/c_core.mak, so we only have one place
 * to modify them, no matter which target we're building for. Used
 * `sinclude' to include it, which won't give an error if the file is
 * missing entirely. It'll just not define any of the C core stuff.
 *
 * Revision 1.5  2004/05/08 18:52:36  urchlay
 *
 * restored original asm comments to c_core.c functions
 *
 * Revision 1.4  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
