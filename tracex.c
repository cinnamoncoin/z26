/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

db RROM, RROM1, RROM2;  /* contain the result of ReadROM(cpu_pc) */

enum {_imp, _ac, _rel, _imm, _abs, _abs_x, _abs_y, _zero, _zero_x, _zero_y, _ind, _ind_x, _ind_y};

extern void cpu_Instruction(void);
extern void cpu_Reset(void);

/*
extern unsigned char ReadROM(unsigned int);
*/

/** these are declared in globals.c now **
typedef unsigned long int   dd;
typedef unsigned short 		dw;
typedef unsigned char  		db;
*/

dd cpu_MAR;
db cpu_Rbyte;

unsigned char ReadROM(unsigned int adr)
{
}

unsigned int ReadRAM(unsigned int adr)
{
}


dw cpu_pc;
db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;

dw P0_Pos, P1_Pos, M0_Pos, M1_Pos, BL_Pos;

dw adr, prevadr;

dd frame;
dw line;
db cycle;

void ShowWeird(int Cycle)
{
}

void ShowDeep(int Now, int Prev, int Cycle)
{
}

void ShowVeryDeep(int Now, int Prev, int Cycle)
{
}

void ShowAdjusted(void)
{
}

void ShowUndocTIA(void)
{
}

void ShowCollision(void)
{
}

void ShowSCWrite(void)
{
}

void Showaddress(void)
{
}

int ti_op8(void)
{
}

unsigned int ti_op16(void)
{
}

void ti_show_imp(void)
{
}

void ti_show_ac(void)
{
}

void ti_show_zero_xy(unsigned int op)
{
}

void ti_show_zero(void)
{
}

void ti_show_zero_x(void)
{
}

void ti_show_zero_y(void)
{
}

void ti_show_abs_xy(unsigned int op)
{
}

void ti_show_abs(void)
{
}

void ti_show_abs_y(void)
{
}

void ti_show_abs_x(void)
{
}


void ti_show_ind(void)
{
}

void ti_show_ind_x(void)
{
}

void ti_show_ind_y(void)
{
}

void ti_show_immediate(void)
{
}

void ti_show_relative(void)
{
}

void ShowInstruction(void)
{
}

void ShowRegisters(void)
{
}


/*
 * $Log: tracex.c,v $
 * Revision 1.2  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
