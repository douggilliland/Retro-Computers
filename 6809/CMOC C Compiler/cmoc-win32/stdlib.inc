* stdlib.inc - Standard CMOC library.
*
* By Pierre Sarrazin <http://sarrazip.com/>.
* This file is in the public domain.

stdlib_start:


#if defined(OS9)
#define DAT Y  /* CMOC uses Y to point to the data segment of the current process. */
#else
#define DAT PCR  /* The data segment at a fixed offset of the code segment. */
#endif

#if defined(OS9)
* OS-9 System calls.
F$Exit		equ	$06	Terminate Process
F$Sleep		equ	$0A	Suspend Process
I$Write		equ	$8A	Write Data
I$ReadLn	equ	$8B	Read Line of ASCII Data
I$WritLn	equ	$8C	Write Line of ASCII Data
#endif


* /*
* Initialize the standard library.
; Input: D = minus the number of bytes for the stack space (e.g., -1024 for 1k stack).
* Saves the initial stack for use by exit().
* Initializes internal variables used by sbrk().
* Initializes the seed of the random number generator with a fixed value.
* Initializes the null pointer and stack overflow handler pointers.
* Initializes CHROUT, which points to the system's character output routine.
* Initializes the global variables.
* */
*
INILIB
	IFNDEF OS9
; Zero out "BSS" segment.
; Must be done first, because code that follows initializes INISTK, etc.
        LDX     #bss_end-bss_start      ; number of bytes in "bss" section
        BEQ     @done
        LEAU    bss_start,pcr           ; address of "bss" section
@loop
        CLR     ,U+
        LEAX    -1,X
        BNE     @loop
@done
        ENDC

	LEAX	2,S			X = initial stack pointer
	STX	INISTK,DAT		save this for exit()

	LEAX	D,X			point to top of stack space
	STX	end_of_sbrk_mem,DAT	sbrk() will not allocate past this
	LEAX	program_end,PCR		end of generated code
	STX	program_break,DAT	initial Unix-like "program break" (cf sbrk)

#if defined(_CMOC_NEED_rand_) || defined(_CMOC_NEED_srand_)
	CLR	SEED,DAT
	CLR	SEED+1,DAT
#endif

#ifdef _CMOC_CHECK_NULL_POINTERS_
	LEAX	nop_handler,PCR
	STX	null_ptr_handler,DAT
#endif

#ifdef _CMOC_CHECK_STACK_OVERFLOW_
	LDX	#0
	STX	stack_overflow_handler,DAT	
#endif

#if defined(_CMOC_NEED_putchar_) || defined(_CMOC_NEED_putstr_) || defined(_CMOC_NEED_sprintf_) || defined(_CMOC_NEED_printf_)
#ifdef _COCO_BASIC_  /* CoCo's Extended Color Basic */
	LDX	$A002		/* system's current address for PUTCHR */
#else
	LEAX	PUTCHR,PCR
#endif
	STX	CHROUT,DAT
#endif

	LBRA	INITGL		initialize global variables


* void exit(int exitStatus);
*
* Clean up before returning control to the host environment.
* That environment does not necessarily use the exit status.
* It may only use the low byte.
*
* MUST be called by BSR, LBSR or JSR, not jumped to with BRA, LBRA or JMP,
* so that 2,S can be used to get 'exitStatus'.
*
_exit

#ifdef _COCO_BASIC_

#if defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_)

* Zero out the LINBUF line buffer.  This seems necessary to avoid
* ?SN ERROR after program execution on the CoCo.
	LDX	#LINBUF
EXIT10	CLR	,X+
	CMPX	#LINBUF+1+LBUFMX
	BLO	EXIT10

#endif

	LDS	INISTK,DAT	retrieve stack pointer saved at beginning
	RTS

#elif defined(OS9)

        ldb     3,s             get LSB of exit() argument
	os9	F$Exit

#elif defined(USIM)  /* 6809 simulator */

	SYNC			to leave usim

#elif defined(VECTREX)

	BRA	_exit	The eternal Vectrex loop on exit...

#else

#error Undefined target platform.

#endif

#if defined(VECTREX)
* VECTREX BIOS
Vec_Snd_Shadow  EQU     $C800   ;Shadow of sound chip registers (15 bytes)
Vec_Btn_State   EQU     $C80F   ;Current state of all joystick buttons
Vec_Prev_Btns   EQU     $C810   ;Previous state of all joystick buttons
Vec_Buttons     EQU     $C811   ;Current toggle state of all buttons
Vec_Button_1_1  EQU     $C812   ;Current toggle state of stick 1 button 1
Vec_Button_1_2  EQU     $C813   ;Current toggle state of stick 1 button 2
Vec_Button_1_3  EQU     $C814   ;Current toggle state of stick 1 button 3
Vec_Button_1_4  EQU     $C815   ;Current toggle state of stick 1 button 4
Vec_Button_2_1  EQU     $C816   ;Current toggle state of stick 2 button 1
Vec_Button_2_2  EQU     $C817   ;Current toggle state of stick 2 button 2
Vec_Button_2_3  EQU     $C818   ;Current toggle state of stick 2 button 3
Vec_Button_2_4  EQU     $C819   ;Current toggle state of stick 2 button 4
Vec_Joy_Resltn  EQU     $C81A   ;Joystick A/D resolution (0x80=min 0x00=max)
Vec_Joy_1_X     EQU     $C81B   ;Joystick 1 left/right
Vec_Joy_1_Y     EQU     $C81C   ;Joystick 1 up/down
Vec_Joy_2_X     EQU     $C81D   ;Joystick 2 left/right
Vec_Joy_2_Y     EQU     $C81E   ;Joystick 2 up/down
Vec_Joy_Mux     EQU     $C81F   ;Joystick enable/mux flags (4 bytes)
Vec_Joy_Mux_1_X EQU     $C81F   ;Joystick 1 X enable/mux flag (=1)
Vec_Joy_Mux_1_Y EQU     $C820   ;Joystick 1 Y enable/mux flag (=3)
Vec_Joy_Mux_2_X EQU     $C821   ;Joystick 2 X enable/mux flag (=5)
Vec_Joy_Mux_2_Y EQU     $C822   ;Joystick 2 Y enable/mux flag (=7)
Vec_Misc_Count  EQU     $C823   ;Misc counter/flag byte, zero when not in use
Vec_0Ref_Enable EQU     $C824   ;Check0Ref enable flag
Vec_Loop_Count  EQU     $C825   ;Loop counter word (incremented in Wait_Recal)
Vec_Brightness  EQU     $C827   ;Default brightness
Vec_Dot_Dwell   EQU     $C828   ;Dot dwell time?
Vec_Pattern     EQU     $C829   ;Dot pattern (bits)
Vec_Text_HW     EQU     $C82A   ;Default text height and width
Vec_Text_Height EQU     $C82A   ;Default text height
Vec_Text_Width  EQU     $C82B   ;Default text width
Vec_Str_Ptr     EQU     $C82C   ;Temporary string pointer for Print_Str
Vec_Counters    EQU     $C82E   ;Six bytes of counters
Vec_Counter_1   EQU     $C82E   ;First  counter byte
Vec_Counter_2   EQU     $C82F   ;Second counter byte
Vec_Counter_3   EQU     $C830   ;Third  counter byte
Vec_Counter_4   EQU     $C831   ;Fourth counter byte
Vec_Counter_5   EQU     $C832   ;Fifth  counter byte
Vec_Counter_6   EQU     $C833   ;Sixth  counter byte
Vec_RiseRun_Tmp EQU     $C834   ;Temp storage word for rise/run
Vec_Angle       EQU     $C836   ;Angle for rise/run and rotation calculations
Vec_Run_Index   EQU     $C837   ;Index pair for run
;*                      $C839   ;Pointer to copyright string during startup
Vec_Rise_Index  EQU     $C839   ;Index pair for rise
;*                      $C83B   ;High score cold-start flag (=0 if valid)
Vec_RiseRun_Len EQU     $C83B   ;length for rise/run
;*                      $C83C   ;temp byte
Vec_Rfrsh       EQU     $C83D   ;Refresh time (divided by 1.5MHz)
Vec_Rfrsh_lo    EQU     $C83D   ;Refresh time low byte
Vec_Rfrsh_hi    EQU     $C83E   ;Refresh time high byte
Vec_Music_Work  EQU     $C83F   ;Music work buffer (14 bytes, backwards?)
Vec_Music_Wk_A  EQU     $C842   ;        register 10
;*                      $C843   ;        register 9
;*                      $C844   ;        register 8
Vec_Music_Wk_7  EQU     $C845   ;        register 7
Vec_Music_Wk_6  EQU     $C846   ;        register 6
Vec_Music_Wk_5  EQU     $C847   ;        register 5
;*                      $C848   ;        register 4
;*                      $C849   ;        register 3
;*                      $C84A   ;        register 2
Vec_Music_Wk_1  EQU     $C84B   ;        register 1
;*                      $C84C   ;        register 0
Vec_Freq_Table  EQU     $C84D   ;Pointer to note-to-fr.EQUency table (normally 0xFC8D)
Vec_Max_Players EQU     $C84F   ;Maximum number of players for Select_Game
Vec_Max_Games   EQU     $C850   ;Maximum number of games for Select_Game
Vec_ADSR_Table  EQU     $C84F   ;Storage for first music header word (ADSR table)
Vec_Twang_Table EQU     $C851   ;Storage for second music header word ('twang' table)
Vec_Music_Ptr   EQU     $C853   ;Music data pointer
Vec_Expl_ChanA  EQU     $C853   ;Used by Explosion_Snd - bit for first channel used?
Vec_Expl_Chans  EQU     $C854   ;Used by Explosion_Snd - bits for all channels used?
Vec_Music_Chan  EQU     $C855   ;Current sound channel number for Init_Music
Vec_Music_Flag  EQU     $C856   ;Music active flag (0x00=off 0x01=start 0x80=on)
Vec_Duration    EQU     $C857   ;Duration counter for Init_Music
Vec_Music_Twang EQU     $C858   ;3 word 'twang' table used by Init_Music
Vec_Expl_1      EQU     $C858   ;Four bytes copied from Explosion_Snds U-reg parameters
Vec_Expl_2      EQU     $C859   ;
Vec_Expl_3      EQU     $C85A   ;
Vec_Expl_4      EQU     $C85B   ;
Vec_Expl_Chan   EQU     $C85C   ;Used by Explosion_Snd - channel number in use?
Vec_Expl_ChanB  EQU     $C85D   ;Used by Explosion_Snd - bit for second channel used?
Vec_ADSR_Timers EQU     $C85E   ;ADSR timers for each sound channel (3 bytes)
Vec_Music_Freq  EQU     $C861   ;Storage for base fr.EQUency of each channel (3 words)
;*                      $C85E   ;Scratch 'score' storage for Display_Option (7 bytes)
Vec_Expl_Flag   EQU     $C867   ;Explosion_Snd initialization flag?
;*              $C868...0xC876   ;Unused?
Vec_Expl_Timer  EQU     $C877   ;Used by Explosion_Snd
;*                      $C878   ;Unused?
Vec_Num_Players EQU     $C879   ;Number of players selected in Select_Game
Vec_Num_Game    EQU     $C87A   ;Game number selected in Select_Game
Vec_Seed_Ptr    EQU     $C87B   ;Pointer to 3-byte random number seed (=0xC87D)
Vec_Random_Seed EQU     $C87D   ;Default 3-byte random number seed
                                ;
;*    $C880 - 0xCBEA is user RAM  ;
                                ;
Vec_Default_Stk EQU     $CBEA   ;Default top-of-stack
Vec_High_Score  EQU     $CBEB   ;High score storage (7 bytes)
Vec_SWI3_Vector EQU     $CBF2   ;SWI2/SWI3 interrupt vector (3 bytes)
Vec_SWI2_Vector EQU     $CBF2   ;SWI2/SWI3 interrupt vector (3 bytes)
Vec_FIRQ_Vector EQU     $CBF5   ;FIRQ interrupt vector (3 bytes)
Vec_IRQ_Vector  EQU     $CBF8   ;IRQ interrupt vector (3 bytes)
Vec_SWI_Vector  EQU     $CBFB   ;SWI/NMI interrupt vector (3 bytes)
Vec_NMI_Vector  EQU     $CBFB   ;SWI/NMI interrupt vector (3 bytes)
Vec_Cold_Flag   EQU     $CBFE   ;Cold start flag (warm start if = 0x7321)
                                ;
VIA_port_b      EQU     $D000   ;VIA port B data I/O register
;*       0 sample/hold (0=enable  mux 1=disable mux)
;*       1 mux sel 0
;*       2 mux sel 1
;*       3 sound BC1
;*       4 sound BDIR
;*       5 comparator input
;*       6 external device (slot pin 35) initialized to input
;*       7 /RAMP
VIA_port_a      EQU     $D001   ;VIA port A data I/O register (handshaking)
VIA_DDR_b       EQU     $D002   ;VIA port B data direction register (0=input 1=output)
VIA_DDR_a       EQU     $D003   ;VIA port A data direction register (0=input 1=output)
VIA_t1_cnt_lo   EQU     $D004   ;VIA timer 1 count register lo (scale factor)
VIA_t1_cnt_hi   EQU     $D005   ;VIA timer 1 count register hi
VIA_t1_lch_lo   EQU     $D006   ;VIA timer 1 latch register lo
VIA_t1_lch_hi   EQU     $D007   ;VIA timer 1 latch register hi
VIA_t2_lo       EQU     $D008   ;VIA timer 2 count/latch register lo (refresh)
VIA_t2_hi       EQU     $D009   ;VIA timer 2 count/latch register hi
VIA_shift_reg   EQU     $D00A   ;VIA shift register
VIA_aux_cntl    EQU     $D00B   ;VIA auxiliary control register
;*       0 PA latch enable
;*       1 PB latch enable
;*       2 \                     110=output to CB2 under control of phase 2 clock
;*       3  > shift register control     (110 is the only mode used by the Vectrex ROM)
;*       4 /
;*       5 0=t2 one shot                 1=t2 free running
;*       6 0=t1 one shot                 1=t1 free running
;*       7 0=t1 disable PB7 output       1=t1 enable PB7 output
VIA_cntl        EQU     $D00C   ;VIA control register
;*       0 CA1 control     CA1 -> SW7    0=IRQ on low 1=IRQ on high
;*       1 \
;*       2  > CA2 control  CA2 -> /ZERO  110=low 111=high
;*       3 /
;*       4 CB1 control     CB1 -> NC     0=IRQ on low 1=IRQ on high
;*       5 \
;*       6  > CB2 control  CB2 -> /BLANK 110=low 111=high
;*       7 /
VIA_int_flags   EQU     $D00D   ;VIA interrupt flags register
;*               bit                             cleared by
;*       0 CA2 interrupt flag            reading or writing port A I/O
;*       1 CA1 interrupt flag            reading or writing port A I/O
;*       2 shift register interrupt flag reading or writing shift register
;*       3 CB2 interrupt flag            reading or writing port B I/O
;*       4 CB1 interrupt flag            reading or writing port A I/O
;*       5 timer 2 interrupt flag        read t2 low or write t2 high
;*       6 timer 1 interrupt flag        read t1 count low or write t1 high
;*       7 IRQ status flag               write logic 0 to IER or IFR bit
VIA_int_enable  EQU     $D00E   ;VIA interrupt enable register
;*       0 CA2 interrupt enable
;*       1 CA1 interrupt enable
;*       2 shift register interrupt enable
;*       3 CB2 interrupt enable
;*       4 CB1 interrupt enable
;*       5 timer 2 interrupt enable
;*       6 timer 1 interrupt enable
;*       7 IER set/clear control
VIA_port_a_nohs EQU     $D00F   ;VIA port A data I/O register (no handshaking)

