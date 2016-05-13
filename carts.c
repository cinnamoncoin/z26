/*
** recognize cart and set up special properties
*/


/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

db KoolAide;		/* do KoolAide cheat */
db RSBoxing;		/* do RSBOXING cheat */
dd UserCFirst;		/* user requests game start here */
dd DefaultCFirst;	/* emu recommends game start here */
db MPdirection;		/* direction mouse must move to emulate paddle */
db MinVol;		/* minimum volume needed to make noise on PC-speaker */
db LG_WrapLine;		/* light gun wrap line */


db Lookup(dd *table)
{
	dd t;

	while(1)
	{
		t = *table++;
		if (t == -1)  return(0);
		if (t == crc) return(1);
	}
}


void RecognizeCart(void)
{
	db paddle;
        dd i,j;

        db LeftSuggestion, RightSuggestion;

	KoolAide = 0;				/* KoolAide RESP cheat */
	if (Lookup(Kool)) KoolAide = 1;

	RSBoxing = 0;				/* RSBOXING cheat */
	if (Lookup(Boxing)) RSBoxing = 1;
	
/* special starting lines */

	UserCFirst = CFirst;
	DefaultCFirst = 0xffff;

        if (crc == 0xe5314b6c) CFirst = 50;     /* aciddrop */
	if (crc == 0x7b4eb49c) CFirst = 44;	/* pickpile */
	if (crc == 0xbf0aac36) CFirst = 23;	/* chalenge */
	if (crc == 0x2bcce2c8) CFirst = 24;	/* immies */
        if (crc == 0xbfc1da38) CFirst = 23;     /* Dragon Defender (Thomas Jentzsch) (Video Format Conversion).bin */
	if (crc == 0xcbebf38e) CFirst = 40;	/* Sancho - Nightmare (PAL).bin */
	if (crc == 0xd8777a3b) CFirst = 40;	/* Starsoft - Gefecht im All (PAL).bin */
//	if (crc == 0xbf9da2b1) CFirst = 37;	/* Robin Hood (PAL) */
//	if (crc == 0x4f40a18e) CFirst = 30;	/* air_raid */
//	if (crc == 0x6f62a864) CFirst = 30;	/* grescape */

	if (crc == 0xb17b62db) CFirst = 1;	/* Balthazar */
	if (crc == 0xfa07aa39) CFirst = 0;	/* pharhcrs -- vblank triggers frame */
	if (crc == 0xbcb42d2b) CFirst = 0;	/* traffic  -- vblank triggers frame */

	DefaultCFirst = CFirst;


/* special palettes */

	if (PaletteNumber == 0xff)		/* if user didn't specify a palette */
	{
                if (Lookup(NTSC_colours)) 
		{
			PaletteNumber = 0;	/* NTSC Palette */
			UserPaletteNumber = 0;
		}

                if (Lookup(PAL_colours)) 
                {
                        PaletteNumber = 1;      /* PAL Palette */
                        UserPaletteNumber = 0;
                }
	}


/* phosphorescent games */

	if (Phosphor > 100)
		Phosphor = 0;
	else
		if ((Phosphor == 0) && Lookup(Phosphorescent))
			Phosphor = 77;


/* games that want Player 1 set to hard */

        if (Lookup(Player_1_hard)) IOPortB |= 0x80;


/* games that want the joystick controls reversed */
/* XOR flag bit so that ports can still be swapped by user */
	if (Lookup(joy_rev)) SwapPortsFlag ^= 0x01;


/* games that need to use "impossible" joystick positions */
        if (crc == 0x7a0d162d) AllowAll4 = 1;   /* Bumper Bash NTSC */
        if (crc == 0x4af43194) AllowAll4 = 1;   /* Bumper Bash PAL */


/* detect controllers */
       	LeftSuggestion = JS;		/* assume joystick controllers by default */
	RightSuggestion = JS;

/* paddle games */

	paddle = 0xff;				/* assume not recognized */

	if (Lookup(Paddle_0)) paddle = 0;
	if (Lookup(Paddle_1)) paddle = 1;
	if (Lookup(Paddle_3)) { paddle = 1; SwapPortsFlag ^= 0x01; }
		/* Tac Scan uses paddle on right controller port -> swap ports */
//	if (Lookup(Paddle_3)) paddle = 3;

	/* Marble Craze NTSC and PAL -- use both mouse axis to emulate paddles */
	if (crc == 0x095a655f) { MouseBaseX = 1; MouseBaseY = 0; paddle = 0; }	/* NTSC */
	if (crc == 0x96a0b1f9) { MouseBaseX = 1; MouseBaseY = 0; paddle = 0; }	/* PAL */

	if (paddle != 0xff)			/* if we found a paddle game set its direction */

	{
		LeftSuggestion = PC;
		RightSuggestion = PC;
		if (PaddleSensitivity == 0)   PaddleSensitivity = 6;	/* default sensitivity 3 */

		MPdirection = 0;

		/* MPdir bit0 = 1 -> vertical paddle motion */
		if (Lookup(MPdir_1)) MPdirection = 1;
		if (Lookup(MPdir_2)) MPdirection = 2;
		if (Lookup(MPdir_3)) MPdirection = 3;
		if ((MouseBaseY == 0xff) && (MPdirection & 0x01)) MouseBaseY = paddle;
		else if ((MouseBaseX == 0xff) && !(MPdirection & 0x01)) MouseBaseX = paddle;
	}


/* Kid Vid games */
        if (crc == 0x9927a7ae) { RightSuggestion = KV; KidVid = 0x44; }	/* Smurfs Save the Day */
        if (crc == 0x0b63f9e3) { RightSuggestion = KV; KidVid = 0x48; }	/* The Berenstain Bears */


/* keypad games */

	if (Lookup(keypad_3)) { RightSuggestion = KP; LeftSuggestion = KP; }
	if (Lookup(keypad_2)) RightSuggestion = KP;


/* driving controller games */

        if (Lookup(driving_con_2)) RightSuggestion = DC;
        if (Lookup(driving_con_3)) { RightSuggestion = DC; LeftSuggestion = DC; }


/* lightgun games */

	LG_WrapLine = 78;

	if (crc == 0x0febd060) { LeftSuggestion = LG; Lightgun = 7; LGadjust = 11; }			/* shootacd */
	if (crc == 0x56e2d735) { LeftSuggestion = LG; Lightgun = 8; LGadjust = 0;  }			/* sentinel */
	if (crc == 0xdde8600b) { LeftSuggestion = LG; Lightgun = 9; LGadjust = 5;  LG_WrapLine = 75; }	/* guntest4 */


/* Mindlink games */

        if (crc == 0x81187400) RightSuggestion = ML;	/* Telepathy */
        if (crc == 0x3183c019) LeftSuggestion = ML;	/* Bionic Breakthrough */


/* CompuMate keyboard */
        if (crc == 0xa01ebff4) { RightSuggestion = CM; LeftSuggestion = CM; }	/* Spectravideo CompuMate PAL */


/* TrakBalls */
        if (crc == 0x16119bbc) { RightSuggestion = ST; LeftSuggestion = ST; }	/* Missile Command hack NTSC ST mouse */
        if (crc == 0x094ed116) { RightSuggestion = ST; LeftSuggestion = ST; }	/* Missile Command hack PAL ST mouse */
        if (crc == 0x8f7e1223) { RightSuggestion = TB; LeftSuggestion = TB; }	/* Missile Command hack NTSC CX-22 */
        if (crc == 0x90215889) { RightSuggestion = TB; LeftSuggestion = TB; }	/* Missile Command hack PAL CX-22 */
        if (crc == 0x8590dabb) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack NTSC Amiga mouse */
        if (crc == 0xe4062d87) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack PAL Amiga mouse */
        if (crc == 0xd4f23bda) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack NTSC Amiga mouse (v1.2) */
        if (crc == 0x9593b81c) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack PAL Amiga mouse (v1.2) */

        

/* if the user didn't specify controllers, use autodetection */
        if (LeftController == 0xff) LeftController = LeftSuggestion;
	if (RightController == 0xff) RightController = RightSuggestion;

/* bankswitching */

	if (Lookup(BS_1)) BSType = 1;		/* CommaVid */
	if (Lookup(BS_3)) BSType = 3;		/* Parker Brothers */
	if (Lookup(BS_4)) BSType = 4;		/* Tigervision */
	if (Lookup(BS_5)) BSType = 5;		/* Activision 8K flat model */
	if (Lookup(BS_9)) BSType = 9;		/* 8K banks reversed */
	if (Lookup(BS_6)) BSType = 6;		/* 16K Superchip that can't be recognized automatically */
	if (Lookup(BS_7)) BSType = 7;		/* M Network 16K */
/*      if (Lookup(BS_8)) BSType = 8; */        /* Atari 32K */
        if (crc == 0xa01ebff4) BSType = 10;     /* Spectravideo CompuMate PAL */
	if (Lookup(BS_11)) BSType = 11;		/* 32K Tigervision */
        if (Lookup(BS_12)) BSType = 12;         /* 8K UA Ltd. */

        if(BSType==0)
        {
           switch(CartSize)
           {
           case 0x2000:
              BSType=2;                         /* 8K superchip */
              for(i=0; i<2; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           case 0x4000:
              BSType=6;                         /* 16K superchip */
              for(i=0; i<4; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           case 0x8000:
              BSType=8;                         /* 32K superchip (Fatal Run) */

              for(i=0; i<8; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           }
        }
}


/*
 * $Log: carts.c,v $
 * Revision 1.2  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
