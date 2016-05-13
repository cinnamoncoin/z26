;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


%ifdef C_TIASND
extern Init_Tiasnd
extern KidVid_Sound_Byte
extern TIA_Sound_Byte
extern H_AUDC0
extern H_AUDC1
extern H_AUDF0
extern H_AUDF1
extern H_AUDV0
extern H_AUDV1
%endif

%ifdef C_SQVARS
;;; used to be in soundq.asm, moved to c_core.c
extern SQ_Input
extern SQ_Output
extern SQ_Count
extern SQ_Top
%endif

%ifdef C_INITSERV
;;; used to be in service.asm, moved to c_core.c
extern Init_Service
%endif

%ifdef C_RANDRIOT
;;; used to be in riot.asm, moved to c_core.c
extern RandomizeRIOTTimer
extern Timer
%endif

%ifdef C_INITDATA
;;; used to be in init.asm, moved to c_core.c
extern InitData
extern RiotRam
extern TIA
extern Ram
extern Frame
extern PrevFrame
extern VBlanking
extern VBlank
extern VSyncFlag
extern ScanLine
extern OurBailoutLine
extern WByte
extern DisplayPointer
%endif

%ifdef C_POSGAME
extern TopLine
extern BottomLine
%endif

extern CartRom  ; byte
extern ScreenBuffer  ; dword
extern PCXPalette  ; byte
extern SoundQ  ; byte
extern SQ_Max  ; dword
extern CartSize  ; dword
extern Checksum  ; dword
extern XChecksum  ; dword
extern VideoMode  ; byte
extern CFirst  ; dword
extern quiet  ; byte
extern IOPortA  ; byte
extern IOPortA_Controllers  ; byte
extern IOPortA_UnusedBits  ; byte
extern IOPortB  ; byte
extern DoChecksum  ; byte
extern dsp  ; byte
extern Joystick  ; byte
extern PaletteNumber  ; byte
extern KeyBase  ; byte
extern TraceCount  ; byte
extern TraceEnabled  ; byte
extern OldTraceCount  ; byte
extern KeyPad  ; byte
extern Driving  ; byte
extern BSType  ; dword
extern MouseBase  ; byte
extern SimColourLoss  ; byte
extern Lightgun  ; byte
extern LGadjust  ; dword
extern Mindlink  ; byte
extern AllowAll4  ; byte
extern EnableFastCopy  ; byte
extern KidVid  ; byte
extern KidVidTape  ; byte
extern SampleByte  ; byte
extern kv_TapeBusy  ; dword
extern LinesInFrame  ; dword	; *EST*
extern PrevLinesInFrame  ; dword
extern VBlankOn  ; dword
extern VBlankOff  ; dword
extern BailoutLine  ; dword
extern MaxLines  ; dword
extern UserPaletteNumber  ; byte
extern SC_StartAddress  ; dword
extern SC_ControlByte  ; byte
extern p0_mask         ; byte
extern p1_mask         ; byte
extern m0_mask         ; byte
extern m1_mask         ; byte
extern bl_mask         ; byte
extern pf_mask        ; byte

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;
extern cpu_pc  ; dword
extern cpu_a  ; byte
extern cpu_carry  ; byte
extern cpu_x  ; byte
extern cpu_y  ; byte
extern cpu_sp  ; byte
extern cpu_ZTest  ; byte
extern cpu_NTest  ; byte
extern cpu_D  ; byte
extern cpu_V  ; byte
extern cpu_I  ; byte
extern cpu_B  ; byte
extern cpu_MAR  ; dword
extern cpu_Rbyte  ; byte
extern frame  ; dword
extern line  ; dword
extern cycle  ; byte
extern BL_Pos  ; dword
extern M0_Pos  ; dword
extern M1_Pos  ; dword
extern P0_Pos  ; dword
extern P1_Pos  ; dword
extern InitCVars  ; near
extern ShowRegisters  ; near
extern ShowInstruction  ; near
extern ShowWeird  ; near
extern ShowDeep  ; near
extern ShowVeryDeep  ; near
extern ShowAdjusted  ; near
extern ShowUndocTIA  ; near
extern ShowCollision  ; near
extern ShowSCWrite  ; near
extern cli_LoadNextStarpath  ; near
extern cli_ReloadStarpath  ; near
extern KoolAide  ; byte
extern RSBoxing  ; byte
extern UserCFirst  ; dword
extern DefaultCFirst  ; dword
extern MPdirection  ; byte
extern MinVol  ; byte
extern LG_WrapLine  ; byte
extern RecognizeCart  ; near
extern PCXWriteFile  ; near
extern kv_OpenSampleFile  ; near
extern kv_CloseSampleFile  ; near
extern kv_GetNextSampleByte  ; near
extern kv_SetNextSong  ; near
extern GeneratePalette  ; near
extern MessageCode  ; byte
extern srv_CreateScreen  ; near
extern srv_WindowScreen  ; near
extern srv_DestroyScreen  ; near
extern srv_CopyScreen  ; near
extern srv_Events  ; near
extern srv_Flip  ; near
extern srv_done  ; byte
extern KeyTable  ; byte
extern srv_get_mouse_movement  ; near
extern srv_get_mouse_button_status  ; near
extern srv_mouse_button  ; dword
extern srv_micky_x  ; dword
extern srv_micky_y  ; dword
extern emu_pixels  ; dword
extern screen_pixels  ; dword
extern emu_pixels_prev  ; dword
extern srv_SetPalette  ; near
extern srv_sound_on  ; near
extern srv_sound_off  ; near
extern DMABuf  ; dword
extern bufsize  ; dword
extern srv_lock_audio  ; near
extern srv_unlock_audio  ; near
extern ClearScreenBuffers  ; near
extern NoRetrace  ; dword
extern SyncToSoundBuffer  ; byte
extern ChargeTrigger0  ; dword
;EXTRN _ChargeTrigger1:dword
;EXTRN _ChargeTrigger2:dword
;EXTRN _ChargeTrigger3:dword
extern ChargeCounter  ; dword
extern DumpPorts  ; byte
extern InputLatch  ; byte
extern CM_Collumn  ; byte
extern ExitEmulator  ; byte
extern GamePaused  ; byte
extern OldCFirst  ; dword
extern Controls  ; near
extern InitCompuMate  ; near
extern ControlSWCHAWrite  ; near
extern TestLightgunHit  ; near
extern UpdateTrakBall  ; near
extern Seconds  ; dword


