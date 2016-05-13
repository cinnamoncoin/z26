;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-03-02 -- 32-bit

;*
;* Hardware I/O address bits
;*
;* Dan Boris' 2600 schematics show the TIA and RIOT chips hooked up to the
;* CPU with the following address lines hooked up.
;*
;*   12 | 11  10  09  08 | 07  06  05  04 | 03	02  01	00 
;* 
;*    X			    X					TIA
;*    X		   X		  X					    RIOT
;*
;* If the 1000h bit (bit 12) is set, it's a ROM access.	 This is handled
;* in banks.asm and we'll never come here.
;*
;* Otherwise it's a hardware access.
;*
;* If the 200h bit is		set and the 80h bit is	   set then it's a RIOT access.
;* If the 200h bit is not set and the 80h bit is     set then it's a RAM access.
;* If the 200h bit is not set and the 80h bit is not set then it's a TIA access.
;*

[section .data]
%ifdef C_INITCPUH

extern TIACollide
extern RT_Reg
extern RetWd

extern Init_CPUhand

%else
CH_Start:  ; byte			; <-- start clearing here

TIACollide	dd  0	 ;  Collision flag word.

RT_Reg		dd  0	 ;  TIA reg to read (ReadCollision)
RetWd		db  0	 ;  byte returned from hardware read

;*** keep these in order ***

; variables moved to C code

;_DumpPorts	times 4 db 0	; Input ports (inp0..3)

;InputLatch	db  0	; Input latch (inp4)
;		db  0	; Input latch (inp5)
CH_End:  ; byte			; <-- finish clearing here
%endif

[section .code]

;*
;* Initialization
;*

%ifndef C_INITCPUH
Init_CPUhand:
	clear_mem  CH_Start,  CH_End
 	mov	word [InputLatch],08080h
	ret
%endif

; *****************************************************************************
;  Memory Mapping - Read - 
;  For non-rom areas, esi contains the requested address. 
;  On exit ds:[esi] points to the actual required data.
; *****************************************************************************

ReadHardware:
	test	esi,0200h		 ;  possible RIOT read?
	jnz near ReadRiotMaybe		 ;    yes

ReadHardwarePage0:
	test	esi,080h		 ;  RAM Read?
	jz near ReadTIA			 ;    no
	and	esi,0ffh
	add	esi, RiotRam-128
	ret

ReadRiotMaybe:
	test	esi,080h
	jnz near ReadRIOT

ReadTIA:
	push	eax
 	mov	al,byte [BusState] ; set undefined bits depending
					 ;    on the state of the data bus
	and	eax,03fh		 ;  topmost two bits are always defined

ReadTIAZero:
	and	esi,0fh
 	mov	byte [RetWd],al ; results get OR'd into this
	pop	eax
	cmp	esi,08h			 ;  reading collision registers ???
	jb near ReadCollision
	cmp	esi,0Eh
	jb near ReadInputLatches

	mov	esi, RetWd	 ;  return noisy word
	ret

;*
;* read collision routine
;*

ReadCollision:				 ;  read the collision latch
 	mov	dword [RT_Reg],esi
	SaveCPUState
	mov	dl,0
	call	CatchUpPixels		 ;  render pixels up to the write clock

	push	ecx
 	mov	eax,dword [TIACollide]
 	mov	ecx,dword [RT_Reg] ; ecx = address
	shl	ecx,1			 ;  shift it right 2 x address
	shr	eax,cl			 ;  and do it....
	and	eax,3			 ;  eax is now the 7,6 collide bits
	shl	al,6			 ;  put them back in bits 7 and 6
 	or	byte [RetWd],al ; save word for returning
	pop	ecx

	RestoreCPUState

	mov	esi, RetWd
	ret


ReadInputLatches:			 ;  read the input latch
	cmp	esi,0ch
	jb near ReadDumped
	pushad
 	mov	eax,dword [ScanLine] ; push parameters for C function
	push	eax
 	movzx	eax,byte [RClock]
	push	eax
	call	TestLightgunHit		 ;  void TestLightgunHit(dd RClock, dd ScanLine)
					 ;  updates [InputLatch+x] on Lightgun hit
	pop	eax
	pop	eax			 ;  clean up stack after function call
	popad

	and	esi,1
	add	esi, InputLatch
	push	eax
 	mov	al,byte [esi]
 	or	byte [RetWd],al
	pop	eax
	mov	esi, RetWd
	ret
	
ReadDumped:
	and	esi,3
         mov     edx,dword [ChargeTrigger0 + esi*4]
 	cmp	edx,dword [ChargeCounter] ; this trigger expired ?
	jbe near TriggerExpired			 ; 	  yes
RetZero: or	byte [RetWd],0
	mov	esi, RetWd
	ret

TriggerExpired:
 	or	byte [RetWd],080h
	mov	esi, RetWd
	ret
	

; *****************************************************************************
;   Memory mapping - Write. 
;   On Entry , si contains the address and [WByte] the data.
; *****************************************************************************


WriteHardware:
	test	esi,0200h		 ;  possible RIOT write?
	jnz near WriteRiotMaybe		 ; 	 yes

WriteHardwarePage0:
	test	esi,080h		 ;  RAM write?
	jz near NewTIA			 ; 	 no
	and	esi,0ffh
 	mov	dl,byte [WByte] ; writing to RAM
 	mov	byte [RiotRam-128 + esi],dl
	ret

WriteRiotMaybe:
	test	esi,080h
	jnz near WriteRIOT
	jmp	NewTIA



;
; $Log: cpuhand.asm,v $
; Revision 1.3  2004/05/18 02:17:16  urchlay
;
; Great Variable Migration from asm to C, partly complete.
;
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