Cold_Start      EQU     $F000   ;
Warm_Start      EQU     $F06C   ;
Init_VIA        EQU     $F14C   ;
Init_OS_RAM     EQU     $F164   ;
Init_OS         EQU     $F18B   ;
Wait_Recal      EQU     $F192   ;
Set_Refresh     EQU     $F1A2   ;
DP_to_D0        EQU     $F1AA   ;
DP_to_C8        EQU     $F1AF   ;
Read_Btns_Mask  EQU     $F1B4   ;
Read_Btns       EQU     $F1BA   ;
Joy_Analog      EQU     $F1F5   ;
Joy_Digital     EQU     $F1F8   ;
Sound_Byte      EQU     $F256   ;
Sound_Byte_x    EQU     $F259   ;
Sound_Byte_raw  EQU     $F25B   ;
Clear_Sound     EQU     $F272   ;
Sound_Bytes     EQU     $F27D   ;
Sound_Bytes_x   EQU     $F284   ;
Do_Sound        EQU     $F289   ;
Do_Sound_x      EQU     $F28C   ;
Intensity_1F    EQU     $F29D   ;
Intensity_3F    EQU     $F2A1   ;
Intensity_5F    EQU     $F2A5   ;
Intensity_7F    EQU     $F2A9   ;
Intensity_a     EQU     $F2AB   ;
Dot_ix_b        EQU     $F2BE   ;
Dot_ix          EQU     $F2C1   ;
Dot_d           EQU     $F2C3   ;
Dot_here        EQU     $F2C5   ;
Dot_List        EQU     $F2D5   ;
Dot_List_Reset  EQU     $F2DE   ;
Recalibrate     EQU     $F2E6   ;
Moveto_x_7F     EQU     $F2F2   ;
Moveto_d_7F     EQU     $F2FC   ;
Moveto_ix_FF    EQU     $F308   ;
Moveto_ix_7F    EQU     $F30C   ;
Moveto_ix_b     EQU     $F30E   ; Used to be named Moveto_ix_a but this is wrong.
Moveto_ix       EQU     $F310   ;
Moveto_d        EQU     $F312   ;
Reset0Ref_D0    EQU     $F34A   ;
Check0Ref       EQU     $F34F   ;
Reset0Ref       EQU     $F354   ;
Reset_Pen       EQU     $F35B   ;
Reset0Int       EQU     $F36B   ;
Print_Str_hwyx  EQU     $F373   ;
Print_Str_yx    EQU     $F378   ;
Print_Str_d     EQU     $F37A   ;
Print_List_hw   EQU     $F385   ;
Print_List      EQU     $F38A   ;
Print_List_chk  EQU     $F38C   ;
Print_Ships_x   EQU     $F391   ;
Print_Ships     EQU     $F393   ;
Mov_Draw_VLc_a  EQU     $F3AD   ;count y x y x ...
Mov_Draw_VL_b   EQU     $F3B1   ;y x y x ...
Mov_Draw_VLcs   EQU     $F3B5   ;count scale y x y x ...
Mov_Draw_VL_ab  EQU     $F3B7   ;y x y x ...
Mov_Draw_VL_a   EQU     $F3B9   ;y x y x ...
Mov_Draw_VL     EQU     $F3BC   ;y x y x ...
Mov_Draw_VL_d   EQU     $F3BE   ;y x y x ...
Draw_VLc        EQU     $F3CE   ;count y x y x ...
Draw_VL_b       EQU     $F3D2   ;y x y x ...
Draw_VLcs       EQU     $F3D6   ;count scale y x y x ...
Draw_VL_ab      EQU     $F3D8   ;y x y x ...
Draw_VL_a       EQU     $F3DA   ;y x y x ...
Draw_VL         EQU     $F3DD   ;y x y x ...
Draw_Line_d     EQU     $F3DF   ;y x y x ...
Draw_VLp_FF     EQU     $F404   ;pattern y x pattern y x ... 0x01
Draw_VLp_7F     EQU     $F408   ;pattern y x pattern y x ... 0x01
Draw_VLp_scale  EQU     $F40C   ;scale pattern y x pattern y x ... 0x01
Draw_VLp_b      EQU     $F40E   ;pattern y x pattern y x ... 0x01
Draw_VLp        EQU     $F410   ;pattern y x pattern y x ... 0x01
Draw_Pat_VL_a   EQU     $F434   ;y x y x ...
Draw_Pat_VL     EQU     $F437   ;y x y x ...
Draw_Pat_VL_d   EQU     $F439   ;y x y x ...
Draw_VL_mode    EQU     $F46E   ;mode y x mode y x ... 0x01
Print_Str       EQU     $F495   ;
Random_3        EQU     $F511   ;
Random          EQU     $F517   ;
Init_Music_Buf  EQU     $F533   ;
Clear_x_b       EQU     $F53F   ;
Clear_C8_RAM    EQU     $F542   ;never used by GCE carts?
Clear_x_256     EQU     $F545   ;
Clear_x_d       EQU     $F548   ;
Clear_x_b_80    EQU     $F550   ;
Clear_x_b_a     EQU     $F552   ;
Dec_3_Counters  EQU     $F55A   ;
Dec_6_Counters  EQU     $F55E   ;
Dec_Counters    EQU     $F563   ;
Delay_3         EQU     $F56D   ;30 cycles
Delay_2         EQU     $F571   ;25 cycles
Delay_1         EQU     $F575   ;20 cycles
Delay_0         EQU     $F579   ;12 cycles
Delay_b         EQU     $F57A   ;5*B + 10 cycles
Delay_RTS       EQU     $F57D   ;5 cycles
Bitmask_a       EQU     $F57E   ;
Abs_a_b         EQU     $F584   ;
Abs_b           EQU     $F58B   ;
Rise_Run_Angle  EQU     $F593   ;
Get_Rise_Idx    EQU     $F5D9   ;
Get_Run_Idx     EQU     $F5DB   ;
Get_Rise_Run    EQU     $F5EF   ;
Rise_Run_X      EQU     $F5FF   ;
Rise_Run_Y      EQU     $F601   ;
Rise_Run_Len    EQU     $F603   ;
Rot_VL_ab       EQU     $F610   ;
Rot_VL          EQU     $F616   ;
Rot_VL_Mode_a   EQU     $F61F   ;
Rot_VL_Mode     EQU     $F62B   ;
Rot_VL_dft      EQU     $F637   ;
Xform_Run_a     EQU     $F65B   ;
Xform_Run       EQU     $F65D   ;
Xform_Rise_a    EQU     $F661   ;
Xform_Rise      EQU     $F663   ;
Move_Mem_a_1    EQU     $F67F   ;
Move_Mem_a      EQU     $F683   ;
Init_Music_chk  EQU     $F687   ;
Init_Music      EQU     $F68D   ;
Init_Music_x    EQU     $F692   ;
Select_Game     EQU     $F7A9   ;
Clear_Score     EQU     $F84F   ;
Add_Score_a     EQU     $F85E   ;
Add_Score_d     EQU     $F87C   ;
Strip_Zeros     EQU     $F8B7   ;
Compare_Score   EQU     $F8C7   ;
New_High_Score  EQU     $F8D8   ;
Obj_Will_Hit_u  EQU     $F8E5   ;
Obj_Will_Hit    EQU     $F8F3   ;
Obj_Hit         EQU     $F8FF   ;
Explosion_Snd   EQU     $F92E   ;
Draw_Grid_VL    EQU     $FF9F   ;

Char_Table      EQU     $F9F4   ; Char_Table 
Char_Table_End  EQU     $FBD4   ; Char_Table_End 

vx_music_1      EQU     $FD0D   ; Poweron music, crazy coaster and narrow escape
vx_music_2      EQU     $FD1D   ; Music for Berzerk 
vx_music_3      EQU     $FD81
vx_music_4      EQU     $FDD3   ; Music for Scramble 
vx_music_5      EQU     $FE38   ; Music for Solar Quest 
vx_music_6      EQU     $FE76
vx_music_7      EQU     $FEC6
vx_music_8      EQU     $FEF8   ; Music for Melody Master 
vx_music_9      EQU     $FF26
vx_music_10     EQU     $FF44
vx_music_11     EQU     $FF62
vx_music_12     EQU     $FF7A
vx_music_13     EQU     $FF8F

#endif  /* defined(VECTREX) */

nop_handler:
	RTS


* NOTE on _CMOC_NEED_*_ identifiers.
* Each C function declared in <cmoc.h> should be mentioned in the
* stdLibTable[] array of FunctionCallExpr::emitCode(). Then, its body
* in this file should be delimited by #ifdef _CMOC_NEED_<CFunctionName>_.
*
* MUL16 however is not a C function. It is a utility function. Whenever
* a call to such a function is emitted, it should be emitted using
* callUtility(), and its body in this file should be delimited by
* #ifdef _CMOC_NEED_<UtilityFunctionName>_. Utility function names
* must NOT be mentioned in stdLibTable[].
*
* Note the leading and trailing underscore character.
*
#ifdef _CMOC_NEED_MUL16_

* Multiply D by X, unsigned; return result in D; preserve X.
MUL16	PSHS	U,X,B,A		U pushed to create 2 temp bytes at 4,S
	LDB	3,S		low byte of original X
	MUL
	STD	4,S		keep for later
	LDD	1,S		low byte of orig D, high byte of orig X
	MUL
	ADDB	5,S		only low byte is needed
	STB	5,S
	LDA	1,S		low byte of orig D
	LDB	3,S		low byte of orig X
	MUL
	ADDA	5,S
	LEAS	6,S
	RTS

#endif  /* _CMOC_NEED_MUL16_ */


#ifdef _CMOC_NEED_mulww_

* Multiply D by X, unsigned; return 32-bit result in D (high 16 bits)
* and X (low 16 bits).
*
MUL168_TO32
	pshs	x,b,a
	clr	,-s		allocate 4 bytes to store 24-bit product
	clr	,-s
	clr	,-s
	clr	,-s

	lda	7,s		low byte of X
	mul			mul by B
	std	2,s		low 16-bit of 32-bit storage

	ldd	5,s		original B in A, high byte of X in B
	mul

	addd	1,s		add D to middle 16 bits of storage
	pshs	cc		preserve carry
	std	2,s		store sum in middle 16 bits of storage
	puls	b
	andb	#1		carry from sum
	stb	,s		store carry in high byte of storage

	lda	4,s		original A
	ldb	7,s		low byte of X
	mul
	addd	1,s		add D to middle 16 bits of storage
	pshs	cc		preserve carry
	std	2,s		store sum in middle 16 bits of storage
	puls	b
	andb	#1		carry from sum
	addb	,s		add carry to high byte of storage
	stb	,s

	lda	4,s		original A
	ldb	6,s		high byte of X
	mul
	addd	,s		add D to high word of storage
	std	,s		drop carry

	ldx	2,s		return low word of product in X

	leas	8,s
	rts


* word mulww(word *productHi, word u, word v)
*
* Multiples u by v to obtain a 32-bit product.
* Stores the high word of the product in *productHi,
* and returns the low word of the product.
*
_mulww
	pshs	u
	tfr	s,u

	ldx	6,u	load u
	ldd	8,u	load v
	bsr	MUL168_TO32
	pshs	x	preserve low word of product
	ldx	4,u	get productHi pointer
	std	,x	return high byte of product
	puls	a,b	retrieve and return low word of product

	tfr	u,s
	puls	u,pc

#endif  /* _CMOC_NEED_mulww_ */


#ifdef _CMOC_NEED_mulwb_

* Multiply B by X, unsigned; return 24-bit result in B (high 8 bits)
* and X (low 16 bits). Register A preserved.
MUL168_TO24
	pshs	x,b,a
	clr	,-s		allocate 3 bytes to store 24-bit product
	clr	,-s
	clr	,-s

	lda	6,s		low byte of X
	mul
	std	1,s		low 16-bit of 24-bit storage

	ldd	4,s		original B in A, high byte of X in B
	mul

	addd	,s		add D to high 16 bits of storage
	std	,s

	ldb	,s
	ldx	1,s

	lda	3,s		restore orignal A
	leas	7,s
	rts


* word mulwb(byte *productHi, word w, byte b)
*
* Multiples w by b to obtain a 24-bit product.
* Stores the high byte of the product in *productHi,
* and returns the low word of the product.
*
_mulwb
	pshs	u
	tfr	s,u

	ldx	6,u	load w
	ldb	9,u	load b
	bsr	MUL168_TO24
	pshs	x	preserve low word of product
	ldx	4,u	get productHi pointer
	stb	,x	return high byte of product
	puls	a,b	retrieve and return low word of product

	tfr	u,s
	puls	u,pc

#endif  /* _CMOC_NEED_mulwb_ */


#ifdef _CMOC_NEED_zerodw_

* void zerodw(word *dw)
*
_zerodw
	ldx	2,s	load dw to point to double word
	clra
	clrb
	std	,x
	std	2,x
	rts

#endif  /* _CMOC_NEED_zerodw_ */


#ifdef _CMOC_NEED_adddww_

* void adddww(word *dw, word w)
*
_adddww
	ldx	2,s	load dw to point to double word
	ldd	2,x	low word of dword
	addd	4,s	add w: affects carry flag
	std	2,x	store low word of result (does not affect carry flag)
	ldd	,x	load high word of dword (does not affect carry flag)
	adcb	#0	add possible carry from add of low word with w
	adca	#0	add possible carry from adcb
	std	,x
	rts

#endif  /* _CMOC_NEED_adddww_ */


#ifdef _CMOC_NEED_subdww_

* void subdww(word *dw, word w)
*
_subdww
	ldx	2,s	load dw to point to double word
	ldd	2,x	low word of dword
	subd	4,s	sub w: affects carry flag
	std	2,x	store low word of result (does not affect carry flag)
	ldd	,x	load high word of dword (does not affect carry flag)
	sbcb	#0	sub possible borrow from subd
	sbca	#0	sub possible borrow from sbcb
	std	,x
	rts

#endif  /* _CMOC_NEED_subdww_ */


#ifdef _CMOC_NEED_SDIV16_

* Divide X by D, signed; return quotient in X, remainder in D.
* Non-zero remainder is negative iff dividend is negative.
SDIV16	PSHS	X,B,A
	CLR	,-S		counter: number of negative arguments (0..2)
	CLR	,-S		boolean: was dividend negative?
	TSTA			is divisor negative?
	BGE	SDIV16_10	if not
	INC	1,S
	COMA			negate divisor
	COMB
	ADDD	#1
	STD	2,S
SDIV16_10
	LDD	4,S		is dividend negative?
	BGE	SDIV16_20	if not
	INC	,S
	INC	1,S
	COMA			negate dividend
	COMB
	ADDD	#1
	STD	4,S
SDIV16_20
	LDD	2,S		reload divisor
	LDX	4,S		reload dividend
	LBSR	DIV16

* Counter is 0, 1 or 2. Quotient negative if counter is 1.
	LSR	1,S		check bit 0 of counter (1 -> negative quotient)
	BCC	SDIV16_30	quotient not negative
	EXG	X,D		put quotient in D and remainder in X
	COMA			negate quotient
	COMB
	ADDD	#1
	EXG	X,D		return quotient and remainder in X and D

SDIV16_30
* Negate the remainder if the dividend was negative.
	TST	,S		was dividend negative?
	BEQ	SDIV16_40	if not
	COMA			negate remainder
	COMB
	ADDD	#1
SDIV16_40
	LEAS	6,S
	RTS

#endif  /* _CMOC_NEED_SDIV16_ */


#if defined(_CMOC_NEED_DIV16_) || defined(_CMOC_NEED_SDIV16_)

* Divide X by D, unsigned; return quotient in X, remainder in D.
DIV16	PSHS	X,B,A
	LDB	#16
	PSHS	B
	CLRA
	CLRB
	PSHS	B,A
* 0,S=16-bit quotient; 2,S=loop counter;
* 3,S=16-bit divisor; 5,S=16-bit dividend

D16010	LSL	6,S		shift MSB of dividend into carry
	ROL	5,S		shift carry and MSB of dividend, into carry
	ROLB			new bit of dividend now in bit 0 of B
	ROLA
	CMPD	3,S		does the divisor "fit" into D?
	BLO	D16020		if not
	SUBD	3,S
	ORCC	#1		set carry
	BRA	D16030
D16020	ANDCC	#$FE		reset carry
D16030	ROL	1,S		shift carry into quotient
	ROL	,S

	DEC	2,S		another bit of the dividend to process?
	BNE	D16010		if yes

	PULS	X		quotient to return
	LEAS	5,S
	RTS

#endif  /* defined(_CMOC_NEED_DIV16_) || defined(_CMOC_NEED_SDIV16_) */


#ifdef _CMOC_NEED_SDIV8_

* Divide A by B, signed; return quotient in B, remainder in A.
* Non-zero remainder is negative iff dividend is negative.
* Does not preserve X.
SDIV8
	CLR	,-S		counter: number of negative arguments (0..2)
	CLR	,-S		boolean: was dividend negative?
	TSTB			is divisor negative?
	BGE	SDIV8_10	if not
	INC	1,S		increment counter of negative arguments
	NEGB			negate divisor
SDIV8_10
	TSTA			is dividend negative?
	BGE	SDIV8_20	if not
	INC	,S		remember that dividend was negative
	INC	1,S		increment counter of negative arguments
	NEGA			negate dividend
SDIV8_20
	LBSR	DIV8

* Counter is 0, 1 or 2. Quotient negative if counter is 1.
	LSR	1,S		check bit 0 of counter (1 -> negative quotient)
	BCC	SDIV8_30	quotient not negative
	NEGB			negate quotient

SDIV8_30
* Negate the remainder if the dividend was negative.
	TST	,S		was dividend negative?
	BEQ	SDIV8_40	if not
	NEGA			negate remainder
SDIV8_40
	LEAS	2,S
	RTS

#endif  /* _CMOC_NEED_SDIV8_ */


#if defined(_CMOC_NEED_DIV8_) || defined(_CMOC_NEED_SDIV8_)

* Divide A by B, unsigned; return quotient in B, remainder in A.
* Does not preserve X.
DIV8	PSHS	A		push dividend
	PSHS	B		push divisor
	LDA	#8		loop counter
	CLRB
	PSHS	B
* 0,S=8-bit quotient;
* 1,S=8-bit divisor; 2,S=8-bit dividend

DV8010	LSL	2,S		shift dividend into carry
	ROLB			new bit of dividend now in bit 0 of B
	CMPB	1,S		does the divisor "fit" into B?
	BLO	DV8020		if not
	SUBB	1,S
	ORCC	#1		set carry
	BRA	DV8030
DV8020	ANDCC	#$FE		reset carry
DV8030	ROL	,S		shift carry into quotient

	DECA			another bit of the dividend to process?
	BNE	DV8010		if yes

	TFR	B,A		remainder to return
	PULS	B		quotient to return
	LEAS	2,S
	RTS

#endif  /* defined(_CMOC_NEED_DIV8_) || defined(_CMOC_NEED_SDIV8_) */


#ifdef _CMOC_NEED_DIV8BY7_

* Unsigned division by seven
* Input: an unsigned byte (0..255) in A
* Output: Computes A/7
*         quotient (0..36) in B
*         remainder (0..6) in A
* Using (8a+b)/7 = a + (a+b)/7
* where a = higher five bits and b = lower three bits
* Source: DIVIDE7 on http://mirrors.apple2.org.za/ground.icaen.uiowa.edu/MiscInfo/Programming/div7
*
DIV8BY7
	TFR	A,B
	ANDA	#7
	PSHS	A	low bits (b)
	TFR	B,A
	LSRA
	LSRA
	LSRA
	TFR	A,B	high bits, divided by 8 (a)
	ANDCC	#$FE	clear carry
	ADCA	,S+	a + b. here we know carry is low.
