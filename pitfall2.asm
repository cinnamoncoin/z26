;*
;* Pitfall 2 8K bankswitch scheme -- similar to standard F8
;*
;* 5-12-99 -- break ground
;* 7-17-02 -- 32-bit
;* 5-08-04 -- test CVS ;-)
;*
;* Based in part on David Crane's U.S. Patent 4,644,495, Feb 17,1987.
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

[section .data]

; global Pitfall2 flag 
P2_Start:  ; byte			; <-- start clearing here

global Pitfall2
Pitfall2	db	0		 ;  tell RIOT timer to clock the music

P2_Flags	db	0,0,0,0,0,0,0,0
P2_Counters	dd	0,0,0,0,0,0,0,0
P2_Top		db	0,0,0,0,0,0,0,0
P2_Bottom	db	0,0,0,0,0,0,0,0
P2_Enable	db	0,0,0,0,0,0,0,0
P2_Music_Top	dd	0,0,0,0,0,0,0,0
P2_Music_Bottom	dd	0,0,0,0,0,0,0,0
P2_Music_Count	dd	0,0,0,0,0,0,0,0

P2_Rbyte	db	0		 ;  return value for CPU read commands
P2_Null		db	0		 ;  return value for null read commands
P2_AUDV		db	0		 ;  create an AUDV byte here

P2_sreg		dd	0		 ;  initialize shift register to non-zero val
P2_End:  ; byte			; <-- finish clearing here

[section .data]




ALIGN 2
P2_Vectors:  ; dword

;*
;* read commands
;*

	dd	P2_Read_Random		 ;  00 -- Random # generator
	dd	P2_Read_Random		 ;  01 -- Random # generator
	dd	P2_Read_Random		 ;  02 -- Random # generator
	dd	P2_Read_Random		 ;  03 -- Random # generator
	dd	P2_Read_Sound		 ;  04 -- Sound value
	dd	P2_Read_Sound		 ;  05 -- Sound value
	dd	P2_Read_Sound		 ;  06 -- Sound value
	dd	P2_Read_Sound		 ;  07 -- Sound value
	dd	P2_Read_DF		 ;  08 -- DF0
	dd	P2_Read_DF		 ;  09 -- DF1
	dd	P2_Read_DF		 ;  0a -- DF2
	dd	P2_Read_DF		 ;  0b -- DF3
	dd	P2_Read_DF		 ;  0c -- DF4
	dd	P2_Read_DF		 ;  0d -- DF5
	dd	P2_Read_DF		 ;  0e -- DF6
	dd	P2_Read_DF		 ;  0f -- DF7
	dd	P2_Read_DF_Flag		 ;  10 -- DF0 AND flag
	dd	P2_Read_DF_Flag		 ;  11 -- DF1 AND flag
	dd	P2_Read_DF_Flag		 ;  12 -- DF2 AND flag
	dd	P2_Read_DF_Flag		 ;  13 -- DF3 AND flag
	dd	P2_Read_DF_Flag		 ;  14 -- DF4 AND flag
	dd	P2_Read_DF_Flag		 ;  15 -- DF5 AND flag
	dd	P2_Read_DF_Flag		 ;  16 -- DF6 AND flag
	dd	P2_Read_DF_Flag		 ;  17 -- DF7 AND flag
	dd	P2_NoIO			 ;  18 -- DF0 AND flag swapped
	dd	P2_NoIO			 ;  19 -- DF1 AND flag swapped
	dd	P2_NoIO			 ;  1a -- DF2 AND flag swapped
	dd	P2_NoIO			 ;  1b -- DF3 AND flag swapped
	dd	P2_NoIO			 ;  1c -- DF4 AND flag swapped
	dd	P2_NoIO			 ;  1d -- DF5 AND flag swapped
	dd	P2_NoIO			 ;  1e -- DF6 AND flag swapped
	dd	P2_NoIO			 ;  1f -- DF7 AND flag swapped
	dd	P2_NoIO			 ;  20 -- DF0 AND flag reversed
	dd	P2_NoIO			 ;  21 -- DF1 AND flag reversed
	dd	P2_NoIO			 ;  22 -- DF2 AND flag reversed
	dd	P2_NoIO			 ;  23 -- DF3 AND flag reversed
	dd	P2_NoIO			 ;  24 -- DF4 AND flag reversed
	dd	P2_NoIO			 ;  25 -- DF5 AND flag reversed
	dd	P2_NoIO			 ;  26 -- DF6 AND flag reversed
	dd	P2_NoIO			 ;  27 -- DF7 AND flag reversed
	dd	P2_NoIO			 ;  28 -- DF0 AND flag SHR 1
	dd	P2_NoIO			 ;  29 -- DF1 AND flag SHR 1
	dd	P2_NoIO			 ;  2a -- DF2 AND flag SHR 1
	dd	P2_NoIO			 ;  2b -- DF3 AND flag SHR 1
	dd	P2_NoIO			 ;  2c -- DF4 AND flag SHR 1
	dd	P2_NoIO			 ;  2d -- DF5 AND flag SHR 1
	dd	P2_NoIO			 ;  2e -- DF6 AND flag SHR 1
	dd	P2_NoIO			 ;  2f -- DF7 AND flag SHR 1
	dd	P2_NoIO			 ;  30 -- DF0 AND flag SHL 1
	dd	P2_NoIO			 ;  31 -- DF1 AND flag SHL 1
	dd	P2_NoIO			 ;  32 -- DF2 AND flag SHL 1
	dd	P2_NoIO			 ;  33 -- DF3 AND flag SHL 1
	dd	P2_NoIO			 ;  34 -- DF4 AND flag SHL 1
	dd	P2_NoIO			 ;  35 -- DF5 AND flag SHL 1
	dd	P2_NoIO			 ;  36 -- DF6 AND flag SHL 1
	dd	P2_NoIO			 ;  37 -- DF7 AND flag SHL 1
	dd	P2_ReadFlags		 ;  38 -- DF0 flag
	dd	P2_ReadFlags		 ;  39 -- DF1 flag
	dd	P2_ReadFlags		 ;  3a -- DF2 flag
	dd	P2_ReadFlags		 ;  3b -- DF3 flag
	dd	P2_ReadFlags		 ;  3c -- DF4 flag
	dd	P2_ReadFlags		 ;  3d -- DF5 flag
	dd	P2_ReadFlags		 ;  3e -- DF6 flag
	dd	P2_ReadFlags		 ;  3f -- DF7 flag

