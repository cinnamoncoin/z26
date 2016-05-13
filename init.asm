;*
;* init.asm -- initialize all data in z26 asm modules
;*
;* Apr 2004 - nasm syntax
;* 09-02-02 -- 32-bit
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

%ifndef C_INITDATA
[section .data]
IN_Start:  ; byte			; <-- start clearing hera

RiotRam		times 128 db 0	 ;  RIOT ram (must be initially zero)
TIA		times 64 db 0	 ;  TIA Registers (also should be zero)

global Ram
Ram		times 2048 db 0	 ;  extra ram

Frame		dd  0	 ;  Frame Counter
PrevFrame	dd  0	 ;  Previous value frame counter

VBlanking	dd  0	 ;  0 if vblanking, -1 otherwise
VBlank		db  0	 ;  VBlank flag
VSyncFlag	db  0	 ;  VSync flag

ScanLine	dd  0	 ;  current scan line
OurBailoutLine	dd  0	 ;  initial bailout line
					 ;  we fine tune it if exceeded

global WByte
WByte		db  0	 ;  byte to write

DisplayPointer	dd  0	 ;  pointer into display RAM
IN_End:  ; byte			; <-- finish clearing here
%endif

[section .code]

;*
;* routine to do rep stosb to data segment
;*

rep_stosb:
	cmp	ecx,0
	jz near rs_done

rs_loop:
 	mov	byte [edi],al
	inc	edi
	dec	ecx
	jnz near rs_loop

rs_done:
	ret


;*
;* macro to clear memory
;*

%macro clear_mem 2

	mov	edi, %1
	mov	ecx, %2
	sub	ecx,edi  ;  # of bytes to clear
	xor	al,al
	call	rep_stosb  ;  clear memory

%endmacro


;*
;* initialize data
;*

%ifndef C_INITDATA
InitData:
clear_mem  IN_Start,  IN_End

	mov	dword [OurBailoutLine],1000
	mov	dword [ScanLine],1
	mov	dword [VBlanking],-1

	mov	eax,dword [ScreenBuffer]
	mov	dword [DisplayPointer],eax
	call	InitCVars
	call	Init_CPU
	call	Init_CPUhand
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath
	call	Init_Tiasnd
	call	Init_SoundQ
	call	RandomizeRIOTTimer

	ret
%endif

global	Init_CPU
global	Init_CPUhand
global	Init_TIA
global	Init_Riot
global	Init_P2
global	Init_Starpath
global	Init_Tiasnd

%ifdef C_INITSQ
extern Init_SoundQ
%else
global	Init_SoundQ
%endif

global	RandomizeRIOTTimer



;
; $Log: init.asm,v $
; Revision 1.5  2004/05/19 01:00:57  urchlay
;
; SetupBanks() and associated routines moved to C.
;
; Revision 1.4  2004/05/15 17:00:45  urchlay
;
; Initial incomplete implementation of TIA sound code in C. This isn't
; done yet, but at least compiles, and you can play Pitfall with it (but
; not Pitfall II).
;
; Revision 1.3  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