DIV8BY7_010:
	INCB		the loop is executed between 1 and 6 times
	SBCA	#7	since A is at most 38
	BCC	DIV8BY7_010
	ADDA	#7
	DECB
	RTS
PAUL	EQU	12

#endif  /* _CMOC_NEED_DIV8BY7_ */


#ifdef _CMOC_NEED_DIV16BY10_

* Divide D by 10.
* Quotient left in D.
* Does not preserve X.
* Source: Hacker's Delight (Addison-Wesley, 2003, 2012)
*         http://www.hackersdelight.org/divcMore.pdf
*
DIV16BY10
	TFR	D,X	save n
	LSRA
	RORB		D = n >> 1
	PSHS	B,A	q := ,S (word)
	LSRA
	RORB		D = n >> 2
	ADDD	,S
	STD	,S	q = (n >> 1) + (n >> 2)
	LSRA
	RORB
	LSRA
	RORB
	LSRA
	RORB
	LSRA
	RORB
	ADDD	,S
	STD	,S	D = q + (q >> 4)
	TFR	A,B
	CLRA		q >> 8
	ADDD	,S
	LSRA
	RORB
	LSRA
	RORB
	LSRA
	RORB		q >> 3
	STD	,S
	LSLB
	ROLA
	LSLB
	ROLA		q << 2
	ADDD	,S
	LSLB
	ROLA
	PSHS	B,A
	TFR	X,D	D = n
	SUBD	,S++	D = r
	CMPD	#9	r > 9 ?
	BLS	DIV16BY10_010
	LDB	#1
	BRA	DIV16BY10_020
DIV16BY10_010
	CLRB
DIV16BY10_020
	LDA	,S
	ADDB	1,S
	ADCA	#0
	PULS	X,PC	discard q and return D

#endif  /* _CMOC_NEED_DIV16BY10_ */


#ifdef _CMOC_NEED_divdwb_

* void divdwb(unsigned dividend[2], unsigned char divisor)
*
* Writes quotient into dividend[0..1].
* Does nothing if divisor is zero.
*
_divdwb
_div328
	pshs	u
	tfr	s,u

	tst	7,u		load divisor
	beq	div328_900	division by zero: do nothing

	clra			push 32-bit zero
	clrb
	pshs	b,a
	pshs	b,a		-4,u will be 32-bit quotient

	ldx	4,u		X points to 4-byte dividend

	ldb	#32		one iteration per bit in the dividend
	pshs	b		-5,u is loop counter

	clra			dividend will be shifted left into D
	clrb                    (only low 9 bits are significant)

div328_loop
	lsl	3,x		shift dividend left
	rol	2,x
	rol	1,x
	rol	,x		MSB of dividend now in carry
	rolb
	rola
	cmpd	6,u		does divisor fit into D?
	blo	div328_nofit	if not

	subd	6,u             sub 8-bit divisor from 9-bit accumulator
	orcc	#1		set carry
	bra	div328_rolq

div328_nofit
	andcc	#$fe		reset carry

div328_rolq
	rol	-1,u		shift carry into quotient
	rol	-2,u
	rol	-3,u
	rol	-4,u

	dec	-5,u		dec loop counter
	bne	div328_loop

* Copy quotient into dividend space.
	ldd	-4,u
	std	,x
	ldd	-2,u
	std	2,x

div328_900
	tfr	u,s
	puls	u,pc

#endif  /* _CMOC_NEED_div328_ */


#if defined(_CMOC_NEED_divdww_)

* void divdww(unsigned dividend[2], unsigned divisor)
*
* Writes quotient into dividend[0..1].
* Does nothing if divisor is zero.
*
_divdww
_div3216
	pshs	u
	tfr	s,u

	ldd	6,u		load divisor
	beq	div3216_900	division by zero: do nothing

	clra			push 32-bit zero
	clrb
	pshs	b,a
	pshs	b,a		-4,u will be 32-bit quotient

	ldx	4,u		X points to 4-byte dividend

	ldb	#32		one iteration per bit in the dividend
	pshs	b		-5,u is loop counter

* Dividend will be shifted left into a 17-bit accumulator.
* The low 16 bits are in D, and the low bit of -6,u is bit 16.
* Bits 1..7 of -6,u are ignored.
	clra			
	clrb
	clr	,-s		-6,u

div3216_loop
	lsl	3,x		shift dividend left
	rol	2,x
	rol	1,x
	rol	,x		MSB of dividend now in carry
	rolb
	rola
	rol	-6,u		17th bit of accumulator
	bsr	div3216_tryfit	does divisor fit into accumulator?
	blo	div3216_nofit	if not

	bsr	div3216_sub	substract divisor from accumulator
	orcc	#1		set carry
	bra	div3216_rolq

div3216_nofit
	andcc	#$fe		reset carry

div3216_rolq
	rol	-1,u		shift carry into quotient
	rol	-2,u
	rol	-3,u
	rol	-4,u

	dec	-5,u		dec loop counter
	bne	div3216_loop

* Copy quotient into dividend space.
	ldd	-4,u
	std	,x
	ldd	-2,u
	std	2,x

div3216_900
	tfr	u,s
	puls	u,pc

* Determines if divisor fits into accumulator.
* Input:
*   6,u = 16-bit divisor
*   -6,u and D = 17-bit accumulator
* Output:
*   C = 0 iff divisor fits into accumulator.
* Preserves all registers.
div3216_tryfit
	pshs	b
	ldb	-6,u		bit 16 of acc
	andb	#1
	bne	@fit		bit 16 high, so acc > divisor
	puls	b
* Acc is just D, so compare directly with divisor.
	cmpd	6,u
	rts
@fit
	andcc	#0		return C = 0
	puls	b,pc

* Subtracts divisor from accumulator.
* Assumes result NOT negative.
* Same interface as div3216_tryfit.
div3216_sub
	subd	6,u
	bcc	@noBorrow
	dec	-6,u		bit 16, assumed to 1, becomes 0
@noBorrow
	rts

#endif  /* _CMOC_NEED_div3216_ */


#ifdef _CMOC_NEED_shiftLeft_

* Shifts the 16-bit value on the stack left by
* a number of bits given in D.
* Result left in D.
* CAUTION: Trashes X and pops the 16-bit value off the stack.
*
shiftLeft
	addd	#0	any shift to do?
	beq	shiftLeft_no_change

	cmpd	#16	shifting all bits out?
	blo	shiftLeft_general	if not

* Shifting >= 16 bits out.
	clra
	clrb
	bra	shiftLeft_end

shiftLeft_no_change
	ldd	2,s	return left side of shift operator as is
	bra	shiftLeft_end

shiftLeft_general
	pshs	b	save number of bits to shift
	ldd	3,s	get left side of shift operator
shiftLeft_loop
	lslb
	rola
	dec	,s
	bne	shiftLeft_loop
	leas	1,s	discard counter
shiftLeft_end
	puls	x	pop return value
	leas	2,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftLeft_ */


#ifdef _CMOC_NEED_shiftByteLeft_

* Shifts the 8-bit value on the stack left by
* a number of bits given in D.
* Result left in B.
* CAUTION: Trashes X and pops the 8-bit value off the stack.
*
shiftByteLeft
	addd	#0	any shift to do?
	beq	shiftByteLeft_no_change

	cmpd	#8	shifting all bits out?
	blo	shiftByteLeft_general	if not

* Shifting >= 8 bits out.
	clrb
	bra	shiftByteLeft_end

shiftByteLeft_no_change
	ldb	2,s	return left side of shift operator as is
	bra	shiftByteLeft_end

shiftByteLeft_general
	tfr	b,a	use A for number of bits to shift
	ldb	2,s	get left side of shift operator
shiftByteLeft_loop
	lslb
	deca
	bne	shiftByteLeft_loop
shiftByteLeft_end
	puls	x	pop return value
	leas	1,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftByteLeft_ */


#ifdef _CMOC_NEED_shiftRightUnsigned_

* Shifts the 16-bit unsigned value on the stack right
* by a number of bits given in D.
* Result left in D.
* CAUTION: Trashes X and pops the 16-bit value off the stack.
*
shiftRightUnsigned
	addd	#0	any shift to do?
	beq	shiftRightUnsigned_no_change

	cmpd	#16	shifting all bits out?
	blo	shiftRightUnsigned_general	if not

* Shifting >= 16 bits out.
	clra
	clrb
	bra	shiftRightUnsigned_end

shiftRightUnsigned_no_change
	ldd	2,s	return left side of shift operator as is
	bra	shiftRightUnsigned_end

shiftRightUnsigned_general
	pshs	b	save number of bits to shift
	ldd	3,s	get left side of shift operator
shiftRightUnsigned_loop
	lsra
	rorb
	dec	,s
	bne	shiftRightUnsigned_loop
	leas	1,s	discard counter
shiftRightUnsigned_end
	puls	x	pop return value
	leas	2,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftRightUnsigned_ */


#ifdef _CMOC_NEED_shiftByteRightUnsigned_

* Shifts the 8-bit unsigned value on the stack right
* by a number of bits given in D.
* Result left in B.
* CAUTION: Trashes X and pops the 8-bit value off the stack.
*
shiftByteRightUnsigned
	addd	#0	any shift to do?
	beq	shiftByteRightUnsigned_no_change

	cmpd	#16	shifting all bits out?
	blo	shiftByteRightUnsigned_general	if not

* Shifting >= 16 bits out.
	clrb
	bra	shiftByteRightUnsigned_end

shiftByteRightUnsigned_no_change
	ldb	2,s	return left side of shift operator as is
	bra	shiftByteRightUnsigned_end

shiftByteRightUnsigned_general
	tfr	b,a	use A for number of bits to shift
	ldb	2,s	get left side of shift operator
shiftByteRightUnsigned_loop
	lsrb
	deca
	bne	shiftByteRightUnsigned_loop
shiftByteRightUnsigned_end
	puls	x	pop return value
	leas	1,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftByteRightUnsigned_ */


#ifdef _CMOC_NEED_shiftRightSigned_

* Shifts the 16-bit signed value on the stack right
* by a number of bits given in D.
* Result left in D.
* CAUTION: Trashes X and pops the 16-bit value off the stack.
*
shiftRightSigned
	addd	#0	any shift to do?
	beq	shiftRightSigned_no_change

	cmpd	#15	shifting all mantissa bits out?
	blo	shiftRightSigned_general	if not

* Shifting >= 15 bits out.
	ldd	2,s	left side of shift operator
	tfr	a,b	sign bit of D into bit 7 of B
	sex		repeat bit 7 of B eight times in A
	tfr	a,b	D = $FFFF if original D < 0; D = 0 otherwise
	bra	shiftRightSigned_end

shiftRightSigned_no_change
	ldd	2,s	return left side of shift operator as is
	bra	shiftRightSigned_end

shiftRightSigned_general
	pshs	b	save number of bits to shift
	ldd	3,s	get right side of shift operator
shiftRightSigned_loop
	asra
	rorb
	dec	,s
	bne	shiftRightSigned_loop
	leas	1,s	discard counter
shiftRightSigned_end
	puls	x	pop return value
	leas	2,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftRightSigned_ */


#ifdef _CMOC_NEED_shiftByteRightSigned_

* Shifts the 8-bit signed value on the stack right
* by a number of bits given in D.
* Result left in B.
* CAUTION: Trashes X and pops the 8-bit value off the stack.
*
shiftByteRightSigned
	addd	#0	any shift to do?
	beq	shiftByteRightSigned_no_change

	cmpd	#7	shifting all mantissa bits out?
	blo	shiftByteRightSigned_general	if not

* Shifting >= 7 bits out.
	ldb	2,s	left side of shift operator
	sex		repeat bit 7 of B eight times in A
	tfr	a,b	B = $FF if original D < 0; B = 0 otherwise
	bra	shiftByteRightSigned_end

shiftByteRightSigned_no_change
	ldb	2,s	return left side of shift operator as is
	bra	shiftByteRightSigned_end

shiftByteRightSigned_general
	tfr	b,a	use A for number of bits to shift
	ldb	2,s	get right side of shift operator
shiftByteRightSigned_loop
	asrb
	deca
	bne	shiftByteRightSigned_loop
shiftByteRightSigned_end
	puls	x	pop return value
	leas	1,s	pop left side
	tfr	x,pc	return from routine (with result in D)

#endif /* _CMOC_NEED_shiftByteRightSigned_ */


#ifdef _CMOC_NEED_cmpdww_

* char cmpdww(unsigned left[2], unsigned right)
*
_cmpdww
        ldx     2,s             left
        ldd     ,x              high word of left
        bne     @leftGreater
        ldd     2,x             low word of left
        cmpd    4,s             compare with right
        bhi     @leftGreater
        blo     @leftSmaller
        clrb                    left == right
        rts
@leftSmaller
        ldb     #-1             left < right
        rts
@leftGreater
        ldb     #1              left > right
        rts

#endif /* _CMOC_NEED_cmpdww_ */


#ifdef _CMOC_NEED_setConsoleOutHook_

* void *setConsoleOutHook(void *routine)
*
_setConsoleOutHook
	ldd	CHROUT,pcr	; to be returned
	ldx	2,s        	; 1st argument: 'routine'
	stx	CHROUT,pcr
	rts

#endif  /* _CMOC_NEED_setConsoleOutHook_ */


#if defined(_CMOC_NEED_putchar_)

* void putchar(byte c)
*
* Converts LF ($0A) into CR ($0D) before calling CHROUT.
*
_putchar
	lda	3,s

#endif

#if    defined(_CMOC_NEED_putchar_) \
    || defined(_CMOC_NEED_putstr_) \
    || defined(_CMOC_NEED_sprintf_) \
    || defined(_CMOC_NEED_printf_)

* putchar_a should be called by the other routines (printf, etc.)
* whenever the character to be printed might be a newline.
*
putchar_a

#ifdef _COCO_BASIC_  /* Only Color Basic expects CR for newline; others expect LF. */
	cmpa	#10		C linefeed?
	bne	putchar_010
	lda	#13		CHROUT does newline on char 13
putchar_010:
#endif
	jmp	[CHROUT,DAT]

#endif  /* _CMOC_NEED_putchar_ */


#ifdef _CMOC_NEED_putstr_

* void putstr(byte *s, word len)
*
* Sends characters s[0] to s[len - 1] to standard output.
*
_putstr
putstr:
	pshs	u
	ldx	6,s	number of characters to write
	beq	putstr_900
	ldu	4,s	address of string to write
putstr_100:
	lda	,u+
	lbsr     putchar_a
	leax    -1,x
	bne	putstr_100
putstr_900:
	puls    u,pc

#endif  /* _CMOC_NEED_putstr_ */


#ifdef _CMOC_NEED_sprintf_

* Writes register A at the address given by chrtomem_writer,
* which gets incremented by 1. Used by _sprintf.
*
chrtomem:
	pshs	x
	ldx	chrtomem_writer,DAT
	sta	,x+
	stx	chrtomem_writer,DAT
	puls	x,pc


_sprintf
	ldx	CHROUT,DAT
	stx	sprintf_oldCHROUT,DAT	preserve initial output routine address
	leax	chrtomem,pcr		install chrtomem as destination of printf()
	stx	CHROUT,DAT

	ldx	,s++			remove return address in caller of sprintf()
	stx	sprintf_retaddr,DAT	preserve it

	ldx	,s++			remove destination buffer
	stx	chrtomem_writer,DAT	make chrtomem write to destination buffer

	lbsr	_printf			print into destination buffer via chrtomem

	clr	[chrtomem_writer,DAT]	terminate resulting string

	ldx	sprintf_oldCHROUT,DAT	restore initial output routine address
	stx	CHROUT,DAT

	leas	-2,s			restore stack slot for destination buffer pointer

	jmp	[sprintf_retaddr,DAT]	return to caller of sprintf()

#endif  /* _CMOC_NEED_sprintf_ */


#if defined(_CMOC_NEED_printf_) || defined(_CMOC_NEED_sprintf_)

PRINTF_FLOAT_SIZE	EQU	5	size of a %f argument

* void printf(const char *fmt, ...)
*
* Minimal printf(3) function.
* To redirect the output characters, store a routine pointer in CHROUT.
* That routine must accept the character to print in register A.
*
_printf
	PSHS	U
	LDX	4,S		format string
	LEAU	6,S		variable argument pointer
	LDA	#$20		default padding char
	PSHS	A
	CLR	,-S
	CLR	,-S
* ,S = width parameter (word) (as in "%12u").
* 2,S = current padding char (byte)

PTF010	LDA	,X+		get char from format string
	LBEQ	PTF900
	CMPA	#$25		'%'?
	BEQ	PTF490
PTF020	LBSR    putchar_a	ordinary char: print it
	BRA	PTF010

PTF490				* '%' just seen
	CLR	,S		clear width word
	CLR	1,S
	LDA	#$20
	STA	2,S		reinit padding char

PTF500				* process chars that follow '%'
	LDA	,X+		get char after '%'
	BNE	PTF510
	LDA	#$25		string ends after '%', so print '%'
	JSR	[CHROUT,DAT]
	LBRA	PTF900
PTF510	CMPA	#$75		%u?
	BNE	PTF515
	LDD	,U++		get 16-bit argument
	LBSR	PADWRD		width is in ,S, padding char in 2,S
	LBSR	PRNTWD		print as decimal
	BRA	PTF010
PTF515	CMPA	#$64		%d?
	BNE	PTF520
	LDD	,U		get number to print
	BGE	PTF517
	COMA			negate D
	COMB
	ADDD	#1
	PSHS	B,A
	LDD	2,S		subtract 1 one width, because number to print is < 0
	SUBD	#1
	STD	2,S
	PULS	A,B
PTF517
	LBSR	PADWRD		16-bit width is in ,S, padding char in 2,S

	PSHS	B,A		if number to print < 0, print minus sign
	LDD	,U++		reload number to print, advance arg pointer
	BGE	PTF518
	LDA	#45		minus sign
	JSR	[CHROUT,DAT]