;*
;* write commands
;*

	dd	P2_WriteTop		 ;  40 -- DF0 top count
	dd	P2_WriteTop		 ;  41 -- DF1 top count
	dd	P2_WriteTop		 ;  42 -- DF2 top count
	dd	P2_WriteTop		 ;  43 -- DF3 top count
	dd	P2_WriteTop		 ;  44 -- DF4 top count
	dd	P2_WriteTop		 ;  45 -- DF5 top count
	dd	P2_WriteTop		 ;  46 -- DF6 top count
	dd	P2_WriteTop		 ;  47 -- DF7 top count
	dd	P2_WriteBottom		 ;  48 -- DF0 bottom count
	dd	P2_WriteBottom		 ;  49 -- DF1 bottom count
	dd	P2_WriteBottom		 ;  4a -- DF2 bottom count
	dd	P2_WriteBottom		 ;  4b -- DF3 bottom count
	dd	P2_WriteBottom		 ;  4c -- DF4 bottom count
	dd	P2_WriteBottom		 ;  4d -- DF5 bottom count
	dd	P2_WriteBottom		 ;  4e -- DF6 bottom count
	dd	P2_WriteBottom		 ;  4f -- DF7 bottom count
	dd	P2_WriteCounterLow	 ;  50 -- DF0 counter low
	dd	P2_WriteCounterLow	 ;  51 -- DF1 counter low
	dd	P2_WriteCounterLow	 ;  52 -- DF2 counter low
	dd	P2_WriteCounterLow	 ;  53 -- DF3 counter low
	dd	P2_WriteCounterLow	 ;  54 -- DF4 counter low
	dd	P2_WriteCounterLow	 ;  55 -- DF5 counter low
	dd	P2_WriteCounterLow	 ;  56 -- DF6 counter low
	dd	P2_WriteCounterLow	 ;  57 -- DF7 counter low
	dd	P2_WriteCounterHigh	 ;  58 -- DF0 counter high
	dd	P2_WriteCounterHigh	 ;  59 -- DF1 counter high
	dd	P2_WriteCounterHigh	 ;  5a -- DF2 counter high
	dd	P2_WriteCounterHigh	 ;  5b -- DF3 counter high
	dd	P2_WriteCounterHigh	 ;  5c -- DF4 counter high
	dd	P2_WriteCounterHigh	 ;  5d -- DF5 counter high AND music enable
	dd	P2_WriteCounterHigh	 ;  5e -- DF6 counter high AND music enable
	dd	P2_WriteCounterHigh	 ;  5f -- DF7 counter high AND music enable
	dd	P2_NoIO			 ;  60 -- not used (draw line movement)
	dd	P2_NoIO			 ;  61 -- not used (draw line movement)
	dd	P2_NoIO			 ;  62 -- not used (draw line movement)
	dd	P2_NoIO			 ;  63 -- not used (draw line movement)
	dd	P2_NoIO			 ;  64 -- not used (draw line movement)
	dd	P2_NoIO			 ;  65 -- not used (draw line movement)
	dd	P2_NoIO			 ;  66 -- not used (draw line movement)
	dd	P2_NoIO			 ;  67 -- not used (draw line movement)
	dd	P2_NoIO			 ;  68 -- not used
	dd	P2_NoIO			 ;  69 -- not used
	dd	P2_NoIO			 ;  6a -- not used
	dd	P2_NoIO			 ;  6b -- not used
	dd	P2_NoIO			 ;  6c -- not used
	dd	P2_NoIO			 ;  6d -- not used
	dd	P2_NoIO			 ;  6e -- not used
	dd	P2_NoIO			 ;  6f -- not used
	dd	P2_ResetRandom		 ;  70 -- random number generator reset
	dd	P2_ResetRandom		 ;  71 -- random number generator reset
	dd	P2_ResetRandom		 ;  72 -- random number generator reset
	dd	P2_ResetRandom		 ;  73 -- random number generator reset
	dd	P2_ResetRandom		 ;  74 -- random number generator reset
	dd	P2_ResetRandom		 ;  75 -- random number generator reset
	dd	P2_ResetRandom		 ;  76 -- random number generator reset
	dd	P2_ResetRandom		 ;  77 -- random number generator reset
	dd	P2_NoIO			 ;  78 -- not used
	dd	P2_NoIO			 ;  79 -- not used
	dd	P2_NoIO			 ;  7a -- not used
	dd	P2_NoIO			 ;  7b -- not used
	dd	P2_NoIO			 ;  7c -- not used
	dd	P2_NoIO			 ;  7d -- not used
	dd	P2_NoIO			 ;  7e -- not used
	dd	P2_NoIO			 ;  7f -- not used

