;*
;* 6507 CPU emulator for z26
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 06-27-98 -- new design
; 07-17-98 -- simplify
; 06-26-99 -- cycle perfect
; 08-04-02 -- 32-bit

; CPU doesn't use ecx, ebp, edi -- trashes eax, ebx, edx, esi

[section .data]
ALIGN 2
wreg_pc:  ; word			; a word sized alias to pc (for inc [wreg_pc])
reg_pc		dd	0		 ;  program counter
dwreg_sp:  ; dword			; a dword sized alias to the stack pointer
reg_sp		db	0,1,0,0		 ;  stack pointer

; the following locations must be in this order and next to each other

reg_a		db	0		 ;  accumulator (stored in AL)
flag_carry	db	0		 ;  carry bit   (stored in AH)
		db	0		 ;  pad to dword
		db	0

; the following two locations are padded with an extra byte 
; to allow 16-bit access (see _index)

reg_x		db	0		 ;  x register
		db	0		 ;  pad to dword
		db	0
		db	0
reg_y		db	0		 ;  y register
		db	0		 ;  pad to dword
		db	0
		db	0

; a value is stored in the following vars for later testing

RZTest		db	0		 ;  zero test value (Z set when 0)
RNTest		db	0		 ;  sign test value (N set when negative)

; these vars hold the values of flags other than Z and N

flag_D		db	0		 ;  decimal flag
flag_V		db	0		 ;  overflow flag
flag_I		db	0		 ;  interrupt disable flag
flag_B		db	0		 ;  break flag

; clock variables

RCycles		db	0		 ;  cycles per instruction
RClock		db	0		 ;  clock cycles

; some temporaries for use by decimal arith and ARR

_value		db	0
_reg_a		db	0
_flag_carry	db	0

; state of the data bus -- used in cpuhand.asm

BusState        db      0

[section .code]

Init_CPU:
 	mov	dword [reg_pc],0
 	mov	byte [reg_a],0
 	mov	byte [flag_carry],0
 	mov	word byte [reg_x],0
 	mov	word byte [reg_y],0
 	mov	byte [reg_sp],0
 	mov	byte [RZTest],0
 	mov	byte [RNTest],0
 	mov	byte [flag_D],0
 	mov	byte [flag_V],0
 	mov	byte [flag_I],0
 	mov	byte [flag_B],0
 	mov	byte [RCycles],0
	ret

;*
;* state saving macros
;*

%macro SaveCPUState 0
	push	eax
	push	ebx
	push	edx
	push	esi
%endmacro


%macro RestoreCPUState 0
	pop	esi
	pop	edx
	pop	ebx
	pop	eax
%endmacro



;*
;* timing macro
;*

%macro bumpclock 0
 	inc	byte [RClock]
 	inc	byte [RCycles]
%endmacro


;*
;* memory accessing macros -- everything should go through here
;*

%macro read_bank 0
	push	eax
	bumpclock
 	mov	eax, dword [BSType]

 	call	dword [RBankTab + eax*4] ; trashes eax

         mov     al,byte [esi]
         mov     byte [BusState],al ; remember last data on the bus
        pop     eax
%endmacro


%macro write_bank 0
	push	eax
	bumpclock
 	mov	eax, dword [BSType]

 	call	dword [WBankTab + eax*4] ; trashes eax

         mov     al,byte [WByte]
         mov     byte [BusState],al ; remember last data on the bus
        pop     eax
%endmacro


;*
;* memory accessing macros -- get/put data via op2
;*

%macro read 2 ; read memory
	mov	esi,%2
	read_bank
 	mov	%1,byte dword [esi]
%endmacro

      
%macro readsx 2 ; sign extended
	mov	esi,%2
	read_bank
 	movsx	%1,byte byte [esi]
%endmacro


%macro readzx 2 ; zero extended
	mov	esi,%2
	read_bank
 	movzx	%1,byte byte [esi]
%endmacro


%macro slack_read 1 ; read and throw away result
	mov	esi,%1
	read_bank
%endmacro


%macro write 2 ; write memory
	mov	esi,%2
 	mov	byte [WByte],%1
	write_bank
%endmacro


%macro slack_write 2 ; write memory
	mov	esi,%2
 	mov	byte [WByte],%1
	write_bank
%endmacro


;*
;* opcode (and immediate data) fetching macros
;*

%macro fetch 1
 	read  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


%macro fetchsx 1
 	readsx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


%macro fetchzx 1
 	readzx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


%macro fetch_opcode 1 ; special fetchzx for trace logging
; local ; fo_1


%ifdef TRACE
 	test	byte [TraceCount],1
	jz near %%fo_1

	call	TraceInstruction

%%fo_1:	
%endif
 	mov	byte [RCycles],0
 	readzx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


