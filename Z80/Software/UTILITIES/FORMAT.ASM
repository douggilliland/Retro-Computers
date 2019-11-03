; DISK FORMATTING PROGRAM
; WRITTEN BY DICK CULBERTSON IN AUG, 1977
; MODIFIED BY DON TARBELL IN SEP, 1977
;
; THE PURPOSE OF THIS PROGRAM IS TO FORMAT
; OR REFORMAT A DISK ON DRIVE A.  THIS MAY BE REQUIRED
; IF A NEW DISK IS NOT FORMATTED CORRECTLY,
; OR IF AN OLD ONE IS CRASHED.
; BE CAREFULL,  THIS PROGRAM WIPES OUT
; ANY INFORMATION YOU MAY HAVE HAD
; ON THE DISK.  ALSO BE SURE THAT YOU HAVE
;CHANGED C4 FROM 1000PF TO .1MFD PERMENANTLY.
;
DCOM      EQU  0F8H        ;DISK COMMAND PORT
DSTAT     EQU  0F8H        ;DISK STATUS PORT
TRACK     EQU  0F9H        ;DISK TRACK COMMAND
SECTP     EQU  0FAH        ;DISK SECTOR PORT
DDATA     EQU  0FBH        ;DISK DATA PORT
ENTRY	  EQU  5	   ;ENTRY PT TO FDOS
WAIT      EQU  0FCH        ;DISK WAIT CONTROL PORT
          ORG  0100H       ;LOAD & EX HERE
;

;STARTING MESSAGE

	
	MVI C,9		;GET CODE FOR PRINT.
	LXI D,MSG	;GET ADR OF MESSAGE.
	CALL ENTRY	;PRINT OPENING.
BGIN:	MVI C,9
	LXI  D,RDY	;PRINT READY MESSAGE.
	CALL ENTRY
	MVI C,1		;READ A CHAR FROM KB.
	CALL ENTRY
	CPI 'Y'		;IF IT'S A 'Y',
	RNZ
	JMP  START	;GO AHEAD AND DO IT.
MSG:	 DB 'INITIALIZATION ROUTINE FOR FLOPPIES'
	DB 0DH,0AH,0AH
	DB 'BY DICK CULBERTSON'
	DB 0DH,0AH,'AUG, 1977 $'
RDY:	DB 0DH,0AH,'BLANK DISK READY TO FORMAT? (Y,N) $'

;
; RESTORE DRIVE TO TRACK 00
;
START:	MVI  A,0B2H	;SET PERSCI
	OUT  WAIT	;RESTORE LINE.
	MVI  A,3	;LOAD HOME CMD.
          OUT  DCOM        ;ISSUE HOME CMD
	  IN WAIT	    ;WAIT FOR HOME
	MVI  A,0F2H	;RESET RESTORE LINE.
	OUT  WAIT
          MVI  C,0         ;SET TRACK NUMBER TO 0
          MVI  H,77        ;SET TOTAL TRACKS TO 77
NXTTRK    MVI  D,1         ;SECTOR CNT TO 0
          MVI  E,26        ;SET MAX # SECTORS -1 
          MVI  B,46        ;GAP 4 PREINDEX 40 BYTES OF FF
  !       MVI  A,0F4H      ;LOAD TRACK WRITE COMMAND
          OUT  DCOM        ;ISSUE TRACK WRITE
; WRITE PREINDEX FILL
PREIND    IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          XRA  A           ;LOAD PREINDEX FILL
          OUT  DDATA       ;WRITE IT ON DISK
          DCR  B           ;COUNT =COUNT - 1
          JNZ  PREIND      ;GO BACK TILL B =0
;
; WRITE ADDRESS MARK ON TRACK
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MVI  A,0FCH      ;LOAD ADDRESS MARK
          OUT  DDATA       ;WRITE IT ON DISK
;
; POST INDEX GAP
;
          MVI  B,26        ;SET # OF BYTES
POSTID    IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP  ERRMSG       ;JMP OUT IF ERROR
          MVI  A,0FFH      ;LOAD FILL DATA
          OUT  DDATA       ;WRITE IT ON DISK
          DCR  B           ;COUNT = COUNT - 1
          JNZ  POSTID      ;IF NOT 0 GO BACK
;
; PRE ID SECTION
;
ASECT     MVI  B,6         ;GET # OF BYTES
SECTOR    IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          XRA  A           ;MAKE A = 0
          OUT  DDATA       ;WRITE IT ON TRACK
          DCR  B           ;COUNT = COUNT=1
          JNZ  SECTOR      ;JMP BACK IF NOT DONE
