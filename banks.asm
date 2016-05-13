; banks.asm -- z26 bank switch stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 02-17-98  got Parker Bros Working and added TigerVision
; 08-03-02  32-bit

[section .data]
RBankTab:  ; dword
	dd	RBank4			 ;   0 -- 4K Atari
	dd	RBankCV			 ;   1 -- Commavid
	dd	RBank8sc		 ;   2 -- 8K superchip
	dd	RBank8pb		 ;   3 -- 8K Parker Bros.
	dd	RBank8tv		 ;   4 -- 8K Tigervision
	dd	RBank8FE		 ;   5 -- 8K Flat
	dd	RBank16sc		 ;   6 -- 16K superchip
	dd	RBank16mn		 ;   7 -- 16K M-Network
	dd	RBank32sc		 ;   8 -- 32K superchip
	dd	RBank8			 ;   9 -- 8K Atari - banks swapped
	dd	RBankCM			 ;  10 -- Compumate
	dd	RBank32tv		 ;  11 -- 512K Tigervision
   dd      RBank8ua                 ;  12 -- 8K UA Ltd.
   dd      RBankEF                  ;  13 -- 64K Homestar Runner / Paul Slocum
	dd	RBank8P2		 ;  14 -- Pitfall2
	dd	RBank_SP		 ;  15 -- Starpath
	dd	RBank16			 ;  16 -- 16K Atari
	dd	RBank32			 ;  17 -- 32K Atari
	dd	RBankMB			 ;  18 -- Megaboy
   dd RBank12                  ;  19 -- 12K
   dd RBank8                   ;  20 -- 8K Atari
WBankTab:  ; dword
	dd	WBank4
	dd	WBankCV
	dd	WBank8sc
	dd	WBank8pb
	dd	WBank8tv
	dd	WBank8FE
	dd	WBank16sc
	dd	WBank16mn
	dd	WBank32sc
	dd	WBank8
	dd	WBankCM
	dd	WBank32tv
	dd WBank8ua
	dd WBankEF
	dd	WBank8P2
	dd	WBank_SP
	dd	WBank16
	dd	WBank32
	dd	WBankMB
	dd	WBank12
	dd	WBank8

%ifdef C_BANKVARS
extern RomBank

extern PBSlice0
extern PBSlice1
extern PBSlice2
extern PBSlice3

extern TVSlice0
extern TVSlice1

extern TVSlice032
extern TVSlice132

extern MNSlice0
extern MNSlice1

extern MNRamSlice

extern CMRamState
%else

global RomBank
global PBSlice0
global PBSlice1
global PBSlice2
global PBSlice3
global TVSlice0
global TVSlice1
global TVSlice032
global TVSlice132
global MNSlice0
global MNSlice1
global MNRamSlice
global CMRamState

RomBank		dd	0		 ;  Rom bank pointer for F8 & F16

; Parker Brother's ROM Slices

PBSlice0	dd	0
PBSlice1	dd	1*400h
PBSlice2	dd	2*400h
PBSlice3	dd	7*400h		 ;  this one doesn't change
					 ;  points to 1K bank #7
; Tigervision ROM Slices

TVSlice0	dd	0
TVSlice1	dd	3*800h		 ;  this one doesn't change
					 ;  points to 2K bank #3
; Tigervision 32 ROM Slices

TVSlice032	dd	0
TVSlice132	dd	15*800h		 ;  this one doesn't change
					 ;  points to 2K bank #15
; M-Network ROM Slices

MNSlice0	dd	0
MNSlice1	dd	7*800h		 ;  this one doesn't change
					 ;  points to 2K bank #3
; M-Network RAM Slices

MNRamSlice	dd	0		 ;  which 256 byte ram slice

; CompuMate RAM state

CMRamState	dd	10h		 ;  RAM enabled - read/write state
%endif

[section .code]

%ifdef C_SETUPBANKS
extern SetupBanks
%else
;*
;* set up bank switch scheme
;*


SetupBanks:
 	mov	dword [RomBank],0
 	mov	dword [PBSlice0],0
 	mov	dword [PBSlice1],1*400h
 	mov	dword [PBSlice2],2*400h
 	mov	dword [PBSlice3],7*400h
 	mov	dword [TVSlice0],0
 	mov	dword [TVSlice1],3*800h
 	mov	dword [TVSlice032],0
   mov     eax,dword [CartSize] ; make last 2K bank fixed for 3F games
   sub     eax,2048
   mov     dword [TVSlice132],eax
;;  mov     [TVSlice132],15*800h
 	mov	dword [MNSlice0],0
 	mov	dword [MNSlice1],7*800h
 	mov	dword [MNRamSlice],0
 	mov	byte [Pitfall2],0
 	mov	byte [Starpath],0

 	mov	eax,dword [BSType] ; bankswitching type specified
	test	eax,eax			 ; 	  by user?
	je near DetectBySize		 ;  no ... autodetect it *EST*
	cmp	eax,1			    
	je near SCV			 ;  Commavid extra RAM
	cmp	eax,10
	je near SCM			 ;  CompuMate computer module
	ret

DetectBySize:
	mov	eax,dword [CartSize]
	cmp	eax,02000h
	je near Set8kMode		 ;  8K cart
	cmp	eax,03000h
	je near Set12KMode		 ;  12K cart
	cmp	eax,04000h
	je near Set16kMode		 ;  16K cart
	cmp	eax,08000h
	je near Set32kMode		 ;  32K cart
	cmp	eax,028ffh
	je near SetPitfallII		 ;  Pitfall II cart
	cmp     eax,65536
	je near SMB			 ;  Megaboy 64K cart *EST*
	cmp	eax,6144
	je near SetStarpath              ;  Supercharger image
	mov     ebx,8448                 ;  file size is multiple of 8448 bytes?
	xor     edx,edx
	div     ebx
	cmp     edx,0
	je near SetStarpath              ;  ... must be Supercharger game
	mov	eax,dword [CartSize]
	cmp     eax,65536
	ja near Set32kTVMode             ;  large Tigervision game
	ret


; Setup CompuMate

SCM: mov     dword [RomBank],03000h
	pushad
	call	InitCompuMate		 ;  init Compumate keyboard
	popad
	ret				 ;  see controls.c


; Setup Commavid RAM module

SCV:	mov	ebx,2047		 ;  copy ROM to RAM for MagiCard
SCV1: mov	al,byte [CartRom+ebx]
 	mov	byte [Ram+ebx],al
	dec	ebx
	jns	SCV1
	ret

Set8kMode:
 	mov	dword [RomBank],01000h ; need this for moonswep and lancelot
         mov     dword [BSType],20
	ret

Set12KMode:
         mov     dword [BSType],19
	ret

Set16kMode:
 	mov	dword [BSType],16
	ret

Set32kMode:
 	mov	dword [BSType],17
	ret

SMB: mov	dword [BSType],18
	ret

Set32kTVMode:
         mov     dword [BSType],11
        ret

%endif

;*
;* hardware read/write testing macros
;*

%macro test_hw_read 0
	and	esi,01fffh
	cmp	esi,1000h  ;  if not ROM, read hardware
	jb near ReadHardware
%endmacro


%macro test_hw_write 0
	and	esi,01fffh
	cmp	esi,1000h
	jb near WriteHardware
%endmacro


%macro MapRomBank 0
 	add	esi,dword [RomBank]
	add	esi, CartRom - 1000h
%endmacro


%macro WriteRam 0
 	mov	al,byte [WByte]
 	mov	byte [esi],al
%endmacro


;*
;* standard 4K cart
;*

RBank4: test_hw_read
	add	esi, CartRom - 1000h
	ret
        

WBank4:	test_hw_write
	ret


;*
;* Commavid RAM cart (vidlife)
;*

%macro CVR_TestRam 0
; local ; NotRam

	cmp	esi,17ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	ret

%%NotRam:
%endmacro


%macro CVW_TestRam 0
; local ; NotRam

	cmp	esi,17ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 400h
	WriteRam
	ret

%%NotRam:
%endmacro



RBankCV: test_hw_read
	CVR_TestRam
	add	esi, CartRom - 1000h
	ret
        

WBankCV:test_hw_write
	CVW_TestRam
	ret

;*
;* standard 8K cart (F8)
;*

%macro SetBank_8 0
; local ; NoChange

	cmp	esi,1FF8h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FF9h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF8h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank8:	test_hw_read
	SetBank_8
	MapRomBank
	ret


WBank8:	test_hw_write
	SetBank_8
	ret

;*
;* standard 8K cart with Super-Chip (F8+sc)
;*

%macro SCR_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 80h
	ret

%%NotRam:
%endmacro


%macro SCW_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	WriteRam
	ret

%%NotRam:
%endmacro



RBank8sc:
	test_hw_read
	SetBank_8
	SCR_TestRam
	MapRomBank
	ret

WBank8sc:
	test_hw_write
	SetBank_8
	SCW_TestRam
	ret

;*
;* 12K Ram Plus cart (FA)
;*

%macro SetBank_12 0
; local ; NoChange

	cmp	esi,1FF8h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FFAh
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF8h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


%macro FAR_TestRam 0
; local ; NotRam

	cmp	esi,11ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 100h
	ret

%%NotRam:
%endmacro


%macro FAW_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	WriteRam

%%NotRam:
%endmacro


RBank12:
	test_hw_read
	SetBank_12
	FAR_TestRam
	MapRomBank
	ret


WBank12:
	test_hw_write
	SetBank_12
	FAW_TestRam
	ret

;*
;* standard 16K cart (F16)
;*

%macro SetBank_16 0
; local ; NoChange

	cmp	esi,1FF6h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FF9h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF6h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank16:
	test_hw_read
	SetBank_16
	MapRomBank
	ret


WBank16:
	test_hw_write
	SetBank_16
	ret


;*
;* standard 16K cart with Super-Chip (F16+sc)
;*

RBank16sc:
	test_hw_read
	SetBank_16
	SCR_TestRam
	MapRomBank
	ret



WBank16sc:
	test_hw_write
	SetBank_16
	SCW_TestRam
	ret

;*
;* CompuMate computer module
;*

%macro ChangeState_CM 0
	cmp	esi,0280h
	jne near %%NoChange
 	test	byte [WByte],20h
	jz near %%NoResetKeyCount
 	mov	byte [CM_Collumn],0
%%NoResetKeyCount:
 	test	byte [WByte],40h
	jz near %%NoIncreaseKeyCount
 	inc	byte [CM_Collumn]
 	cmp	byte [CM_Collumn],10
	jne near %%NoIncreaseKeyCount
 	mov	byte [CM_Collumn],0
%%NoIncreaseKeyCount:
 	mov	al,byte [WByte]
 	mov	dword [CMRamState],eax
	and	eax,03h
	shl	eax,12
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro



%macro TestRam_CM 0
	cmp	esi,1800h
	jb near %%NoRAM
 	test	dword [CMRamState],10h ; RAM enabled?
	jnz near %%NoRAM
	add	esi, Ram - 1000h - 800h
 	test	dword [CMRamState],20h ; write enabled?
	jz near %%NoWrite
	WriteRam
%%NoWrite:
	ret
%%NoRAM:
%endmacro



RBankCM:
	test_hw_read
	TestRam_CM
	MapRomBank
	ret


WBankCM:
	ChangeState_CM
	test_hw_write
	TestRam_CM
	ret

;*
;* standard 32K cart (F4)
;*

%macro SetBank_32 0
	cmp	esi,1FF4h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FFbh
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF4h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank32:
	test_hw_read
	SetBank_32
	MapRomBank
	ret

WBank32:
	test_hw_write
	SetBank_32
	ret

;*
;* standard 32K cart with Super-Chip (F4+sc)
;*

RBank32sc:
	test_hw_read
	SetBank_32
	SCR_TestRam
	MapRomBank
	ret

WBank32sc:
	test_hw_write
	SetBank_32
	SCW_TestRam
	ret

;*
;* Parker Brother's 8K cart
;*


%macro PB_SetSlice 0
	cmp	esi,1Fe0h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp     esi,1FF7h
	ja near %%NoChange

	push	ebx
	mov	eax,esi
	and	eax,7
	shl	eax,10  ;  new bank
	mov	ebx,esi
	and	ebx,18h
	shr	ebx,1  ;  slice to set *4
 	mov	dword [PBSlice0 + ebx],eax	
	pop	ebx

%%NoChange:
%endmacro


%macro PB_MapSlice 0
	mov	eax,esi
	and	eax,0c00h
	shr	eax,8  ;  slice # we're in *4
	and	esi,03ffh  ;  mask low order bits
 	add	esi,dword [PBSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom

%endmacro



RBank8pb:
	test_hw_read
	PB_SetSlice
	PB_MapSlice
	ret


WBank8pb:
	test_hw_write
	PB_SetSlice
	ret

;*
;* Tigervision 8K cart
;* extended to 512K, but $1800-$1FFF still is the fixed bank
;*

%macro TV_SetSlice 0
	cmp	esi,03fh
	ja near %%NoChange

 	mov	al,byte [WByte]
	and     eax,0ffh
	shl	eax,11  ;  new bank
 	mov	dword [TVSlice0],eax

%%NoChange:
%endmacro


%macro TV_MapSlice 0
	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in *4
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [TVSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom
%endmacro



RBank8tv:
	test_hw_read
	TV_MapSlice
	ret

WBank8tv:
	TV_SetSlice
	test_hw_write
	ret


;*
;* Tigervision 32K cart
;* extended to 512K - last 2K in ROM get used as fixed bank
;*

%macro TV_SetSlice32 0

	cmp	esi,03fh
	ja near %%NoChange

 	mov	al,byte [WByte]
	and	eax,0ffh  ;  0fh
	shl	eax,11  ;  new bank
 	mov	dword [TVSlice032],eax

%%NoChange:
%endmacro


%macro TV_MapSlice32 0
	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in *4
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [TVSlice032 + eax] ; point to proper ROM slice
	add	esi, CartRom
%endmacro



RBank32tv:
	test_hw_read
	TV_MapSlice32
	ret

WBank32tv:
	TV_SetSlice32
	test_hw_write
	ret


;*
;* FE 8K bankswitch scheme -- flat model
;*

%macro FE_SetBank 0
	cmp byte byte [debugflag],1 ; no BS if trace code reads the memory
	je near %%Trace
	cmp     esi,1000h
	jb near %%Trace
	mov     eax,2000h
	and     eax,esi  ;  isolate bank bit from address
	xor     eax,2000h  ;  invert it
	shr     eax,1  ;  position it
	mov     dword [RomBank],eax ; this is our bank
%%Trace:
%endmacro



RBank8FE:
	FE_SetBank
	test_hw_read
	MapRomBank
	ret


WBank8FE:
	FE_SetBank
	test_hw_write
	ret


;*
;* M-Network 16K cart
;*

; small chunks mapped at 0 to 3FF
;
; 0 --	00 -  FF
; 1 -- 100 - 1FF
; 2 -- 200 - 2FF
; 3 -- 300 - 3FF

; large chunk mapped at 400 to 7FF


%macro MNR_TestRam 0
	cmp	esi,19ffh
	ja near %%Done
	cmp	esi,1400h
	jb near %%Done
	cmp	esi,17ffh
	jbe near %%ReadBig
	cmp	esi,1900h
	jb near %%Done
 	add	esi,dword [MNRamSlice] ; read small, pick up current slice
	add	esi, Ram - 1900h
	ret

%%ReadBig:
 	cmp	dword [MNSlice0],0ffffh ; RAM mapped in ?
	jne near %%Done  ;  no
	add	esi, Ram - 1400h + 400h
	ret

%%Done:
%endmacro


%macro MNW_TestRam 0
	cmp	esi,18ffh
	ja near %%Done
	cmp	esi,1000h
	jb near %%Done
	cmp	esi,13ffh
	jbe near %%WriteBig
	cmp	esi,1800h
	jb near %%Done
 	add	esi,dword [MNRamSlice] ; write small, pick up current slice
	add	esi, Ram - 1800h
	WriteRam
	ret

%%WriteBig:
 	cmp	dword [MNSlice0],0ffffh ; RAM mapped in ?
	jne near %%Done  ;  no
	add	esi, Ram - 1000h + 400h
	WriteRam
	ret
	
%%Done:
%endmacro


%macro MN_SetRamSlice 0
	cmp	esi,1FE7h
	jne near %%NotMapLower
 	mov	dword [MNSlice0],0ffffh ; map RAM into lower slice
	jmp	%%Done

%%NotMapLower:
	cmp	esi,1fe8h
	jb near %%Done
	cmp	esi,1feBh
	ja near %%Done
	mov	eax,esi
	sub	eax,1fe8h
	shl	eax,8
 	mov	dword [MNRamSlice],eax

%%Done:
%endmacro


%macro MN_SetSlice 0
	cmp	esi,1FE0h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FE6h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FE0h  ;  bank #
	shl	eax,11  ;  bank address
 	mov	dword [MNSlice0],eax

%%NoChange:
%endmacro


%macro MN_MapSlice 0
	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [MNSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom

%endmacro



RBank16mn:
	test_hw_read
	MN_SetSlice
	MN_SetRamSlice
	MNR_TestRam
	MN_MapSlice
	ret

WBank16mn:
	test_hw_write
	MN_SetSlice
	MN_SetRamSlice
	MNW_TestRam
	ret

;*
;* Megaboy (F0) *EST*
;*

%macro SetBank_MB 0

	cmp	esi,1FF0h  ;  if not in switch area ...
	jne near %%NoChange  ;  ... there's no change

 	mov	eax,dword [RomBank]
	add	eax,01000h
        and     eax,0f000h
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBankMB:
	test_hw_read
	SetBank_MB
	MapRomBank
	ret


WBankMB:
	test_hw_write
	SetBank_MB
	ret

;*
;* UA Ltd. 8K cart (24)
;*

%macro SetBank_8ua 0
        cmp     esi,220h  ;  bank 0 hotspot?
        je near %%DoChange                
        cmp     esi,240h  ;  bank 1 hotspot?
        jne near %%NoChange

%%DoChange:
        push    eax
        mov     eax,esi
        and     eax,40h  ;  high or low bank
        shl     eax,6  ;  bank address
         mov     dword [RomBank],eax
        pop     eax

%%NoChange:
%endmacro


RBank8ua:
        SetBank_8ua
        test_hw_read
	MapRomBank
	ret


WBank8ua:
        SetBank_8ua
        test_hw_write
        ret

;*
;* Homestar Runner / Paul Slocum (EF) 64K
;*

%macro SetBank_EF 0
	cmp     esi,1FE0h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
	cmp     esi,1FEFh
	ja near %%NoChange

	mov	eax,esi
	sub     eax,1FE0h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBankEF:
	test_hw_read
        SetBank_EF
	MapRomBank
	ret


WBankEF:
	test_hw_write
        SetBank_EF
	ret



;
; $Log: banks.asm,v $
; Revision 1.5  2004/05/19 01:00:57  urchlay
;
; SetupBanks() and associated routines moved to C.
;
; Revision 1.4  2004/05/18 04:56:11  urchlay
;
; More variable and initialization code migration.
;
; Revision 1.3  2004/05/18 02:17:15  urchlay
;
; Great Variable Migration from asm to C, partly complete.
;
; Revision 1.2  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
