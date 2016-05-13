;*
;* z26 RIOT emu
;*
;* 07-19-02 -- 32-bit
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;*
;* I'm not really sure what mode the timer starts up in but it's not mode 1.
;* Otherwise blueprnt.bin doesn't come up and others as well.
;*

START_TIME equ 07fffh 			 ;  03ffffh

[section .data]

%ifndef C_RANDRIOT
Timer		dd	START_TIME	 ;  the RIOT Timer
					 ;  (gets initialized in INIT.ASM now)
%endif

TimerReadVec	dd	ReadTimer1024	 ;  timer read vector
TimerByte	db	0		 ;  a return value
TimerIntReg	db	0		 ;  Timer Interrupt Register

; *EST* variables
DDR_A		db	0
DDR_B		db	0
IOPortA_read	db	0		 ;  generate IOportA value on SWCHA read
					 ;    when it needs some adjusting for some
					 ;    controllers

ALIGN 2
ReadRIOTTab:  ; dword
	dd	ReadPortA		 ;  280h PA Data
	dd	ReadDDR_A		 ;  281h PA Direction
	dd	ReadPortB		 ;  282h PB Data
	dd	ReadDDR_B		 ;  283h PB Direction
	dd	ReadTimer		 ;  284h Read Timer
	dd	ReadTimerIntReg		 ;  285h Read Timer Interrupt Register
	dd	ReadTimer		 ;  286h Read Timer
	dd	ReadTimerIntReg		 ;  287h Read Timer Interrupt Register
WriteRIOTTab:  ; dword
	dd	SetRIOTTimer1		 ;  294h
	dd	SetRIOTTimer8		 ;  295h
	dd	SetRIOTTimer64		 ;  296h
	dd	SetRIOTTimer1024	 ;  297h

; *EST* table
WriteRIOTTab2:  ; dword
	dd	WritePortA		 ;  280h
	dd	WriteDDR_A		 ;  281h
	dd	WriteNothing		 ;  282h
	dd	WriteDDR_B		 ;  283h

[section .code]


Init_Riot:
 	mov	dword [Timer],START_TIME
 	mov	dword [TimerReadVec], ReadTimer1024
 	mov	byte [TimerByte],0
 	mov	byte [TimerIntReg],0

	ret

;*
;* CPU wants to read a RIOT register
;*

ReadRIOT:
	and	esi,07h
 	jmp	dword [ReadRIOTTab + esi*4]

ReadDDR_A:				 ;  read data direction register A
	mov	esi, DDR_A
	ret

ReadDDR_B:				 ;  read data direction register B
	mov	esi, DDR_B
	ret

ReadPortB:				 ;  read console switches (port b)
	mov	esi, IOPortB
	ret

ReadPortA:				 ;  read hand controllers (port a)
	pushad
 	mov	eax,dword [ScanLine]
	push	eax
	call	UpdateTrakBall
	pop	eax
	popad
	push	eax
 	mov	al,byte [IOPortA_Controllers] ; pins grounded by controller ...
 	or	al,byte [IOPortA_UnusedBits] ; read 0 even on pins where HIGH ...
 	and	al,byte [IOPortA] ; was written to (see Star Raiders)
 	mov	byte [IOPortA_read],al
	pop	eax
	mov	esi, IOPortA_read
	ret

;*
;* CPU wants to write to a RIOT register
;* On entry, si contains the address and [WByte] contains the value
;*

WriteRIOT:
	test	esi,010h
	jnz near WR_EST2
	test	esi,04h
	jnz near WriteNothing

	and	esi,03h
 	jmp	dword [WriteRIOTTab2 + esi*4]
WR_EST2:
	test	esi,04h
	jz near WriteNothing

	and	esi,03h
 	jmp	dword [WriteRIOTTab + esi*4]
	

WriteNothing:
	ret