%macro slack_fetch 0 ; read and throw away, don't inc PC
 	slack_read  dword [reg_pc]
%endmacro


;*
;* 6507 stack macros
;*

%macro zpush 1
 	write  %1,dword [dwreg_sp] ;;; GUESSED dword ; write byte to top of stack
 	dec	byte [reg_sp] ; and decrement stack pointer
%endmacro


%macro zpop 1
 	inc	byte [reg_sp] ; increment the	stack pointer
 	read  %1,dword [dwreg_sp] ;;; GUESSED dword ; and read the top byte
%endmacro


%macro slack_pop 0 ; read stack and throw away, don't inc SP
 	slack_read  dword [dwreg_sp] ;;; GUESSED dword
%endmacro


;*
;* memory addressing helper macros
;*

%macro absolute 0
	fetch  bl
	fetch  bh
%endmacro


%macro zeropage 0
	fetchzx  ebx
%endmacro


%macro readaddress 0 ; read data in bx -> bx
	and	ebx,0ffh  ;  must be in page zero
	read  dl,ebx
	inc	bl
	read  dh,ebx
	mov	ebx,edx
%endmacro


;*
;* memory addressing macros
;*

%macro abs_read 0 ; Absolute addressing
	absolute
%endmacro


%macro abs_rmw 0
	absolute
%endmacro


%macro abs_write 0
	absolute
%endmacro



%macro zero_read 0 ; Zero page addressing
	zeropage
%endmacro


%macro zero_rmw 0
	zeropage
%endmacro


%macro zero_write 0
	zeropage
%endmacro



%macro zero_x_read 0 ; Zero page indexed addressing
	zeropage
	slack_read  ebx
 	add	bl,byte [reg_x]
%endmacro


%macro zero_x_rmw 0
	zero_x_read
%endmacro


%macro zero_x_write 0
	zero_x_read
%endmacro


%macro zero_y_read 0
	zeropage
	slack_read  ebx
 	add	bl,byte [reg_y]
%endmacro


%macro zero_y_write 0
	zero_y_read
%endmacro



%macro abs_x_read 0 ; Absolute indexed addressing
; local ; done

	absolute
 	add	bl,byte [reg_x]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro
	

%macro abs_x_rmw 0
	absolute
	slack_read  ebx
 	add	ebx, dword dword [reg_x]
%endmacro


%macro abs_x_write 0
	abs_x_rmw
%endmacro


%macro abs_y_read 0
; local ; done

	absolute
 	add	bl,byte [reg_y]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro


%macro abs_y_rmw 0
	absolute
	slack_read  ebx
 	add	ebx, dword dword [reg_y]
%endmacro


%macro abs_y_write 0
	abs_y_rmw
%endmacro



%macro ind_x_read 0 ; Indexed indirect addressing
	zeropage
	slack_read  ebx
 	add	ebx, dword dword [reg_x]
	readaddress
%endmacro


%macro ind_x_rmw 0
	ind_x_read
%endmacro


%macro ind_x_write 0
	ind_x_read
%endmacro



%macro ind_y_read 0 ; Indirect indexed addressing
; local ; done

	zeropage
	readaddress
 	add	bl,byte [reg_y]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro


%macro ind_y_rmw 0
	zeropage
	readaddress
	push	ebx
 	add	bl,byte [reg_y]
	slack_read  ebx
	pop	ebx
 	add	ebx, dword dword [reg_y]
%endmacro


%macro ind_y_write 0
	ind_y_rmw
%endmacro


;*
;* opcode definition macros
;*

%macro op_align 0
  ;  ALIGN 4
%endmacro


%macro op_register 3
op_align
%1:	slack_fetch
	mov	dl,%3
	_%2
	mov	%3,dl
	ret
%endmacro


%macro op_transfer 3
op_align
%1:	slack_fetch
	mov	dl,%3
	mov	%2,dl
	ret
%endmacro


%macro op_transfertest 3
op_align
%1:	slack_fetch
	mov	dl,%3
	mov	%2,dl
	usetest  dl
	ret
%endmacro


%macro op_immediate 2
op_align
%1:	fetch  dl
	_%2
	ret
%endmacro


%macro op_read 3
op_align
%1:	%3_read
	read  dl,ebx
	_%2
	ret
%endmacro


%macro op_rmw 3
op_align
%1:	%3_rmw
	read  dl,ebx
	slack_write  dl,ebx
	_%2
	write  dl,ebx
	ret
%endmacro


%macro op_write 3
op_align
%1:	%3_write
	_%2
	write  dl,ebx
	ret
%endmacro


%macro op_branch 4
op_align
%1:	fetchsx  edx ;  sign-extended branch offset into dx
	test	%2,%3
	%4	DoBranch
	ret