PTF518
	PULS	A,B		restore absolute value of number to print

	LBSR	PRNTWD		print as decimal
	BRA	PTF010
PTF520	CMPA	#$78		%x?
	BNE	PTF525
PTF522	LDD	,U++		get 16-bit argument
	LBSR	PADHEX		16-bit width is in ,S, padding char in 2,S
	LBSR	PRNTWH		print as hex
	BRA	PTF010
PTF525	CMPA	#$58		%X?
	BEQ	PTF522
	CMPA	#$70		%p?
	BNE	PTF530
	LDA	#$24		prefix pointer representation with $
	JSR	[CHROUT,DAT]
	LDD	#4		always 4 hex digits for a pointer
	STD	,S
	LDA	#$30		pad pointer with '0'
	STA	2,S
	BRA	PTF522		do %X

PTF530	CMPA	#$73		%s?
	BNE	PTF540

	LDD	,S		width of the string field
	BLT	PTF532		if post-padding requested (signed branch)

	LDD	,U		get address of string
	LBSR	PADSTR_PRE
PTF532
	LDD	,U		get address of string
	LBSR	PRINTS

	LDD	,S		width of the string field
	BPL	PTF538		if pre-padding requested: it's done, we're finished with %s

	LDD	,U		reload address of string
	LBSR	PADSTR_POST	do post-padding
PTF538
	LEAU	2,U		pass string address argument
	LBRA	PTF010		finished with %s

PTF540	CMPA	#$63		%c?
	BNE	PTF550
        LDD     ,U++            get char in B
	TFR     B,A
	LBSR    putchar_a
	LBRA	PTF010
PTF550	CMPA	#$66		%f?
	BNE	PTF555
	LBSR	printReal
	LEAU	PRINTF_FLOAT_SIZE,U	pass the float
	LBRA	PTF010
PTF555	CMPA	#'l		%lu, %ld or %lx?
	LBNE	PTF559
	LDA	,X+		check letter that follows %l
	CMPA	#'u
	BEQ	@ulong
	CMPA	#'d
	BEQ	@slong
	CMPA	#'x
	LBEQ	@xlong
	CMPA	#'X
	LBEQ	@xlong
	LEAX	-1,X		neither: tolerate %l as alias for %ld
	CLRA			indicates that no minus sign must be printed
@slong
* If the (big endian) dword at ,U is negative, negate it and
* print a minus sign.
	TST	,U
	BPL	@longNotNeg
	EXG	U,X
	LBSR	negateDWord
	EXG	U,X
	LDA	#'-
@longNotNeg
@ulong
*
* Here, A is '-' iff a minus sign must be printed before the number.
* Also, 16-bit width is in ,S, padding char in 2,S
*
* Call dwtoa().
	PSHS	X,A		X trashed by _dwtoa, A indicates if minus sign needed
	LEAS	-11,S		buffer for dwtoa
	LDD	,U		high word
	LDX	2,U		low word
	PSHS	X,B,A		pushes 4 bytes for _dwtoa
	LEAX	4,S		point to 11-byte buffer
	PSHS	X		pass address to _dwtoa
	LBSR	_dwtoa
	LEAS	6,S		discard arguments
	TFR	D,X		point to first digit to print
* Here, 16-bit width is in 14,S, padding char in 16,S, minus sign indicator in 11,S
*
* Print minus sign BEFORE padding IF padding char is NOT space.
	LDA	16,S		padding char
	CMPA	#$20		is space?
	BEQ	@checkPadding
	LDA	11,S		load minus sign indicator
	CMPA	#'-
	BNE	@checkPadding	no minus sign to print
	LDA	#'-
	JSR	[CHROUT,DAT]	print it
*
@checkPadding
*
	LBSR	@decPadding
*
* Print minus sign AFTER padding IF padding char is space.
	LDA	16,S		padding char
	CMPA	#$20		is space?
	BNE	@printCond
	LDA	11,S		load minus sign indicator
	CMPA	#'-
	BNE	@printCond	no minus sign to print
	LDA	#'-
	JSR	[CHROUT,DAT]	print it
	BRA	@printCond
*
@printLoop
	JSR	[CHROUT,DAT]	print it
@printCond
	LDA	,X+		load digit
	BNE	@printLoop	if not '\0'
	LEAS	11,S		discard buffer
	PULS	A,X		restore X (points into printf format string)
	LEAU	4,U		pass the 32-bit long
	LBRA	PTF010
;
;
; Input: U => dword to be printed in hex.
; Output: D => number of hex digits needed to print dword (1..8).
; Preserves X and U.
;
@countHexDigitsInDWord
	CLRB
@nextDWordByte
	LDA	B,U		get byte from dword
	BNE	@nonNullByte	found 1st non-null byte
	INCB			count another null byte
	CMPB	#4		if reached 4, all bytes null
	BEQ	@oneDigitNeeded
	BRA	@nextDWordByte
@nonNullByte			; B is index (0..3) of 1st non null byte
	LSLB
	NEGB
	ADDB	#8		number of digits needed is B or B-1
	BITA	#$F0		is high nybble null?
	BNE	@highNybbleNotNull
	DECB			one less digit needed
@highNybbleNotNull	
	CLRA
	RTS
@oneDigitNeeded
	LDB	#1		A is already 0
@done
	RTS
;
;
@xlong
; Pad if required.
* Here, 16-bit width is in ,S, padding char in 2,S
	BSR	@countHexDigitsInDWord		uses U; result in D
	SUBD	,S				subtract width
	BHS	@noHexPadding
	PSHS	X
	TFR	D,X				use X as upwards counter
@hexPad
	LDA	4,S				padding char
	JSR	[CHROUT,DAT]
	LEAX	1,X
	BNE	@hexPad
	PULS	X
@noHexPadding
	LDD	,U		high word
	BEQ	@highWordZero   if no digit to print
	LBSR	PRNTWH		print high word
; Print low word, padded with zeroes to a width of 4.
	LDB	#'0		padding char for PADHEX
	PSHS	B
	LDD	#4		print 2nd word as 4 digits
	PSHS	B,A		pass to PADHEX
	LDD	2,U		low word
	LBSR	PADHEX		preserves D and X
	LEAS	3,S
@highWordZero
	LDD	2,U		low word
	LBSR	PRNTWH		print D (low word)
	LEAU	4,U		pass the 32-bit long
	LBRA	PTF010		done with %lx
;
; Input: S (before call) => 11-digit buffer;
;        X => first digit to print in the 11-digit buffer;
;        16-bit width is in 14,S, padding char in 16,S, minus sign indicator in 11,S.
; Preserves X. Trashes D.
;
@decPadding
	PSHS	X
; Here, 16-bit width is in 18,S, padding char in 20,S, minus sign indicator in 15,S.
	TFR	S,D
	ADDD	#2+2+10		addr of NUL-terminating byte of buffer (written by _dwtoa)
	PSHS	X
	SUBD	,S++		D minus addr of 1st digit to print = # of digits to print
	PSHS	A
	LDA	16,S		get minus sign indicator
	CMPA	#'-		minus needed?
	PULS	A
	BNE	@noMinusNeeded
	ADDD	#1		count minus as 1 more char to print
@noMinusNeeded
	SUBD	18,S		compare with width; negative result means padding needed
	BHS	@noPadding	if width matched or exceeded, no padding
	TFR	D,X		use X as upwards counter (must reach up to 0)
@decPadPrint
	LDA	20,S		padding char
	JSR	[CHROUT,DAT]
	LEAX	1,X
	BNE	@decPadPrint
@noPadding
	PULS	X,PC

PTF559	CMPA	#$25		%%?
	BNE	PTF560
	JSR	[CHROUT,DAT]
	LBRA	PTF010
PTF560	CMPA	#45		minus? *** CAUTION: ONLY SUPPORTED FOR STRING PADDING ***
	BNE	PTF562

	LBSR	ATOW		read integer following minus sign into D
	PSHS	B,A		negate D
	CLRA
	CLRB
	SUBD	,S++
	STD	,S		store negative width
	LBRA	PTF500		continue to process the chars following the %

PTF562	CMPA	#$30		width?
	BLO	PTF570
	CMPA	#$39
	BHI	PTF570
	CMPA	#$30		zero?
	BNE	PTF565
	STA	2,S		exception: this zero specifies the padding char
	BRA	PTF567
PTF565	LEAX	-1,X
PTF567	LBSR	ATOW
	STD	,S
	LBRA	PTF500		continue to process the chars following the %
PTF570	EQU	*
PTF800	PSHS	A		unknown code after '%': print '%' then the code
	LDA	#$25
	JSR	[CHROUT,DAT]
	PULS	A
	LBSR    putchar_a
	LBRA	PTF010

PTF900	LEAS	3,S
	PULS	U,PC


* Input: D = word to write in decimal.
PADWRD	PSHS	X,B,A
	LDX	6,S		width of the number
	LEAX	-5,X		assume word in D has 5 decimal digits
	CMPD	#10
	BHS	PWD020
	LEAX	1,X		D < 10, so add one padding char
PWD020	CMPD	#100
	BHS	PWD030
	LEAX	1,X
PWD030	CMPD	#1000
	BHS	PWD040
	LEAX	1,X
PWD040	CMPD	#10000
	BHS	PWD050
	LEAX	1,X

PWD050	CMPX	#0
	BLE	PWD900		no padding if X negative or zero
PWD060	LDA	8,S		get padding char
	JSR	[CHROUT,DAT]
	LEAX	-1,X
	BNE	PWD060

PWD900	CLR	6,S		clear width for next time
	CLR	7,S
	LDA	#$20		restore default padding char for next time
	STA	8,S
	PULS	A,B,X,PC


* Input: D = address of string to write
PADSTR_PRE
	PSHS	X,B,A
	PSHS	B,A		send string address to _strlen
	LBSR	_strlen		get length of string
	STD	,S		reuse arg slot to store length
	LDD	8,S		width of the string field
	SUBD	,S		substract string length; D = number of padding chars
	BLE	PADSTR_900	if nothing to do
PADSTR_050
	TFR	D,X		use X as padding counter
PADSTR_100
	LDA	#32		use space as padding char
	JSR	[CHROUT,DAT]
	LEAX	-1,X
	BNE	PADSTR_100
PADSTR_900
	LEAS	2,S		pop arg slot
	PULS	A,B,X,PC

* Input: D = address of string to write
PADSTR_POST
	PSHS	X,B,A
	PSHS	B,A		send string address to _strlen
	LBSR	_strlen		get length of string
	STD	,S		save length
	CLRA
	CLRB
	SUBD	8,S		negated field width, which is now > 0
	SUBD	,S		subtract number of printed chars
	BLS	PADSTR_900	if nothing to do
	BRA	PADSTR_050	/* reuse previous subroutine's padding loop */


* Input: D = number to write.
*        Before call, ,S must contain 16-bit width in chars
*        and 2,S must contain padding char.
*
PADHEX	PSHS	X,B,A
	LDX	6,S		width of the number
	LEAX	-4,X		assume word in D has 4 hex digits
	CMPD	#$10
	BHS	PHX020
	LEAX	1,X		D < 16, so add one padding char
PHX020	CMPD	#$100
	BHS	PHX030
	LEAX	1,X
PHX030	CMPD	#$1000
	BHS	PHX050
	LEAX	1,X
PHX050	CMPX	#0
	BLE	PHX900		no padding if X negative or zero
PHX060	LDA	8,S		get padding char
	JSR	[CHROUT,DAT]	note that this may trash A
	LEAX	-1,X
	BNE	PHX060

PHX900	CLR	6,S		clear width for next time
	CLR	7,S
	LDA	#$20		restore default padding char for next time
	STA	8,S
	PULS	A,B,X,PC


; Prints D in hex.
; Preserves D and X.
; Uses HEXDIG.
;
PRNTWH	PSHS	X,B,A
	SUBD	#0		handle special case
	BNE	PRWH10
	LDA	#'0
	JSR	[CHROUT,DAT]
	BRA	PRWH99
PRWH10	CLR	,-S		create 4-character buffer for 4 hex digits
	CLR	,-S
	CLR	,-S
	CLR	,-S
	LEAX	HEXDIG,PCR
	LSRA			get first nybble of 16-bit value to print
	LSRA
	LSRA
	LSRA
	LDA	A,X
	STA	,S
	LDA	4,S		retrieve MSB of 16-bit value of print
	ANDA	#$0F		get second nybble of 16-bit value
	LDA	A,X
	STA	1,S
	LSRB			get third nybble
	LSRB
	LSRB
	LSRB
	LDB	B,X
	STB	2,S
	LDB	5,S
	ANDB	#$0F
	LDB	B,X
	STB	3,S

	LEAX	,S		have X point to 4-char buffer
	LDB	#5		char counter
PRWH30	LDA	,X+		search for first non-'0' character
	DECB
	CMPA	#'0
	BEQ	PRWH30

	LEAX	-1,X		go back to first non-'0'
PRWH40	LDA	,X+		print the characters
	JSR	[CHROUT,DAT]
	DECB
	BNE	PRWH40

	LEAS	4,S		remove 4-char buffer

PRWH99	PULS	A,B,X,PC


* Table of ASCII characters for hexadecimal digits
HEXDIG	FCC	"0123456789ABCDEF"


* Print unsigned number in D in decimal.
PRNTWD	PSHS	X,B,A

	CLR	,-S
PRWD10	INC	,S
	SUBD	#10000
	BHS	PRWD10
	ADDD	#10000

	CLR	,-S
PRWD20	INC	,S
	SUBD	#1000
	BHS	PRWD20
	ADDD	#1000

	CLR	,-S
PRWD30	INC	,S
	SUBD	#100
	BHS	PRWD30
	ADDD	#100

	CLR	,-S
PRWD40	INC	,S
	SUBD	#10
	BHS	PRWD40
	ADDD	#10

	INCB
	PSHS	B
* All five digits are 1 more than their intended value.

	LDB	#5
	PSHS	B		loop counter
	LEAX	6,S

PRWD60	LDB	,-X		find first non-zero digit
	CMPB	#1
	BNE	PRWD80		if found
	DEC	,S
	BNE	PRWD60

	INC	,S		all zeroes: print one zero
	LEAX	1,X

PRWD70	LDB	,-X
PRWD80	ADDB	#$2F
	BSR	PRINTC
	DEC	,S
	BNE	PRWD70

	LEAS	6,S
PRWD90	PULS	A,B,X,PC


* Print the ASCII character in B.  Preserves X and D.
PRINTC	PSHS	A
	TFR	B,A
	LBSR    putchar_a
	PULS	A,PC


* Print the ASCIIZ pointed by D.  Preserves X and D.
PRINTS	PSHS	X,B,A
	TFR	D,X
	BRA	PRS020
PRS010	LBSR    putchar_a
PRS020	LDA	,X+
	BNE	PRS010
	PULS	A,B,X,PC

* Input: U => packed real number.
printReal
#ifdef _COCO_BASIC_
	PSHS	U,Y,X
	LEAU	,S		; stack frame pointer
	LEAS	-38,S		; buffer to write ASCII string to

	LDX	4,U		; address of packed number (saved U)
	JSR	$BC14		; unpack into Basic's FPA0

	PSHS	U		; save frame pointer
	LEAU	-38,U		; address of ASCII buffer
	JSR	$BDDC		; convert FPA0 to ASCII
	PULS	U

	LEAX	-38,U		; address of ASCII buffer
	LDA	,X
	CMPA	#32		; is 1st char space?
	BNE	@print
	LEAX	1,X		; skip space
@print
	LDA	,X+
	BEQ	@donePrinting
	JSR	[CHROUT,DAT]
	BRA	@print
@donePrinting
	LEAS	,U
	PULS	X,Y,U,PC

#else  /* This platform does not support printing reals. */
	LDA	#'!
	JMP	[CHROUT,DAT]
#endif

#endif  /* _CMOC_NEED_printf_ */


#ifdef _CMOC_NEED_readword_

* unsigned readword();
* Read an unsigned decimal 16-bit integer from the user.  Return result in D.
_readword
	LBSR	_readline
	TFR	D,X		pass string address in X
	BRA	ATOW

#endif  /* _CMOC_NEED_readword_ */

_
#if    defined(_CMOC_NEED_printf_) \
    || defined(_CMOC_NEED_readword_) \
    || defined(_CMOC_NEED_atoi_) \
    || defined(_CMOC_NEED_atoui_)

* Convert unsigned decimal integer pointed by X into word returned in D.
* Upon return, X points to character where conversion stopped.
ATOW	CLR	,-S		init 16-bit accumulator
	CLR	,-S

ATW100	LDB	,X+		read next char from line buffer
	CMPB	#$30
	BLO	ATW900		stop reading at non-digit char
	CMPB	#$39
	BHI	ATW900		stop reading at non-digit char
	SUBB	#$30		convert from ASCII '0'..'9' to 0..9
	CLRA

	PSHS	X,B,A
	LDX	4,S		multiply acc by ten
	LDB	#10
	BSR	MUL168
	STD	4,S
	PULS	A,B,X

	ADDD	,S		add this digit to acc
	STD	,S
	BRA	ATW100

ATW900	LEAX	-1,X
	PULS	A,B,PC


* Multiply B by X, unsigned; return result in D; preserve X.
MUL168	PSHS	X,B,A		acc A pushed to create temp byte at ,S
	LDA	2,S		high byte of X
	MUL			multiply by B
	STB	,S		keep intermediate result
	LDB	1,S		original B
	LDA	3,S		low byte of X
	MUL
	ADDA	,S
	LEAS	4,S
	RTS


#endif


#if defined(_CMOC_NEED_atoui_)

* unsigned atoui(char *s);
_atoui
        ldx     2,s             argument 's'
        lbra    ATOW

