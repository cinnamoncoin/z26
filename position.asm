; Yes, the whole file's wrapped in this ifdef:
%ifdef C_POSGAME

extern position_game
extern TopLine
extern BottomLine

%else
[section .data]

TopLine		dd  0	 ;  top line of display
BottomLine	dd  0	 ;  bottom line of display

StartLineTable:  ; dword
        dd      28, 28, 28       ;  400x300
        dd      22, 42, 42       ;  320x240
        dd      42, 58, 58       ;  320x200
        dd      28, 28, 28       ;  800x600
        dd      22, 42, 42       ;  640x480
        dd      42, 58, 58       ;  640x400
        dd      28, 28, 28       ;  800x600
        dd      22, 42, 42       ;  640x480
        dd      42, 58, 58       ;  640x400

;              NTSC PAL SECAM
MaxLineTable:  ; dword
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200

[section .code]


global position_game
position_game:

;*
;* set up max # of lines to display based on video mode
;*

	movzx	esi,byte [VideoMode]
	mov	esi,dword [MaxLineTable + esi*4]
	cmp     esi,dword [MaxLines] ; did user specify a screen height?
	ja near UserSetHeight            ;    yes, don't override
	mov	dword [MaxLines],esi
UserSetHeight:

;*
;* set up CFirst (first line to display)
;*

 	mov	edx,dword [UserCFirst]
 	mov	dword [CFirst],edx
 	cmp	dword [UserCFirst],0ffffh ; did user specify a line number?
	jne near TGM_TestUltimate	 ;    yes, don't override
 	mov	edx,dword [DefaultCFirst]
 	mov	dword [CFirst],edx
 	cmp	dword [DefaultCFirst],0ffffh ; does game have a recommended starting line?
	jne near TGM_TestUltimate	 ;    yes, use it

         movzx   esi,byte [PaletteNumber]
        cmp     esi,3                    ;  if not NTSC, PAL or SECAM (0, 1, 2)
        jb near ValidPaletteNumber
        mov     esi,0                    ;    then position for NTSC game
ValidPaletteNumber:
         movzx   edx,byte [VideoMode]
        imul    edx,3                    ;  3 palettes per video mode
        add     esi,edx
 	mov	esi,dword [StartLineTable + esi*4]
 	mov	dword [CFirst],esi ; use the standard default

;*
;* adjust CFirst based on game size
;*

TGM_TestUltimate:
 	cmp	dword [MaxLines],400 ; in a very tall video mode?
	jb near TGM_Done		 ;    no
 	cmp	dword [CFirst],0 ; frogpond or pharhcrs ?
	jz near TGM_Done		 ;    yes
 	mov	dword [CFirst],1 ; no, this is ultimate reality mode

TGM_Done:
 	mov	edx,dword [CFirst]
 	mov	dword [OldCFirst],edx ; remember starting line for homing the display
 	mov	dword [TopLine],edx ; set up some things in case there's no vsync
 	add	edx,dword [MaxLines] ; (like bowlg_tw.bin)
 	mov	dword [BottomLine],edx

	ret
%endif


;
; $Log: position.asm,v $
; Revision 1.4  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
