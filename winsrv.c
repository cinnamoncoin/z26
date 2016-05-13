/*
** winsrv.c -- Windows specific service code
*/

/*
** z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

#include <windows.h>

void win_msg(char *msg)
{
	MessageBox(NULL, msg, "z26", MB_OK);
}




/*
 * $Log: winsrv.c,v $
 * Revision 1.3  2004/05/14 22:08:19  estolberg
 * Added the 'void', because there were warnings with the -Wall option.
 *
 * Revision 1.2  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
