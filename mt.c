/*
** note: this is no longer used -- modify ct.c manually
**
** mt.c -- create game compatibility tables for z26
**
** usage:
**
** mt > ct.c
**
** where mt resides in a directory full of Good2600 renamed ROMS
**
**
** note:  this is a 32-bit Windows program
**
** build like this:
**
** lc mt.c
**
** using Jacob Navia's lcc-win32 compiler
*/


#include <stdio.h>
#include <string.h>
#include <windows.h>

typedef unsigned long	int	dd;
typedef unsigned short	int	dw;
typedef unsigned char  		db;

WIN32_FIND_DATA wfd;		/* windows file data */
HANDLE fnf;			/* handle to find next file */

dd ROMcount;
dd Checksum;
dd XChecksum;
dd Cartsize;

dd crc_table[4096];

#define CRC16_REV 0xA001	/* CRC-16 polynomial reversed */
#define CRC32_REV 0xA0000001	/* CRC-32 polynomial reversed */
dd	crc;			/* holds accumulated CRC */
dd	crctab[256];


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

void init_crc(void) 
{
  int i;
  for (i=0;i<256;i++)
    crctab[i] = crcrevhware(i,CRC32_REV,0);
}


/*
** update CRC
*/

void ucrc(unsigned char data) 
{
   crc = (crc >> 8) ^ crctab[(crc ^ data) & 0xff];
}


void checksum_ROM(void)
{
	FILE *fp;
	int i, j;
	int ch;

	fp = fopen(wfd.cFileName, "rb");
	if (fp == NULL)	return;
			
	Cartsize = 0;
	Checksum = 0;
	crc = 0;

	while ( (ch = getc(fp)) != EOF )
	{
		ucrc(ch);
		Checksum += ch;
		++Cartsize;
		if (Cartsize > 65536) break;
	}

	fclose(fp);
}

void do_ROM(void)
{
	++ROMcount;
//	checksum_ROM();
}

void start_ROM_list(void)
{
	ROMcount = 0;
	init_crc();
	fnf = FindFirstFile("*.bin",&wfd);
	if (fnf == INVALID_HANDLE_VALUE)
	{
		printf("Can't find first ROM");
		exit(1);
	}
}

#define SS(FFF) (strstr(wfd.cFileName, FFF))