%endmacro


%macro op_weird 2
op_align
%1:	_%2
	ret
%endmacro


;*
;* flag setting macros
;*

%macro useztest 1 ; use to test Z
 	mov	byte [RZTest],%1
%endmacro


%macro usentest 1 ; use to test N		 
 	mov	byte [RNTest],%1
%endmacro


%macro usetest 1 ; use to test both N and Z (normal)
	useztest  %1
	usentest  %1
%endmacro


;*
;* compare macros
;*

%macro CompDH 0 ; compare dh and dl
	sub	dh,dl
	usetest  dh
	setnc	ah
%endmacro


%macro _CMP 0 ; compare al and dl
	mov	dh,al
	CompDH
%endmacro


;*
;*  CPU macros
;*
;* (al=accumulator, ah=carry, dl=operand)
;*

%macro _ADC 0
	call	DoADC
%endmacro


DoADC: cmp	byte [flag_D],0
	jnz near ADCBCD
	shr	ah,1
	adc	al,dl
 	seto	 [flag_V]
	usetest  al
	setc	ah
	ret

ADCBCD:	push	ecx

 	mov	byte [_reg_a],al
 	mov	byte [_value],dl

	add	al,dl			 ;  set some flags using binary addition
 	seto	 [flag_V]
	add	al,ah			 ;  add carry
 	mov	byte [RZTest],al

 	mov	al,byte [_reg_a] ; now do decimal addition
	and	al,0fh
	and	dl,0fh			 ;  dl has _value
	add	al,dl			 ;  add bottom nybbles
	add	al,ah			 ;  add carry
	cmp	al,9			 ;  fixup bottom nybble
	jbe near ADCD_1
	add	al,6
ADCD_1:	mov	cl,al			 ;  save result with half carry
	and	eax,0fh
 	mov	dl,byte [_reg_a]
	and	edx,0f0h
	add	eax,edx			 ;  combine with top nybble of _reg_a
 	mov	dl,byte [_value]
	and	edx,0f0h
	add	edx,eax			 ;  add top nybble of _value
	cmp	cl,0fh			 ;  did lower nybble fixup overflow ?
	jbe near ADCD_3
	add	edx,010h		 ;    yes
ADCD_3: mov	byte [RNTest],dl ; set a flag
	mov	eax,edx			 ;  fixup top nybble
	and	edx,01f0h
	cmp	edx,090h
	jbe near ADCD_6
	add	eax,060h
ADCD_6:	test	ah,ah
	setnz	ah			 ;  set carry
 	mov	dl,byte [_value] ; ADC must preserve dl for RRA

	pop	ecx
	ret	

%macro _ANC 0
	and	al,dl
	usetest  al
	test	al,080h
	setnz	ah
%endmacro


%macro _AND 0
	and	al,dl
	usetest  al
%endmacro


%macro _ANE 0
	or	al,0eeh
 	and	al,byte [reg_x]
	and	al,dl
	usetest  al
%endmacro


%macro _ARR 0

  ;  algorithm based on 6510core.c by Ettore Perazzoli (ettore@comm2000.it)

	push	ebx
	push	ecx

	and	al,dl
	mov	bl,al

 	cmp	byte [flag_D],0
	je near ARR_4

 	mov	byte [RNTest],ah
 	shl	byte [RNTest],7

	mov	ecx,eax
	shr	ecx,1

 	setnz	byte [RZTest]

	mov	al,cl
	xor	al,bl
	and	al,64
 	setnz	byte [flag_V]

	mov	al,bl
	mov	dl,bl
	and	al,15
	and	dl,1
	add	al,dl
	cmp	al,5
	jbe near ARR_1
	mov	dl,cl
	and	cl,240
	add	dl,6
	and	dl,15
	or	cl,dl
ARR_1:	mov	al,bl
	and	eax,240
	and	ebx,16
	add	eax,ebx
	cmp	eax,80
	jbe near ARR_2
	mov	al,cl
	and	al,15
	mov	bl,cl
	add	bl,96
	and	bl,240
	or	al,bl
	mov	ah,1
	jmp	ARR_5

ARR_2:	xor	ah,ah
	mov	al,cl
	jmp	ARR_5

ARR_4:	shr	eax,1
	usetest  al

	mov	bl,al
	test	bl,64
	setnz	ah

	and	bl,32
	shl	bl,1
	mov	dl,al
	and	dl,64
	xor	bl,dl
 	setnz	byte [flag_V]
ARR_5:
	pop	ecx
	pop	ebx
%endmacro


%macro _ASL 0
	shl	dl,1
	setc	ah
	usetest  dl
%endmacro


%macro _ASR 0
	and	al,dl
	test	al,1
	setnz	ah
	shr	al,1
	usetest  al