[section .code]

;*
;* Pitfall 2 initialization
;*

Init_P2:				 ;  <-- from init.asm

	clear_mem  P2_Start,  P2_End

 	mov	dword [P2_sreg],1 ; random # generator (must be non-zero)
	ret

global SetPitfallII;

SetPitfallII:				 ;  <-- from banks.asm
 	mov	dword [BSType],14
 	mov	dword [RomBank],01000h ; don't know if this is needed...
 	mov	byte [Pitfall2],1 ; tell RIOT to clock the music
	ret

;*
;* bankswitch entry points
;*

RBank8P2:
	test_hw_read
	cmp	esi,107fh
	jbe near R_P2
	SetBank_8  ;  F8 macro
	MapRomBank
	ret


WBank8P2:
	test_hw_write
	cmp	esi,107fh
	jbe near W_P2
	SetBank_8  ;  F8 macro
	ret

;*
;* read Pitfall 2 register
;*

R_P2:
	cmp	esi,1040h		 ;  read in range?
	jae near P2_NoIO			 ;    no
	and	esi,07fh
 	jmp	dword [P2_Vectors+esi*4]

;*
;* write Pitfall 2 register
;*

W_P2:
	cmp	esi,1040h		 ;  write in range?
	jb near P2_NoIO			 ; 	  no
	and	esi,07fh
 	jmp	dword [P2_Vectors+esi*4]