void do_Kool(void)
{
	start_ROM_list();

	printf("dd\tKool[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Kool Aid Man")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_Boxing(void)
{
	start_ROM_list();

	printf("dd\tBoxing[] = {\n");

	do
	{
		do_ROM();

		if (	SS("RealSports Boxing")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_TIAZ(void)
{
	start_ROM_list();

	printf("dd\tTIAZ[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Berzerk")				||
			SS("Q-bert's Qubes")			||
			SS("Space Canyon")			||
			SS("Space Cavern")			||
			SS("This Planet Sucks")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_Paddle_0(void)
{
	start_ROM_list();

	printf("dd\tPaddle_0[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Fireball")				||
			SS("Party Mix")				||
			SS("Sweat!")				||
			SS("Action Force")			||
			SS("Bachelor Party")			||
			SS("Bachelorette Party")		||
			SS("Backgammon")			||
			SS("Beat \'Em and Eat \'Em")		||
			SS("Blackjack")				||
			SS("Breakout")				||
			SS("Bugs.bin")				||
			SS("Casino")				||
			(SS("Circus Atari") && !SS("Joystick")) ||
			SS("Eggomania")				||
			SS("Encounter at L5")			||
			SS("G.I. Joe")				||
			SS("Guardian")				||
			SS("Kaboom!")				||
			SS("Mondo Pong")			||
			SS("Music Machine")			||
			SS("Night Driver")			||
			SS("Philly Flasher")			||
			SS("Picnic")				||
			SS("Piece o' Cake")			||
			SS("Secret Agent")			||
			SS("Solar Storm")			||
			SS("Steeplechase")			||
			SS("Warlords")				||
			SS("Warplock")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_Paddle_1(void)
{
	start_ROM_list();

	printf("dd\tPaddle_1[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Canyon Bomber")			||
			SS("Demons to Diamonds")		||
			SS("Jedi Arena")			||
			SS("Street Racer")			||
			SS("Video Olympics")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_Paddle_3(void)
{
	start_ROM_list();

	printf("dd\tPaddle_3[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Tac Scan")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_MPdir_1(void)
{
	start_ROM_list();

	printf("dd\tMPdir_1[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Party Mix (3 of 3)")		||
			SS("Bachelor Party")			||
			SS("Bachelorette Party")		||
			SS("Blackjack")				||
			SS("Casino")				||
			SS("Steeplechase")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_MPdir_3(void)
{
	start_ROM_list();

	printf("dd\tMPdir_3[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Sweat! - The Decathalon Game (1 of 2)")	||
			SS("Backgammon")				||
			SS("Canyon Bomber")				||
			SS("Mondo Pong")				||
			SS("Video Olympics")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_quiet(void)
{
	start_ROM_list();

	printf("dd\tbe_quiet[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Video Chess")				||
			(SS("Boxing") && !SS("RealSports"))		||
			SS("Dice Puzzle")				||
			SS("Double Dragon")				||
			SS("Casino")					||
			SS("Stampede")					||
			SS("3-D Tic-Tac-Toe")				||
			SS("Home Run Baseball")				||
			SS("Slot Machine")				||
			SS("Video Checkers")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_joy_rev(void)
{
	start_ROM_list();

	printf("dd\tjoy_rev[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Raiders of the Lost Ark")			||
			SS("Pick 'n Pile")				||
			SS("Traffic")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_keypad_3(void)
{
	start_ROM_list();

	printf("dd\tkeypad_3[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Game of Concentration")			||
			SS("Alpha Beam with Ernie")			||
			SS("Basic Programming")				||
			SS("Big Bird's Egg Catch")			||
			SS("Brain Games")				||
			SS("Code Breaker")				||
			SS("Cookie Monster Munch")			||
			SS("Grover's Music Maker")			||
			SS("Magicard")					||
			SS("Oscar's Trash Race")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_keypad_2(void)
{
	start_ROM_list();

	printf("dd\tkeypad_2[] = {\n");

	do
	{
		do_ROM();

		if (	
			SS("Star Raiders")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_driving_con(void)
{
	start_ROM_list();

	printf("dd\tdriving_con[] = {\n");

	do
	{
		do_ROM();

		if (	
			SS("Indy 500")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_1(void)
{
	start_ROM_list();

	printf("dd\tBS_1[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Video Life")				||
			SS("Magicard")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_3(void)
{
	start_ROM_list();

	printf("dd\tBS_3[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Death Star Battle")				||
			SS("Gyruss")					||
			SS("Super Cobra")				||
			SS("Tutankham")					||
			SS("Popeye")					||
			SS("Star Wars - The Arcade Game")		||
			SS("Q-bert's Qubes")				||
			SS("Frogger II - Threedeep!")			||
			SS("Montezuma's Revenge")			||
			SS("Mr. Do!'s Castle")				||
			SS("Tooth Protectors")				||
			SS("James Bond 007")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_4(void)
{
	start_ROM_list();

	printf("dd\tBS_4[] = {\n");

	do
	{
		do_ROM();

		if (	SS("River Patrol")				||
			SS("Springer")					||
			SS("Polaris")					||
			SS("Miner 2049er")				||
			SS("Espial")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_5(void)
{
	start_ROM_list();

	printf("dd\tBS_5[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Decathlon")					||
			SS("Robot Tank")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_9(void)
{
	start_ROM_list();

	printf("dd\tBS_9[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Private Eye")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_6(void)
{
	start_ROM_list();

	printf("dd\tBS_6[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Dig Dug")					||
			SS("Off the Wall")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_7(void)
{
	start_ROM_list();

	printf("dd\tBS_7[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Masters of the Universe - The Power of He-Man")	||
			SS("Bump n Jump")					||
			SS("Burgertime")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void do_BS_8(void)
{
	start_ROM_list();

	printf("dd\tBS_8[] = {\n");

	do
	{
		do_ROM();

		if (	SS("Fatal Run")
		   )
		{
			checksum_ROM();
			printf("\t0x%08lx,\t/* %s */\n", crc, wfd.cFileName);
		}
	}
	while (FindNextFile(fnf, &wfd));

	printf("\t-1\n};\n\n");
}

void main(int argc, char *argv[])
{
	printf("/*\n** This table generated by mt.c.\n");
	printf("** You probably don't want to modify it manually.\n*/\n\n");

	do_Kool();
	do_Boxing();
	do_TIAZ();
	do_Paddle_0();
	do_Paddle_1();
	do_Paddle_3();
	do_MPdir_1();
	do_MPdir_3();
	do_quiet();
	do_joy_rev();
	do_keypad_3();
	do_keypad_2();
	do_driving_con();
	do_BS_1();
	do_BS_3();
	do_BS_4();
	do_BS_5();
	do_BS_9();
	do_BS_6();
	do_BS_7();
	do_BS_8();
}


/*
 * $Log: mt.c,v $
 * Revision 1.2  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
