/*
** z26 command line stuff
*/


/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


/*
** load next Starpath Rom
*/

#define SC_LOAD0_SAVE 515330    // where in ROM buffer to save Load 0

void cli_LoadNextStarpath(void)
{
    dd i,j, LoadCount, LoadNum;
	dd pageadr, pagebyte, pagecount;
	db *p;
	db *q;

        SC_StartAddress=0;
        LoadCount=61;
        LoadNum=SC_ControlByte;
        for (i = 1; i < 61; i++)
        {
                if (CartRom[i*8448 + 0x2005] == LoadNum) LoadCount=i;
        }
        LoadNum=LoadCount;

        if (LoadNum == 61) return;

        pagecount = CartRom[LoadNum*8448 + 0x2003];

	for (i = 0; i < pagecount; i++)
	{
                pagebyte = CartRom[LoadNum*8448 + 0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

                p = CartRom + pageadr;
                q = CartRom + LoadNum*8448 + i*256;

		for (j = 0; j < 256; j++)
		{
			*p++ = *q++;
		}
	}
        SC_StartAddress=CartRom[LoadNum*8448+0x2001]*256+CartRom[LoadNum*8448+0x2000];
        SC_ControlByte=CartRom[LoadNum*8448+0x2002];
}

/*
** reload a Starpath file
*/

void cli_ReloadStarpath(void)
{
	dd i,j;
	dd pageadr, pagebyte, pagecount;
	db *p;
        db *q;

        if(CartSize == 6144)
        {
                for(i = 0; i < 6144; i++)
                {
                        CartRom[i]=CartRom[SC_LOAD0_SAVE+i];
                }
                SC_StartAddress=CartRom[0x17fd]*256+CartRom[0x17fc];
                SC_ControlByte=0x0d;
        }else
        {
	pagecount = CartRom[0x2003];

	for (i = 0; i < pagecount; i++)
	{
		pagebyte = CartRom[0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

                p = CartRom + pageadr;
                q = CartRom + SC_LOAD0_SAVE + i*256;
		for (j = 0; j < 256; j++)
		{
                        *p++ = *q++;
		}
	}

        SC_StartAddress=CartRom[0x2001]*256+CartRom[0x2000];
        SC_ControlByte=CartRom[0x2002];
        }
}


#define CRC16_REV 0xA001	/* CRC-16 polynomial reversed */
#define CRC32_REV 0xA0000001	/* CRC-32 polynomial reversed */


/*
** used for generating the CRC lookup table
*/

dd crcrevhware(dd data, dd genpoly, dd accum) 
{
  int i;
  data <<= 1;
  for (i=8;i>0;i--) {
    data >>= 1;
    if ((data ^ accum) & 1)
      accum = (accum >> 1) ^ genpoly;
    else
      accum >>= 1;
    }
  return(accum);
}


/*
** init the CRC lookup table
*/

/*
void init_crc(void) 
{
  int i;
  for (i=0;i<256;i++)
    crctab[i] = crcrevhware(i,CRC32_REV,0);
}
*/

void init_crc(void)
{
}

/*
** update CRC
*/

void ucrc(unsigned char data) 
{
   crc = (crc >> 8) ^ crcrevhware((crc ^ data) & 0xff,CRC32_REV,0);
}

/*
void ucrc(unsigned char data) 
{
   crc = (crc >> 8) ^ crctab[(crc ^ data) & 0xff];
}
*/

/*
** load a ROM image
**
** gets called from gui also -- special ROM setup can go here
*/

int cli_LoadROM(unsigned char *filename)
{

unsigned char SCBIOS[188] = { 
0xa5,0xfa,0x85,0x81,0x4c,0x0e,0xf8,0xff,
0xff,0xff,0xa9,0x00,0x85,0x81,0xa9,0x00,
0x85,0x1b,0x85,0x1c,0x85,0x1d,0x85,0x1e,
0x85,0x1f,0x85,0x19,0x85,0x1a,0x85,0x08,
0x85,0x01,0xa9,0x10,0x85,0x21,0x85,0x02,
0xa2,0x07,0xca,0xca,0xd0,0xfd,0xa9,0x00,
0x85,0x20,0x85,0x10,0x85,0x11,0x85,0x02,
0x85,0x2a,0xa9,0x05,0x85,0x0a,0xa9,0xff,
0x85,0x0d,0x85,0x0e,0x85,0x0f,0x85,0x84,
0x85,0x85,0xa9,0xf0,0x85,0x83,0xa9,0x74,
0x85,0x09,0xa9,0x0c,0x85,0x15,0xa9,0x1f,
0x85,0x17,0x85,0x82,0xa9,0x07,0x85,0x19,
0xa2,0x08,0xa0,0x00,0x85,0x02,0x88,0xd0,
0xfb,0x85,0x02,0x85,0x02,0xa9,0x02,0x85,
0x02,0x85,0x00,0x85,0x02,0x85,0x02,0x85,
0x02,0xa9,0x00,0x85,0x00,0xca,0x10,0xe4,
0x06,0x83,0x66,0x84,0x26,0x85,0xa5,0x83,
0x85,0x0d,0xa5,0x84,0x85,0x0e,0xa5,0x85,
0x85,0x0f,0xa6,0x82,0xca,0x86,0x82,0x86,
0x17,0xe0,0x0a,0xd0,0xc3,0xa9,0x02,0x85,
0x01,0xa5,0x81,0xa2,0x1c,0xa0,0x00,0x84,
0x19,0x84,0x09,0x94,0x81,0xca,0x10,0xfb,
0xa2,0xff,0x29,0xff,0xd0,0x03,0x4c,0xf1,
0xff,0x4c,0xf0,0xff
};

	FILE *fp;
    dd i;
	dd ch;
	db *p;

	init_crc();

	fp = fopen(filename, "rb");
	if (fp == NULL)	return(0);
			
        p = CartRom;
//        p = Megaboy;
	CartSize = 0;
	Checksum = 0;
	XChecksum = 0;
	crc = 0;

	while ( (ch = getc(fp)) != EOF )
	{
		*p++ = (db) ch;
		Checksum += ch;
		ucrc((db) ch);
		if (XChecksum & 0x8000000) XChecksum |= 1;
		XChecksum = (XChecksum << 1) ^ ch;
		++CartSize;
                if (CartSize > 0x80000) break;
	}

	fclose(fp);

	if (CartSize == 2048)	/* 2K cart -- copy lower to upper */
	{
		for (i = 0; i < 2048; i++)
		{
			CartRom[2048+i] = CartRom[i];
		}
	}

        if ((CartSize == 6144)||(CartSize % 8448 == 0))
        /* Starpath image -- reload according to page table */
	{
                for (i = 0; i < 8448; i++)      /* save first SC load */
                {
                        CartRom[i+SC_LOAD0_SAVE] = CartRom[i];
                }

                for (i = 0; i < 0x2000; i++)    /* fill everything with Starpath halts */
		{
			CartRom[i] = 0x52;
		}

                for (i = 0; i< 188; i++)        /* generate fake SC BIOS */
                {
                        CartRom[i + 0x1800] = SCBIOS[i];
                }

                CartRom[0x1ffc]=0x0a;           /* setup BIOS reset vector */
                CartRom[0x1ffd]=0xf8;

                cli_ReloadStarpath();
	}

	return(1);
}


/*
**  Command Line interpreter
**
**	-u <n>	upper scan line
**  ->	-b      black and white
**	-c <n>  choose color palette <n>
**  ->	-q	quiet
**  ->	-s <n>  sound options
** ->    -S      use signed audio
**	-x	print out checksum of cartridge
**  ->	-r	sync with monitor (full screen), -r<n> run at <n> fps
**  ->	-d <n>  do digital signal processing
**	-p <n>  set keyboard sensitivity to <n> for paddle emulation
**	-t	trace instructions
**  ->	-0      player 0 hard
**  ->	-1      player 1 hard
**      -g <n>  overrride bankswitching type detection *EST*
**	-m <n>	paddle to emulate with mouse; 0xff=joystick *EST*
**	-o	simulate PAL colour loss *EST*
**	-l <n>	emulate lightgun and adjust horizontally *EST*
**	-a <n>	adjust lightgun vertically *EST*
**	-n	show line number count and FPS
**      -4      allow all 4 directions on the joystick simultaniously *EST*
**      -e      enable faster mode X copy routines
**      -h <n>  screen render and copy height *EST*
**      -v <n>  video mode
**      -z      don't compare new frame buffer with old FB before copying
**      -!      simulate interlaced display in some video modes
**      -B      save high-bpp screen shots as BMP file *EST*
**      -R      sync to sound buffer
**	-) <a>  set left controller (JS, PC, KP, DC, LG, CM, KV, ML, ST, TB, AM)
**	-( <a>  set right controller
**	-w	swap port 0 with port 1
**	-i <a>	inactivate keyboard (K), mouse (M), joystick (J) or Stelladaptor (S)
**	-P <n>  enable half resolution for joysticks in paddle emulation and
**		delay the paddle-bit flipping by <n> scanlines
**	-f <n>	enable phosporescent effect (n=0 through n=100; default n=77)
*/

FILE *zlog;

void cli_InterpretParm(char *p)
{
	int ch, parm;
	char cli_controllers[12][3] =
		{"JS","PC","KP","DC","LG","CM","KV","ML","ST","TB","AM","NC"};
	int i;
	

	p++;
	ch = *p++;
	parm = atol(p);

	switch (ch)
	{
	case 'F': 	fast = 1;	break;
#ifdef UNIX_TIMING
	case 'T':  	flipType = parm;
#ifdef LINUX_RTC_TIMING
					if(parm < 1 || parm > FLIP_LINUX_RTC)
#else
					if(parm < 1 || parm > FLIP_CPUHOG)
#endif
					{
						fprintf(stderr, "Invalid -T option\n");
						exit(-1);
					}
					break;

#endif
	case 'u':  	CFirst = parm;				break;
	case 'q':  	quiet = 1;				break;
	case 's':	{
				SQ_Max = parm;
				if (SQ_Max > 65536) SQ_Max = 65536;
			}
			break;
	case 'S':	signed_audio++;	break;
	case '0':  	IOPortB |= 64;				break;
	case '1':  	IOPortB |= 128;				break;
	case 'b':  	IOPortB &= 0xc3;			break;
        case 'B':       UseBMP = 1;                             break;
	case 'x':  	DoChecksum = 1;				break;
	case 'd':  	dsp = parm;				break;
	case 'c':  	PaletteNumber = parm;
			UserPaletteNumber = parm;
                        if(parm == 2) {
                           IOPortB &= 0xf7;
                        }
                        break;
	case 'p':  	PaddleSensitivity = (parm & 0xf) << 1;	break;
        case 'm':       if (parm < 100)
                        {
                                MouseBaseX = parm & 3;
                        } else
                        {
                                parm = parm - 100;
                                MouseBaseX = parm / 10;
                                MouseBaseY = parm % 10;
                                MPdirection = 1;  /* set directions for Marble Craze */
                        }
                        break;
	case 'M':	MouseRude = parm;
			break;
	case 'G':	GrabInput = 1;
			break;
	case 't':
	{
		if (parm)
			TraceCount = parm;
		else
			TraceCount = 0xff;

		OldTraceCount = TraceCount;
		TraceEnabled = 1; // controls.c checks this

		/* -tt means `start with trace disabled, until I hit F11' */
		if(*p == 't')
			TraceCount = 0;

		zlog = fopen("z26.log", "w");
		if (zlog == NULL)
		{
			sprintf(msg, "Couldn't build log file.");
			srv_print(msg);
			TraceCount = 0;
			TraceEnabled = 0;
			OldTraceCount = 0;
		}
		break;
	}

	case 'r':  	if (parm == 0)
#ifdef WINDOWS
				NoRetrace = 0;
#else
					fprintf(stderr,
							"Option ignored: "
							"The -r option with no parameter does "
							"not work on non-Windows platforms.\n");
#endif
			else
				NoRetrace = parm;

			target_fps = parm;
			SyncToSoundBuffer = 0;
			break;

        case 'R':      
#ifdef WINDOWS
								SyncToSoundBuffer = 1;
                        NoRetrace = -1;
#else
					fprintf(stderr,
							"Option ignored: "
							"The -R option does "
							"not work on non-Windows platforms.\n");
#endif
					break;

        case 'g':       BSType = parm & 0x0f;                  break; /* *EST* */
	case 'o':	SimColourLoss = 1;		       break; /* *EST* */
	case 'l':	Lightgun = parm;		       break; /* *EST* */
	case 'a':	LGadjust = parm;		       break; /* *EST* */
	case 'n':	ShowLineCount = 1;		       break; /* *EST* */
        case '4':       AllowAll4 = 1;                         break; /* *EST* */
        case 'e':       if (parm == 0) 
				Effect = 1;
			else
				Effect = parm;
			break;
	case 'f':	if (parm == 0)
				Phosphor = 77;
			else
				Phosphor = parm;
			break;

        case 'h':       MaxLines = parm;                       break; /* *EST* */
        case 'V':
          printf(Z26_VERSION "\n");
			 exit(0);
        case 'v':
			if(parm % 10 == 9) {
				parm -= 9;
				printf("Invalid video mode, defaulting to %d\n", parm);
			}

			if (parm < 10)
			{
				VideoMode = parm;
				InWindow = 0;
				TrueColor = 0;
				break;
			}
			if (parm < 20)
			{
				VideoMode = parm % 10;
				InWindow = 1;
				TrueColor = 1;
				break;
			}
			if (parm < 30)
			{
				VideoMode = parm % 10;
				InWindow = 0;
				TrueColor = 1;
				break;
			}
			break;

        case 'z':       DisableCompareCopy = 1;                break; /* *EST* */
        case '!':       DoInterlace = 1;                       break; /* *EST* */
	case 'P':	PaddleAdjust = parm;			break;
       	case ')':	LeftController = 0xff;
			for (i=0; i<12; i++)
			{
				if (strcmp(p, cli_controllers[i]) == 0)
					LeftController=i;
			}
			if (LeftController == 0xff)
			{
				sprintf(msg, "Unknown controller type: %s", p);
				srv_print(msg);
				exit(1);
			}
			break;
	case '(':	RightController = 0xff;
			for (i=0; i<12; i++)
			{
				if (strcmp(p, cli_controllers[i]) == 0)
					RightController=i;
			}
			if (RightController == 0xff)
			{
				sprintf(msg, "Unknown controller type: %s", p);
				srv_print(msg);
				exit(1);
			}
			break;
        case 'w':       SwapPortsFlag = 1;			break;
        case 'i':	for (i = 0; i < strlen(p); i++)
        		{
	        		switch (p[i])
	        		{
		        		case 'J':	JoystickEnabled = 0;		break;
		        		case 'M':	MouseEnabled = 0;		break;
		        		case 'K':	KeyboardEnabled = 0;		break;
		        		case 'S':	StelladaptorEnabled = 0;	break;
		        		default:
		        			sprintf(msg, "Can't inactivate PC controller type: %c", p[i]);
						srv_print(msg);
						exit(1);
						break;
	        		}
        		}
        		break;
        default:   	sprintf(msg, "Bad command line switch seen: -%c", ch);
			srv_print(msg);
		   	exit(1);
	}
}

void cli_WriteParms(int argc, char *argv[])
{
	int i, ch;
	FILE *fp;
	char *p;

	fp = fopen("z26.cli", "w");
	if (fp == NULL)
	{
		sprintf(msg, "Couldn't build cli file.");
		srv_print(msg);
		exit(1);
	}

	i = 1;
	argc--;		/* skip over the filename */

	while (argc--)
	{
		p = argv[i++];
		if (*p == '-')
		{		
			while ( (ch = *p++) )
			{
				fputc(ch, fp);
			}
			
			fputc(' ', fp);
		}
	}

	fputc(0, fp);
	fclose(fp);
}


void cli_ReadParms(void)
{
	int ch, i;
	FILE *fp;
	char ParmString[1024];
	char *p;

	fp = fopen("z26.cli", "r");
	if (fp == NULL)
		return; /* was return(0); *EST* */
	i = 0;

	while ( (( ch = fgetc(fp)) != EOF) && (i <= 1022) )
		ParmString[i++] = ch;

	ParmString[i] = 0;
	i = 0;

	p = ParmString;

	while (*p == '-')
	{
		cli_InterpretParm(p);
		while (!isspace(*p++)) ;
	}
	
	fclose(fp);	
}


char FileName[260];

void cli_CommandLine(int argc, char *argv[])
{
	long int i;
	int cnt;
	unsigned char *p;
	char ROMLoaded = 0; char ROMSeen = 0;
//        char FileName[260];     /* to z26.c */
	FILE *xfp;

        ShowFPS=0;              /* resets flag for displaying FPS count - move to GLOBALS.C for GUI */

	cli_ReadParms();

	i = 1;
	cnt = argc - 1;		/* skip over the program name */

	while(cnt--)
	{
		p = argv[i++];
		if (*p == '-')
			cli_InterpretParm(p);
		else
		{	
			strncpy(FileName,p,255);
			if (!strchr(FileName,'.'))
				strcat(FileName,".bin");
			ROMLoaded = cli_LoadROM(FileName);
			ROMSeen = 1;
			if (TraceEnabled) {
				fprintf(zlog,"Loaded ROM: %s\n\n", FileName);
				fprintf(zlog,
						"(Frame Line Cycle Clock) "
						"(P0_Pos P1_Pos M0_Pos M1_Pos BL_Pos)  "
						"flags  A X Y SP  Code  Disasm\n");
			}
		}
	}

	if (!ROMSeen)
	{
		cli_WriteParms(argc, argv);
		sprintf(msg, "\nParameters recorded.\nTo restore defaults delete the file z26.cli.\n");
		srv_print(msg);
		exit(0);
	}

	if (!ROMLoaded)
	{
		sprintf(msg, "File not found... %s", FileName);
		srv_print(msg);
		exit(1);
	}
/*
	if (CartSize > 32768)
	{
		sprintf(msg, "Unsupported file.");
		srv_print(msg);
		exit(1);
	}
*/
	if (DoChecksum)
	{
		sprintf(msg, "%06x checksum -- %08x crc\n%d bytes", Checksum, crc, CartSize);
		srv_print(msg);

		exit(1);	/* delete comment before shipping ;-) */

		xfp = fopen("z26.crc", "a");
		if (xfp == NULL)
			srv_print("Couldn't open CRC file.");
		else
		{
			fprintf(xfp,"  0x%08x,  /* %s */\n", crc, FileName);
			fclose(xfp);
		}

		exit(1);
	}

	OriginalNoRetrace = NoRetrace;
	if (InWindow && (NoRetrace == 0))
	{
		NoRetrace = -1;
	}

}



/*
 * $Log: cli.c,v $
 * Revision 1.7  2004/05/16 21:54:20  urchlay
 *
 * changed install.unix target so it doesn't choke & die if the target
 * directories are missing. Requested by tmbg (who is making a gentoo
 * ebuild for us)
 *
 * Revision 1.6  2004/05/15 18:53:37  urchlay
 *
 * Made -t (trace mode) work again. Added -tt option (trace mode on, but
 * disabled until the user presses F11).
 *
 * Revision 1.5  2004/05/12 22:16:26  urchlay
 *
 * added -V option (version).
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
 * Revision 1.3  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