;
; $Log: extern.asm,v $
; Revision 1.7  2004/05/15 17:00:45  urchlay
;
; Initial incomplete implementation of TIA sound code in C. This isn't
; done yet, but at least compiles, and you can play Pitfall with it (but
; not Pitfall II).
;
; Revision 1.6  2004/05/15 15:36:13  urchlay
;
; The rest of the graphics can be disabled/enabled:
;
; Alt+key   Graphic
; Z         P0
; X         P1
; C         M0
; V         M1
; B         Ball
; N         Playfield (whole thing)
; /         Turns all of the above ON
;
; Revision 1.5  2004/05/14 20:03:17  urchlay
;
; We can enable/disable player 0 and player 1 graphics by pressing alt-z and
; alt-x, respectively. The default state (of course) is enabled.
;
; Revision 1.4  2004/05/09 00:38:29  urchlay
;
; Ported a few more functions to C. Tia_process() is still acting weird.
;
; Moved the C core defines to conf/c_core.mak, so we only have one place
; to modify them, no matter which target we're building for. Used
; `sinclude' to include it, which won't give an error if the file is
; missing entirely. It'll just not define any of the C core stuff.
;
; Revision 1.3  2004/05/08 18:06:57  urchlay
;
; Added Log tag to all C and asm source files.
;
;