#endif  /* defined(_CMOC_NEED_atoui_) */


#if defined(_CMOC_NEED_atoi_)

* int atoi(char *s);
_atoi
        ldx     2,s             s
        clr     ,-s             sign byte: 0 = positive
        ldb     ,x              1st char
        cmpb    #'-             minus sign?
        bne     atoi_010        no
        com     ,s              $FF = negative
        leax    1,x             pass minus sign
atoi_010
        lbsr    ATOW            convert rest of s
        tst     ,s+             apply sign byte
        beq     atoi_020        positive
        coma
        comb
        addd    #1
atoi_020
        rts

#endif  /* defined(_CMOC_NEED_atoi_) */


#if defined(_CMOC_NEED_strtoul_)

; unsigned long strtoul(char *nptr, char **endptr);
;
; A hidden first argument is passed to point to the 32-bit return value slot.
;
_strtoul
	pshs	u
	leau	,s
	clr	,-s		-1,U: boolean: string contains negative number

	ldx	4,u		address of return value slot
	clra
	clrb
	std	,x		clear return value (accumulator)
	std	2,x

	ldx	6,u		nptr
	ldb	,x
	cmpb	#'-		negative number?
	bne	@loop		no
	inc	-1,u
	leax	1,x		pass minus sign
@loop
	LDB	,X+		read next char from ASCII buffer
	CMPB	#'0
	BLO	@done		stop reading at non-digit char
	CMPB	#'9
	BHI	@done		stop reading at non-digit char
	SUBB	#'0		convert from ASCII '0'..'9' to 0..9
	CLRA
	pshs	x,b		preserve char reader, new digit
; Call mulDWordUnsignedInt to multiply accumulator by 10.
	ldb	#10
	pshs	b,a
	ldx	4,u		address of return value slot
	pshs	x
	lbsr	mulDWordUnsignedInt	preserves X, trashes D
	leas	4,s
;
	puls	b		restore new digit
; Add B to accumulator.
	clra
	ldx	4,u		address of return value slot
	addd	2,x		add low word of acc, sets carry
	std	2,x
	ldd	,x		get high word of acc
	adcb	#0		add carry
	adca	#0
	std	,x
;
	puls	x		restore char reader
	bra	@loop
@done
	leax	-1,x		go back to last non-digit char
	stx	[8,U]		return that address in *endptr

	ldx	4,u		address of return value slot

; Negate the result if minus sign was read.
	tst	-1,u
	beq	@notNeg
	lbsr	negateDWord
@notNeg
	leas	,u
	puls	u,pc

#endif


#ifdef _CMOC_NEED_srand_

* void srand(int seed);
_srand
SRAND	LDD	2,S
	STD	SEED,DAT
	RTS

#endif  /* _CMOC_NEED_srand_ */


#ifdef _CMOC_NEED_rand_

* int rand(void);
* Compute a random 15-bit non-negative integer and return it in D.
* A linear congruence is used: SEED = SEED * (256 + 128 + 1) + 1.
* However, the two bytes of the result are interchanged before being returned.
_rand
RAND	LDD	SEED,DAT
	PSHS	B,A	SEED
	TFR	B,A
	CLRB
	PSHS	B,A	SEED * 256
	LSRA
	RORB
	PSHS	B
	LSLA
	LDB	SEED,DAT	MSB of SEED
	LSRB
	RORA
	PULS	B	D = SEED * 128
	ADDD	,S++	D = SEED * (256 + 128)
	ADDD	,S++	D = SEED * (256 + 128 + 1)
	ADDD	#1
        EORB    #$40            ; improves distribution of this bit 
	STD	SEED,DAT
	ANDA	#$7F	15-bit result
	RTS

#endif  /* _CMOC_NEED_rand_ */


LBUFMX	EQU	250		number of available bytes in LINBUF buffer


#ifdef _COCO_BASIC_

#if defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_)

LINBUF	EQU	$02DC		buffer where READLN stores line read from user

_readline
	JSR	$A390		CoCo Basic routine to read a line w/ cursor
	LDD	#LINBUF+1	return address of 1st char
	RTS

#endif  /* defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_) */


#ifdef _CMOC_NEED_delay_

TIMER	EQU	$0112		CoCo Basic 60 Hz 16 bit timer

* Wait for a number of ticks (1/60 second) which is given on the stack.
_delay
DELAY	PSHS	B,A
	LDD	4,S		number of ticks to wait
	BEQ	DELAY9
	ADDD	TIMER		value that TIMER must reach
DELAY1	CMPD	TIMER
	BNE	DELAY1
DELAY9	PULS	A,B,PC

#endif  /* _CMOC_NEED_delay_ */


#elif defined(OS9)


#if defined(_CMOC_NEED_putchar_) || defined(_CMOC_NEED_putstr_) || defined(_CMOC_NEED_sprintf_) || defined(_CMOC_NEED_printf_)
* NOTE: This is inefficient for a string: have printf accumulate, then send a string.
PUTCHR	pshs	u,y,x,a
	leax	,s		point to char pushed in stack
	ldy	#1		1 char to print
	lda	#1		write to stdout
	os9	I$WritLn
	puls	a,x,y,u,pc
#endif


#if defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_)

_readline
	pshs	y		preserve process data pointer
	leax	LINBUF+1,y	+1 as in Color Basic
	ldy	#LBUFMX-1	max num chars allowed (w/ room for final NUL)
	clra			read from stdin
	os9	I$ReadLn
	bcc	readline_ok

	clra			return null pointer to signal error
	clrb
	puls	y,pc

readline_ok
	tfr	y,d		number of bytes actually read
	cmpd	#0		empty line?
	beq	readline_empty	yes

	leax	d,x		point past last byte read
	ldb	-1,x		is last byte read carriage return?
	cmpb	#13
	bne	readline_notCR	no

	leax	-1,x		point to CR, to nullify it

readline_notCR

readline_empty
	clr	,x		terminate line with NUL
	puls	y
	leax	LINBUF+1,y	+1 as in Color Basic
	tfr	x,d		return start of string
	rts

#endif  /* defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_) */


#ifdef _CMOC_NEED_delay_
* Wait for a number of ticks (1/60 second) which is given on the stack.
_delay
DELAY	ldx	2,s
	os9	F$Sleep
	rts
#endif


#elif defined(USIM)


* Code to be used with the version of usim that comes with CMOC.
*
PUTCHR	STA	$FF00
	RTS


#if defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_)

LINBUF	RMB	LBUFMX+1	buffer where READLN stores line read from user

_readline
	LEAX	LINBUF+1,DAT	+1 as in Color Basic
	LDB	#LBUFMX-1	number of bytes still available in buffer
*				(1 byte reserved for terminating NUL)
RDLN10	LDA	$FF00		check for a character from the user
	BEQ	RDLN10
	CMPA	#255		if EOF
	BEQ	CRASH
	CMPA	#10		if newline
	BEQ	RDLN90
	TSTB			room left in buffer?
	BEQ	RDLN10		if no
	STA	,X+		there is room: store the character
	DECB
	BRA	RDLN10
RDLN90	CLR	,X		terminate the string with a NUL character
	LEAX	LINBUF+1,DAT	return start of string
	TFR	X,D
	RTS

CRASH	SYNC

#endif  /* defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_) */


#ifdef _CMOC_NEED_delay_

* Wait for a number of ticks (1/60 second) which is given on the stack.
_delay
DELAY	PSHS	B,A
	LDD	4,S		number of ticks to wait
	STD	$FF02		ask simulator to wait
	PULS	A,B,PC

#endif  /* _CMOC_NEED_delay_ */

#elif defined(VECTREX)

PUTCHR
	RTS

#if defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_)

* Return NULL (meaning failure) on the Vectrex, which has no keyboard.
_readline
	CLRA
	CLRB
	RTS

#endif  /* defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_) */


#ifdef _CMOC_NEED_delay_

_delay
DELAY
	RTS

#endif  /* _CMOC_NEED_delay_ */

#endif  /* platform */


#ifdef _CMOC_NEED_strcmp_

* int strcmp(char *, char *);
*
_strcmp
	pshs	u,x
	ldx	6,s		1st string
	ldu	8,s		2nd string

_strcmp_050
	ldb	,u+
	lda	,x+
	bne	_strcmp_010
	tstb
	beq	_strcmp_900	return 0 (in B)

* a zero but b non zero, so 1st string comes before
_strcmp_040
	ldb	#$ff
	bra	_strcmp_900

_strcmp_010	equ	*
	tstb
	bne	_strcmp_020

* a non zero but b zero, so 1st string comes after
_strcmp_030	equ	*
	ldb	#1
	bra	_strcmp_900

_strcmp_020	equ	*
* a and b non zero.
	cmpa	-1,u
	bhi	_strcmp_030	return +1
	blo	_strcmp_040	return -1
	bra	_strcmp_050

_strcmp_900
	sex
	puls	x,u,pc

#endif  /* _CMOC_NEED_strcmp_ */


#if defined(_CMOC_NEED_strlen_) || defined(_CMOC_NEED_printf_) || defined(_CMOC_NEED_sprintf_)

_strlen pshs	x
	ldx	4,s
_strlen_010
	tst	,x+
	bne	_strlen_010

	tfr	x,d
	subd	#1		compensate for increment past '\0'
	subd	4,s		substract start address

	puls	x,pc

#endif


#ifdef _CMOC_NEED_memset_

* void *memset(void *s, int c, size_t n)
*
_memset	pshs	u
	tfr	s,u
	leas	-2,s		end address

	ldd	4,u		start address (s)
	tfr	d,x
	addd	8,u		add number of bytes (n) to get end address
	std	-2,u		store in local var

	lda	7,u		byte to write (c)
	bra	_memset_cond
_memset_loop
	sta	,x+
_memset_cond
	cmpx	-2,u		at end?
	bne	_memset_loop	no, continue

	ldd	4,u		return start address
	tfr	u,s
	puls	u,pc

#endif  /* _CMOC_NEED_memset_ */


#ifdef _CMOC_NEED_memcpy_

* Preserves X and U. Trashes D.
*
memcpy
_memcpy pshs	u,x
	ldx	6,s		destination string
	ldu	8,s		source string
	tfr	u,d
	addd	10,s		end of source region
	pshs	b,a
	bra	_memcpy_100
_memcpy_050
	lda	,u+
	sta	,x+
_memcpy_100
	cmpu	,s		compare with end address
	bne	_memcpy_050

	leas	2,s		dispose of end address
	ldd	6,s		return start address
	puls	x,u,pc

#endif  /* _CMOC_NEED_memcpy_ */


#ifdef _CMOC_NEED_copyMem_

; Like memcpy, but with only one argument passed on the stack.
; Input: X => Desination address.
;        D => Number of bytes to copy.
;        Pushed argument => Source address.
; Does not return anything.
; Does not preserve X or D.
; Preserves U and Y.
;
copyMem
	pshs	u		preserve frame pointer
	ldu	4,s		source address
	leau	d,u		end of source region
	pshs	u		store for loop condition
	ldu	6,s		source address
	bra	@cond
@loop
	lda	,u+
	sta	,x+
@cond
	cmpu	,s		compare with end address
	bne	@loop

	puls	x,u,pc		pull end address in X instead of leas 2,s

#endif  /* _CMOC_NEED_copyMem_ */


#ifdef _CMOC_NEED_initSingleFromSingle_

; Interface of routines named initXXXFromSingle:
; Input: D = Address of packed single-precision real to use as source.
;        X = Address of location to be initialized, of type XXX.
;
initSingleFromSingle
#ifdef _COCO_BASIC_
	pshs	u
	tfr	d,u
	ldd	,u
	std	,x
	ldd	2,u
	std	2,x
	ldb	4,u
	stb	4,x
	puls	u,pc
#else
	rts
#endif

#endif  /* _CMOC_NEED_initSingleFromSingle_ */


#ifdef _CMOC_NEED_push4ByteStruct_

; Copies a 4-byte region of memory into the stack.
; X: Address of the 4-byte region to read.
; S: Address where to copy the region to.
; Example:
;       LEAX    destination,PCR
;       LEAS    -4,S
;       LBSR    push4ByteStruct
; Preserves X. Trashes D. Returns nothing.
;
push4ByteStruct
	ldd	,x
	std	2,s
	ldd	2,x
	std	4,s
	rts

#endif  /* _CMOC_NEED_push4ByteStruct_ */


#ifdef _CMOC_NEED_push5ByteStruct_

; Copies a 5-byte region of memory into the stack.
; X: Address of the 5-byte region to read.
; S: Address where to copy the region to.
; Example:
;       LEAX    destination,PCR
;       LEAS    -5,S
;       LBSR    push5ByteStruct
; Preserves X. Trashes D. Returns nothing.
;
push5ByteStruct
	ldd	,x
	std	2,s
	ldd	2,x
	std	4,s
	ldb	4,x
	stb	6,s
	rts

#endif  /* _CMOC_NEED_push5ByteStruct_ */


#ifdef _CMOC_NEED_pushStruct_

; Copies a region of memory into the stack.
; X: Address of the region to read.
; D: Size in bytes of the region. Must not be zero.
; S: Address where to copy the region to.
; Example:
;       LEAX    destination,PCR
;       LDD     #17
;       LEAS    -17,S
;       LBSR    pushStruct
; Preserves U, Y. Trashes D, X. Returns nothing.
;
pushStruct
        pshs	u
	leau    4,s             destination (past pushed U and return address)
        leas    -2,s
	pshs    x               preserve source address
        leax    d,x             compute end of source region
        stx     2,s             preserve end
	puls    x               restore source address; ,s is now end
@copyByte
	lda	,x+
	sta	,u+
	cmpx	,s		compare with end address
	bne	@copyByte
	leas	2,s		dispose of end address
	puls	u,pc

#endif  /* _CMOC_NEED_memcpy_ */


#ifdef _CMOC_NEED_memcmp_

* int memcmp(void *s1, void *s2, size_t n)
*
* Returns 0, 1 or $FF in B. Leaves A undefined.
*
_memcmp
	pshs	u,y
	ldy	10,s		number of bytes to compare
	beq	_memcmp_equal
	ldx	6,s		1st string
	ldu	8,s		2nd string

_memcmp_loop
	lda	,x+		byte from 1st string
	cmpa	,u+		compare with byte from 2nd
	bne	_memcmp_diff	if bytes different

	leay	-1,y		one byte done
	bne	_memcmp_loop	if more to do

_memcmp_equal
	clrb			return 0: regions are equal
	bra	_memcmp_end

_memcmp_diff
	cmpa	-1,u
	bhi	_memcmp_ret1	return +1: 1st string comes after

	ldb	#$FF		return -1: 1st string comes before
	bra	_memcmp_end

_memcmp_ret1
	ldb	#1

_memcmp_end
	sex			return int
	puls	y,u,pc

#endif  /* _CMOC_NEED_memcmp_ */


#if defined(_CMOC_NEED_strcpy_) || defined(_CMOC_NEED_strcat_)

* byte *strcpy(byte *dest, byte *src);
* Returns dest.
*
_strcpy
	pshs	u,x
	ldx	6,s		destination string
	ldu	8,s		source string

_strcpy_010
	lda	,u+
	sta	,x+
	bne	_strcpy_010

	ldd	6,s		destination string
	puls	x,u,pc

#endif


#ifdef _CMOC_NEED_strncpy_

* byte *strncpy(byte *dest, byte *src, word n);
* Returns dest.
*
_strncpy
strncpy				* also defined with this name, b/c it is a utility sub-routine too
	pshs	u,y,x
	ldx	8,s		destination string
	ldu	10,s		source string
	ldy	#0		counts bytes filled
	bra	_strncpy_020

_strncpy_010
	lda	,u+		is next source byte terminator?
	beq	_strncpy_050	yes

	sta	,x+		store in destination string
	leay	1,y		one more byte filled
_strncpy_020
	cmpy	12,s		filled all bytes to fill?
	blo	_strncpy_010	no

	bra	_strncpy_090

_strncpy_040
	clr	,x+		pad with '\0'
	leay	1,y

_strncpy_050
	cmpy	12,s		filled all bytes to fill?
	blo	_strncpy_040	no
	
_strncpy_090
	ldd	8,s		destination string
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_strncpy_ */


#ifdef _CMOC_NEED_strcat_

* byte *strcat(byte *dest, byte *src);
* Returns dest.
*
_strcat
	pshs	x
	ldx	6,s		source string
	pshs	x		pass it to _strcpy

	ldx	6,s		destination string
_strcat_010
	tst	,x+
	bne	_strcat_010

	leax	-1,x		point back to '\0'
	pshs	x		pass as destination string to _strcpy

	lbsr	_strcpy

	leas	4,s		dispose of _strcpy arguments
	ldd	4,s		return original destination address
	puls	x,pc

#endif  /* _CMOC_NEED_strcat_ */


#ifdef _CMOC_NEED_strchr_

* byte *strchr(byte *s, word c)
* Note that CMOC passes a character value (e.g., 'x')
* as a word to a function.
*
_strchr pshs	x
	ldx	4,s		string
	lda	7,s		char to search for (ignore MSB)

_strchr_100
	cmpa	,x
	beq	_strchr_800	found
	tst	,x+
	bne	_strchr_100

	clra			not found: return NULL
	clrb
	bra	_strchr_900
_strchr_800
	tfr	x,d		return address where char found
_strchr_900
	puls	x,pc

#endif  /* _CMOC_NEED_strchr_ */


#ifdef _CMOC_NEED_strlwr_

* byte *strlwr(byte *)
_strlwr	pshs	x
	ldx	4,s		string address
	bra	_strlwr_020
_strlwr_010
	cmpa	#65		'A'
	blo	_strlwr_020
	cmpa	#90		'Z'
	bhi	_strlwr_020
	adda	#32		make lowercase
	sta	-1,x
