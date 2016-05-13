; trace.asm -- z26 trace stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit


[section .data]

debugflag	db	0

[section .code]

;*
;* trace routines
;*
;* so trace code written in C can access the assembler language machinery
;*
global ReallyReadROM

ReallyReadROM:
	pushad
 	mov	esi,dword [cpu_MAR]

 	mov	byte [debugflag],1
 	mov	eax, dword [BSType]
 	call	dword [RBankTab + eax*4] ; trashes eax
 	mov	byte [debugflag],0

 	mov	al,byte [esi]
 	mov	byte [cpu_Rbyte],al

	popad
	ret
global ReallyReadRAM

ReallyReadRAM:
	pushad
 	mov	esi,dword [cpu_MAR]

 	mov	byte [debugflag],1
	call	ReadHardware
 	mov	byte [debugflag],0

 	mov	al,byte [esi]
 	mov	byte [cpu_Rbyte],al

	popad
	ret



;*
;* trace routine so assembler routine can
;* start the C trace routine
;*

TraceInstruction:
	pushad

 	mov	byte [cpu_a],al
 	mov	byte [cpu_carry],ah

 	mov	eax,dword [Frame]
 	mov	dword [frame],eax
 	mov	eax,dword [ScanLine]
 	mov	dword [line],eax
 	mov	al,byte [RClock]
 	mov	byte [cycle],al

 	mov	eax,dword [BL_Position]
 	mov	dword [BL_Pos],eax
 	mov	eax,dword [M0_Position]
 	mov	dword [M0_Pos],eax
 	mov	eax,dword [M1_Position]
 	mov	dword [M1_Pos],eax
 	mov	eax,dword [P0_Position]
 	mov	dword [P0_Pos],eax
 	mov	eax,dword [P1_Position]
 	mov	dword [P1_Pos],eax

 	mov	eax,dword [reg_pc]
 	mov	dword [cpu_pc],eax
 	mov	al,byte [reg_x]
 	mov	byte [cpu_x],al
 	mov	al,byte [reg_y]
 	mov	byte [cpu_y],al
 	mov	al,byte [reg_sp]
 	mov	byte [cpu_sp],al
 	mov	al,byte [RZTest]
 	mov	byte [cpu_ZTest],al
 	mov	al,byte [RNTest]
 	mov 	byte [cpu_NTest],al
 	mov	al,byte [flag_D]
 	mov	byte [cpu_D],al
 	mov	al,byte [flag_V]
 	mov	byte [cpu_V],al
 	mov	al,byte [flag_I]
 	mov	byte [cpu_I],al
 	mov	al,byte [flag_B]
 	mov	byte [cpu_B],al

	call	ShowRegisters
	call	ShowInstruction

	popad
	ret




;
; $Log: trace.asm,v $
; Revision 1.2  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