%endmacro


%macro _BIT 0
	test	dl,040h  ;  bit 6 is the overflow flag
 	setnz	byte [flag_V]
	usentest  dl ;  the memory bit 7 is the n flag
	and	dl,al  ;  this is the and result
	useztest  dl ;  use it to test for zero
%endmacro


%macro _CPX 0
 	mov	dh,byte [reg_x]
	CompDH
%endmacro


%macro _CPY 0
 	mov	dh,byte [reg_y]
	CompDH
%endmacro


%macro _DCP 0
	dec	dl
	_CMP
%endmacro


%macro _DEC 0
	dec	dl
	usetest  dl
%endmacro


%macro _EOR 0
	xor	al,dl
	usetest  al
%endmacro


%macro _INC 0
	inc	dl
	usetest  dl
%endmacro


%macro _ISB 0
	inc	dl
	call	DoSBC
%endmacro


%macro _LAS 0
 	and	dl,byte [reg_sp]
	mov	al,dl
 	mov	byte [reg_x],dl
 	mov	byte [reg_sp],dl
	usetest  dl
%endmacro


%macro _LAX 0
 	mov	byte [reg_x],dl
	mov	al,dl
	usetest  dl
%endmacro


%macro _LDA 0
	mov	al,dl
	usetest  dl
%endmacro


%macro _LDX 0
 	mov	byte [reg_x],dl
	usetest  dl
%endmacro


%macro _LDY 0
 	mov	byte [reg_y],dl
	usetest  dl
%endmacro


%macro _LSR 0
	shr	dl,1
	setc	ah
	usetest  dl
%endmacro


%macro _LXA 0
	or	al,0eeh
	and	al,dl
 	mov	byte [reg_x],al
	usetest  al
%endmacro


%macro _NOP 0
%endmacro


%macro _ORA 0
	or	al,dl
	usetest  al
%endmacro


%macro _RLA 0
	shr	ah,1
	rcl	dl,1
	setc	ah
	and	al,dl
	usetest  al
%endmacro


%macro _ROL 0
	shr	ah,1
	rcl	dl,1
	setc	ah
	usetest  dl
%endmacro


%macro _ROR 0
	shr	ah,1
	rcr	dl,1
	setc	ah
	usetest  dl
%endmacro


%macro _RRA 0
	shr	ah,1
	rcr	dl,1
	setc	ah
	call	DoADC
%endmacro


%macro _SAX 0
	mov	dl,al
 	and	dl,byte [reg_x]
%endmacro


%macro _SBC 0
	call	DoSBC
%endmacro


DoSBC: cmp	byte [flag_D],0
	jnz near SBCBCD
	shr	ah,1
	cmc			 ;  set carry
	sbb	al,dl
 	seto	 [flag_V]
	usetest  al
	setnc	ah
	ret

SBCBCD:	push	ecx

 	mov	byte [_reg_a],al
 	mov	byte [_value],dl

	xor	ah,1
	sahf
	sbb	al,dl		 ;  set flags using binary subtraction
	usetest  al
 	setnc	byte [_flag_carry]
 	seto	 [flag_V]

 	mov	al,byte [_reg_a] ; now do decimal subtraction
	and	edx,0fh
	add	dl,ah
	and	eax,0fh
	sub	eax,edx		 ;  subtract bottom nybbles with carry
	mov	ecx,eax		 ;  save result
 	mov	al,byte [_reg_a]
	and	eax,0f0h
 	mov	dl,byte [_value]
	and	edx,0f0h
	sub	eax,edx		 ;  subtract top nybbles
	test	ecx,010h		 ;  bottom nybble underflow ?
	je near SBCD_5
	add	eax,-16		 ; 	 yes, fixup
	mov	edx,ecx
	add	edx,-6
	jmp	SBCD_6

SBCD_5:	mov	edx,ecx
SBCD_6:	and	edx,0fh
	or	eax,edx		 ;  combine lower and upper nybble result
	test	eax,0100h	 ;  upper nybble underflow ?
	je near SBCD_7
	sub	eax,060h		 ; 	  yes, fixup
SBCD_7: mov	ah,byte [_flag_carry]
 	mov	dl,byte [_value] ; SBC must preserve dl for ISB

	pop	ecx
	ret	

%macro _SBX 0
	mov	dh,al
 	and	dh,byte [reg_x]
	sub	dh,dl
	usetest  dh
	setnc	ah
 	mov	byte [reg_x],dh
%endmacro


%macro _SHA 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
	and	dl,al
%endmacro


%macro _SHS 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
	and	dl,al
	mov	dh,al
 	and	dh,byte [reg_x]
 	mov	byte [reg_sp],dh
%endmacro


%macro _SHX 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
%endmacro