_strlwr_020
	lda	,x+
	bne	_strlwr_010
	ldd	4,s		return string address
	puls	x,pc

#endif  /* _CMOC_NEED_strlwr_ */


#ifdef _CMOC_NEED_strupr_

* byte *strupr(byte *)
_strupr	pshs	x
	ldx	4,s		string address
	bra	_strupr_020
_strupr_010
	cmpa	#97		'a'
	blo	_strupr_020
	cmpa	#122		'z'
	bhi	_strupr_020
	suba	#32		make uppercase
	sta	-1,x
_strupr_020
	lda	,x+
	bne	_strupr_010
	ldd	4,s		return string address
	puls	x,pc

#endif  /* _CMOC_NEED_strupr_ */


#ifdef _CMOC_NEED_toupper_

_toupper
	ldd	2,s		character in B
	cmpb	#97		'a'
	blo	_toupper_done
	cmpb	#122		'z'
	bhi	_toupper_done
	subb	#32
_toupper_done
	rts

#endif  /* _CMOC_NEED_toupper_ */


#ifdef _CMOC_NEED_tolower_

_tolower
	ldd	2,s		character in B
	cmpb	#65		'A'
	blo	_tolower_done
	cmpb	#90		'Z'
	bhi	_tolower_done
	addb	#32
_tolower_done
	rts

#endif  /* _CMOC_NEED_tolower_ */


#if    defined(_CMOC_NEED_dwtoa_) \
    || defined(_CMOC_NEED_printf_) \
    || defined(_CMOC_NEED_sprintf_) \
    || defined(_CMOC_NEED_divDWordDWord_) \
    || defined(_CMOC_NEED_divDWordUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_signedDivDWordDWord_) \
    || defined(_CMOC_NEED_divModUnsignedIntDWord_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_modUnsignedIntDWord_)

* Subtract 32-bit unsigned integer from another.
* In: X => first integer, U => second integer.
* Out: first minus second in space pointed by X,
*      carry bit reflects subtraction.
* Preserves: all, except CC
*
sub32xu	pshs	b,a

	ldd	2,x		low word of first
	subd	2,u		low word of second
	std	2,x		store in low word of first

	ldd	,x		high word of first
	sbcb	1,u
	sbca	,u
	std	,x

	puls	a,b,pc		carry bit from last sub returned

#endif


#if defined(_CMOC_NEED_dwtoa_) || defined(_CMOC_NEED_printf_) || defined(_CMOC_NEED_sprintf_)

* byte sub32(word *hi, word h, word l)
* Subtracts 32-bit integer h:l from 32-bit unsigned integer
* pointed by 'hi'.
* Returns carry of the subtraction in B.
*
sub32:
	PSHS	U	
	LEAU	,S
	LEAS	-1,S		variable carry
	pshs	x,b
	pshs	u
	ldx	4,U		variable hi
	leau	6,U		variable h
	lbsr	sub32xu
	puls	u
	tfr	cc,b
	andb	#1
	stb	-1,U		variable carry
	puls	b,x
	LDB	-1,U		variable carry
	LEAS	,U
	PULS	U,PC	


* Utility routine for dwtoa.
*
doDigit:
	PSHS	U	
	TFR	S,U	
	LEAS	-5,S	
* Line 84: init of variable c
	CLR	-1,U		variable c

doDigit_010:
* Line 85: for body
* Line 87: init of variable hiCopy
	LDX	4,U		variable hi (word *)
	LDD	,X		read *hi (word)
	STD	-5,U		variable hiCopy
* Line 88: init of variable loCopy
	LDD	2,X		load hi[1] (word)
	STD	-3,U		variable loCopy
* Line 90: if
* Line 90: function call: sub32()
	LDD	8,U		variable l
	PSHS	B,A		argument 3 of sub32()
	LDD	6,U		variable h
	PSHS	B,A		argument 2 of sub32()
	PSHS	X		'hi': argument 1 of sub32()
	LBSR	sub32		sub32(): returns carry in B
	LEAS	6,S	
	TSTB
	BEQ	doDigit_020	no carry: continue subtracting
* Line 93: assignment: =
	LDX	4,U		variable hi
	LDD	-5,U	
	STD	,X	
* Line 94: assignment: =
	LDD	-3,U	
	STD	2,X	
	BRA	doDigit_030	break

doDigit_020:
	INC	-1,U		variable c
	BRA	doDigit_010	

doDigit_030:

* Line 101: assignment: +=
	LDB	-1,U	
	ADDB	#$30	
* Line 103: assignment: =
	LDX	10,U		variable dest (byte *)
	STB	,X		store character in *dest

	TFR	U,S	
	PULS	U,PC		end of doDigit


* char *dwtoa(char *buffer, unsigned hi, unsigned lo)
*
* Prints the 32-bit unsigned integer given by 'hi' and 'lo'
* in the designated 11-byte buffer as an ASCII decimal string
* terminated by a '\0' character.
* The resulting buffer always receives a 10-character string
* and is zero padded at the left.
* Returns (in D) the address of the first non-'0' character in the
* resulting buffer, or of the last '0' character if the given
* value was zero.
* Preserves U. Trashes X.
*
_dwtoa	PSHS	U	
	LEAU	,S
	LEAS	-5,S	
* Line 125: init of variable dest
	LDD	4,U		variable buffer
	STD	-4,U		variable dest
* Line 127: init of variable pPower
	LEAX	powersOfTen,pcr	variable pow10_9_hi
	STX	-2,U		variable pPower
* Line 131: for init
* Line 131: init of variable i
	LDB	#$09	
	STB	-5,U		variable i
	BRA	dwtoa_020	jump to for condition

dwtoa_010:
* Line 131: for body

* Line 138: function call: doDigit()
	ldx	-4,U		variable dest
	PSHS	x		argument 4 of doDigit()
	leax	1,x		point to next byte for next iteration
	stx	-4,u

	LDX	-2,U		variable pPower

	LDD	2,X		low word of that power of 10
	PSHS	B,A		argument 3 of doDigit()

	LDD	,X		high word of a power of 10
	PSHS	B,A		argument 2 of doDigit()

	leax	4,x		advance pPower to next power of 10
	stx	-2,U		store into variable pPower for next iteration

	LEAX	6,U		point to argument 'hi', which is followed by 'lo'
	PSHS	X		argument 1 of doDigit()

	BSR	doDigit

	LEAS	8,S	

* Line 131: for increment
	DEC	-5,U		variable i
dwtoa_020:
* Line 131: for condition
	TST	-5,U	
	BNE	dwtoa_010	end of loop of calls to doDigit()

* Store last digit, which is in variable 'lo', at 'dest'.
* Line 143: assignment: =
	LDB	9,U		low byte of variable lo (contains 0..9)
	addb	#$30		make 0..9 into '0'..'9' in ASCII
	LDX	-4,U		variable dest
	STB	,X+
	clr	,x		write terminating '\0'

* Skip leading zeroes in the resulting string.
	LDX	4,U		variable buffer
dwtoa_030:
	LDB	,X+
	CMPB	#$30
	BEQ	dwtoa_030	

	leax	-1,x

* If entire string contains '\0' characters, return address of last '\0'.
	TST	,X	
	BNE	dwtoa_040	
	leax	-1,x

dwtoa_040:
	tfr	x,d		return address of 1st non-0 digit, or of last 0 if value is 0

	LEAS	,U
	PULS	U,PC	

* Powers of ten as 32-bit integers, in descending order.
* Used by dwtoa.
*
powersOfTen:
	FDB	$3b9a,$ca00	10**9
	FDB	$05f5,$e100	10**8
	FDB	$0098,$9680	10**7
	FDB	$000f,$4240	10**6
	FDB	$0001,$86a0	10**5
	FDB	$0000,$2710	10**4
	FDB	$0000,$03E8	10**3
	FDB	$0000,$0064	10**2
	FDB	$0000,$000A	10**1

#endif  /* _CMOC_NEED_dwtoa_ */


#ifdef _CMOC_CHECK_NULL_POINTERS_

* void set_null_ptr_handler(char *newHandler);
*
_set_null_ptr_handler:
	LDD	2,S	first argument
	STD	null_ptr_handler,DAT
check_null_ptr_x_end:
	RTS


* Checks if the pointer in X in null and if it is, invokes
* the handler in null_ptr_handler.
* 
check_null_ptr_x:
	CMPX	#0
	BNE	check_null_ptr_x_end
	PSHS	U,Y,X,B,A
	LDD	8,S	return address of LBSR that led to this routine
	SUBD	#3	point to LBSR instruction
	PSHS	B,A
	JSR	[null_ptr_handler,DAT]
	LEAS	2,S
	PULS	A,B,X,Y,U,PC

#endif  /* _CMOC_CHECK_NULL_POINTERS_ */


#ifdef _CMOC_CHECK_STACK_OVERFLOW_

_set_stack_overflow_handler:
	LDD	2,S	first argument
	STD	stack_overflow_handler,DAT
	RTS

check_stack_overflow:
        PSHS    B,A
	LDD	stack_overflow_handler,DAT	is there a handler?
	BEQ	no_stack_overflow		no
	CMPS    end_of_sbrk_mem,DAT
	BLO     stack_overflow_detected
	CMPS	INISTK,DAT
	BLO	no_stack_overflow
stack_overflow_detected:
	LDD	stack_overflow_handler,DAT	get current handler
	LDX	#0				disable stack checking
	STX	stack_overflow_handler,DAT	because handler calls this routine
	TFR	D,X	preserve handler address in X, for the JSR

	TFR	S,D	pass out-of-range stack ptr as 2nd argument to handler
	ADDD	#4	don't count current routine call
	PSHS	B,A
	LDD	4,S	return address of LBSR that led to this routine
	SUBD	#3	point to LBSR instruction
	PSHS	B,A
	JSR	,X	handler does not have to return
stack_overflow_freeze:
	BRA	stack_overflow_freeze	freeze if handler returned
no_stack_overflow:
        PULS    A,B,PC

#endif  /* _CMOC_CHECK_STACK_OVERFLOW_ */


#ifdef _CMOC_NEED_sbrk_

* void *sbrk(size_t increment);
*
* Returns (byte *) -1 upon failure (not enough memory).
* Returns the old program break upon success
* (i.e., the address of the newly allocated buffer).
*
* Asking for an increment of zero always succeeds.
* This can be used to get the current program break.
*
* Uses the program_end label generated by the compiler at the very end
* of the generated program.
*
* Return value will be in D. Does not preserve X.
*
* The following system variables are initialized by INILIB.
*
_sbrk
	lbsr	_sbrkmax		D = max number of allocatable bytes
	cmpd	2,s			compare with 'increment'
	bhs	sbrk_success		increment not too large: allocate
	ldd	#-1			fail
	rts
sbrk_success:
	ldd	2,s			get 'increment'
	addd	program_break,DAT	new, tentative program break
	ldx	program_break,DAT	preserve original program break
	std	program_break,DAT	advance program break
	tfr	x,d			return original program break in D
	rts

#endif  /* _CMOC_NEED_sbrk_ */


#if defined(_CMOC_NEED_sbrkmax_) || defined(_CMOC_NEED_sbrk_)

* size_t sbrkmax();
*
* Returns (in D) the maximum number of bytes that can be successfully
* asked of sbrk().
*
_sbrkmax
	ldd	end_of_sbrk_mem,DAT
	subd	program_break,DAT
        bhs     _sbrkmax_non_neg
* The program break is after the stack space. Not supported by sbrk().
        clra
        clrb
_sbrkmax_non_neg
	rts

#endif  /* defined(_CMOC_NEED_sbrkmax_) || defined(_CMOC_NEED_sbrk_) */


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Support for the "long" type.
;

#if    defined(_CMOC_NEED_copyDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: X = destination address; D = source address.
; Preserves X. Trashes D.
;
copyDWord
	pshs	u
	tfr     d,u		; source address
	ldd	,u		; high word
	std	,x
	ldd	2,u		; low word
	std	2,x
	puls	u,pc

#endif


#if    defined(_CMOC_NEED_copyDWordFromXToD_)

; Copies a 4-byte region of memory.
; X: Address of the 4 bytes to read.
; D: Address where to copy the bytes to.
; Preserves X. Trashes D. Returns nothing.
;
copyDWordFromXToD
        pshs    u
        tfr     d,u
	ldd	,x
	std	,u
	ldd	2,x
	std	2,u
	puls    u,pc

#endif


#if    defined(_CMOC_NEED_negateDWord_) \
    || defined(_CMOC_NEED_testAndRemoveSignOnDWord_) \
    || defined(_CMOC_NEED_testAndRemoveSignOnWord_) \
    || defined(_CMOC_NEED_signedDivDWordDWord_) \
    || defined(_CMOC_NEED_printf_) \
    || defined(_CMOC_NEED_strtoul_) \
    || defined(_CMOC_NEED_strtol_) \
    || defined(_CMOC_NEED_initDWordFromSingle_)

; Input: X => Long to negate.
; Preserves X. Trashes D.
;
negateDWord
	com	3,x
	com	2,x
	com	1,x
	com	,x
	ldd	2,x		; low word
	addd	#1		; sets carry value
	std	2,x
	ldd	,x		; high word
	adcb	#0		; add carry
	adca	#0
	std	,x
	rts

#endif


#if    defined(_CMOC_NEED_cmpDWordDWord_) \
    || defined(_CMOC_NEED_cmpDWordSignedInt_) \
    || defined(_CMOC_NEED_cmpSignedIntDWord_) \
    || defined(_CMOC_NEED_cmpDWordUnsignedInt_) \
    || defined(_CMOC_NEED_cmpUnsignedIntDWord_) \
    || defined(_CMOC_NEED_divModDWordDWord_) \
    || defined(_CMOC_NEED_divDWordDWord_) \
    || defined(_CMOC_NEED_modDWordDWord_) \
    || defined(_CMOC_NEED_divDWordUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_signedDivDWordDWord_) \
    || defined(_CMOC_NEED_divModUnsignedIntDWord_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_modUnsignedIntDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: Stacked arguments: address of left dword, address of right dword.
; Output: Sets N, Z, V, C.
; Preserves X, Y, U. Trashes D.
;
cmpDWordDWord
	pshs	u,x
	ldx	6,s		; left long
	ldu	8,s		; right long
	leas	-5,s		; locals
; ,s (4 bytes): temp long
; 4,s: temp flags
;
	bsr	sub32Stack	; *X - *U in ,s; sets N, V, C
	tfr	cc,b
	andb	#$FB		; reset Z (Z to be computed separatedly)
	stb	4,s		; preserve CC from sub32Stack

	bsr	isLongZeroStack	; checks 4 bytes at ,s
	tfr	cc,a
	anda	#4		; keep only Z
	ora	4,s		; add flags from CC obtained from sub32Stack

	tfr	a,cc
	leas	5,s
	puls	x,u,pc

; Pushed long receives *X - *U (unsigned).
; Sets N, V, C. Trashes D.
;
sub32Stack
	ldd	2,x
	subd	2,u
	std	4,s	; low word of result
	ldd	,x	
	sbcb	1,u
	sbca	,u
	pshs	cc	; preserve flags to be returned
	std	3,s	; high word of result
	puls	cc,pc

; Checks if pushed long is zero. Sets Z flag.
; Preserves registers.
;
isLongZeroStack
	tst	2,s
	bne	@done
	tst	3,s
	bne	@done
	tst	4,s
	bne	@done
	tst	5,s
@done	rts

#endif


#if defined(_CMOC_NEED_isDWordZero_)

; Input: X => long.
; Output: Z flag.
; Preserves X and D.
;
isDWordZero
	tst	,x
	bne	@done
	tst	1,x
	bne	@done
	tst	2,x
	bne	@done
	tst	3,x
@done	rts

#endif


#if defined(_CMOC_NEED_cmpDWordSignedInt_)

; Input: 2 pushed arguments.
; Preserves X and U. Trashes D.
;
cmpDWordSignedInt
	pshs	u,x
	ldx	6,s		; address of dword
	ldd	8,s		; signed int
	pshs	b,a		; create temp dword in stack
	tfr	a,b
	sex			; sign extend int into A
	pshs	a
	pshs	a		; pushed dword version of int
	leau	,s		; point to dword (right side)
	pshs	u,x
	lbsr	cmpDWordDWord
	leas	8,s		; clean up pushed U and X, and temp long
	puls	x,u,pc

#endif


#if defined(_CMOC_NEED_cmpSignedIntDWord_)

cmpSignedIntDWord
	pshs	u,x
	ldu	8,s		; address of dword
	ldd	6,s		; signed int
	pshs	b,a		; create temp dword in stack
	tfr	a,b
	sex			; sign extend int into A
	pshs	a
	pshs	a		; pushed dword version of int
	leax	,s		; point to dword (left side)
	pshs	u,x
	lbsr	cmpDWordDWord
	leas	8,s		; clean up pushed U and X, and temp long
	puls	x,u,pc

#endif


#if defined(_CMOC_NEED_cmpDWordUnsignedInt_)

cmpDWordUnsignedInt
	pshs	u,x
	ldx	6,s		; address of dword
	ldd	8,s		; unsigned int
	pshs	b,a		; create temp dword in stack
	clr	,-s
	clr	,-s		; pushed dword version of int
	leau	,s		; point to dword (right side)
	pshs	u,x
	lbsr	cmpDWordDWord
	leas	8,s		; clean up pushed U and X, and temp long
	puls	x,u,pc

#endif


#if defined(_CMOC_NEED_cmpUnsignedIntDWord_)

cmpUnsignedIntDWord
	pshs	u,x
	ldu	8,s		; address of dword
	ldd	6,s		; signed int
	pshs	b,a		; create temp dword in stack
	clr	,-s
	clr	,-s		; pushed dword version of int
	leau	,s		; point to dword (left side)
	pshs	u,x
	lbsr	cmpDWordDWord
	leas	8,s		; clean up pushed U and X, and temp long
	puls	x,u,pc

#endif


#if defined(_CMOC_NEED_addDWordDWord_)

; Input: pushed addresses: left dword, right dword.
;        X => destination dword.
; Output: Result at X.
; Preserves X. Trashes D.
;
addDWordDWord
	pshs	u,y
	ldu	6,s		; left
	ldy	8,s		; right

	ldd	2,u		; low word
	addd	2,y
	std	2,x

	ldd	,u		; high word
	adcb	1,y
	adca	,y
	std	,x

	puls	y,u,pc

#endif


#if defined(_CMOC_NEED_addDWordUnsignedInt_)

; Input: Pushed arguments: address of dword, value of unsigned int.
;        X => destination dword.
; Preserves X.
;
addDWordUnsignedInt
	pshs	u
	ldu	4,s		; source dword
	ldd	6,s		; word to add
	addd	2,u		; add to low word of source dword; sets carry
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	adcb	#0		; add carry of low word add
	adca	#0
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_addUnsignedIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
addUnsignedIntDWord
	pshs	u
	ldu	6,s		; source dword
	ldd	4,s		; word to add
	addd	2,u		; add to low word of source dword; sets carry
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	adcb	#0		; add carry of low word add
	adca	#0
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_addDWordInt_)