;*
;* Pitfall 2 register handlers
;*

;*
;* null register read/write
;*

P2_NoIO:
	mov	esi, P2_Null
	ret


;*
;* routine to tune the pitch of the music
;*
;* We use this to match the Pitfall II music clock to the TIA music clock.
;*
;* Due to the discrete nature of this stuff, since the two clocks are not 
;* integer multiples of one another, adjustments of the ratio can affect the
;* relative pitch of notes in a chord as well as the overall pitch.  So you 
;* need to make sure that the important chords sound *nice*.
;*

Tune_Music:
	push	eax
	push	ecx
	mov	al,dl
	xor	edx,edx
	mov	cl,129
	mul	cl
	mov	ecx,79
	div	ecx
	mov	edx,eax
	pop	ecx
	pop	eax

	ret

;*
;* write top register
;*

P2_WriteTop:
	and	esi,7
 	mov	dl,byte [WByte] ; pick up byte to write
 	mov	byte [P2_Top + esi],dl ; save in TOP
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Top + esi*4],edx

P2_WriteDone:
	ret

;*
;* write bottom register
;*

P2_WriteBottom:
	and	esi,7
 	mov	dl,byte [WByte] ; pick up byte to write
 	mov	byte [P2_Bottom + esi],dl ; save in BOTTOM
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Bottom + esi*4],edx
	ret

;*
;* write counter low
;*

P2_WriteCounterLow:
	and	esi,7
 	mov	edx,dword [P2_Counters + esi*4]
 	mov	dl,byte [WByte] ; pick up byte to write in LOW counter byte
	and	edx,07ffh			 ;  mask to 11 bits
 	mov	dword [P2_Counters + esi*4],edx
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Count + esi*4],edx
	ret

;*
;* write counter high AND music enable
;*

P2_WriteCounterHigh:
	and	esi,7
 	mov	edx,dword [P2_Counters + esi*4]
 	mov	dh,byte [WByte] ; pick up byte to write in HI counter byte
 	mov	byte [P2_Enable + esi],dh ; save whole thing in enable
	and	edx,07ffh			 ;  mask to 11 bits
 	mov	dword [P2_Counters + esi*4],edx
 	mov	byte [P2_Flags + esi],0 ; this also clears the FLAG
	ret

;*
;* reset the random number generator
;*

P2_ResetRandom:
 	mov	dword [P2_sreg],1
	ret

;*
;* read flags
;*

P2_ReadFlags:
	and	esi,7
	add	esi, P2_Flags
	ret

;*
;* macro to read data via data fetcher
;*

Read_DF:
	and	esi,7
	push	ebx
 	mov	edx,dword [P2_Counters + esi*4] ; use old counter value for flag test
 	dec	dword [P2_Counters + esi*4] ; decrement for current fetch
 	cmp	dl,byte [P2_Top + esi] ; equal to top value?
	je near P2_FlagOne			 ;    yes, set flag
 	cmp	dl,byte [P2_Bottom + esi] ; equal to bottom value?
	je near P2_FlagZero			 ;    yes, clear flag
	jmp	P2_Cont

P2_FlagOne:
 	mov	byte [P2_Flags + esi],0ffh ; set flag
	jmp	P2_Cont

P2_FlagZero:
 	mov	byte [P2_Flags + esi],0 ; clear flag

P2_Cont:
 	mov	ebx,dword [P2_Counters + esi*4] ; get current counter
	neg	ebx				 ;  fetch data

 	mov	dl,byte [CartRom + 027feh + ebx] ; yes it *is* magic

 	mov	byte [P2_Rbyte],dl ; save data
	pop	ebx
	ret



;*
;* read data via data fetcher
;*

