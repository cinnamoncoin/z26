; new TIA write handlers

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 3-12-1999 -- break ground
; 09-07-02 -- 32-bit

[section .data]
TIARegHandler:  ; dword

	dd	H_VSYNC		 ;  00 -- VSYNC
	dd	H_VBLANK		 ;  01 -- VBLANK
	dd	H_WSYNC		 ;  02 -- WSYNC
	dd	H_Null		 ;  03 -- reset horizontal sync
					 ; 	  for factory testing only !

	dd	H_NUSIZ0		 ;  04 -- NUSIZ0
	dd	H_NUSIZ1		 ;  05 -- NUSIZ1
	dd	H_COLUP0		 ;  06 -- COLUP0
	dd	H_COLUP1		 ;  07 -- COLUP1
	dd	H_COLUPF		 ;  08 -- COLUPF
	dd	H_COLUBK		 ;  09 -- COLUBK
	dd	H_CTRLPF		 ;  0a -- CTRLPF
	dd	H_REFP0		 ;  0b -- REFP0
	dd	H_REFP1		 ;  0c -- REFP1
	dd	H_PF			 ;  0d -- PF0
	dd	H_PF			 ;  0e -- PF1
	dd	H_PF			 ;  0f -- PF2
	dd	H_RESP0		 ;  10 -- RESP0
	dd	H_RESP1		 ;  11 -- RESP1
	dd	H_RESM0		 ;  12 -- RESM0
	dd	H_RESM1		 ;  13 -- RESM1
	dd	H_RESBL		 ;  14 -- RESBL
	dd	H_AUDC0		 ;  15 -- AUDC0
	dd	H_AUDC1		 ;  16 -- AUDC1
	dd	H_AUDF0		 ;  17 -- AUDF0
	dd	H_AUDF1		 ;  18 -- AUDF1
	dd	H_AUDV0		 ;  19 -- AUDV0
	dd	H_AUDV1		 ;  1a -- AUDV1
	dd	H_GRP0		 ;  1b -- GRP0
	dd	H_GRP1		 ;  1c -- GRP1
	dd	H_ENAM0		 ;  1d -- ENAM0
	dd	H_ENAM1		 ;  1e -- ENAM1
	dd	H_ENABL		 ;  1f -- ENABL
	dd	H_HMP0		 ;  20 -- HMP0
	dd	H_HMP1		 ;  21 -- HMP1
	dd	H_HMM0		 ;  22 -- HMM0
	dd	H_HMM1		 ;  23 -- HMM1
	dd	H_HMBL		 ;  24 -- HMBL
	dd	H_VDELP0		 ;  25 -- VDELP0
	dd	H_VDELP1		 ;  26 -- VDELP1
	dd	H_VDELBL		 ;  27 -- VDELBL
	dd	H_RESMP0		 ;  28 -- RESMP0
 	dd	H_RESMP1		 ;  29 -- RESMP1
	dd	H_HMOVE		 ;  2a -- HMOVE
	dd	H_HMCLR		 ;  2b -- HMCLR
	dd	H_CXCLR		 ;  2c -- CXCLR

	dd	H_Null		 ;  2d -- these registers are undefined
	dd	H_Null		 ;  2e
	dd	H_Null		 ;  2f
	dd	H_Null		 ;  30
	dd	H_Null		 ;  31
	dd	H_Null		 ;  32
	dd	H_Null		 ;  33
	dd	H_Null		 ;  34
	dd	H_Null		 ;  35
	dd	H_Null		 ;  36
	dd	H_Null		 ;  37
	dd	H_Null		 ;  38
	dd	H_Null		 ;  39
	dd	H_Null		 ;  3a
	dd	H_Null		 ;  3b
	dd	H_Null		 ;  3c
	dd	H_Null		 ;  3d
	dd	H_Null		 ;  3e
	dd	H_Null		 ;  3f

	dd	H_Null

PFDelay db	4, 3, 2, 5	 ;  delays for writes to PF registers
BallSize:  ; byte
	db	10000000b
	db	11000000b
	db	11110000b
	db	11111111b
TIAReflect8:  ; byte
 db 0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240
 db 8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248
 db 4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244
 db 12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252
 db 2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242
 db 10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250
 db 6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246
 db 14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254
 db 1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241
 db 9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249
 db 5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245
 db 13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253
 db 3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243
 db 11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251
 db 7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247
 db 15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255
WeirdRespCorrection:  ; dword
 dd   0,  0,  0,  0,  0,  0,  1,  2,  2,  3
 dd   4,  5,  5,  6,  7,  8,  8,  9, 10, 11
 dd  11, 12, 13, 14, 14, 15

TempCFirst	dd	0


[section .code]


;*
;* blank the remainder of the display each frame
;*

TIABlank:
	pushad
	xor	eax,eax
 	mov	edi,dword [DisplayPointer]
	cmp	edi,15000
	jb near TIABRet
 	mov	ebx,dword [MaxLines]
	imul	ebx,160
TIABLoop:
	cmp	edi,ebx			 ;  reached end of display area?
	jae near TIABRet			 ;    yes, done
 	;gs_store  [edi],eax
	mov dword [edi], eax
	add	edi,4
	jmp	TIABLoop

TIABRet:
 	mov	dword [DisplayPointer],edi
	popad
	ret

;*
;* deep motion tracing macro
;*