; Input: Pushed arguments: address of dword, value of signed int.
;        X => destination dword.
; Preserves X.
;
addDWordInt
	pshs	u
	ldu	4,s		; source dword
	ldd	6,s		; word to add
	addd	2,u		; add to low word of source dword; sets carry
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	adcb	#0		; add carry of low word add
	adca	#0
	tst	6,s		; test sign bit of high word of int
	bpl	@intNotNeg
	addd	#$FFFF		; as if int had been sign-extended to 32 bits
@intNotNeg
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_addIntDWord_)

; Input: Pushed arguments: value of signed int, address of dword.
;        X => destination dword.
; Preserves X.
;
addIntDWord
	pshs	u
	ldu	6,s		; source dword
	ldd	4,s		; word to add
	addd	2,u		; add to low word of source dword; sets carry
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	adcb	#0		; add carry of low word add
	adca	#0
	tst	4,s		; test sign bit of high word of int
	bpl	@intNotNeg
	addd	#$FFFF		; as if int had been sign-extended to 32 bits
@intNotNeg
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_subDWordDWord_)

subDWordDWord
	pshs	u,y
	ldu	6,s		; left
	ldy	8,s		; right

	ldd	2,u		; low word
	subd	2,y
	std	2,x

	ldd	,u		; high word
	sbcb	1,y
	sbca	,y
	std	,x

	puls	y,u,pc

#endif


#if defined(_CMOC_NEED_subDWordUnsignedInt_)

; Input: Pushed arguments: address of dword, value of unsigned int.
;        X => destination dword.
; Preserves X.
;
subDWordUnsignedInt
	pshs	u
	ldu	4,s		; source dword
	ldd	2,u		; load low word of source dword
	subd	6,s		; subtract right side
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	sbcb	#0		; sub carry of low word sub
	sbca	#0
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_subUnsignedIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
subUnsignedIntDWord
	pshs	u
	ldd	4,s		; left side
	ldu	6,s		; source dword
	subd	2,u		; sub low word of source dword
	std	2,x		; store in low word of result dword
	ldd	#0		; zero-extend left side (clra & clrb would clear C)
	sbcb	1,u		; sub carry of low word sub from zero-extension
	sbca	,u
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_subDWordInt_)

; Input: Pushed arguments: address of dword, value of unsigned int.
;        X => destination dword.
; Preserves X.
;
subDWordInt
	pshs	u
	ldu	4,s		; source dword
	ldd	2,u		; load low word of source dword
	subd	6,s		; subtract right side
	std	2,x		; store in low word of result dword
	ldd	,u		; load high word of source dword
	sbcb	#0		; sub carry of low word sub
	sbca	#0
	tst	6,s		; test sign bit of high word of int
	bpl	@intNotNeg
	subd	#$FFFF		; as if int had been sign-extended to 32 bits
@intNotNeg
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_subIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
subIntDWord
	pshs	u
	ldd	4,s		; left side
	ldu	6,s		; source dword
	subd	2,u		; sub low word of source dword
	std	2,x		; store in low word of result dword
	ldd	#0		; zero-extend left side (clra & clrb would clear C)
	sbcb	1,u		; sub carry of low word sub from zero-extension
	sbca	,u
	tst	4,s		; test sign bit of high word of int
	bpl	@intNotNeg
	subd	#1
@intNotNeg
	std	,x
	puls	u,pc

#endif


#if    defined(_CMOC_NEED_mulDWordDWord_) \
    || defined(_CMOC_NEED_mulDWordUnsignedInt_) \
    || defined(_CMOC_NEED_mulUnsignedIntDWord_) \
    || defined(_CMOC_NEED_mulDWordInt_) \
    || defined(_CMOC_NEED_mulIntDWord_) \
    || defined(_CMOC_NEED_strtoul_) \
    || defined(_CMOC_NEED_strtol_)

; Multiplies the two unsigned longs whose addresses are in X (left)
; and U (right). Stores the result in the unsigned long at Y.
; Synopsis:
;	pshs	y
; 	leax	left,pcr
;	leau	right,pcr
;	leay	product,pcr
;	lbsr	MUL32
;	puls	y
; Preserves X, U and Y. Trashes D.
;
MUL32
;
; Let L0,L1,L2,L3 be the 4 bytes of the left operand.
; Let R0,R1,R2,R3 be the 4 bytes of the right operand.
; The product is
;	         L3 * (R0,R1,R2,R3)
;	+ 2^8  * L2 * (R0,R1,R2,R3)
;	+ 2^16 * L1 * (R0,R1,R2,R3)
;	+ 2^24 * L0 * (R0,R1,R2,R3)
; But some parts of this formula overflow the resulting 32-bit word.
; The the 32-bit result is
;	         L3 * (R0,R1,R2,R3)
;	+ 2^8  * L2 * (R1,R2,R3)
;	+ 2^16 * L1 * (R2,R3)
;	+ 2^24 * L0 * R3.
; 
; Let P3,P2,P1,P0 be the product to be computed in the result buffer.
;
	lda	3,x		; L3
	ldb	3,u		; R3
	mul
	std	2,y		; store in P2,P3

	lda	3,x		; L3
	ldb	2,u		; R2
	mul
	addb	2,y		; add P2
	adca	#0
	std	1,y		; store in P1,P2

	lda	3,x		; L3
	ldb	1,u		; R1
	mul
	addb	1,y		; add P1
	adca	#0
	std	,y		; store in P0,P1

	lda	3,x		; L3
	ldb	,u		; R0
	mul
	addb	,y		; add P0
	stb	,y		; store in P0

; Done with L3.

	lda	2,x		; L2
	ldb	3,u		; R3
	mul
	addb	2,y		; add P2
	adca	1,y		; add P1
	std	1,y		; store in P1,P2
	ldb	,y		; add carry to P0
	adcb	#0
	stb	,y

	lda	2,x		; L2
	ldb	2,u		; R2
	mul
	addb	1,y		; add P1
	adca	,y		; add P0
	std	,y		; store in P0,P1

	lda	2,x		; L2
	ldb	1,u		; R1
	mul
	addb	,y		; add P0
	stb	,y		; store in P0

; Done with L2.

	lda	1,x		; L1
	ldb	3,u		; R3
	mul
	addb	1,y		; add P1
	adca	,y		; add P0
	std	,y		; store in P0,P1

	lda	1,x		; L1
	ldb	2,u		; R2
	mul
	addb	,y		; add P0
	stb	,y		; store in P0

; Done with L1.

	lda	,x		; L0
	ldb	3,u		; R3
	mul
	addb	,y		; add P0
	stb	,y		; store in P0

; Done with L0.

	rts

#endif


#if defined(_CMOC_NEED_mulDWordDWord_)

; Input: pushed arguments: addresses of left and right dwords
;        X => destination dword: X is allowed to be the same address
;             as that of the left dword.
; Output: product at X.
; Preserves X. Trashes D.
;
mulDWordDWord
	pshs	u,y,x
	leas	-4,s		; temp result
	leay	,s		; make MUL32 store result at ,s
	ldx	12,s		; left address
	ldu	14,s		; right address
	lbsr	MUL32
	ldx	4,s		; original X points to destination
    	ldd	,y		; copy MUL32 result to original X
	std	,x
	ldd	2,y
	std	2,x
	leas	4,s
	puls	x,y,u,pc

#endif


#if defined(_CMOC_NEED_mulDWordUnsignedInt_) \
    || defined(_CMOC_NEED_strtoul_) \
    || defined(_CMOC_NEED_strtol_)

; Input: Pushed arguments: address of dword, value of unsigned int.
;        X => destination dword: X is allowed to be the same address
;             as that of the left dword.
; Preserves X.
;
mulDWordUnsignedInt
	pshs	u,y,x
	leas	-4,s		; temp result
	leay	,s		; make MUL32 store result at ,s
	ldx	12,s		; left address
	ldd	14,s		; right side
	pshs	b,a
	clr	,-s
	clr	,-s
	leau	,s		; point to zero-extended right side
	lbsr	MUL32
	ldx	8,s		; original X points to destination
    	ldd	,y		; copy MUL32 result to original X
	std	,x
	ldd	2,y
	std	2,x
	leas	8,s
	puls	x,y,u,pc

#endif


#if defined(_CMOC_NEED_mulUnsignedIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
mulUnsignedIntDWord
	pshs	u,y,x
	tfr	x,y		; result address
	ldd	8,s		; left side
	ldx	10,s		; right address
	pshs	b,a
	clr	,-s
	clr	,-s
	leau	,s		; point to zero-extended left side
	lbsr	MUL32
	leas	4,s
	puls	x,y,u,pc

#endif


#if defined(_CMOC_NEED_mulDWordInt_)

; Input: Pushed arguments: address of dword, value of signed int.
;        X => destination dword: X is allowed to be the same address
;             as that of the left dword.
; Preserves X.
;
mulDWordInt
	pshs	u,y,x
	leas	-4,s		; temp result
	leay	,s		; make MUL32 store result at ,s	
	ldx	12,s		; left address
	ldd	14,s		; right side
	pshs	b,a
	tfr	a,b
	sex
	pshs	a
	pshs	a
	leau	,s		; point to sign-extended right side
	lbsr	MUL32
	ldx	8,s		; original X points to destination
    	ldd	,y		; copy MUL32 result to original X
	std	,x
	ldd	2,y
	std	2,x
	leas	8,s
	puls	x,y,u,pc

#endif


#if defined(_CMOC_NEED_mulIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
mulIntDWord
	pshs	u,y,x
	tfr	x,y		; result address
	ldd	8,s		; left side
	ldx	10,s		; right address
	pshs	b,a
	tfr	a,b
	sex
	pshs	a
	pshs	a
	leau	,s		; point to zero-extended left side
	lbsr	MUL32
	leas	4,s	
	puls	x,y,u,pc

#endif


