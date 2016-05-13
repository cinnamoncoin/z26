;other definitions -- outside any segment

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;;; MSDOS equ 021H 		 ;  MSDOS	caller (Obsolete!)

CYCLESPERSCANLINE equ 76 		 ;  TIA timing constant

;*
;* TIA register definitions
;*

VSYNC equ 00h 		 ; * vertical sync set/clear       \ 
VBLANK equ 01h 		 ; * vertical blank set/clear       \  immediate
WSYNC equ 02h 		 ; * wait for horizontal blank      /  action
RSYNC equ 03h 		 ; * reset horizontal sync counter /

NUSIZ0 equ 04h 		 ;  missile/player size controls
NUSIZ1 equ 05h 
COLUP0 equ 06h 		 ;  colors
COLUP1 equ 07h 
COLUPF equ 08h 
COLUBK equ 09h 
CTRLPF equ 0Ah 		 ;  REF, SCORE, PFP, ball width
REFP0 equ 0Bh 		 ;  reflect player
REFP1 equ 0Ch 
PF0 equ 0Dh 		 ;  playfield bits
PF1 equ 0Eh 
PF2 equ 0Fh 
RESP0 equ 10h 		 ;  horizonal position
RESP1 equ 11h 
RESM0 equ 12h 
RESM1 equ 13h 
RESBL equ 14h 

AUDC0 equ 15h 		 ; * audio control
AUDC1 equ 16h 		 ; *
AUDF0 equ 17h 		 ; * audio frequency
AUDF1 equ 18h 		 ; *
AUDV0 equ 19h 		 ; * audio volume
AUDV1 equ 1Ah 		 ; *

GRP0 equ 1Bh 		 ;  graphics
GRP1 equ 1Ch 
ENAM0 equ 1Dh 		 ;  enables
ENAM1 equ 1Eh 
ENABL equ 1Fh 
HMP0 equ 20h 		 ;  horizontal motion
HMP1 equ 21h 
HMM0 equ 22h 
HMM1 equ 23h 
HMBL equ 24h 
VDELP0 equ 25h 		 ;  vertical delay
VDELP1 equ 26h 
VDELBL equ 27h 
RESMP0 equ 28h 		 ;  missile locked to player
RESMP1 equ 29h 

HMOVE equ 2Ah 		 ;  apply horizontal motion
HMCLR equ 2Bh 		 ;  clear horizontal motion registers
CXCLR equ 2Ch 		 ;  clear collision latches

;*
;* to make macros easier to write
;*

NUSIZM0 equ NUSIZ0 
NUSIZM1 equ NUSIZ1 
NUSIZP0 equ NUSIZ0 
NUSIZP1 equ NUSIZ1 



;*
;* TIA bit mask definitions
;*

REF equ 01h 		 ;  (CTRLPF) reflect playfield
SCORE equ 02h 		 ;  (CTRLPF) score mode
PFP equ 04h 		 ;  (CTRLPF) playfield gets priority


;*
;* pixel  bit definitions
;*

PF_BIT equ 1 
BL_BIT equ 2 
P1_BIT equ 4 
M1_BIT equ 8 
P0_BIT equ 16 
M0_BIT equ 32 
DL_BIT equ 64 


; some display related stuff

DEFAULT_CFirst equ 39 
MEDIUM_Offset equ 19 			 ;  offset a medium game this much
					 ;  tune so that game in mode 3 and mode 5
					 ;  appear at same vertical position
					 ;  (unless it's a known tall game)

MAX_TallGame equ 240 			 ;  size of a tall game





;
; $Log: defs.asm,v $
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
