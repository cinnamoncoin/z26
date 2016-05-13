
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

;; On Linux:
;;   nasm -felf -o z26core.o all.asm

;; On Windows, with Msys/MinGW (and maybe Cygwin):
;;   nasm -felf --prefix _ -o z26core.o all.asm

%include "head.asm"		; asm time definitions
%include "extern.asm"	; external to ASM, internal to C
%include "defs.asm"		; our definitions
%include "init.asm"		; initialized data
%include "service.asm"	; I/O and other services for emulation core
%include "soundq.asm"	; sound queue stuff
%include "lincopy.asm"	; video copy support
%include "position.asm"	; position game vertically
%include "main.asm"		; <-- the main machine
%include "banks.asm"		; bank switch code
%include "pitfall2.asm"	; Pitfall II bank switch code
%include "starpath.asm"	; Starpath Supercharger bank switch code
%include "riot.asm"		; RIOT emu
%include "cpu.asm"		; 6502 opcodes, macros and support routines
%include "cpujam.asm"	; jam handler
%include "cpuhand.asm"	; cpu memory & register handlers
%include "trace.asm"		; trace buffer stuff
%include "tiatab.asm"	; various tables for TIA graphics emulation
%include "tiawrite.asm"	; handle writes to TIA registers
%include "tialine.asm"	; TIA graphics generation
%include "tiasnd.asm"	; asm version of Ron Fries' TIASound
%include "tail.asm"		; the END


;
; $Log: z26core.asm,v $
; Revision 1.2  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