%macro _SHY 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_y]
%endmacro


%macro _SLO 0
	shl	dl,1
	setc	ah
	or	al,dl
	usetest  al
%endmacro


%macro _SRE 0
	mov	ah,1
	and	ah,dl
	shr	dl,1
	xor	al,dl
	usetest  al
%endmacro


%macro _STA 0
	mov	dl,al
%endmacro


%macro _STX 0
 	mov	dl,byte [reg_x]
%endmacro


%macro _STY 0
 	mov	dl,byte [reg_y]
%endmacro


;*
;* weird opcodes
;*

%macro _BRK 0
	slack_fetch

 	mov	byte [flag_B],1 ; set break flag
 	inc	dword [wreg_pc] ;;; GUESSED dword
 	mov	ebx,dword [reg_pc] ; push return address
	zpush  bh
	zpush  bl

	call	GetPSW  ;  get PSW in DL
	or	dl,010h  ;  force break flag
	zpush  dl

 	mov	byte [flag_I],1 ; disable interrupts
	mov	ebx,0FFFEh  ;  fetch	the vector

	push	eax
	read  al,ebx
	inc	ebx
	read  ah,ebx
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; and transfer control
	pop	eax
%endmacro


%macro _JMPI 0
	fetch  bl ;  read the address of the the jump
	fetch  bh
	read  dl,ebx
	inc	bl  ;  stay in current page
	read  dh,ebx
	and	edx,0ffffh
 	mov	dword [reg_pc],edx ; and jump to it
%endmacro


%macro _JMPW 0
	fetch  bl ;  fetch	the address
	fetch  bh
	and	ebx,0ffffh
 	mov	dword [reg_pc],ebx ; jump to it
%endmacro


%macro _JSR 0
	fetch  bl ;  bottom byte of new PC

	slack_pop

	push	eax
 	mov	eax,dword [reg_pc] ; ax is	the return address
	zpush  ah ;  we are automatically pushing return-1
	zpush  al
	pop	eax

	fetch  bh ;  now we fetch the top byte of PC
	and	ebx,0ffffh
 	mov	dword [reg_pc],ebx ; transfer control
%endmacro


%macro _PHA 0
	slack_fetch
	zpush  al
%endmacro


%macro _PLA 0
	slack_fetch
	slack_pop
	zpop  al
	usetest  al
%endmacro


%macro _PHP 0
	slack_fetch
	call	GetPSW  ;  get PSW in DL
	or	dl,010h  ;  force break flag
	zpush  dl
%endmacro


%macro _PLP 0
	slack_fetch
	slack_pop
	zpop  dh ;  pull PSW from stack
	call	PutPSW
%endmacro


%macro _RTI 0
	slack_fetch
	slack_pop
	zpop  dh ;  pull PSW from stack
	call	PutPSW  ;  and scatter the flags
	push	eax
	zpop  al
	zpop  ah ;  pull return address
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; transfer control
	pop	eax
%endmacro


%macro _RTS 0
	slack_fetch
	slack_pop
	push	eax
	zpop  al
	zpop  ah ;  pull return address
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; transfer control
	pop	eax
	slack_fetch
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro



; load CPU registers

%macro LoadRegs 0
 	mov	eax,dword dword [reg_a] ; mov al,[reg_a]; mov ah,[flag_carry]
%endmacro


; save CPU registers

%macro SaveRegs 0
 	mov	dword dword [reg_a],eax ; mov [reg_a],al; mov [flag_carry],ah
%endmacro


;*
;* do a single instruction (just for show)
;*

do_Instruction:

	LoadRegs  ;  load the CPU registers

	fetch_opcode  ebx ;  (fetchzx) get the opcode
 	call 	dword [vectors + ebx*4] ; --> do the instruction
	ClockRIOT

	SaveRegs  ;  save the CPU registers

	ret

;*
;* Reset the CPU
;*

Reset:
 	mov	byte [reg_sp],0FFh ; SP initialises to 255
	mov	ebx,0fffch	 ;  get reset address
	read  dl,ebx
	inc	ebx
	read  dh,ebx
	and	edx,0ffffh
 	mov	dword [reg_pc],edx
 	mov	byte [RClock],0
	ret

;*
;* Handle relative jumps
;*

DoBranch:
 	mov	ebx,dword [reg_pc] ; bh is	the current page
 	add	edx,dword [reg_pc] ; destination address
	and	edx,0ffffh
 	mov	dword [reg_pc],edx ; set the program counter

	cmp	bh,dh		 ;  page changed ?
	je near dbjn		 ;    no

	xchg	bh,dh
	slack_fetch  ; 	  yes, another cycle
	xchg	bh,dh

dbjn:	slack_fetch  ;  branch is taken -- one extra cycle

	ret

