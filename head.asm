;;; page 66,132

; head.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

;; Converted from MASM syntax to NASM, 20040413 bkw. Most of the work
;; was done with a perl script (scripts/masm_to_nasm.pl), with a bit
;; of manual tweaking.

;; This file contains all the assembly code from Z26, catted together
;; in one file. To assemble, use NASM version 0.98.38 (other versions
;; may or may not work, YMMV). Get NASM from http://nasm.sourceforge.net

;; On Linux:
;;   nasm -t -felf -o z26core.o all.asm

;; On Windows, with Msys/MinGW (and maybe Cygwin):
;;   nasm -t -felf --prefix _ -o z26core.o all.asm


;;;;; macro kludgery to emulate variadic macros	

%macro fake_arg 0
	; fake argument
%endmacro

%macro PF_PixelLoop 5
	PF_PixelLoop %1, %2, %3, %4, %5, fake_arg
%endmacro

%macro BK_PixelLoop 5
	BK_PixelLoop %1, %2, %3, %4, %5, fake_arg
%endmacro

%macro PF_PixelLoop 4
	PF_PixelLoop %1, %2, %3, %4, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 4
	BK_PixelLoop %1, %2, %3, %4, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 3
	PF_PixelLoop %1, %2, %3, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 3
	BK_PixelLoop %1, %2, %3, fake_arg, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 2
	PF_PixelLoop %1, %2, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 2
	BK_PixelLoop %1, %2, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 1
	PF_PixelLoop %1, fake_arg, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 1
	BK_PixelLoop %1, fake_arg, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

? equ 0


; assembly time definitions

%define TRACE 1 
%define showdeep 1 
;CHEATS equ 1  ; unused



;
; $Log: head.asm,v $
; Revision 1.3  2004/05/15 18:53:37  urchlay
;
; Made -t (trace mode) work again. Added -tt option (trace mode on, but
; disabled until the user presses F11).
;
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
