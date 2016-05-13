;*
;* Starpath Supercharger support for z26
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

%ifdef C_INITSPATH

extern SP_Scheme

extern SPSlice0
extern SPSlice1

extern SP_PrevAdr

extern SP_RamWord
%define SP_RamByte SP_RamWord

extern Starpath
extern SP_WriteEnable
extern SP_PulseDelay

extern Init_Starpath

%else
[section .data]

; Starpath ROM Slices
SP_Scheme:  ; dword                   ; table of bankswitch schemes
        dd      2*800h,3*800h
        dd      0*800h,3*800h
        dd      2*800h,0*800h
        dd      0*800h,2*800h
        dd      2*800h,3*800h
        dd      1*800h,3*800h
        dd      2*800h,1*800h
        dd      1*800h,2*800h

SPSlice0        dd      0
SPSlice1        dd      3*800h

SP_PrevAdr      dd      0
SP_RamWord:  ; dword
SP_RamByte      db      0,0,0,0          ;  byte to write to RAM (pad to allow dword write)

global Starpath
Starpath        db      0                ;  global Starpath flag
SP_WriteEnable  db      0                ;  SC RAM write enabled

SP_PulseDelay   db      7                ;  # of cycles since last memory reference

%endif

[section .code]

;*
;* set bankswitch scheme from bx
;*

%macro SP_SetScheme 0

	push    eax
	shr     ebx,2
	setc     [SP_WriteEnable]
	and     ebx,7
	shl     ebx,3
	mov     eax,dword [SP_Scheme+ebx]
	mov     dword [SPSlice0],eax
	mov     eax,dword [SP_Scheme+ebx+4]
	mov     dword [SPSlice1],eax
	pop     eax

%endmacro


%ifndef C_INITSPATH
;*
;* Starpath initialization
;*

; <-- from init.asm

Init_Starpath:
         mov     dword [SPSlice0],0
         mov     dword [SPSlice1],3*800h
         mov     byte [Starpath],0
         mov     byte [SP_WriteEnable],0
         mov     byte [SP_RamByte],0
         mov     byte [SP_PulseDelay],7
         mov     dword [SP_PrevAdr],0
        ret
%endif

; <-- from banks.asm

global SetStarpath
SetStarpath:
        push    ebx
         mov     dword [BSType],15
         mov     byte [Starpath],1
        mov     bl,0
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        pop     ebx
        ret

;*
;* Starpath exit routines
;*

StarpathLoadNotFound:
        popad
         mov     byte [MessageCode],1 ; Unable to find load
;       call    ShowMessage
        jmp     GoAway

StarpathRealJAM:
        popad
         mov     eax,dword [reg_pc]
         mov     dword [cpu_pc],eax
         mov     byte [MessageCode],2 ; Starpath call @
;       call    ShowMessage
        jmp     GoAway

;*
;* Starpath jam handler (game jumped to ROM)
;*

StarpathJAM:
        pushad
         mov     eax,dword [reg_pc]
        and     eax,01fffh
        cmp     eax,01ff0h
        jne near SPJ1
        push    esi
        mov     esi,000faH
        and     esi,0ffffh

         mov     byte [debugflag],1
        call    ReadHardware
         mov     byte [debugflag],0

         mov     al,byte [esi]
        pop     esi
         mov     byte [SC_ControlByte],al

        call    cli_LoadNextStarpath

         mov     eax,dword [SC_StartAddress]
        test    eax,eax
        je near StarpathLoadNotFound
         mov     dword [reg_pc],eax
         mov     bl,byte [SC_ControlByte] ; bank switch scheme at startup
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        popad
        ret

SPJ1:
        cmp     eax,01ff1h
        jne near StarpathRealJAM

        call    cli_ReloadStarpath

         mov     eax,dword [SC_StartAddress]
        test    eax,eax
        je near StarpathLoadNotFound
         mov     dword [reg_pc],eax
         mov     bl,byte [SC_ControlByte] ; bank switch scheme at startup
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        popad
        ret