;*
;* Build the PSW out of the various flags and the last register into DL
;*

GetPSW: mov	dl,byte [RNTest] ; dl = last result
	and	dl,128		 ;  use bit 7 of that for N
 	mov	dh,byte [flag_V] ; bit 6	is V
	shl	dh,6
	or	dl,dh
	or	dl,020H		 ;  bit 5	is always set
 	mov	dh,byte [flag_B] ; bit 4	is B
	shl	dh,4
	or	dl,dh
 	mov	dh,byte [flag_D] ; bit 3	is D
	shl	dh,3
	or	dl,dh
 	mov	dh,byte [flag_I] ; bit 2	is I
	shl	dh,2
	or	dl,dh
 	cmp	byte [RZTest],0 ; bit 1 is Z
	jnz near PSWZero
	or	dl,02h
PSWZero:or	dl,ah		 ;  bit 0	is C
	ret

;*
;* set various flags from PSW in dh
;*

PutPSW: mov	byte [RNTest],dh ; PSW will do for N
	mov	ah,dh
	and	ah,1		 ;  bit 0 is C
	test	dh,02h		 ;  bit 1 is Z
 	setz	byte [RZTest]
	test	dh,04h		 ;  bit 2 is I
 	setnz	byte [flag_I]
	test	dh,08h		 ;  bit 3 is D
 	setnz	byte [flag_D]
	test	dh,010h		 ;  bit 4 is B
 	setnz	byte [flag_B]
	test	dh,040h		 ;  bit 6 is V
 	setnz	byte [flag_V]
	ret

[section .data]

;*
;* opcode vector table
;*
;* note:  the jam handler should be defined externally
;*	  (since it is typically environment dependent)
;*
vectors:  ; dword
    dd _00,_01,jam,_03,_04,_05,_06,_07,_08,_09,_0a,_0b,_0c,_0d,_0e,_0f
    dd _10,_11,jam,_13,_14,_15,_16,_17,_18,_19,_1a,_1b,_1c,_1d,_1e,_1f
    dd _20,_21,jam,_23,_24,_25,_26,_27,_28,_29,_2a,_0b,_2c,_2d,_2e,_2f  ; _2b=_0b
    dd _30,_31,jam,_33,_34,_35,_36,_37,_38,_39,_3a,_3b,_3c,_3d,_3e,_3f
    dd _40,_41,jam,_43,_44,_45,_46,_47,_48,_49,_4a,_4b,_4c,_4d,_4e,_4f
    dd _50,_51,jam,_53,_54,_55,_56,_57,_58,_59,_5a,_5b,_5c,_5d,_5e,_5f
    dd _60,_61,jam,_63,_64,_65,_66,_67,_68,_69,_6a,_6b,_6c,_6d,_6e,_6f
    dd _70,_71,jam,_73,_74,_75,_76,_77,_78,_79,_7a,_7b,_7c,_7d,_7e,_7f
    dd _80,_81,_82,_83,_84,_85,_86,_87,_88,_89,_8a,_8b,_8c,_8d,_8e,_8f
    dd _90,_91,jam,_93,_94,_95,_96,_97,_98,_99,_9a,_9b,_9c,_9d,_9e,_9f
    dd _a0,_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_aa,_ab,_ac,_ad,_ae,_af
    dd _b0,_b1,jam,_b3,_b4,_b5,_b6,_b7,_b8,_b9,_ba,_bb,_bc,_bd,_be,_bf
    dd _c0,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_ca,_cb,_cc,_cd,_ce,_cf
    dd _d0,_d1,jam,_d3,_d4,_d5,_d6,_d7,_d8,_d9,_da,_db,_dc,_dd,_de,_df
    dd _e0,_e1,_e2,_e3,_e4,_e5,_e6,_e7,_e8,_e9,_ea,_e9,_ec,_ed,_ee,_ef  ; _eb=_e9
    dd _f0,_f1,jam,_f3,_f4,_f5,_f6,_f7,_f8,_f9,_fa,_fb,_fc,_fd,_fe,_ff

[section .code]

;*
;* opcode handlers
;*

op_weird  _00,BRK
op_read  _01,ORA,ind_x

op_rmw  _03,SLO,ind_x
op_read  _04,NOP,zero
op_read  _05,ORA,zero
op_rmw  _06,ASL,zero
op_rmw  _07,SLO,zero
op_weird  _08,PHP
op_immediate  _09,ORA
op_register  _0a,ASL,al
op_immediate  _0b,ANC
op_read  _0c,NOP,abs
op_read  _0d,ORA,abs
op_rmw  _0e,ASL,abs
op_rmw  _0f,SLO,abs
 op_branch  _10,byte [RNTest],128,jz
