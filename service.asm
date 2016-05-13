; service.asm -- I/O and other services for z26 core

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 07-27-02 -- break ground


;*
;* sprite table support
;*

%macro AddTablePointer 1
 	add	esi,dword [%1_Table] ; 32-bit -- add in table offset
%endmacro



;*
;* routine to do rep stosw to graphics segment
;*

%macro gs_rep_stosw 0
	rep	stosw
%endmacro


;*
;* routine to store to graphics segment
;*

%macro gs_store 2
	mov	byte %1, %2
%endmacro



;*
;* initialize services
;*

%ifndef C_INITSERV
Init_Service:
	call	srv_sound_on
	call	TIAGraphicMode		 ;  Switch into VGA mode
;	call	MouseInit		; *EST*
	ret
%endif

;*
;* end of program (escape pressed or bad opcode)
;*

GoAway:
%ifndef C_INITSERV
	pushad
	call	kv_CloseSampleFile	 ;  close file if opened
	call	srv_sound_off		 ;  turn sound off (Soundblaster)
	call	srv_DestroyScreen
	popad
%endif

	jmp	ModuleReturn

TestEscExit:
 	test	byte [ExitEmulator],128 ; ESC or backslash pressed?
	jnz near GoAway
	ret

;*
;* soundblaster entry points
;*

;SetupSoundBlaster:
;	call	srv_sound_on
;	ret

;sound_clear:
;	call	srv_sound_off
;	ret


;*
;* frame synchronizer
;*

VSync:	
	pushad

	call	srv_Events
 	cmp	byte [srv_done],0
	jnz near GoAway

	call	srv_Flip

	popad
	ret


;*
;* z26 linear graphics modes and palette setup
;*

;TIARestoreVideoMode:
;	pushad
;	call	srv_DestroyScreen	 ;  destroy the screen
;	popad
;	ret

;*
;* turn on graphics mode
;*

%ifdef C_TIAGRAPH
extern TIAGraphicMode
%else
global TIAGraphicMode

TIAGraphicMode:
	pushad
         cmp     byte [VideoMode],8 ; did user specify a valid (0-8) video mode
        jna near UserVideoMode            ;     yes, don't override
         mov     byte [VideoMode],0 ; set default mode
UserVideoMode:
	call	position_game		 ;  set game vertical positionn
;	call	_GeneratePalette	; calculate palette colors
	call	srv_CreateScreen	 ;  set up the screen
        call    ClearScreenBuffers      ;  clear the 4 buffers for screen comparing
	popad
	ret
%endif

;*
;* switch windowed mode
;*

;; Unused
;; TIAWindowMode:
;; 	pushad
;; 	call	srv_WindowScreen
;; 	popad
;; 	ret

;*
;* copy frame buffer to screen
;*

;; Unused
;; ModeXCopyScreen:
;; 	pushad
;; 	call	srv_CopyScreen
;; 	popad
;; 	ret


;*
;* routine to blank the remains of the screen buffer, if not all of the
;* displayed data gets filled by the rendering routine
;* gets called from MAIN.ASM
;*

BlankBufferEnd:
        pushad
 	mov	eax,dword [MaxLines]
 	lea	eax, [eax+eax*4]
	shl	eax,5			 ;  *160

 	add	eax,dword [ScreenBuffer]

 	cmp	dword [DisplayPointer],eax ; render pointer past end of displayable?
        jae near BBEret                   ;         yes, don't blank unfilled buffer

         mov     esi,dword [DisplayPointer]
        sub     eax,esi                  ;  max. buffer size - current buffer position
        mov     ebx,0
BBEdo:
         mov     dword [esi],ebx ; fill unused buffer space with black
        add     esi,4
        sub     eax,4
        jnz near BBEdo
BBEret:
        popad
        ret



;
; $Log: service.asm,v $
; Revision 1.4  2004/05/08 18:52:36  urchlay
;
; restored original asm comments to c_core.c functions
;
; Revision 1.3  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