%macro CheckDeep 0
; local ; NotDeep, IsDeep, VeryDeep
%ifdef showdeep
 	test	byte [TraceCount],4
	jz near %%NotDeep

 	cmp	byte [RClock],25
	ja near %%NotDeep
 	cmp	byte [HMOVE_Cycle],0
	jne near %%IsDeep
 	cmp	byte [Last_HMOVE_Cycle],54
	ja near %%IsDeep
	jmp	%%NotDeep

%%IsDeep:
 	cmp	byte [HMOVE_Cycle],3
	jne near %%VeryDeep

	pushad
 	movzx	edx,byte [RClock]
	push	edx
 	movzx	edx,byte [TIA+esi]
	and	edx,0fh
	push	edx
 	mov	dl,byte [WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	ShowDeep
	pop	edx
	pop	edx
	pop	edx
	popad

	jmp	%%NotDeep

%%VeryDeep:
	pushad
 	movzx	edx,byte [RClock]
	push	edx
 	movzx	edx,byte [TIA+esi]
	and	edx,0fh
	push	edx
 	mov	dl,byte [WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	ShowVeryDeep
	pop	edx
	pop	edx
	pop	edx
	popad

%%NotDeep:
%endif
%endmacro


;*
;* weird motion tracing macro
;*

%macro CheckWeird 0
; local ; NotWeird
%ifdef showdeep
 	test	byte [TraceCount],2
	jz near %%NotWeird

 	cmp	byte [RClock],3
	je near %%NotWeird

	pushad
 	movzx	edx,byte [RClock]
	push	edx
	call	ShowWeird
	pop	edx
	popad

%%NotWeird:
%endif
%endmacro


;*
;* This is the TIA write handler.
;*
;* on entry:
;*
;*	si =	  TIA register to write to
;*	[WByte] = value to write
;*

NewTIA:	
	SaveCPUState
	and	esi,03fh
	call	VecTIA		 ;  call the write handler
	RestoreCPUState
	ret

VecTIA:
 	jmp	dword [TIARegHandler + esi*4]


;*
;* WSYNC -- wait for horizontal sync
;*

H_WSYNC:
 	cmp	byte [RClock],CYCLESPERSCANLINE ; did WSYNC come after end of line?
	ja near SetSkip				 ;    yes, skip a line (** check this **)

WsyncSimple:
	mov	edx,CYCLESPERSCANLINE
 	sub	dl,byte [RClock]
 	sub	dword dword [Timer],edx ; clock RIOT
 	mov	byte [RClock],CYCLESPERSCANLINE ; and CPU clock
	ret

SetSkip:
	mov	edx,2*CYCLESPERSCANLINE		 ;  skipping a line, bigger adjustment
 	sub	dl,byte [RClock]
 	sub	dword dword [Timer],edx ; clock RIOT
 	mov	byte [RClock],2*CYCLESPERSCANLINE ; and CPU clock
	ret

;*
;* VSYNC -- vertical sync set-clear
;*

H_VSYNC:
 	test	byte [WByte],2 ; if d1 is set then ....
	jz near ZRET
 	test	byte [VSyncFlag],2 ; somebody hitting Vsync more than necessary?
	jnz near VSyncAlreadySet		 ; 	  yep

 	mov	edx,dword [LinesInFrame]
 	mov	dword [PrevLinesInFrame],edx
 	mov	edx,dword [ScanLine]
 	mov	dword [LinesInFrame],edx ; *EST*
 	dec	dword [LinesInFrame]

DontUpdateLinesInFrame:
 	mov	dword [LooseColour],0ffffffffh
;	cmp	[PaletteNumber],1	; PAL palette?
;	jne near GrayFrame		;   no, don't simulate color loss
 	test	byte [SimColourLoss],1
	jz near GrayFrame
 	test	dword [LinesInFrame],1
	jz near GrayFrame
 	mov	dword [LooseColour],007070707h ; see tialine.asm
GrayFrame:
 	mov	dword [ScanLine],1 ; back to screen top

	cmp	edx,5			 ;  a quick double hit (pickpile)?
	jb near VSyncAlreadySet		 ; 	 yes, no new frame
 	inc	dword [Frame] ; new frame.

;*
;* automatic adjustment of game position (and video mode)
;*

 	mov	edx,dword [CFirst]
 	mov	dword [TempCFirst],edx ; to see how much we're changing by

 	cmp	dword [Frame],5
	je near AdjustUnstable		 ;  force adjustment of unstable games (pickpile)

 	mov	edx,dword [LinesInFrame]
 	cmp	edx,dword [PrevLinesInFrame]
	jne near AlreadyInPALMode	 ;  don't change video mode if not matching previous frame (quadrun)

 	test	byte [IOPortB],1 ; reset being pressed?
	jz near VSyncAlreadySet		 ; 	 yes, don't adjust

AdjustUnstable:
 	cmp	dword [LinesInFrame],282 ; NTSC game? (pharhcrs 296 when fire button pressed ...
					 ; 		    (... air_raid 292, zoofun 291, dumbo 286, curtiss 286,
					 ; 		    (... tps 285, galaga 282, tomboy 277)
	jb near AlreadyInPALMode	 ; 	 yes

 	cmp	byte [PaletteNumber],1 ; PAL mode already ?
	jz near AlreadyInPALMode	 ; 	 yes
 	cmp	byte [UserPaletteNumber],0ffh ; is there a palette override?
	jnz near AlreadyInPALMode	 ; 	  yes, don't switch

 	test	dword [Frame],0ffffff00h ; more than 256 frames passed?
	jnz near AlreadyInPALMode	 ;     yes, don't change TV type *EST*

 	mov	byte [PaletteNumber],1 ; set up PAL palette
	pushad
        call    position_game            ;  adjust starting line for PAL/NTSC
        call	srv_SetPalette		 ;  reset video mode for PAL games
	popad

AlreadyInPALMode:
 	cmp	dword [LinesInFrame],512 ; game ridiculously large?
	ja near VSyncAlreadySet		 ; 	 yes, no automatic adjustment
 	cmp	dword [LinesInFrame],220 ; game ridiculously small?
	ja near GameSizeOK		 ;    no
 	cmp	dword [BailoutLine],512 ; maybe BailoutLine is too small -- too big already?
	ja near GameSizeOK
 	mov	edx,dword [LinesInFrame]
	add	edx,4			 ;  match offset to below (aciddrop)
 	add	dword [BailoutLine],edx
	jmp	BailoutSet

GameSizeOK:
 	mov	edx,dword [LinesInFrame]
 	cmp	edx,dword [PrevLinesInFrame]
	jne near BailoutSet		 ;  don't reset BailoutLine if not matching previous frame (quadrun)
	add	edx,4			 ;  minimum 6 is needed for aciddrop or it flashes
 	mov	dword [BailoutLine],edx

BailoutSet:

VSyncAlreadySet:
 	mov	edx,dword [CFirst]
	cmp	edx,0			 ;  forcing first line ?
	jz near ZRET			 ;    no, let vblank take care of it

	call	TIABlank

DontBlank:
 	mov	dword [TopLine],edx
 	add	edx,dword [MaxLines]
 	mov	dword [BottomLine],edx
ZRET: mov	dl,byte [WByte]
 	mov	byte [VSyncFlag],dl	
 	Ret

;*
;* VBLANK -- vertical blank set-clear
;*

H_VBLANK:
	SaveCPUState
	mov	dl,1			 ;  VBlank delayed by 1 pixel
	call	CatchUpPixels		 ;  render pixels up to the write clock
	RestoreCPUState

 	mov	dl,byte [WByte]
 	mov	byte [VBlank],dl
	test	dl,2			 ;  setting or clearing ?
	jz near WVBClear		 ; 	  clearing

 	mov	edx,dword [ScanLine]
	cmp	edx,200
	jb near VBOnAlreadySet
 	mov	dword [VBlankOn],edx

VBOnAlreadySet:
 	cmp	dword [CFirst],0 ; VBlank triggering new frame ?
	je near WTB_1			 ; 	yes, don't mess with VBlanking
 	mov	dword [VBlanking],0
	jmp	HandleDumpedInputs

WTB_1:
 	mov	dword [TopLine],65535 ; setting -- turn off Tia
	call	TIABlank		 ;  clear rest of screen
	jmp	HandleDumpedInputs

WVBClear:
 	mov	edx,dword [ScanLine]
 	cmp	byte [PaletteNumber],1 ; NTSC game?
	jnz near DoNTSCTest		 ;    yes
	cmp	edx,78			 ;  allow penguin vblank
	ja near VBOffAlreadySet
 	mov	dword [VBlankOff],edx
	jmp	VBOffAlreadySet

DoNTSCTest:
	cmp	edx,58			 ;  allow brickick vblank
	ja near VBOffAlreadySet
 	mov	dword [VBlankOff],edx

VBOffAlreadySet:
 	cmp	dword [CFirst],0 ; VBlank triggering new frame ?
	je near WTB_2			 ; 	yes, don't mess with VBlanking
 	mov	dword [VBlanking],-1
	jmp	HandleDumpedInputs

WTB_2:
 	mov	edx,dword [ScanLine]
 	cmp	edx,dword [CFirst]
	jae near WVBPastMin
 	mov	edx,dword [CFirst]
WVBPastMin:
	inc	edx
 	mov	dword [TopLine],edx
 	add	edx,dword [MaxLines]
 	mov	dword [BottomLine],edx
	jmp	HandleDumpedInputs	 


HandleDumpedInputs:
 	test	byte [VBlank],080h ; discharging capacitors ?
	jz near HandleLatchedInputs	 ;    no
 	mov	dword dword [ChargeCounter],0 ; yes, zero the line counter

HandleLatchedInputs:
	ret




;*
;* some support code for TIA registers
;*

;*
;* get object position into bx
;*

[section .code]

%macro PositionObject 1
; local ; HBLnowrap, HBLdone, HBLnotweird, HBLinrange, HBLhandle78

 	movzx	ebx,byte [RClock]
	sub	ebx,CYCLESPERSCANLINE  ;  beyond end of scanline?
	jb near %%HBLnowrap  ;  no
%%HBLnotweird:
 	lea	ebx, [ebx+ebx*2]
	cmp	bl,67  ;  positioned in HBLANK area?
	ja near %%HBLdone  ;  no
	mov	bl,226
	jmp	%%HBLdone

%%HBLnowrap:
	add	ebx,CYCLESPERSCANLINE

 	cmp	byte [HMOVE_Cycle],3 ; HMOVE happening?
	jne near %%HBLnotweird  ;  no

	cmp	bl,24  ;  affected by weirdness?
	ja near %%HBLnotweird  ;  no
 	mov	ebx,dword [WeirdRespCorrection+4*ebx]
 	sub	ebx,dword [%1_Motion]
	add	ebx,226
	cmp	ebx,234
	jbe near %%HBLinrange
	mov	ebx,234
%%HBLinrange:	
	cmp	ebx,228
	jb near %%HBLdone
	sub	ebx,160

%%HBLdone:
%endmacro


;*
;* object rendering macros
;*
;* they should OR their respective bits into BL
;* AX, DL and SI are free registers that these routines can use
;*


;*
;* table update support macro
;*

%macro UpdateTable 1
; local ; regular_ok

 	movzx	esi,byte [TIA+NUSIZ%1]
	and	esi,7
 	movzx	edx,byte [%1_SizeTable+esi]
 	mov	dword [%1_Size],edx
 	mov	edx,dword [%1_RegularTable+esi*4] ; assume regular table
 	cmp	byte [%1_TripleFlag],0 ;;; GUESSED dword, changed to byte
	jnz near %%regular_ok
 	mov	edx,dword [%1_MultipleTable+esi*4] ; use multiple table

%%regular_ok:
 	mov	dword [%1_Table],edx
%endmacro



%macro SetObjectBit 1
; local ; done, nowrap

	movzx	esi,cl
 	sub	esi,dword [%1_Position]
	jae near %%nowrap
	add	esi,160
%%nowrap:	
 	cmp	esi,dword [%1_Size]
	ja near %%done
	add	esi,esi  ;  index into table
	AddTablePointer  %1
 	mov	al,byte [%1_Graphics]
 	test	al,[esi]
	jz near %%done
	or	bl,%1_BIT
%%done:
%endmacro


;*
;* get dl = object delay
;*     al = triple flag
;*     bx = object position
;*

%macro GetObjectDelay 1
; local ; done, nowrap

	PositionObject  %1
	mov	esi,ebx

	xor	dl,dl  ;  assume delay 0
	xor	al,al  ;  assume no triple flag

 	sub	esi,dword [%1_Position] ; where the object is
	jae near %%nowrap
	add	esi,160			
%%nowrap:	
 	cmp	esi,dword [%1_Size] ; beyond it's size?
	ja near %%done  ;  yes, no delay
	add	esi,esi  ;  index into table
	inc	esi  ;  point at delay byte
	AddTablePointer  %1
 	mov	dl,byte [esi] ; get delay byte
	test	dl,080h  ;  triple flag set?
	setnz	al  ;  set al if so
	and	dl,07fh  ;  delay value
%%done:
%endmacro




;*
;* Object activation/deactivation
;*
;* bit to activate/deactivate in al
;*

%macro ActivateObject 1
 	or	dword [ActiveObjects],%1
%endmacro


%macro DeactivateObject 1
 	and	dword [ActiveObjects], ~%1
%endmacro



;*
;* update playfield color
;*
;* call before every pixel run (lots of things can affect PF color)
;*

doUpdatePlayfieldColor:
 	mov	dl,byte [TIA+COLUPF]
	mov	dh,dl			 ;  16-bit playfield color
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh			 ;  32-bit playfield color
 	mov	dword [BL_Color],edx ; ball is always this color
 	mov	dword [PF_Color],edx ; assume *normal* state of affairs

	mov	edx, TIADisplayToColour
 	test	byte [TIA+CTRLPF],PFP ; does playfield have priority?
	jz near UPFC_CheckScore		 ; 	 no
	mov	edx, TIADisplayToColour2
 	mov	dword [PixelColorTable],edx ; yes, update pixel to color translation table
	jmp	UPFC_done		 ;  don't pay attention to score mode...

UPFC_CheckScore:
 	mov	dword [PixelColorTable],edx ; update pixel to color translation table
 	test	byte [TIA+CTRLPF],SCORE ; in score mode?
	jz near UPFC_done		 ;    no
 	mov	edx,dword [P0_Color] ; assume Player 0 color
	cmp	cl,147			 ;  right side of playfield?
	jbe near UPFC_SetReg		 ;    no
 	mov	edx,dword [P1_Color] ; yes, use Player 1 color
UPFC_SetReg:
 	mov	dword [PF_Color],edx ; update the register

UPFC_done:
	ret


%macro UpdatePlayfieldColor 0
	call	doUpdatePlayfieldColor
%endmacro



;*
;* update playfield reflection
;*
;* call at mid-line, and when CTRLPF is updated
;*

%macro UpdatePlayfieldReflection 0
; local ; UPFR_Ret

 	mov	dword [PF_Table], PFClockToBitForward
 	test	byte [TIA+CTRLPF],REF ; playfield reflected?
	jz near %%UPFR_Ret  ;  no
 	mov	dword [PF_Table], PFClockToBitReversed
%%UPFR_Ret:

%endmacro



;*
;* update ball graphics
;*

UpdateBallGraphics:
	
 	mov	dl,byte [TIA+ENABL] ; assume regular ball
 	test	byte [TIA+VDELBL],1 ; using delayed register?
	jz near UBGtestball		 ;    no
 	mov	dl,byte [BL_Delayed] ; yes, use delayed ball

UBGtestball:
	test	dl,2			 ;  ball turned on?
	jz near UBGnoball		 ;    no
	ActivateObject  BL_BIT ;    yes, ActivateObject
	mov	dl,030h			 ;  mask ball size
 	and	dl,byte [TIA+CTRLPF]
	movzx	esi,dl
	shr	esi,4
 	mov	dl,byte [BallSize + esi] ; look up in table
 	mov	byte [BL_Graphics],dl ; set graphics register
	ret


UBGnoball:
	DeactivateObject  BL_BIT ;  no ball, DeactivateObject
 	mov	byte [BL_Graphics],0 ;;; GUESSED dword (changed to byte) ; clear the graphics register

	ret


;*
;* player graphics support macro
;*

%macro UpdatePlayerGraphics 1
; local ; UPnodelay, UPdone

 	mov	dl,byte [TIA+GR%1] ; assume regular graphics
 	test	byte [TIA+VDEL%1],1 ; using delayed register?
	jz near %%UPnodelay  ;  no
 	mov	dl,byte [%1_Delayed] ; yes, use delayed graphics
%%UPnodelay:
	DeactivateObject  %1_BIT ;  assume not active
	test	dl,dl  ;  graphics active?
	jz near %%UPdone  ;  no, done
	ActivateObject  %1_BIT ;  yes, ActivateObject
 	test	byte [TIA+REF%1],08h ; reflected?
	jz near %%UPdone  ;  no
	movzx	esi,dl  ;  yes
 	mov	dl,byte [TIAReflect8+esi] ; reflect it
%%UPdone:
 	mov	byte [%1_Graphics],dl ; update register
%endmacro



;*
;* update P0 graphics
;*

UpdateP0Graphics:

	UpdatePlayerGraphics  P0

	ret


;*
;* update P1 graphics
;*

UpdateP1Graphics:

	UpdatePlayerGraphics  P1

	ret

;*
;* missile graphics support macro
;*

RESM0P equ RESMP0 
RESM1P equ RESMP1 

%macro UpdateMissileGraphics 1
; local ; noMissile

	DeactivateObject  %1_BIT ;  assume inactive
 	mov	byte [%1_Graphics],0 ;;; GUESSED dword  (changed to byte); clear register
 	test	byte [TIA+RES%1P],2 ; missile locked to player?
	jnz near %%noMissile  ;  yes, no missile
 	test	byte [TIA+ENA%1],2 ; missile enabled?
	jz near %%noMissile  ;  no
	ActivateObject  %1_BIT ;  yes, ActivateObject
 	movzx	esi,byte [TIA+NUSIZ%1] ; size is here
	and	esi,030h  ;  mask size bits
	shr	esi,4
 	mov	dl,byte [BallSize + esi] ; look up in table
 	mov	byte [%1_Graphics],dl ; update register
%%noMissile:
%endmacro



;*
;* update M0 graphics
;*

UpdateM0Graphics:

	UpdateMissileGraphics  M0

	ret

;*
;* update M1 graphics
;*

UpdateM1Graphics:

	UpdateMissileGraphics  M1

	ret

;*
;* update P0 Table
;*

UpdateP0Table:

	UpdateTable  P0

	ret

;*
;* update P1 Table
;*

UpdateP1Table:

	UpdateTable  P1

	ret

;*
;* update M0 Table
;*

UpdateM0Table:

	UpdateTable  M0

	ret

;*
;* update M1 Table
;*

UpdateM1Table:

	UpdateTable  M1

	ret

;*
;* set up multi-sprite trick
;* call at beginning of each scanline
;*

SetupMultiSpriteTrick:
 	cmp	byte [M0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_M1
 	mov	byte [M0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateM0Table

SMS_M1: cmp	byte [M1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_P0
 	mov	byte [M1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateM1Table

SMS_P0: cmp	dword [P0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_P1
 	mov	byte [P0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateP0Table

SMS_P1: cmp	dword [P1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_done
 	mov	byte [P1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateP1Table

SMS_done:	
	ret


;*
;* missile locking support macro
;*

[section .data]
MissileOffset db 5, 5, 5, 5, 5, 8, 5, 12
[section .code]

%macro LockMissile 2
; local ; nowrap

	push	esi
 	movzx	esi,byte [TIA+NUSIZ%1]
	and	esi,7
 	movzx	edx,byte [MissileOffset+esi]
	pop	esi

 	add	edx,dword [%2_Position]
	cmp	edx,227
	jbe near %%nowrap
	sub	edx,160
%%nowrap:
 	mov	byte [TIA+RES%1],dl
 	mov	dword [%1_Position],edx

%endmacro


;*
;* update M0 locking
;*

UpdateM0Locking:
 	test	byte [TIA+RESMP0],2
	jz near M0nolock

	LockMissile  M0,  P0

M0nolock:
	ret

;*
;* update M1 locking
;*

UpdateM1Locking:
 	test	byte [TIA+RESMP1],2
	jz near M1nolock

	LockMissile  M1,  P1

M1nolock:
	ret

;*
;* a do nothing TIA register write
;*

H_Null:	ret				 ;  a null TIA register write


;*
;* color setting support macro
;*

%macro SetColor 1
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	shr	dl,1  ;  pre shift right 1 bit
 	mov	byte [TIA+COLU%1],dl ; update the register
	mov	dh,dl
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh

%endmacro


;*
;* a TIA color register write
;*

H_COLUP0:
	SetColor  P0
 	mov	dword [P0_Color],edx

	ret

H_COLUP1:
	SetColor  P1
 	mov	dword [P1_Color],edx

	ret

H_COLUBK:
	SetColor  BK
 	mov	dword [BK_Color],edx	

	ret

H_COLUPF:
	SetColor  PF

	ret


;*
;* CTRLPF write
;*

H_CTRLPF:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+CTRLPF],dl

HCPFdone:
	call	UpdateBallGraphics
	ret

;*
;* a TIA playfield bit write
;*
;* Delays are set to make sure all 4 pixels of a playfield bit go 
;* out unchanged even if the write occurs in middle of 4 bit group.
;* Plus there is additional delay if write occurs on last pixel 
;* of a 4 bit group.  The next group uses the old value.
;*

H_PF:
 	mov	bl,byte [RClock]
	add	bl,bl
 	add	bl,byte [RClock] ; write occurred here

	and	ebx,3
 	mov	dl,byte [PFDelay+ebx] ; render this far into the future

	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [pf_mask]
 	mov	byte [TIA+esi],dl ; update the register

	DeactivateObject  PF_BIT
 	test	dword byte [TIA+PF0],0ffffffh ; test playfield bits
	jz near H_PFRet
	ActivateObject  PF_BIT

H_PFRet:
	ret

;*
;* horizontal motion support macro
;*

%macro DoMotion 1
; local ; positive, done

 	mov	edx,dword [%1_Motion]
 	sub	dword [%1_Position],edx
 	cmp	dword [%1_Position],68 ;;; GUESSED dword, looks OK
	jae near %%positive
 	add	dword [%1_Position],160 ;;; GUESSED dword, looks OK
	jmp	%%done

%%positive:
 	cmp	dword [%1_Position],228 ;;; GUESSED dword, looks OK
	jb near %%done
 	sub	dword [%1_Position],160 ;;; GUESSED dword, looks OK
%%done:
%endmacro


;*
;* HMOVE
;*

;*
;* this could be called at beginning of a scanline
;* but it's called at register write time
;*

doHMOVE:
 	cmp	byte [HMOVE_Pending],0
	jz near noHMOVE

	DoMotion  P0
	DoMotion  P1
	DoMotion  M0
	DoMotion  M1
	DoMotion  BL

	call	UpdateM0Locking
	call	UpdateM1Locking

 	mov	byte [HMOVE_Pending],0

noHMOVE:
	ret

;*
;* macro to set up amount of motion for HMOVES near beginning of scan line
;*

[section .data]
MaxMotion:  ; byte
 db   7,  7,  7,  7,  6,  5,  5,  4,  3,  2
 db   2,  1,  0, -1, -1, -2, -3, -4, -4, -5
 db  -6

[section .code]

%macro FixupMotionLow 1
; local ; MotionOK

 	movsx	edx,byte [TIA+HM%1]
	push	ebx
 	movzx	ebx,byte [RClock]
 	movsx	ebx,byte [MaxMotion+ebx]
	cmp	edx,ebx
	jl near %%MotionOK
	mov	edx,ebx
 	mov	dword [%1_Motion],edx
%%MotionOK:
	pop	ebx
%endmacro


;*
;* this is called at register write time
;*	

H_HMOVE:
	mov	dl,0
	call	CatchUpPixels

	CheckWeird
	
 	mov	dl,byte [RClock]
 	mov	byte [HMOVE_Cycle],dl ; remember where HMOVE was (cosmic)
 	cmp	byte [M0_Confused],0
	jz near WasntConfused

 	mov	byte [M0_Confused],0 ; HMOVE cancels confusion
	call	UpdateM0Graphics

WasntConfused:
 	movsx	edx,byte [TIA+HMP0] ; xx_Motion is different from HMxx
 	mov	dword [P0_Motion],edx ; in case we decide to doHMOVE 
 	movsx	edx,byte [TIA+HMP1] ; somewhere else
 	mov	dword [P1_Motion],edx
 	movsx	edx,byte [TIA+HMM0]
 	mov	dword [M0_Motion],edx
 	movsx	edx,byte [TIA+HMM1]
 	mov	dword [M1_Motion],edx
 	movsx	edx,byte [TIA+HMBL]
 	mov	dword [BL_Motion],edx

 	mov	byte [HMOVE_Pending],1 ; also in case we doHMOVE elsewhere

 	cmp	byte [RClock],20
	ja near HiBlank
 	cmp	byte [RClock],3
	jbe near LoBlank

DoBlank:
	FixupMotionLow  P0
	FixupMotionLow  P1
	FixupMotionLow  M0
	FixupMotionLow  M1
	FixupMotionLow  BL
LoBlank:
 	mov	byte [HBlanking],0 ; set up the HMOVE blank
	call	doHMOVE
	ret

HiBlank:
 	cmp	byte [RClock],54
	jbe near NoMotion
 	cmp	byte [RClock],74
	jbe near NoBlank
 	mov	byte [SetHBlanking],1

	call	doHMOVE
	ret	

[section .data]

HiTable db 14, 13, 12, 12, 11, 10, 9, 9, 8, 7, 6, 6, 5, 4, 3, 3, 2, 1, 0, 0

[section .code]

%macro FixupMotionHi 1
; local ; SetMotion

 	movsx	edx,byte [TIA+HM%1]
	add	edx,8
	push	ebx
 	movzx	ebx,byte [RClock]
	sub	ebx,55
 	movsx	ebx,byte [HiTable+ebx]
	sub	edx,ebx
	cmp	edx,0
	jg near %%SetMotion
	mov	edx,0

%%SetMotion:
 	mov	dword [%1_Motion],edx
	pop	ebx
%endmacro




NoBlank:
	FixupMotionHi  P0
	FixupMotionHi  P1
	FixupMotionHi  M0
	FixupMotionHi  M1
	FixupMotionHi  BL

	call	doHMOVE
	ret

NoMotion:
	ret


;*
;* RESBL
;*


H_RESBL:
	GetObjectDelay  BL

;*
;* mind master cheat
;*

 	cmp	byte [Starpath],0 ; if you don't do this, the cheat breaks keystone.bin
	jz near RBL_goahead
	cmp	bl,69			 ;  other than that, you don't want to know...
	je near RBL_handle69
	cmp	bl,226
	jne near RBL_goahead

RBL_handle69:
 	cmp	byte [HMOVE_Cycle],5
	je near RBL_isweird
 	cmp	byte [HMOVE_Cycle],0
	jne near RBL_goahead
 	cmp	byte [Last_HMOVE_Cycle],78
	jne near RBL_goahead

RBL_isweird:
	mov	bl,74			 ;  if we're cheating, the ball lands here

;*
;* end of cheat
;*

RBL_goahead:
	push	ebx			 ;  save object position
	call	CatchUpPixels
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESBL],bl
 	mov	dword [BL_Position],ebx

	ret


;*
;* a positioning cheat for Kool Aide
;*

%macro CheatKoolAidePosition 3
; local ; done

 	cmp	byte [KoolAide],0 ; doing Kool Aide cheat?
	jz near %%done  ;  no
 	cmp	dword [ScanLine],%1
	jne near %%done
	cmp	ebx,%2+68-5
	jne near %%done

	mov	ebx,%3+68-5  ;  yes, do the cheat

%%done:
%endmacro



;*
;* RESP0
;*

H_RESP0:
	GetObjectDelay  P0
	push	ebx			 ;  save object position
 	mov	byte [P0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP0Table
	pop	ebx			 ;  restore object position

	CheatKoolAidePosition  40,  54,  52
	CheatKoolAidePosition  49,  63,  61

 	mov	byte [TIA+RESP0],bl
 	mov	dword [P0_Position],ebx

	call	UpdateM0Locking

	ret


;*
;* RESP1
;*

H_RESP1:
	GetObjectDelay  P1
	push	ebx			 ;  save object position
 	mov	byte [P1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP1Table
	pop	ebx			 ;  restore object position

	CheatKoolAidePosition  40,  63,  65
	CheatKoolAidePosition  49,  72,  74

 	mov	byte [TIA+RESP1],bl
 	mov	dword [P1_Position],ebx

	call	UpdateM1Locking

	ret

;*
;* RESM0
;*

H_RESM0:
 	test	byte [TIA+RESMP0],2 ; missile locked to player ?
	jnz near noRESM0			 ;    yes, don't position

	GetObjectDelay  M0
	push	ebx			 ;  save object position
 	mov	byte [M0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM0Table
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESM0],bl
 	mov	dword [M0_Position],ebx

noRESM0:
	ret


;*
;* RESM1
;*

H_RESM1:
 	test	byte [TIA+RESMP1],2 ; missile locked to player ?
	jnz near noRESM1			 ;    yes, don't position

	GetObjectDelay  M1
	push	ebx			 ;  save object position
 	mov	byte [M1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM1Table
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESM1],bl
 	mov	dword [M1_Position],ebx

noRESM1:
	ret


;*
;* ENABL
;*

H_ENABL:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [bl_mask]
 	mov	byte [TIA+ENABL],dl

	call	UpdateBallGraphics
	ret


;*
;* ENAM0
;*

H_ENAM0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [m0_mask]
 	mov	byte [TIA+ENAM0],dl

	call	UpdateM0Graphics
	ret


;*
;* ENAM1
;*

H_ENAM1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [m1_mask]
 	mov	byte [TIA+ENAM1],dl

	call	UpdateM1Graphics
	ret

;*
;* macro to handle writes to NUSIZ register
;*

%macro DoNUSIZ 1
; local ; NoCatchup, CatchupWide, NoCheat, done

	GetObjectDelay  M%1
	call	CatchUpPixels  ;  render any missile in progress
	
 	mov	dl,byte [TIA+NUSIZ%1]
	and	dl,7
	cmp	dl,7  ;  quad wide player?
	je near %%CatchupWide  ;  yes
	cmp	dl,5  ;  double wide player?
	je near %%CatchupWide  ;  yes

	GetObjectDelay  P%1 ;  no
	call	CatchUpPixels  ;  complete the player in progress
	jmp	%%NoCatchup

%%CatchupWide:
	GetObjectDelay  P%1
	test	dl,dl  ;  are we in the wide sprite?
	jz near %%NoCatchup  ;  no
	mov	dl,4  ;  (4 for sentinel)
	call	CatchUpPixels  ;  render a few trailing pixels

%%NoCatchup:
 	mov	dl,byte [WByte]
 	mov	byte [TIA+NUSIZ%1],dl ; switch to new NUSIZ

	call	UpdateM%1Graphics  ;  update things
	call	UpdateP%1Table
	call	UpdateM%1Table

 	mov	dl,byte [P%1_Graphics]
	push	edx  ;  save current player graphics
 	mov	byte [P%1_Graphics],0 ;;; GUESSED dword, changed to byte ; set to zero to render nothing
	GetObjectDelay  P%1
	test	dl,dl  ;  would table switch land us in a sprite?
	jz near %%done  ;  no

 	cmp	byte [RSBoxing],0 ; doing RSBOXING cheat?
	jz near %%NoCheat  ;  no
	sub	dl,2  ;  yes, don't render completely thru new sprite

%%NoCheat:
	call	CatchUpPixels  ;  yes, render nothing thru new sprite
  ;  (** messes up rsboxing a little bit -- too far into future **)
  ;  (** if I ever fix this right, it might fix PROWREST too **)

%%done:
	pop	edx
 	mov	byte [P%1_Graphics],dl ; restore player graphics
%endmacro



;*
;* NUSIZ0
;*

H_NUSIZ0:
	DoNUSIZ  0
	ret


;*
;* NUSIZ1
;*

H_NUSIZ1:
	DoNUSIZ  1
	ret


;*
;* VDELBL
;*

H_VDELBL:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELBL],dl

	call	UpdateBallGraphics
	ret


;*
;* VDELP0
;*

H_VDELP0:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELP0],dl

	call	UpdateP0Graphics
	ret


;*
;* VDELP1
;*

H_VDELP1:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELP1],dl

	call	UpdateP1Graphics
	ret

;*
;* GRP0
;*

H_GRP0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [p0_mask]
 	mov	byte [TIA+GRP0],dl

 	mov	dl,byte [TIA+GRP1]
 	mov	byte [P1_Delayed],dl
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret


;*
;* GRP1
;*

H_GRP1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	and	dl,byte [p1_mask]
 	mov	byte [TIA+GRP1],dl

 	mov	dl,byte [TIA+ENABL]
 	mov	byte [BL_Delayed],dl
 	mov	dl,byte [TIA+GRP0]
 	mov	byte [P0_Delayed],dl
	call	UpdateBallGraphics
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret

;*
;* handle a non-M0 motion register
;*

%macro HandleMotion 1
; local ; NormalMotion

	push	ebx

 	cmp	byte [HMOVE_Cycle],3
	jne near %%NormalMotion

 	cmp	byte [RClock],26
	jae near %%NormalMotion
 	movzx	ebx,byte [TIA+HM%1]
	and	ebx,0fh
	shl	ebx,4
 	movzx	edx,byte [WByte]
	shr	edx,4
	and	edx,0fh
	add	ebx,edx
	shl	ebx,5
 	movzx	edx,byte [RClock]
	and	edx,01fh
	add	ebx,edx
 	mov	dl,byte [DeepHMOVE + ebx]
	test	dl,dl
	jz near %%NormalMotion
	cmp	dl,99
	je near %%NormalMotion  ;  cosmic is normal for now
	movsx	edx,dl
	neg	edx
 	mov	dword [%1_Motion],edx
	DoMotion  %1
 	cmp	byte [TraceCount],0
	jz near %%NormalMotion

	pushad
	call	ShowAdjusted
	popad

%%NormalMotion:
 	mov	dl,byte [WByte]
	sar	dl,4  ;  pre-shift right 4 bits (preserve sign)
 	mov	byte [TIA+HM%1],dl
	pop	ebx

%endmacro



H_HMP0:
	CheckDeep
	HandleMotion  P0
	ret

H_HMP1:
	CheckDeep
	HandleMotion  P1
	ret

H_HMM1:
	CheckDeep
	HandleMotion  M1
	ret

H_HMBL:
	CheckDeep
	HandleMotion  BL
	ret

;*
;* HMM0
;*

H_HMM0:
	CheckDeep
 	cmp	byte [HMOVE_Cycle],3
	jne near NotConfused
 	cmp	byte [RClock],24
	jne near NotConfused
 	cmp	dword [M0_Motion],7 ;;; GUESSED dword, looks OK
	jne near NotConfused
 	cmp	byte [WByte],060h
	jne near NotConfused
 	mov	byte [M0_Confused],1
 	mov	dword [CosmicScanLine],1
 	mov	dword [M0_Motion],2 ;;; GUESSED dword, looks OK
	DoMotion  M0

NotConfused:
	HandleMotion  M0
	ret

;*
;* HMCLR
;*

H_HMCLR:
 	mov	dl,byte [WByte]
	push	edx
 	mov	byte [WByte],0

	CheckDeep

 	cmp	byte [HMOVE_Cycle],3
	jne near HMC_NotConfused
 	cmp	byte [RClock],23
	jne near HMC_NotConfused
 	cmp	dword [M0_Motion],7 ;;; GUESSED dword, looks OK
	jne near HMC_NotConfused
 	mov	byte [M0_Confused],1
 	mov	dword [CosmicScanLine],1

HMC_NotConfused:
	HandleMotion  M0
	HandleMotion  M1
	HandleMotion  P0
	HandleMotion  P1
	HandleMotion  BL

	pop	edx
 	mov	byte [WByte],dl
	jmp	HMCLR_Done

HMCLR_NotWeird:
 	mov	byte [TIA+HMP0],0
 	mov	byte [TIA+HMP1],0
 	mov	byte [TIA+HMM0],0
 	mov	byte [TIA+HMM1],0
 	mov	byte [TIA+HMBL],0

HMCLR_Done:
	ret


;*
;* CXCLR
;*

H_CXCLR:
	mov	dl,0
	call	CatchUpPixels

 	mov	dword [TIACollide],0
	ret



;*
;* REFP0
;*

H_REFP0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+REFP0],dl
	call	UpdateP0Graphics
	ret



;*
;* REFP1
;*

H_REFP1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+REFP1],dl
	call	UpdateP1Graphics
	ret

;*
;* RESMP0
;*

H_RESMP0:

	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+RESMP0],dl

	call	UpdateM0Locking
	call	UpdateM0Graphics

	ret

;*
;* RESMP1
;*

H_RESMP1:

	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+RESMP1],dl

	call	UpdateM1Locking
	call	UpdateM1Graphics

	ret



;
; $Log: tiawrite.asm,v $
; Revision 1.5  2004/05/15 18:53:37  urchlay
;
; Made -t (trace mode) work again. Added -tt option (trace mode on, but
; disabled until the user presses F11).
;
; Revision 1.4  2004/05/15 15:36:13  urchlay
;
; The rest of the graphics can be disabled/enabled:
;
; Alt+key   Graphic
; Z         P0
; X         P1
; C         M0
; V         M1
; B         Ball
; N         Playfield (whole thing)
; /         Turns all of the above ON
;
; Revision 1.3  2004/05/14 20:03:17  urchlay
;
; We can enable/disable player 0 and player 1 graphics by pressing alt-z and
; alt-x, respectively. The default state (of course) is enabled.
;
; Revision 1.2  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