op_read  _11,ORA,ind_y

op_rmw  _13,SLO,ind_y
op_read  _14,NOP,zero_x
op_read  _15,ORA,zero_x
op_rmw  _16,ASL,zero_x
op_rmw  _17,SLO,zero_x
op_transfer  _18,ah,0
op_read  _19,ORA,abs_y
op_transfer  _1a,al,al
op_rmw  _1b,SLO,abs_y
op_read  _1c,NOP,abs_x
op_read  _1d,ORA,abs_x
op_rmw  _1e,ASL,abs_x
op_rmw  _1f,SLO,abs_x
op_weird  _20,JSR
op_read  _21,AND,ind_x

op_rmw  _23,RLA,ind_x
op_read  _24,BIT,zero
op_read  _25,AND,zero
op_rmw  _26,ROL,zero
op_rmw  _27,RLA,zero
op_weird  _28,PLP
op_immediate  _29,AND
op_register  _2a,ROL,al

op_read  _2c,BIT,abs
op_read  _2d,AND,abs
op_rmw  _2e,ROL,abs
op_rmw  _2f,RLA,abs
 op_branch  _30,byte [RNTest],128,jnz
op_read  _31,AND,ind_y

op_rmw  _33,RLA,ind_y
op_read  _34,NOP,zero
op_read  _35,AND,zero_x
op_rmw  _36,ROL,zero_x
op_rmw  _37,RLA,zero_x
op_transfer  _38,ah,1
op_read  _39,AND,abs_y
op_transfer  _3a,al,al
op_rmw  _3b,RLA,abs_y
op_read  _3c,NOP,abs_x
op_read  _3d,AND,abs_x
op_rmw  _3e,ROL,abs_x
op_rmw  _3f,RLA,abs_x
op_weird  _40,RTI
op_read  _41,EOR,ind_x

op_rmw  _43,SRE,ind_x
op_read  _44,NOP,zero
op_read  _45,EOR,zero
op_rmw  _46,LSR,zero
op_rmw  _47,SRE,zero
op_weird  _48,PHA
op_immediate  _49,EOR
op_register  _4a,LSR,al
op_immediate  _4b,ASR
op_weird  _4c,JMPW
op_read  _4d,EOR,abs
op_rmw  _4e,LSR,abs
op_rmw  _4f,SRE,abs
 op_branch  _50,byte [flag_V],0ffh,jz
op_read  _51,EOR,ind_y

op_rmw  _53,SRE,ind_y
op_read  _54,NOP,zero_x
op_read  _55,EOR,zero_x
op_rmw  _56,LSR,zero_x
op_rmw  _57,SRE,zero_x
 op_transfer  _58,byte [flag_I],0
op_read  _59,EOR,abs_y
op_transfer  _5a,al,al
op_rmw  _5b,SRE,abs_y
op_read  _5c,NOP,abs_x
op_read  _5d,EOR,abs_x
op_rmw  _5e,LSR,abs_x
op_rmw  _5f,SRE,abs_x
op_weird  _60,RTS
op_read  _61,ADC,ind_x

op_rmw  _63,RRA,ind_x
op_read  _64,NOP,zero
op_read  _65,ADC,zero
op_rmw  _66,ROR,zero
op_rmw  _67,RRA,zero
op_weird  _68,PLA
op_immediate  _69,ADC
op_register  _6a,ROR,al
op_immediate  _6b,ARR
op_weird  _6c,JMPI
op_read  _6d,ADC,abs
op_rmw  _6e,ROR,abs
op_rmw  _6f,RRA,abs
 op_branch  _70,byte [flag_V],0ffh,jnz
op_read  _71,ADC,ind_y

op_rmw  _73,RRA,ind_y
op_read  _74,NOP,zero_x
op_read  _75,ADC,zero_x
op_rmw  _76,ROR,zero_x
op_rmw  _77,RRA,zero_x
 op_transfer  _78,byte [flag_I],1
op_read  _79,ADC,abs_y
op_transfer  _7a,al,al
op_rmw  _7b,RRA,abs_y
op_read  _7c,NOP,abs_x
op_read  _7d,ADC,abs_x
op_rmw  _7e,ROR,abs_x
op_rmw  _7f,RRA,abs_x
op_immediate  _80,NOP
op_write  _81,STA,ind_x
op_immediate  _82,NOP
op_write  _83,SAX,ind_x
op_write  _84,STY,zero
op_write  _85,STA,zero
op_write  _86,STX,zero
op_write  _87,SAX,zero
 op_register  _88,DEC,byte [reg_y]
op_immediate  _89,NOP
 op_transfertest  _8a,al,byte [reg_x]