;
; WRITE ID ADDRESS MARK
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;IF ERROR JMP OUT
          MVI  A,0FEH      ;GET ADDRESS MARK
          OUT  DDATA       ;WRITE IT ON DISK
;
; WRITE TRACK NUMBER ON DISK
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MOV  A,C         ;GET TRACK NUMBER
          OUT  DDATA       ;WRITE IT ON DISK
;
; WRITE ONE BYTE OF 00
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          XRA  A           ;SET A TO 0
          OUT DDATA        ;WRITE IT ON DISK
;
; WRITE SECTOR # ON DISK
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MOV  A,D         ;GET SECTOR #
          OUT DDATA        ;WRITE IT ON DISK
;
; ONE MORE BYTE 0
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          XRA  A           ;SET A TO 00
          OUT  DDATA       ;WRITE IT ON DISK
          INR  D           ;BUMP SECT. #
;
; WRITE 2 CRC'S ON THIS SECTOR
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MVI  A,0F7H      ;GET CRC PATTERN
          OUT DDATA        ;WRITE IT ON DISK
;
; PRE DATA 17 BYTES 00
;
          MVI  B,17        ;SET COUNT
PREDAT    IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          XRA  A           ;SET A TO 00
          OUT  DDATA       ;WRITE IT ON DISK
          DCR  B           ;REDUCE COUNT BY 1
          JNZ  PREDAT      ;GO BACK IF NOT DONE
;
; DATA ADDRESS MARK
;
          IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MVI  A,0FBH      ;GET DATA ADDRESS MARK
          OUT  DDATA       ;WRITE IT ON DISK
;
; FILL DATA FIELD WITH E5
;
          MVI  B,128       ;SET FIELD LENGTH
DFILL     IN   WAIT        ;WAIT FOR DRQ
          ORA  A           ;YOU KNOW WHAT
          JP   ERRMSG      ;HAPPENS HERE BY NOW
          MVI  A,0E5H      ;GET FILL BYTE
          OUT  DDATA       ;WRITE IT ON DISK
          DCR  B           ;DROP 1 FROM COUNT
          JNZ  DFILL       ;DO TILL 00
;
; WRITE CRC'S
;
          IN   WAIT        ;WAIT TILL DRQ
          ORA  A           ;SET FLAGS
          JP   ERRMSG      ;JMP OUT IF ERROR
          MVI  A,0F7H      ;GET CRC BYTE
          OUT  DDATA       ;WRITE IT ON DISK
;
; END OF SECTOR FILL
;
	  DCR  E	   ;REDUCE SECTOR COUNT
	  JZ  ENDTRK	   ;IF 0 DO END OF TRACK RTN
DATGAP    IN WAIT          ;WAIT FOR DRQ
          ORA  A           ;SET FLAGS   
          JP   ERRMSG      ;JMP OUT IF ERROR
	  MVI  A,0FFH	   ;GET FILL CHARACTER
          OUT  DDATA       ;WRITE IT ON DISK
	  JMP  POSTID-2    ;GO BACK FOR MORE
;
; DO TRACK & SECTOR HOUSE KEEPING
;
ENDTRK    IN   WAIT        ;WAIT FOR DRQ OR INTRQ
          ORA  A           ;SET FLAGS
          JP   DONE        ;JMP OUT IF ERROR
	  MVI  A,0FFH	   ;LOAD A WITH FFH
          OUT  DDATA       ;WRITE IT ON DISK
          JMP  ENDTRK      ;DO UNTIL INTRQ
;
; ERROR SORT ROUTINE
;
DONE      IN   DSTAT       ;READ STATUS
          ANI  0FFH        ;TEST FOR FLAG
	  JNZ  ERRMSG	   ;IF ERR GO TO ERR PRINT RTN
          INR  C           ;BUMP TRACK #
          DCR  H           ;TRK COUNT =COUNT -1
          JNZ  BMPTRK      ;IF NOT 0 THEN DO MORE
	  JMP  BGIN		;GO BACK TO DO ROUTINE AGAIN

BMPTRK    MVI  A,43H       ;LOAD STEP IN
          OUT  DCOM        ;STEP IN
	MVI  A,1	;GET PERSCI STEP COMMAND
	OUT  WAIT	;AND ISSUE IT.
	  IN  WAIT         ;WAIT TIL DONE
	  ORA A            ;SET FLAGS
	  IN   WAIT	   ;WAIT FOR DRQ
	  IN   DSTAT       ;CHECK STATUS
	  ANI  0FFH	   ;MASK NON ERR BITS
	  JNZ  ERRMSG
	  JMP  NXTTRK
;
;ERROR ROUTINE
;
ERRMSG	  STA 0000H
	  HLT
          