#if    defined(_CMOC_NEED_divModDWordDWord_) \
    || defined(_CMOC_NEED_divDWordDWord_) \
    || defined(_CMOC_NEED_modDWordDWord_) \
    || defined(_CMOC_NEED_divDWordUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_signedDivDWordDWord_) \
    || defined(_CMOC_NEED_divModUnsignedIntDWord_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_modUnsignedIntDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Divides the unsigned long at X by the one at U.
; Stores the quotient in the unsigned long at Y
; and the remainder in the unsigned long at 4,Y.
; The 8 bytes at Y must not overlap the dividend or divisor.
; Synopsis:
;	pshs	y
; 	leax	dividend,pcr
;	leau	divisor,pcr
;	leay	eightByteBuffer,pcr
;	lbsr	DIV32
;	puls	y
; Preserves the divisor, X, Y, U. Trashes the dividend and D.
;
DIV32
	ldb	#32
	pshs	b
; 0,s: loop counter.
	clra
	clrb
	std	,y		; clear quotient
	std	2,y
	std	4,y		; clear accumulator (finishes as the remainder)
	std	6,y
@loop	lsl	3,x		; shift high bit of dividend into carry
	rol	2,x
	rol	1,x
	rol	,x
	rol	7,y		; shift that bit into bit 0 of acc
	rol	6,y
	rol	5,y
	rol	4,y
	bsr	@doesDivisorFitAcc
	blo	@noFit		; if not
	bsr	@subDivisorFromAcc
	orcc	#1		; set carry
	bra	@carryToQuotient
@noFit
	andcc	#$FE		; reset carry
@carryToQuotient
	rol	3,y		; shift carry into quotient
	rol	2,y
	rol	1,y
	rol	,y
	dec	,s		; another bit of the dividend to process?
	bne	@loop		; if yes
	puls	b,pc
;
; Input: U => divisor, 4,Y => accumulator.
; Output: C=1 if accumulator < divisor, C=0 otherwise (i.e., divisor goes into acc).
;
@doesDivisorFitAcc
	pshs	x		; preserve X
	leax	4,y
	pshs	u,x
	lbsr	cmpDWordDWord	; sets C
	leas	4,s
	puls	x,pc
;
; Input: U => divisor, 4,Y => accumulator.
;
@subDivisorFromAcc
	pshs	x		; preserve X
	leax	4,y
	lbsr	sub32xu		; *X -= *U
	puls	x,pc

#endif


#if defined(_CMOC_NEED_divModDWordDWord_) \
    || defined(_CMOC_NEED_divDWordDWord_) \
    || defined(_CMOC_NEED_modDWordDWord_)

; Input: pushed addresses of dividend and divisor;
;        X => address of result (quotient or remainder);
;        B => 0 for division, 1 for remainder.
; Preserves X, Y, U. Trashes D.
;
divModDWordDWord
	pshs	u,y,x,b
	leas	-12,s
; 0,s: Copy of dividend (to avoid modifying the caller's).
; 4,s: Quotient received from DIV32.
; 8,s: Remainder received from DIV32.
	ldx	21,s		; address of dividend
	ldd	,x		; copy to 0,s
	std	,s
	ldd	2,x
	std	2,s
	leax	,s		; point to dividend
	ldu	23,s		; point to divisor
	leay	4,s		; point to quotient and remainder (8 bytes)
	lbsr	DIV32
	ldx	13,s		; retrieve destination address for quotient
	tst	12,s		; caller wants quotient or remainder?
	bne	@remainder
	leau	4,s
	bra	@copy
@remainder
	leau	8,s
@copy
	ldd	,u		; copy result to X
	std	,x
	ldd	2,u
	std	2,x
	leas	12,s
	puls	b,x,y,u,pc

#endif


#if defined(_CMOC_NEED_divDWordDWord_)

divDWordDWord
	clrb
	lbra	divModDWordDWord

#endif


#if defined(_CMOC_NEED_modDWordDWord_)

modDWordDWord
	ldb	#1
	lbra	divModDWordDWord

#endif


#if defined(_CMOC_NEED_divModDWordUnsignedInt_) \
    || defined(_CMOC_NEED_divDWordUnsignedInt_) \
    || defined(_CMOC_NEED_modDWordUnsignedInt_)

; Input: Pushed arguments: address of dword, value of unsigned int.
;        X => destination dword.
; Preserves X.
;
divModDWordUnsignedInt
	pshs	u,y,x,b
	leas	-16,s
; 0,s: Copy of dividend (to avoid modifying the caller's).
; 4,s: Extension of divisor to 32 bits.
; 8,s: Quotient received from DIV32.
; 12,s: Remainder received from DIV32.
	ldx	25,s		; address of dividend
	ldd	,x		; copy to 0,s
	std	,s
	ldd	2,x
	std	2,s
	leax	,s		; point to dividend
	ldd	27,s		; value of divisor
	std	6,s		; extend divisor to 32 bits
	clr	5,s
	clr	4,s
	leau	4,s		; point to 32-bit divisor
	leay	8,s		; point to quotient and remainder (8 bytes)
	lbsr	DIV32
	ldx	17,s		; retrieve destination address for quotient
	tst	16,s		; caller wants quotient or remainder?
	bne	@remainder
	leau	8,s
	bra	@copy
@remainder
	leau	12,s
@copy
	ldd	,u		; copy quotient to X
	std	,x
	ldd	2,u
	std	2,x
	leas	16,s
	puls	b,x,y,u,pc

#endif


#if defined(_CMOC_NEED_divDWordUnsignedInt_)

divDWordUnsignedInt
	clrb
	lbra	divModDWordUnsignedInt

#endif


#if defined(_CMOC_NEED_modDWordUnsignedInt_)

modDWordUnsignedInt
	ldb	#1
	lbra	divModDWordUnsignedInt

#endif


#if defined(_CMOC_NEED_divModUnsignedIntDWord_) \
    || defined(_CMOC_NEED_divUnsignedIntDWord_) \
    || defined(_CMOC_NEED_modUnsignedIntDWord_)

; Input: Pushed arguments: value of unsigned int, address of dword.
;        X => destination dword.
; Preserves X.
;
divModUnsignedIntDWord
	pshs	u,y,x,b
	leas	-12,s
; 0,s: Dividend extended to 32 bits.
; 4,s: Quotient received from DIV32.
; 8,s: Remainder received from DIV32.
	ldd	21,s		; value of dividend
	std	2,s		; extend to 32 bits
	clr	1,s
	clr	,s
	leax	,s		; point to dividend
	ldu	23,s		; address of divisor
	leay	4,s		; point to quotient and remainder (8 bytes)
	lbsr	DIV32
	ldx	13,s		; retrieve destination address for quotient
	tst	12,s		; caller wants quotient or remainder?
	bne	@remainder
	leau	4,s
	bra	@copy
@remainder
	leau	8,s
@copy
	ldd	,u		; copy quotient to X
	std	,x
	ldd	2,u
	std	2,x
	leas	12,s
	puls	b,x,y,u,pc

#endif


#if defined(_CMOC_NEED_divUnsignedIntDWord_)

divUnsignedIntDWord
	clrb
	lbra	divModUnsignedIntDWord

#endif


#if defined(_CMOC_NEED_modUnsignedIntDWord_)

modUnsignedIntDWord
	ldb	#1
	lbra	divModUnsignedIntDWord

#endif


#if    defined(_CMOC_NEED_testAndRemoveSignOnDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: pushed address => dword to test;
;        X => destination to copy absolute value of dword to;
; Output: non-negative dword at X;
;         N is 1 if input dword was negative, 0 otherwise.
; Preserves X. Trashes D.
;
testAndRemoveSignOnDWord
	pshs	u
	ldu	4,s		; address of input dword
	ldd	2,u		; copy input dword to destination
	std	2,x
	ldd	,u
	std	,x
	bpl	@done		; branch if high bit of high word is 0
; Input dword is negative: remove sign of destination dword.
	lbsr	negateDWord
	orcc	#8		; set N = 1
@done
	puls	u,pc
#endif


#if defined(_CMOC_NEED_testAndRemoveSignOnWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: pushed word => signed word to test;
;        X => dword that receives absolute value of word.
; Output: non-negative dword at X;
;         N is 1 if input word was negative, 0 otherwise.
; Preserves X. Trashes D.
;
testAndRemoveSignOnWord
	ldd	2,s		; pushed argument
	std	2,x
	tfr	a,b		; sign extension
	sex
	sta	1,x
	sta	,x
	bpl	@done
	lbsr	negateDWord	; dword at X is < 0; make is positive
	orcc	#8		; set N = 1
@done
	rts

#endif


#if    defined(_CMOC_NEED_copyWordToDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: pushed word => input word;
;        X => destination dword.
; Output: Zero-extended dword at X.
; Preserves X. Trashes D.
;
copyWordToDWord
	ldd	2,s
	std	2,x
	clr	1,x
	clr	,x
	rts

#endif


#if    defined(_CMOC_NEED_signExtWordToDWord_) \
    || defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: pushed word => input signed word;
;        X => destination dword.
; Output: Sign-extended dword at X.
; Preserves X. Trashes D.
;
signExtWordToDWord
	ldd	2,s
	std	2,x
	tfr	a,b
	sex
	sta	1,x
	sta	,x
	rts

#endif


#if defined(_CMOC_NEED_signedDivOrModOnDWord_)

; Input: bit 3 of B: sign to give to the quotient.
;        X => 2 unsigned dwords (dividend, divisor).
; Output: quotient written in place of dividend; remainder in place of divisor
; Preserves B. Trashes A and X.
; 
signedDivDWordDWord
	pshs	u,y,b
	leas	-8,s		; result of DIV32

	leau	4,x		; point to divisor
	leay	,s		; point to result dwords
	lbsr	DIV32

	ldd	,y		; copy quotient over dividend
	std	,x
	ldd	2,y
	std	2,x
	ldd	4,y		; copy remainder over divisor
	std	4,x
	ldd	6,y
	std	6,x

	ldb	8,s		; look at input B: is quotient negative?
	bitb	#8		; N flag
	beq	@notNeg		; branche if quotient non-negative
	lbsr	negateDWord	; negative quotient (at X)
@notNeg
	leas	8,s
	puls	b,y,u,pc

; Input: push word: address of source dword;
;        X => address of destination dword;
;        bit 3 or B: sign to give to the destination dword.
; Preserves X.
;
copyModuloDWord
	pshs	u,b
	ldu	5,s		; address of source dword
	ldd	,u
	std	,x
	ldd	2,u
	std	2,x
	ldb	,s		; check N in flags received in B
	bitb	#8
	beq	@done
	lbsr	negateDWord
@done
	puls	b,u,pc


; Output: X => destination dword; B = flag byte.
; Trashes D.
;
signedDivOrModOnDWord
	pshs	u
	leau	,s
	leas	-10,s
	pshs	b
; Arguments:
; 4,U: address of destination dword.
; 6,U: dividend (address if dword; word value if short integral).
; 8,U: divisor (address if dword; word value if short integral).
; Locals:
; -4,U: 2nd temp dword (divisor as dword)
; -8,U: 1st temp dword (dividend as dword)
; -9,U: CC of divisor.
; -10,U: CC of dividend.
; -11,U: flag byte received from caller in B:
;            bit 0 ($01): operation flag (0 = modulo, 1 = division)
;            bit 1 ($02): quotient signedness flag (0 = unsigned, 1 = signed)
;            bit 2 ($04): dividend size flag (0 = word, 1 = dword)
;            bit 3 ($08): dividend signedness flag
;            bit 4 ($10): divisor size flag
;            bit 5 ($20): divisor signedness flag
;
; Convert divisor to non-negative.
	
	ldx	8,u	; divisor
	pshs	x	; pass to utility routine
	leax	-4,u	; 2nd temp word
	ldb	-11,u	; flag byte
	andb	#$22	; divisor and quotient signedness flags
	cmpb	#$22
	bne	@noSignToRemoveOnDivisor
; Remove sign on divisor.
	ldb	-11,u		; flag byte
	bitb	#$10		; is divisor word or dword?
	beq	@wordDivisor_0
	lbsr	testAndRemoveSignOnDWord
	bra	@divisorSignRemoved
@wordDivisor_0
	lbsr	testAndRemoveSignOnWord
@divisorSignRemoved
	tfr	cc,b		; preserve N flag for divisor
	stb	-9,u
	bra	@divisorNowDWord
;
@noSignToRemoveOnDivisor
; Copy divisor to 2nd temp dword.
	ldb	-11,u		; flag byte
	bitb	#$10		; is divisor word or dword?
	beq	@wordDivisor_1
        ldd     ,s              ; address of word to copy
	lbsr	copyDWord
	bra	@nullN
@wordDivisor_1
	bitb	#$20		; divisor signedness
	beq	@unsignedWordDivisor
	lbsr	signExtWordToDWord
	bra	@nullN
@unsignedWordDivisor
	lbsr	copyWordToDWord
@nullN
	clr	-9,u		; null N flag for divisor
;
@divisorNowDWord
	leas	2,s		; discard arg of utility routine
;
; Convert dividend to non-negative.
	ldx	6,u	; dividend
	pshs	x	; pass to utility routine
	leax	-8,u	; 1st temp dword
	ldb	-11,u	; flag byte
	andb	#$0A	; dividend and quotient signedness
	cmpb	#$0A
	bne	@noSignToRemoveOnDividend
; Remove sign on dividend.
	ldb	-11,u	; flag byte
	bitb	#$04	; is dividend word or dword?
	beq	@wordDividend_0
	lbsr	testAndRemoveSignOnDWord
	bra	@dividendSignRemoved
@wordDividend_0
	lbsr	testAndRemoveSignOnWord
@dividendSignRemoved
	bra	@dividendNowDWord
;
@noSignToRemoveOnDividend
; Copy dividend to 1st temp dword.
	ldb	-11,u	; flag byte
	bitb	#$04	; is dividend word or dword?
	beq	@wordDividend_1
        ldd     ,s             ; address of word to copy
	lbsr	copyDWord
	bra	@andcc
@wordDividend_1
	bitb	#$08	; dividend signedness
	beq	@unsignedWordDividend
	lbsr	signExtWordToDWord
	bra	@andcc
@unsignedWordDividend
	lbsr	copyWordToDWord
@andcc
	andcc	#$F7		; null N flag for dividend
;
@dividendNowDWord
	leas	2,s		; discard arg of utility routine
;
; Here, the N flag represents the sign of the left side.
; Call the division routine.
	tfr	cc,b		; N flag in B
	stb	-10,u		; preserve sign of dividend
	eorb	-9,u		; XOR with sign of divisor
	leax	-8,u		; point to the 2 temp dwords
	lbsr	signedDivDWordDWord
;
; Resulting dword is one of temp dwords, depending on operation.
;
	leax	-8,u		; 1st temp dword (contains quotient)
	ldb	-11,u	; flag byte
	bitb	#$01		; operation
	bne	@division_0
	leax	4,x		; 2nd temp dword (contains modulo)
@division_0
	pshs	x		; address to dword to copy
	ldx	4,u		; address of destination dword
	bitb	#$01		; operation
	bne	@division_1
	ldb	-10,u		; sign of dividend
	lbsr	copyModuloDWord	; preserves X
	bra	@done
@division_1
        ldd     ,s              ; address of word to copy
	lbsr	copyDWord	; preserves X
@done
	leas	,u		; discards arg pushed to copy*DWord
	puls	u,pc

#endif


#if defined(_CMOC_NEED_initDWordFromSignedWord_)

; Input: X => dword to initialize. D => signed word to initialize the dword with.
; Preserves X. Trashes D.
;
initDWordFromSignedWord
	std	2,x		; low word
	tfr	a,b
	sex
	sta	1,x
	sta	,x
	rts

#endif


#if defined(_CMOC_NEED_initDWordFromUnsignedWord_)

; Input: X => dword to initialize. D => unsigned word to initialize the dword with.
; Preserves X.
;
initDWordFromUnsignedWord
	std	2,x		; low word
	clr	1,x
	clr	,x
	rts

#endif


#if defined(_CMOC_NEED_initWordFromDWord_)

; Input: X => destination word; D => source dword.
; Preserves X. Trashes D.
;
initWordFromDWord
	pshs	u
	tfr	d,u
	ldd	2,u		; low word of source dword
	std	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_initByteFromDWord_)

; Input: X => destination byte; D => source dword.
; Preserves X. Trashes D.
;
initByteFromDWord
	pshs	u
	tfr	d,u
	ldb	3,u		; low byte of source dword
	stb	,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_incrementDWord_)

; Preserves X. 
;
incrementDWord
	ldd	2,x		; low word
	addd	#1
	std	2,x
	ldd	,x
	adcb	#0
	adca	#0
	std	,x
	rts

#endif


#if defined(_CMOC_NEED_decrementDWord_)

; Preserves X. 
;
decrementDWord
	ldd	2,x		; low word
	subd	#1
	std	2,x
	ldd	,x
	sbcb	#0
	sbca	#0
	std	,x
	rts

#endif


#if defined(_CMOC_NEED_leftShiftDWord_)

; Input: Z must reflect B.
; Preserves X. Trashes D.
;
leftShiftDWordAtXByB
	beq	@done
	cmpb	#8	; at least 8 bits to shift?
	blo	@bitLoop
@byteLoop
	lda	1,x
	sta	,x
	lda	2,x
	sta	1,x
	lda	3,x
	sta	2,x
	clr	3,x
	subb	#8
	beq	@done
	cmpb	#8
	bhs	@byteLoop
@bitLoop
	lsl	3,x
	rol	2,x
	rol	1,x
	rol	,x
	decb
	bne	@bitLoop
@done
	rts

#endif


#if defined(_CMOC_NEED_leftShiftDWord_)

; Input: 1st pushed argument: address of dword;
;        2nd pushed argument: byte containing number of bits to shift;
;        X => destination dword (may point to left dword).
; Output: Result at X.
; Preserves X. Trashes D.
;
leftShiftDWord
	pshs	u
	ldb	6,s		; number of bits to shift
	cmpb	#32
	bhs	@resultZero	; all bits of left dword get shifted out
	ldu	4,s		; address of left dword
	ldd	,u		; copy left dword to destination
	std	,x
	ldd	2,u
	std	2,x
	ldb	6,s		; number of bits to shift
	lbsr	leftShiftDWordAtXByB	; preserves X
	bra	@done
@resultZero
	clr	,x
	clr	1,x
	clr	2,x
	clr	3,x
@done
	puls	u,pc

#endif


#if defined(_CMOC_NEED_rightShiftDWord_)

; Input: A: 0 = zero-extend, $FF = sign-extend;
;        B: number of bits to shift;
;        X => dword to shift (in place).
; Preserves X. Trashes D.
;
rightShiftDWordAtXByB
	pshs	a
	tstb
	beq	@done
	cmpb	#8	; at least 8 bits to shift?
	blo	@bitLoop
@byteLoop
	lda	2,x
	sta	3,x
	lda	1,x
	sta	2,x
	lda	,x
	sta	1,x
	bmi	@useExtByte	; if high bit of dword is 1
	clra
	bra	@storeExtByte
@useExtByte
	lda	,s		; zero/sign extension byte
@storeExtByte
	sta	,x
	subb	#8
	beq	@done
	cmpb	#8
	bhs	@byteLoop
@bitLoop
	tst	,s		; zero or sign extension?
	beq	@zeroExtBitLoop
@signExtBitLoop
	asr	,x
	ror	1,x
	ror	2,x
	ror	3,x
	decb
	bne	@signExtBitLoop
	bra	@done
@zeroExtBitLoop
	lsr	,x
	ror	1,x
	ror	2,x
	ror	3,x
	decb
	bne	@zeroExtBitLoop
@done
	puls	a,pc

#endif


#if defined(_CMOC_NEED_rightShiftDWord_)

; Input: 1st pushed argument: address of dword;
;        2nd pushed argument: byte containing sign extension flag
;                             (0 = zero-extended; $FF = sign-extend);
;        3rd pushed argument: byte containing number of bits to shift;
;        X => destination dword (may point to left dword).
; Output: Result at X.
; Preserves X. Trashes D.
;
rightShiftDWord
	pshs	u
	ldb	7,s		; number of bits to shift
	cmpb	#32
	bhs	@shiftAll	; all bits of left dword get shifted out
	ldu	4,s		; address of left dword
	ldd	,u		; copy left dword to destination
	std	,x
	ldd	2,u
	std	2,x
	ldd	6,s		; A = sign extension flag, B = number of bits to shift
	lbsr	rightShiftDWordAtXByB	; preserves X
	bra	@done
@shiftAll
	ldb	6,s		; sign extension flag
	beq	@allZeroes
	tst	[4,s]		; test high byte of input dword
	bmi	@fillWithB
@allZeroes
	clrb			; fill with 0's b/c zero-extend or signed dword >= 0
@fillWithB
	stb	,x
	stb	1,x
	stb	2,x
	stb	3,x
@done
	puls	u,pc

#endif


#if defined(_CMOC_NEED_orDWordDWord_)

; Input: Pushed arguments: addresses of left and right dword;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
orDWordDWord
	pshs	u,y
	ldu	6,s		; left dword
	ldy	8,s		; right dword
	ldd	,u		; high word
	ora	,y
	orb	1,y
	std	,x
	ldd	2,u		; low word
	ora	2,y
	orb	3,y
	std	2,x
	puls	y,u,pc

#endif


#if defined(_CMOC_NEED_orDWordWord_)

; Input: Pushed arguments: addresses of left dword, value of right word;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
orDWordWord
	pshs	u
	ldu	4,s		; left dword
	ldd	,u		; high word
	std	,x		; unchanged
	ldd	2,u		; low word
	ora	6,s		; right word is at S+6
	orb	7,s
	std	2,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_xorDWordDWord_)

; Input: Pushed arguments: addresses of left and right dword;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
xorDWordDWord
	pshs	u,y
	ldu	6,s		; left dword
	ldy	8,s		; right dword
	ldd	,u		; high word
	eora	,y
	eorb	1,y
	std	,x
	ldd	2,u		; low word
	eora	2,y
	eorb	3,y
	std	2,x
	puls	y,u,pc

#endif


#if defined(_CMOC_NEED_xorDWordWord_)

; Input: Pushed arguments: addresses of left dword, value of right word;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
xorDWordWord
	pshs	u
	ldu	4,s		; left dword
	ldd	,u		; high word
	std	,x		; unchanged
	ldd	2,u		; low word
	eora	6,s		; right word is at S+6
	eorb	7,s
	std	2,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_andDWordDWord_)

; Input: Pushed arguments: addresses of left and right dword;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
andDWordDWord
	pshs	u,y
	ldu	6,s		; left dword
	ldy	8,s		; right dword
	ldd	,u		; high word
	anda	,y
	andb	1,y
	std	,x
	ldd	2,u		; low word
	anda	2,y
	andb	3,y
	std	2,x
	puls	y,u,pc

#endif


#if defined(_CMOC_NEED_andDWordWord_)

; Input: Pushed arguments: addresses of left dword, value of right word;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
andDWordWord
	pshs	u
	clr	,x		; high word becomes 0
	clr	1,x
	ldu	4,s		; left dword
	ldd	2,u		; low word
	anda	6,s		; right word is at S+6
	andb	7,s
	std	2,x
	puls	u,pc

#endif


#if defined(_CMOC_NEED_signedJumpTableSwitch_) \
 || defined(_CMOC_NEED_unsignedJumpTableSwitch_)

; Input: X => Table of 16-bit offsets, one for each non-default case.
;        D => Switch expression.
; Table: -6,X = minimum case value; -4,X: max value; -2,X: offset for default case.
;
; An offset is to be added to the address of the table (in X) to obtain
; the effective address of the case code to jump to.
;
signedJumpTableSwitch
        cmpd    -4,x        ; higher than max?
        bgt     @default
        subd    -6,x        ; switch value lower than minimum case value?
        blt     @default
        bra     @useTable
unsignedJumpTableSwitch
        cmpd    -4,x        ; higher than max?
        bhi     @default
        subd    -6,x        ; switch value lower than minimum case value?
        blo     @default
@useTable
        lslb                ; 2 bytes per address in table
        rola
        ldd     d,x         ; get offset from table
        jmp     d,x         ; add table address to offset to get absolute address to jump to
@default
        ldd     -2,x        ; get offset of default routine
        jmp     d,x

#endif


; Floating-point is only supported in the Extended Color Basic environment.
;
#ifdef _COCO_BASIC_
#include "float-ecb.inc"
#endif


stdlib_end:
