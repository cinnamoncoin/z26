/*
	20040416 bkw: This is my imcomplete attempt at porting the
	TIA sound code. Don't try to compile this, it won't.
	*/
/*
; tiasnd.asm -- z26 sound generation routines
;               based on TIASound (c) 1996-1997 by Ron Fries
;		please see the end of this file for Ron's banner

; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 04-08-98 -- first release
; 04-19-99 -- added sound queue
; 07-27-02 -- 32-bit
; 12-08-03 -- polynomials adapted to Adam Wozniak's description

[section .data]

sreg	dd	1		 ;  initialize shift register to non-zero val
*/

extern db Pitfall2;
extern db WByte;

/* CONSTANT DEFINITIONS */

/* definitions for AUDCx (15, 16) */
#define SET_TO_1     0x00      /* 0000 */
#define POLY4        0x01      /* 0001 */
#define DIV31_POLY4  0x02      /* 0010 */
#define POLY5_POLY4  0x03      /* 0011 */
#define PURE         0x04      /* 0100 */
#define PURE2        0x05      /* 0101 */
#define DIV31_PURE   0x06      /* 0110 */
#define POLY5_2      0x07      /* 0111 */
#define POLY9        0x08      /* 1000 */
#define POLY5        0x09      /* 1001 */
#define DIV31_POLY5  0x0a      /* 1010 */
#define POLY5_POLY5  0x0b      /* 1011 */
#define DIV3_PURE    0x0c      /* 1100 */
#define DIV3_PURE2   0x0d      /* 1101 */
#define DIV93_PURE   0x0e      /* 1110 */
#define DIV3_POLY5   0x0f      /* 1111 */
                 
#define DIV3_MASK    0x0c                 
                 
#define AUDC0        0x15
#define AUDC1        0x16
#define AUDF0        0x17
#define AUDF1        0x18
#define AUDV0        0x19
#define AUDV1        0x1a

/* the size (in entries) of the 4 polynomial tables */
#define POLY4_SIZE  0x000f
#define POLY5_SIZE  0x001f
#define POLY9_SIZE  0x01ff

/* channel definitions */
#define CHAN1       0
#define CHAN2       1

#define FALSE       0
#define TRUE        1

dd sreg = 1;

/*
; Initialze the bit patterns for the polynomials.

; The 4bit and 5bit patterns are the identical ones used in the tia chip.
; Though the patterns could be packed with 8 bits per byte, using only a
; single bit per byte keeps the math simple, which is important for
; efficient processing.

;Bit4    db      1,1,0,1,1,1,0,0,0,0,1,0,1,0,0
;Bit5    db      0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0,0,0,1
Bit4    db      0,1,1,0,0,1,0,1,0,0,0,0,1,1,1
Bit5    db      0,0,0,0,0,1,1,1,0,0,1,0,0,0,1,0,1,0,1,1,1,1,0,1,1,0,1,0,0,1,1
*/

db Bit4[] = { 0,1,1,0,0,1,0,1,0,0,0,0,1,1,1 };
db Bit5[] = { 0,0,0,0,0,1,1,1,0,0,1,0,0,0,1,0,1,0,1,1,1,1,0,1,1,0,1,0,0,1,1 };

/*
; 1 = toggle output in 5 bit poly - used when poly5 clocks other outputs
Bit5T   db      1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0
*/

db Bit5T[] = { 1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0 };

/*
; The 'Div by 31' counter is treated as another polynomial because of
; the way it operates.  It does not have a 50% duty cycle, but instead
; has a 13:18 ratio (of course, 13+18 = 31).  This could also be
; implemented by using counters.

Div31   db      0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0

Div6    db      0,1,0,0,1,0
*/

db Div31[] = { 0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0 };

db Div6[] = { 0,1,0,0,1,0 };

/*
; The sample output is treated as another divide by N counter.
; For better accuracy, the Samp_n_cnt has a fixed binary decimal point
; which has 8 binary digits to the right of the decimal point.

Samp_n_cnt	dd	0
Samp_n_max	dd	0
*/

dd Samp_n_cnt = 0;
dd Samp_n_max = 0;

/*
TS_Start:  ; byte			; <-- start clearing here

D6              db      0,0
P4              db      0,0
P5		db	0,0
AUDC		db	0,0
AUDF		db	0,0
AUDV		db	0,0
Outvol		db	0,0
Div_n_cnt 	db	0,0
Div_n_max 	db	0,0
TS_End:  ; byte			; <-- finish clearing here
*/

db D6[] = { 0, 0 };
db P4[] = { 0, 0 };
db P5[] = { 0, 0 };
db AUDC[] = { 0, 0 };
db AUDF[] = { 0, 0 };
db AUDV[] = { 0, 0 };
db Outvol[] = { 0, 0 };
db Div_n_cnt[] = { 0, 0 };
db Div_n_max[] = { 0, 0 };

/*
P9_sreg		dd	1,1


new_val		dd	0

prev_sample	dd	0
next_sample	db	0
*/

dd P9_sreg[] = { 1, 1 };
dd prev_sample = 0;
db next_sample = 0;


/*
AUDC_Jumptab:  ; dword	; HEX  D3 D2 D1 D0    Clock Source    Clock Modifier    Source Pattern
				 ;  --- -------------  --------------  ----------------  ----------------
	dd	TSB_Ch0done	 ;   0    0  0  0  0    3.58 MHz/114 ->  none  (pure)  ->      none
	dd	TSB_Poly4	 ;   1    0  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   4-bit poly
	dd	TSB_Div31_Poly4	 ;   2    0  0  1  0    3.58 MHz/114 ->  divide by 31  ->   4-bit poly
	dd	TSB_Poly5_Poly4	 ;   3    0  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   4-bit poly
	dd	TSB_Pure	 ;   4    0  1  0  0    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Pure	 ;   5    0  1  0  1    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Div31_Pure	 ;   6    0  1  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
;        dd      TSB_Poly5_Pure  ;  7    0  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   pure  (~Q)
        dd      TSB_Poly5        ;   7    0  1  1  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
	dd	TSB_Poly9	 ;   8    1  0  0  0    3.58 MHz/114 ->  none  (pure)  ->   9-bit poly
	dd	TSB_Poly5	 ;   9    1  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
;        dd      TSB_Div31_Poly5 ;  A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   5-bit poly
        dd      TSB_Div31_Pure   ;   A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
	dd	TSB_Poly5_Poly5	 ;   B    1  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   5-bit poly
        dd      TSB_Div6_Pure    ;   C    1  1  0  0    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div6_Pure    ;   D    1  1  0  1    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div31_Div6   ;   E    1  1  1  0    3.58 MHz/114 ->  divide by 31  ->   divide by 6
        dd      TSB_Poly5_Div6   ;   F    1  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   divide by 6
		  */

/* Ain't C declarations fun? */
/* That's `array of pointers to functions which take no args and return void',
	in case you can't read it (I can't, and I *wrote* it!)
*/
/*
void (*AUDC_Jumptab[])() = {
	TSB_Ch0done,
	TSB_Poly4,
	TSB_Div31_Poly4,
	TSB_Poly5_Poly4,
	TSB_Pure,
	TSB_Pure,
	TSB_Div31_Pure,
	TSB_Poly5,
	TSB_Poly9,
	TSB_Poly5,
	TSB_Div31_Pure,
	TSB_Poly5_Poly5,
	TSB_Div6_Pure,
	TSB_Div6_Pure,
	TSB_Div31_Div6,
	TSB_Poly5_Div6
};
*/

/*

[section .code]
;*
;* handle the power-up initialization functions
;* these functions should only be executed on a cold-restart
;*

Init_Tiasnd:

; calculate the sample 'divide by N' value based on the playback freq

	mov	eax,31400
	shl	eax,8
	mov	ebx,31400
	xor	edx,edx
	div	ebx			 ;  ax = (_sample_freq<<8)/_playback_freq
 	mov	dword [Samp_n_max],eax
 	mov	dword [Samp_n_cnt],0

	clear_mem  TS_Start,  TS_End

 	mov	dword [P9_sreg],1
 	mov	dword [P9_sreg+4],1

	ret	
	*/

