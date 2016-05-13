;*
;* z26 sound stuff
;*
;* it's up to the *operating system* to empty the sound queue
;* it's up to the z26 core to fill it up
;*
;
; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Subroutines in this file, status
; Init_SoundQ: ported (C_INITSQ)
; SQ_Test: ported (C_SQTEST)
; SQ_Store: ported (C_SQSTORE)
; QueueSoundBytes: ported (C_QSBYTES)
; QueueSoundByte: ported (C_QSBYTE)
; Tia_Process: ported, but has issues (C_TIAPROC)

[section .data]

%ifndef C_SQVARS

; make them global in case C code needs them
global SQ_Input
global SQ_Output
global SQ_Count
global SQ_Top

;_SQ_Max		dd	3072*3
SQ_Start:  ; byte		; <-- start clearing here

SQ_Input	dd  0	 ;  point to next avail byte for storing
SQ_Output	dd  0	 ;  point to next avail byte for fetching
SQ_Count	dd  0
SQ_Top		dd  0

;SQ_MAX = 3072*3			; 3072, 1024

;_SoundQ	times 65000 db 0
SQ_End:  ; byte			; <-- finish clearing here

%endif

[section .code]

;*
;* Initialize sound queue
;*

%ifndef C_INITSQ
Init_SoundQ:

%ifndef C_SQVARS
; only use clear_mem if the vars are defined in asm
; (otherwise, the C code handles it)
	clear_mem  SQ_Start,  SQ_End
%endif

 	mov	dword [SQ_Input], SoundQ ; initialize sound queue stuff
 	mov	dword [SQ_Output], SoundQ
 	mov	dword [SQ_Count],0
	mov	eax, SoundQ
	inc	eax
 	add	eax,dword [SQ_Max]
 	mov	dword [SQ_Top],eax
;	mov	[SQ_Top], SoundQ + SQ_MAX + 1

	ret
%endif

;*
;* routine to get status of sound queue
;*
;* returns:
;*
;*    -1 if sound queue full and no room for more output
;*     0 if there's too much room      (less than 1/2 full)
;*     1 if there's just enough room   (more than 1/2 full)
;*

%ifdef C_SQTEST
extern SQ_Test
%else
global SQ_Test
SQ_Test:
 	cmp	byte [quiet],0 ; doing sound at all?
	jnz near SQ_Just_Right		 ;    no, pretend queue is *just right*

 	mov	eax,dword [SQ_Max]
 	cmp	dword [SQ_Count],eax ; sound queue already full?
	jae near SQ_Full			 ;    yes, don't queue anything
	shr	eax,1
 	cmp	dword [SQ_Count],eax ; less than 1/2 full?
	jbe near SQ_Empty		 ;    yes

SQ_Just_Right:
	mov	eax,1			 ;    no
	ret

SQ_Empty:
	mov	eax,0
	ret

SQ_Full:
	mov	eax,-1
	ret
%endif

%ifdef C_SQSTORE
extern SQ_Store
%else
;*
;* routine to put byte in al in the sound queue
;* always make sure SQ_Count < SQ_MAX before calling
;*

SQ_Store:

 	cmp	byte [quiet],0 ; doing sound at all?
	jnz near SQS_skip_store		 ;    no, don't store sound byte

%ifdef LOCK_AUDIO_SQ
	pushad
	call	srv_lock_audio
	popad
%endif

 	mov	esi,dword [SQ_Input]
 	mov	byte [esi],al
	inc	esi
 	inc	dword [SQ_Count]
 	cmp	esi,dword [SQ_Top]
	jb near SQS_done
	mov	esi, SoundQ
SQS_done:
 	mov	dword [SQ_Input],esi

%ifdef LOCK_AUDIO_SQ
	pushad
	call	srv_unlock_audio
	popad
%endif

SQS_skip_store:
	ret
%endif

%ifdef C_TIAPROC
extern Tia_process
%else

;*
;* routine to put the sound in the sound buffer
;*
global Tia_process

Tia_process:
	pushad
 	mov	eax,dword [bufsize]
 	cmp	dword [SQ_Count],eax ; enough sound available?
	ja near Sound_Enough		 ;    yes

	pushad				 ;    no, make sure there's enough
	call	QueueSoundBytes
	popad

Sound_Enough:
 	mov	ecx,dword [bufsize] ; # of bytes

 	mov	edi,dword [DMABuf]
 	mov	esi,dword [SQ_Output]

SoundFillLoop:
 	mov	al,byte [esi]
	inc	esi
 	cmp	esi,dword [SQ_Top]
	jb near SF_done
	mov	esi, SoundQ
SF_done: mov	byte [edi],al ; put it in soundblaster buffer
	inc	edi
	dec	ecx			 ;  more room in soundblaster buffer?
	jnz near SoundFillLoop		 ;    yes, get more

 	mov	eax,dword [bufsize]
 	sub	dword [SQ_Count],eax
 	mov	dword [SQ_Output],esi
	
SoundBufferBail:
	popad
	ret

%endif

;*
;* put a byte in the sound queue
;*

%ifdef C_QSBYTE
extern QueueSoundByte
%else
global QueueSoundByte
QueueSoundByte:
; Happily, C calling conventions use eax for a function's
; return value. The asm version of SQ_Test also uses eax
; for its return value, so we don't have to change anything
; here where we call whichever version is compiled in.

	call	SQ_Test
	cmp	eax,-1			 ;  sound queue already full?
	jne near QSB_room		 ;    no, there's room

;        cmp     [NoRetrace],-1         ; synchronizing to monitor?

	cmp     byte [SyncToSoundBuffer],1 ; syncronizing to sound buffer?
	jne near SoundQueueFull           ;    no, don't queue anything

	pushad				 ;    no, wait for room
	call	srv_Events ; I think you're not supposed to call this from the callback
	popad
	jmp	QueueSoundByte

QSB_room:
	call	KidVid_Sound_Byte	 ;    no, get kidvid sample
	push	eax
	call	TIA_Sound_Byte		 ;  get TIA sample
	pop	ebx			 ;  kidvid sample

	add     eax,ebx			 ;  mix the samples
	shr     eax,1

%ifdef C_SQSTORE
; Conform to C calling conventions, if we're calling the
; C version of SQ_Store().
	push eax
%endif

	call	SQ_Store		 ;  put it in the sound queue

%ifdef C_SQSTORE
	pop eax
%endif

SoundQueueFull:
	ret
%endif

%ifdef C_QSBYTES
extern QueueSoundBytes
%else
global QueueSoundBytes
;*
;* put sound bytes into buffer
;* called once per scan line
;*

QueueSoundBytes:  ;  proc near


SoundQueueLoop:
	call	QueueSoundByte
	call	QueueSoundByte

	call	SQ_Test
	cmp	eax,0			 ;  sound queue at least 1/2 full?
	je near SoundQueueLoop		 ;    no

	ret

; QueueSoundBytes endp

%endif



;
; $Log: soundq.asm,v $
; Revision 1.4  2004/05/09 00:38:29  urchlay
;
; Ported a few more functions to C. Tia_process() is still acting weird.
;
; Moved the C core defines to conf/c_core.mak, so we only have one place
; to modify them, no matter which target we're building for. Used
; `sinclude' to include it, which won't give an error if the file is
; missing entirely. It'll just not define any of the C core stuff.
;
; Revision 1.3  2004/05/08 18:06:58  urchlay
;
; Added Log tag to all C and asm source files.
;
;