op_immediate  _8b,ANE
op_write  _8c,STY,abs
op_write  _8d,STA,abs
op_write  _8e,STX,abs
op_write  _8f,SAX,abs
op_branch  _90,ah,ah,jz
op_write  _91,STA,ind_y

op_write  _93,SHA,ind_y
op_write  _94,STY,zero_x
op_write  _95,STA,zero_x
op_write  _96,STX,zero_y
op_write  _97,SAX,zero_y
 op_transfertest  _98,al,byte [reg_y]
op_write  _99,STA,abs_y
 op_transfer  _9a,byte [reg_sp],[reg_x]
op_write  _9b,SHS,abs_y
op_write  _9c,SHY,abs_x
op_write  _9d,STA,abs_x
op_write  _9e,SHX,abs_y
op_write  _9f,SHA,abs_y
op_immediate  _a0,LDY
op_read  _a1,LDA,ind_x
op_immediate  _a2,LDX
op_read  _a3,LAX,ind_x
op_read  _a4,LDY,zero
op_read  _a5,LDA,zero
op_read  _a6,LDX,zero
op_read  _a7,LAX,zero
 op_transfertest  _a8,byte [reg_y],al
op_immediate  _a9,LDA
 op_transfertest  _aa,byte [reg_x],al
op_immediate  _ab,LXA
op_read  _ac,LDY,abs
op_read  _ad,LDA,abs
op_read  _ae,LDX,abs
op_read  _af,LAX,abs
op_branch  _b0,ah,ah,jnz
op_read  _b1,LDA,ind_y

op_read  _b3,LAX,ind_y
op_read  _b4,LDY,zero_x
op_read  _b5,LDA,zero_x
op_read  _b6,LDX,zero_y
op_read  _b7,LAX,zero_y
 op_transfer  _b8,byte [flag_V],0
op_read  _b9,LDA,abs_y
 op_transfertest  _ba,byte [reg_x],[reg_sp]
op_read  _bb,LAS,abs_y
op_read  _bc,LDY,abs_x
op_read  _bd,LDA,abs_x
op_read  _be,LDX,abs_y
op_read  _bf,LAX,abs_y
op_immediate  _c0,CPY
op_read  _c1,CMP,ind_x
op_immediate  _c2,NOP
op_rmw  _c3,DCP,ind_x
op_read  _c4,CPY,zero
op_read  _c5,CMP,zero
op_rmw  _c6,DEC,zero
op_rmw  _c7,DCP,zero
 op_register  _c8,INC,byte [reg_y]
op_immediate  _c9,CMP
 op_register  _ca,DEC,byte [reg_x]
op_immediate  _cb,SBX
op_read  _cc,CPY,abs
op_read  _cd,CMP,abs
op_rmw  _ce,DEC,abs
op_rmw  _cf,DCP,abs
 op_branch  _d0,byte [RZTest],0ffh,jnz
op_read  _d1,CMP,ind_y

op_rmw  _d3,DCP,ind_y
op_read  _d4,NOP,zero_x
op_read  _d5,CMP,zero_x
op_rmw  _d6,DEC,zero_x
op_rmw  _d7,DCP,zero_x
 op_transfer  _d8,byte [flag_D],0
op_read  _d9,CMP,abs_y
op_transfer  _da,al,al
op_rmw  _db,DCP,abs_y
op_read  _dc,NOP,abs_x
op_read  _dd,CMP,abs_x
op_rmw  _de,DEC,abs_x
op_rmw  _df,DCP,abs_x
op_immediate  _e0,CPX
op_read  _e1,SBC,ind_x
op_immediate  _e2,NOP
op_rmw  _e3,ISB,ind_x
op_read  _e4,CPX,zero
op_read  _e5,SBC,zero
op_rmw  _e6,INC,zero
op_rmw  _e7,ISB,zero
 op_register  _e8,INC,byte [reg_x]
op_immediate  _e9,SBC
op_transfer  _ea,al,al

op_read  _ec,CPX,abs
op_read  _ed,SBC,abs
op_rmw  _ee,INC,abs
op_rmw  _ef,ISB,abs
 op_branch  _f0,byte [RZTest],0ffh,jz
op_read  _f1,SBC,ind_y

op_rmw  _f3,ISB,ind_y
op_read  _f4,NOP,zero_x
op_read  _f5,SBC,zero_x
op_rmw  _f6,INC,zero_x
op_rmw  _f7,ISB,zero_x
 op_transfer  _f8,byte [flag_D],1
op_read  _f9,SBC,abs_y
op_transfer  _fa,al,al
op_rmw  _fb,ISB,abs_y
op_read  _fc,NOP,abs_x
op_read  _fd,SBC,abs_x
op_rmw  _fe,INC,abs_x
op_rmw  _ff,ISB,abs_x




;
; $Log: cpu.asm,v $
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