void Init_Tiasnd() {
	int chan;
	
	Samp_n_max = (31400 << 8) / 31400;
	Samp_n_cnt = 0;

	for (chan = CHAN1; chan <= CHAN2; chan++)
	{
		Outvol[chan]		=		0;
		Div_n_cnt[chan]	=		0;
		Div_n_max[chan]	=		0;
		AUDC[chan]			=		0;
		AUDF[chan]			=		0;
		AUDV[chan]			=		0;
		P4[chan]				=		0;
		P5[chan]				=		0;
		//	P9[chan]				=		0;

		P9_sreg[chan]		=		1;
	}

}

/*


;*
;* routine to get kid-vid sound byte
;*

KidVid_Sound_Byte:

         test    byte [KidVid],0ffH
        jz near NoSamplePlay

	pushad
        call    kv_GetNextSampleByte
	popad
 	movzx	eax,byte [SampleByte]

NoSamplePlay:

	ret

	*/


db KidVid_Sound_Byte() {
	return 0;
	/*
	if(KidVid != 0xff)
		return kv_GetNextSampleByte();
	else
		return 0;
		*/
}

/*


;*
;* generate a sequence of pseudo-random bits 511 bits long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.
;*

ShiftRegister9:
 	mov	eax,dword [sreg]
	mov	edx,eax
	and	eax,1		 ;  bit 9 (register output & return val)
	and	edx,16
	shr	edx,4		 ;  position bit 5 at bottom
	xor	edx,eax		 ;  xor with bit 9 = new bit 1
 	shr	dword [sreg],1 ; shift the register
	shl	edx,8		 ;  position the feedback bit
 	or	dword [sreg],edx ; or it in
	ret	
	*/
db ShiftRegister9() {
	dd eax, ebx, edx;

	eax = sreg;
	edx = eax;

	eax &= 1;

	edx &= 16;
	edx >>= 4;
	edx ^= eax;

	sreg >>= 1;
	edx <<= 8;

	sreg |= edx;

	return eax;
}

/*

;*
;* update TIA sound registers
;*

H_AUDC0:
 	mov	al,byte [WByte]
	and	al,15
 	mov	byte [AUDC],al
	jmp	UTS_Chan0
	*/


void H_AUDC0() {
	AUDC[0] = WByte & 0x0f;
	UTS_Chan(0);
}

/*

H_AUDC1:
 	mov	al,byte [WByte]
	and	al,15
 	mov	byte [AUDC+1],al
	jmp	UTS_Chan1
	*/

void H_AUDC1() {
	AUDC[1] = WByte & 0x0f;
	UTS_Chan(1);
}

/*

H_AUDF0:
 	mov	al,byte [WByte]
	and	al,31
 	mov	byte [AUDF],al
	jmp	UTS_Chan0
	*/

void H_AUDF0() {
	AUDF[0] = WByte & 0x1f;
	UTS_Chan(0);
}

/*

H_AUDF1:
 	mov	al,byte [WByte]
	and	al,31
 	mov	byte [AUDF+1],al
	jmp	UTS_Chan1
	*/

void H_AUDF1() {
	AUDF[1] = WByte & 0x1f;
	UTS_Chan(1);
}

/*

H_AUDV0:
 	mov	al,byte [WByte]
	and	al,15
	shl	al,3
 	mov	byte [AUDV],al
	*/

void H_AUDV0() {
	AUDV[0] = (WByte & 0x1f) << 3;
	UTS_Chan(0);
}

/*

UTS_Chan0:
	xor	ebx,ebx
	jmp	UTS_RegSet

H_AUDV1:
 	mov	al,byte [WByte]
	and	al,15
	shl	al,3
 	mov	byte [AUDV+1],al

	*/

void H_AUDV1() {
	AUDV[1] = (WByte & 0x1f) << 3;
	UTS_Chan(1);
}

/*
UTS_Chan1:
	mov	ebx,1

; the output value has changed

*/