WritePortA:
	push	eax
 	mov	al,byte [WByte]
 	and	al,byte [DDR_A] ; make sure that only output bits
 	mov	ah,byte [DDR_A] ; get written to SWCHA *EST*
	xor	ah,0FFh			
 	and	ah,byte [IOPortA]		
	or	al,ah			

 	mov	byte [IOPortA],al

	pop	eax
	pushad
	call	ControlSWCHAWrite	 ;  update controllers on SWCHA write
					 ;  Keypad, Compumate, Mindlink
	popad
	ret
	

WriteDDR_A:
	push	eax
 	mov	al,byte [WByte]
 	mov	byte [DDR_A],al
	pop	eax
	ret

WriteDDR_B:
	push	eax
 	mov	al,byte [WByte]
 	mov	byte [DDR_B],al
	pop	eax
	ret

;*
;* CPU wants to set the timer by writing to one of the RIOT timer regs:
;*
;* 	$294 (TIM1T)
;* 	$295 (TIM8T)
;* 	$296 (TIM64T)
;* 	$297 (TIM1024T)
;*
;* On entry, si contains the address and [WByte] contains the value
;*

%macro set_timer 2

SetRIOTTimer%2:
 	mov	byte [RCycles],0 ; don't clock this instruction
 	movzx	edx,byte [WByte]

	shl	edx,%1
 	mov	dword [Timer],edx
 	mov	dword [TimerReadVec], ReadTimer%2
	ret

%endmacro


	set_timer  0,1
	set_timer  3,8
	set_timer  6,64
	set_timer  10,1024


;*
;* CPU wants to read the RIOT timer
;*
;* return with si pointing to value to read from $284 (INTIM)
;*

%macro read_timer 2

ReadTimer%2:
	shr	edx,%1
 	mov	byte [TimerByte],dl
	mov	esi, TimerByte

	ret

%endmacro


	read_timer  0,1
	read_timer  3,8
	read_timer  6,64
	read_timer  10,1024

ReadTimer:
 	movzx	edx,byte [RCycles] ; clock this instruction
 	sub	dword [Timer],edx
 	mov	byte [RCycles],0 ; prevent double clock

 	mov	edx,dword [Timer]
	test	edx,040000h		 ;  has the timer overflowed yet ?
	jnz near ReadOverflowed		 ; 	 yes
 	mov	esi,dword [TimerReadVec] ; no, do appropriate read
	jmp	esi			 ;  jmp [TimerReadVec] doesn't work in 16-bit segment 

ReadOverflowed:
 	mov	byte [TimerByte],dl ; return this value
	mov	esi, TimerByte
	ret

;*
;* CPU wants to read the RIOT Timer Interrupt Register
;*
;* return with si pointing to value to read from $285
;*

ReadTimerIntReg:
 	mov	edx,dword [Timer]
	shr	edx,24
	and	dl,080h			 ;  position the very top bit
 	mov	byte [TimerIntReg],dl ; return this value

;*
;* I don't exactly know how many bits to leave in the Timer counter
;* because I don't exactly know how long it is to the next interrupt.
;* But another interrupt *does* come.  (Otherwise lockchse.bin fails.)
;*

 	and	dword [Timer],START_TIME ; clear interrupt flag
	mov	esi, TimerIntReg
	ret

;*
;* macro to clock the RIOT timer (after every instruction)
;*

%macro ClockRIOT 0
; local ; NoPF2

 	movzx	edx,byte [RCycles] ; # of cycles for this instruction
 	sub	dword [Timer],edx ; subtract from timer

%endmacro


;*
;* randomize RIOT timer
;*

%ifndef C_RANDRIOT
RandomizeRIOTTimer:
 	mov	eax,dword [Seconds] ; gets set in GLOBALS.C
	and	eax,0ffh
	shl	eax,10
 	mov	dword [Timer],eax ; see RIOT.ASM for details
	ret
%endif





;
; $Log: riot.asm,v $
; Revision 1.3  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