;*
;* Starpath bankswitch macros
;*

%macro SP_MapSlice 0 ; u v
        push    ebx  ;  1
        mov     ebx,esi  ;  1
        and     esi,07ffh  ;  1   mask low order bits
        and     ebx,0800h  ;  1
        add     esi, CartRom  ;  1
        shr     ebx,9  ;  1     slice # we're in *4
         add     esi,dword [SPSlice0 + ebx] ; 2     point to proper ROM slice
        pop     ebx  ;  1
  ;  5-6
%endmacro


;*
;* write byte to ram
;*

%macro SP_WriteRam 0
; local ; done

         cmp     byte [SP_PulseDelay],5 ; pulse delay in range?
        jne near %%done  ;  no

        push    esi
        SP_MapSlice
         mov     bl,byte [SP_RamByte]

         mov     byte [SP_PulseDelay],7 ; cancel write in progress

         mov     byte [esi],bl ; write byte to memory
        pop     esi

         cmp     byte [TraceCount],0
        jz near %%done

        pushad
        call    ShowSCWrite
        popad

%%done:
%endmacro


;*
;* process current address
;*

%macro SP_Q_Adr 0
; local ; done, notbank, notrambyte, pulsedone, prevdone

        push    ebx

        and     esi,01fffh
         cmp     byte [SP_PulseDelay],5 ; write pending?
        ja near pulse%%done  ;  no
         cmp     esi,dword [SP_PrevAdr] ; a new memory address?
        je near prev%%done  ;  no, don't count it
         inc     byte [SP_PulseDelay] ; yes, count it
         mov     dword [SP_PrevAdr],esi ; remember address for next time...
prev%%done:
        test    esi,01000h  ;  adr in ROM?
        jz near %%done  ;  no

%%notrambyte:
        cmp     esi,01ff8h  ;  bankswitch request ?
        jne near %%notbank  ;  no

         mov     bl,byte [SP_RamByte] ; yes
        SP_SetScheme  ;  setup bankswitch scheme
         mov     byte [SP_PulseDelay],7 ; cancel any pending writes
        jmp     %%done

pulse%%done:
  ;  cmp     esi,01ff8h              ; bankswitch request ?
  ;  jne near notbank                 ;   no

  ;  mov     bl,[SP_RamByte]         ;   yes
  ;  SP_SetScheme                    ; setup bankswitch scheme
  ;  mov     [SP_PulseDelay],7       ; cancel any pending writes
  ;  jmp     done

  ;  notbank:
        test    esi,01000h  ;  adr in ROM?
        jz near %%done  ;  no

  ;  cmp     [SP_PulseDelay],5       ; write pending?
  ;  jbe near notrambyte              ;   yes, don't reset pulse delay
        cmp     esi,010ffh  ;  triggering a RAM write?
        ja near %%notrambyte  ;  no

         mov     dword [SP_RamWord],esi ; yes, adr is the byte to write
         mov     byte [SP_PulseDelay],0 ; start up the pulse delay counter
         mov     dword [SP_PrevAdr],esi ; set up prev address
        jmp     %%done

%%notbank:
         cmp     byte [SP_WriteEnable],0 ; write enabled?
        jz near %%done  ;  no

        SP_WriteRam  ;  yes, write byte to memory

%%done:
        pop     ebx

%endmacro


;*
;* actual bankswitch code
;*

RBank_SP:
         cmp     byte [debugflag],0 ; ignore memory cycles from disassembler
        jnz near debugread
        SP_Q_Adr
debugread:
        test_hw_read
        SP_MapSlice
        ret

WBank_SP:
        SP_Q_Adr
        test_hw_write
        ret




;
; $Log: starpath.asm,v $
; Revision 1.4  2004/05/19 01:00:57  urchlay
;
; SetupBanks() and associated routines moved to C.
;
; Revision 1.3  2004/05/18 02:17:16  urchlay
;
; Great Variable Migration from asm to C, partly complete.
;
; Revision 1.2  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