P2_Read_DF:
	call	Read_DF
	mov	esi, P2_Rbyte		 ;  pointer for CPU
	ret

;*
;* read data via data fetcher ANDed with flag
;*

P2_Read_DF_Flag:
	call	Read_DF
 	mov	dl,byte [P2_Flags + esi] ; pick up flag
 	and	byte [P2_Rbyte],dl ; AND data
	mov	esi, P2_Rbyte		 ;  restore pointer for CPU
	ret

;*
;* Generate a sequence of pseudo-random numbers 255 numbers long
;* by emulating an 8-bit shift register with feedback taps at
;* positions 4, 5, 6, and 8.
;*

P2_Read_Random:
	push	eax

 	mov	eax,dword [P2_sreg]
	and	eax,1				 ;  isolate bit 8
 	mov	edx,dword [P2_sreg]
	and	edx,4
	shr	edx,2
	xor	eax,edx				 ;  xor with bit 6
 	mov	edx,dword [P2_sreg]
	and	edx,8
	shr	edx,3
	xor	eax,edx				 ;  xor with bit 5
 	mov	edx,dword [P2_sreg]
	and	edx,16
	shr	edx,4
	xor	eax,edx				 ;  xor with bit 4
	shl	eax,7				 ;  this is the new bit 1
 	shr	dword [P2_sreg],1 ; shift the register
 	or	dword [P2_sreg],eax ; or in the feedback

 	mov	edx,dword [P2_sreg]
 	mov	byte [P2_Rbyte],dl
	mov	esi, P2_Rbyte

	pop	eax
	ret	



;*
;* read sound stuff
;*

;*
;* read sound entry point
;*
;* This is just for show -- Pitfall 2 short-circuits AUDV.
;*

P2_Read_Sound:
	mov	esi, P2_AUDV
	ret


;*
;* clock a music channel
;*

%macro Clock_Channel 1
; local ; MusicZero, ChannelDone

 	test	byte [P2_Enable + %1],010h ; channel enabled?
	jz near %%ChannelDone  ;  no
 	mov	edx,dword [P2_Music_Count + %1*4] ; use old counter value for flag test
 	dec	dword [P2_Music_Count + %1*4] ; decrement for current fetch
 	cmp	edx,dword [P2_Music_Bottom + %1*4] ; equal to bottom value?
	je near %%MusicZero  ;  yes, clear flag
	cmp	edx,-1  ;  time to reset?
	jnz near %%ChannelDone  ;  no
 	mov	edx,dword [P2_Music_Top + %1*4] ; yes, reset counter
 	mov	dword [P2_Music_Count + %1*4],edx
 	mov	byte [P2_Flags + %1],0ffh ; set flag
	jmp	%%ChannelDone

%%MusicZero:
 	mov	byte [P2_Flags + %1],0 ; clear flag

%%ChannelDone:
%endmacro



;*
;* clock music -- clock all channels
;*

Clock_Music:
	Clock_Channel  5
	Clock_Channel  6
	Clock_Channel  7

	ret


;*
;* build AUDV byte
;*

[section .data]

;*
;* sound mixing table
;* convert 3 sound channel bits into an AUDV value
;*

Mix_AUDV db 0, 6, 5, 0bh, 4, 0ah, 9, 0fh

[section .code]

;*
;* clock Pitfall 2 from TIA sound
;*


Clock_Pitfall2:
	push	ebx
	push	edx

	call	Clock_Music		 ;  clock P2

 	mov	bl,byte [P2_Flags + 5] ; Build AUDV
 	mov	dl,byte [P2_Flags + 6]
 	mov	dh,byte [P2_Flags + 7]
	and	ebx,1
	and	dl,2
	and	dh,4
	or	bl,dl
	or	bl,dh
 	mov	dl,byte [Mix_AUDV + ebx]
 	mov	byte [P2_AUDV],dl

ClockP2NoClock:
	pop	edx
	pop	ebx
	ret




;
; $Log: pitfall2.asm,v $
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
; Revision 1.3  2004/05/08 22:09:38  tazenda
; test CVS commit
;
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