void UTS_Chan(int chan) {
	dd new_val;
	/*
	db AUDC = AUDC[chan];
	db AUDF = AUDF[chan];
	db AUDV = AUDV[chan];
	db Outvol = Outvol[chan];
	*/
	//	db al;

/*
UTS_RegSet:
 	cmp	byte [AUDC+ebx],0 ; AUDC value of zero is a special case
	jne near UTS_rs1
 	mov	dword [new_val],0 ; indicate clock is zero so ...
 	mov	al,byte [AUDV+ebx] ; ... no processing will occur
 	mov	byte [Outvol+ebx],al ; and set output to selected volume

	jmp	UTS_rs2
	*/

	if(AUDC[chan] == 0) {
		new_val = 0;
		Outvol[chan] = AUDV[chan];
	} else {
	
	/*

UTS_rs1:
 	movzx	eax,byte [AUDF+ebx] ; calc the 'div by N' value
	inc	eax
 	mov	dword [new_val],eax
	*/
		new_val = AUDF[chan]+1;
	}
		/*

UTS_rs2: movzx	eax,byte [Div_n_max+ebx] ; only reset channels that have changed
 	cmp	eax,dword [new_val]
	je near UTS_Done
	*/

	if( new_val != Div_n_max[chan] ) {

	/*
 	mov	al,byte [new_val]
 	mov	byte [Div_n_max+ebx],al ; reset 'div by N' counters
 	cmp	byte [Div_n_cnt+ebx],0
	je near UTS_rs3			 ;  if channel is now volume only ...
 	cmp	dword [new_val],0
	jne near UTS_Done		 ;  ... or was volume only ...

UTS_rs3: mov	al,byte [new_val]
 	mov	byte [Div_n_cnt+ebx],al ; ... reset the counter 
				 	 ;      (otherwise complete previous)
	 */

		Div_n_max[chan] = new_val & 0xff;
		if( Div_n_cnt[chan] == 0 || new_val == 0 )
			Div_n_cnt[chan] = new_val & 0xff;
		/*

UTS_Done:
	ret	
*/
	}
}

/*
	

;*
;* generate a sound byte based on the TIA chip parameters
;*

;;; converted macro:
%macro inc_mod 2
; local ; done

 	inc	byte [%1] ;;; GUESSED dword
 	cmp	byte [%1],%2 ;;; GUESSED dword
	jne near %%done
 	mov	byte [%1],0 ;;; GUESSED dword
%%done:
%endmacro



TIA_Sound_Byte:
*/

int TSB_result;

dd TIA_Sound_Byte() {
	TSB_result = -1;

	while(TSB_result==-1) {
		if(!Pitfall2) TSB_ProcessChannel(0);
		TSB_ProcessChannel(1);
		TSB_Ch0done(); /* sets TSB_result for us */
	}
	return TSB_result;
}

	/*

TSB_ProcessLoop:

	xor	edi,edi			 ;  process channel 0 first

 	cmp	byte [Pitfall2],0 ; doing Pitfall2?
	jz near TSB_ProcessChannel	 ;    no
	inc	edi			 ;    yes, only do channel 1

TSB_ProcessChannel:
 	cmp	byte [Div_n_cnt + edi],1 ; if div by N counter can count down ...
	jb near TSB_Ch0done		 ;    zero is special case, means AUDC==0 -- fast exit
	je near TSB_1
 	dec	byte [Div_n_cnt + edi] ; ... decrement ...
	jmp	TSB_Ch0done		 ;  ... and do next channel
	*/

void TSB_ProcessChannel(int chan) {
	if(Div_n_cnt[chan] < 1) return;
	if(Div_n_cnt[chan] > 1) {
		Div_n_cnt[chan]--;
	} else {
		/* reset the counter */
		Div_n_cnt[chan] = Div_n_max[chan];

		/* the P5 counter has multiple uses, so we inc it here */
		P5[chan]++;
		if (P5[chan] == POLY5_SIZE)
			P5[chan] = 0;

		/* check clock modifier for clock tick */

		/* if we're using pure tones OR
			we're using DIV31 and the DIV31 bit is set OR
			we're using POLY5 and the POLY5 bit is set */
		if  (((AUDC[chan] & 0x02) == 0) ||
				(((AUDC[chan] & 0x01) == 0) && Div31[P5[chan]]) ||
				(((AUDC[chan] & 0x01) == 1) &&  Bit5[P5[chan]]))
		{
			if (AUDC[chan] & 0x04)       /* pure modified clock selected */
			{
				if (Outvol[chan])         /* if the output was set */
					Outvol[chan] = 0;      /* turn it off */
				else
					Outvol[chan] = AUDV[chan];   /* else turn it on */
			}
			else if (AUDC[chan] & 0x08)  /* check for p5/p9 */
			{
				if (AUDC[chan] == POLY9)  /* check for poly9 */
				{
					/* inc the poly9 counter */
//					P9[chan]++;
//					if (P9[chan] == POLY9_SIZE)
//						P9[chan] = 0;
//
//					if (Bit9[P9[chan]])    /* if poly9 bit is set */
//						Outvol[chan] = AUDV[chan];
//					else
//						Outvol[chan] = 0;
				}
				else                      /* must be poly5 */
				{
					if (Bit5[P5[chan]])
						Outvol[chan] = AUDV[chan];
					else
						Outvol[chan] = 0;
				}
			}
			else  /* poly4 is the only remaining option */
			{
				/* inc the poly4 counter */
				P4[chan]++;
				if (P4[chan] == POLY4_SIZE)
					P4[chan] = 0;

				if (Bit4[P4[chan]])
					Outvol[chan] = AUDV[chan];
				else
					Outvol[chan] = 0;
			}
		}
	}

}

void TSB_Ch0done() {
	/* decrement the sample counter - value is 256 since the lower
		byte contains the fractional part */
	Samp_n_cnt -= 256;

	/* if the count down has reached zero */
	if (Samp_n_cnt < 256)
	{
		/* adjust the sample counter */
		Samp_n_cnt += Samp_n_max;

		/* calculate the latest output value and set our result */
		TSB_result = Outvol[0] + Outvol[1];
		/* TODO: Pitfall2, kidvid, silence during pause, DPS effects */
	}
}

	/*

TSB_1: mov	al,byte [Div_n_max + edi] ; otherwise reset the counter and process this channel
 	mov	byte [Div_n_cnt + edi],al

 	movzx	esi,byte [AUDC + edi] ; AUDC = index into branch table

	inc_mod  P5+edi,31 ;  P5 channel has multiple uses (Div31 & P5), inc it here
 	movzx	ebx,byte [P5 + edi]

 	jmp	dword [AUDC_Jumptab + esi*4] ; process sound changes based on AUDC


TSB_Div6_Pure:
        inc_mod  D6+edi,6 ;  inc Div6 counter
         movzx   ebx,byte [D6 + edi]
         cmp     byte [Div6+ebx],0 ; if div 6 bit set ...
	jnz near TSB_Pure		 ;  ... do pure
	jmp	TSB_Ch0done

TSB_Div31_Div6:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
        jnz near TSB_Div6_Pure            ;  ... do div 6
        jmp     TSB_Ch0done

TSB_Div31_Pure:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
	jnz near TSB_Pure		 ;  ... do pure
	jmp	TSB_Ch0done

;TSB_Poly5_Pure:
;        cmp     [Bit5+ebx],0             ; if div 5 bit set ...
;        jz near TSB_Ch0done             ; ... do pure

TSB_Pure:
 	cmp	byte [Outvol + edi],0 ; toggle the output
	je near TSB_VolumeOn
	jmp	TSB_VolumeOff


TSB_Poly9:	
 	mov	edx,dword [P9_sreg+4*edi]
 	mov	dword [sreg],edx ; set shift reg to this channel's shift reg
	call	ShiftRegister9		 ;  calculate next bit
 	mov	edx,dword [sreg] ; save shift reg to our channel
 	mov	dword [P9_sreg+4*edi],edx
	test	al,1			 ;  shift reg bit on?
	je near TSB_VolumeOff		 ;    no
	jmp	TSB_VolumeOn		 ;    yes


;TSB_Div31_Poly5:
;        cmp     [Div31+ebx],0            ; if div 31 bit set ...
;        jnz near TSB_Poly5               ; ... do Poly5
;        jmp     TSB_Ch0done

TSB_Poly5_Div6:
         cmp     byte [Bit5T+ebx],0 ; if Bit5 output changed ...
        jnz near TSB_Div6_Pure            ;  ... do Div 6
	jmp	TSB_Ch0done

TSB_Poly5_Poly5:
 	cmp	byte [Bit5+ebx],0 ; if Poly5 bit set ...
	jz near TSB_Ch0done		 ;  ... do Poly5

TSB_Poly5:
 	movzx	ebx,byte [P5 + edi] ; set the output bit
 	cmp	byte [Bit5+ebx],0
	je near TSB_VolumeOff
	jmp	TSB_VolumeOn


TSB_Div31_Poly4:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
	jnz near TSB_Poly4		 ;  ... do Poly4
	jmp	TSB_Ch0done

TSB_Poly5_Poly4:                         ;  changed from Bit5 to Bit5T *EST*
         cmp     byte [Bit5T+ebx],0 ; if Poly5 bit set ...
	jz near TSB_Ch0done		 ;  ... do Poly4

TSB_Poly4:
	inc_mod  P4+edi,15 ;  inc P4 counter
 	movzx	ebx,byte [P4 + edi]

 	cmp	byte [Bit4+ebx],0 ; and set the output bit
	je near TSB_VolumeOff

TSB_VolumeOn:
 	mov	al,byte [AUDV + edi]
 	mov	byte [Outvol + edi],al
	jmp	TSB_Ch0done

TSB_VolumeOff:
 	mov	byte [Outvol + edi],0

TSB_Ch0done:
	inc	edi			 ;  to next channel
	cmp	edi,1			 ;  done ?
	jbe near TSB_ProcessChannel	 ;    not yet

 	sub	dword [Samp_n_cnt],256 ; decrement sample count
					 ;  (256 since lower byte is 
					 ;   fractional part)
 	cmp	dword [Samp_n_cnt],256 ; if count has reached zero ...
	jae near TSB_ProcessLoop
 	mov	eax,dword [Samp_n_max] ; ... adjust the sample counter
 	add	dword [Samp_n_cnt],eax

 	cmp	byte [Pitfall2],0 ; running Pitfall 2?
	jz near TSB_NotPitfall2		 ;    no

	call	Clock_Pitfall2		 ;    yes, clock P2 music clock (and build AUDV)
 	mov	al,byte [Outvol+1] ; channel 1
 	mov	ah,byte [P2_AUDV]
	and	ah,15
	shl	ah,3
	add	al,ah			 ;  add in Pitfall 2 AUDV byte
	jmp	TSB_Pitfall2_Done

TSB_NotPitfall2:
 	mov	al,byte [Outvol+0] ; not Pitfall 2, do normal mixing
 	add	al,byte [Outvol+1] ; sum the channels

TSB_Pitfall2_Done:
 	cmp	byte [GamePaused],0 ; if game paused
	jz near TSB_NoSilence
	mov	al,080h			 ;  fill buffer with silence
TSB_NoSilence:

 	test	byte [dsp],0ffh ; doing digital signal processing ?
	jz near TSB_ProcessDone		 ;    no, just store it
 	mov	byte [next_sample],al ; yes, take edge off square wave
	xor	eax,eax
 	mov	al,byte [next_sample]
 	add	eax,dword [prev_sample]
	shr	eax,1
 	mov	dword [prev_sample],eax ; dsp=2, scaled moving average

 	cmp	byte [dsp],1
	jne near TSB_ProcessDone
 	movzx	esi,byte [next_sample] ; dsp=1, simple moving average
 	mov	dword [prev_sample],esi

TSB_ProcessDone:
	and	eax,0ffh		 ;  return 32-bit sample
	ret	
	*/


/*
 * $Log: tiasnd.c,v $
 * Revision 1.6  2004/05/15 17:00:46  urchlay
 *
 * Initial incomplete implementation of TIA sound code in C. This isn't
 * done yet, but at least compiles, and you can play Pitfall with it (but
 * not Pitfall II).
 *
 * Revision 1.5  2004/05/15 15:36:13  urchlay
 *
 * The rest of the graphics can be disabled/enabled:
 *
 * Alt+key   Graphic
 * Z         P0
 * X         P1
 * C         M0
 * V         M1
 * B         Ball
 * N         Playfield (whole thing)
 * /         Turns all of the above ON
 *
 * Revision 1.4  2004/05/12 22:16:27  urchlay
 *
 * added -V option (version).
 *
 * Revision 1.3  2004/05/09 00:38:29  urchlay
 *
 * Ported a few more functions to C. Tia_process() is still acting weird.
 *
 * Moved the C core defines to conf/c_core.mak, so we only have one place
 * to modify them, no matter which target we're building for. Used
 * `sinclude' to include it, which won't give an error if the file is
 * missing entirely. It'll just not define any of the C core stuff.
 *
 * Revision 1.2  2004/05/08 18:06:58  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
