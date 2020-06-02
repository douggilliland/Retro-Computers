p equ psw
entry equ 05h
rdcon equ 1
wrcon equ 2
prbuff equ 9
chcon equ 11
seldsk equ 14
openf equ 15
closef equ 16
deletf equ 19
rdrec equ 20
wrrec equ 21
creatf equ 22
inqdsk equ 25
setdma equ 26
;
reof equ 1 ;read end-of-file signal
;
fn equ 1 ;EFCB layout
ft equ 9
ex equ 12
rct equ 15
nr equ 32
status equ 33
driveno equ 34
nxbyte equ 35
buffer equ 36
;
;used by start:
tcorg equ 600h
mstack equ tcorg+46h
bpr equ tcorg+42h
inst equ tcorg+0d08h
move equ tcorg+0c4bh
hlneg equ tcorg+0dc0h
progend equ tcorg+060h
tfcb equ 05ch
tbuff equ 080h
;
;used by USERMC
mceset equ tcorg+2bh
toptoi equ tcorg+2eh
pushk equ tcorg+31h
pzero equ tcorg+1c5h
;
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:::::::::::  tiny - c  :::::::::::::::::::::::::::::::::::
;:::::::::::    cp/m installation  ::::::::::::::::::::::::
;:::::::::::      by t. a. gibson, 1978  ::::::::::::::::::
;:::::::::::        copyright, 1978, tiny-c associates  :::
;:::::::::::          all rights reserved  ::::::::::::::::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
 org 100h
 jmp start
 jmp inch
 jmp aout
 jmp chrdy
 jmp fopen
 jmp rdblok
 jmp wrblok
 jmp fclose
 jmp usermc
;
;
;transforms unit in BC to efcb in DE
unit mov d,b ;DE <- BC
 mov e,c
 mov a,e ;test for unit 1
 dcr a
 ora d
 rnz
 lxi d,efcb ;use built in efcb
 ret
;
;restores BC, DE, HL and returns
bdhret pop b
dhret pop d
 pop h
 ret
;
;assures proper disk is logged on. (DE) is efcb.
asudsk push h!push d!push b
 lxi h,driveno ;retrieve needed drive
 dad d
 mov a,m
 push p
 mvi c,inqdsk
 call fdos
 mov b,a ;current drive -> B

 pop p ;needed drive -> A
 cmp b ;if same do nothing
 jz bdhret
 mov e,a ;logon device (A)
 mvi d,0
 mvi c,seldsk
 call fdos
 jmp bdhret
;
;assure correct DMA for buffer at (DE)+buffer.
asudma push h!push d!push b
 xchg
 mvi c,setdma
 call fdos
 jmp bdhret
;
;restore default DMA buffer
cpmbuff push h! push d! push b
 lxi d,80h
 mvi c,setdma
 call fdos
 jmp bdhret
;
;load buffer, (DE) is EFCB
ldbuff push h! push d ! push b
 call asudsk
 call asudma
 mvi c,rdrec
 call fdos
 jmp bdhret
;
;write the buffer. (DE) is EFCB
wrbuff push h! push d! push b
 call asudma ;must send it out
 call asudsk
 mvi c,wrrec
 call fdos
 jmp bdhret
;
;examines 1st 2 bytes of a drive:fn.ft string.
;(HL) points to the string. If a drive is specified, the
;drive is set up in the EFCB pointed to by (DE).
;Otherwise drive a is set up.
drive push h! push d! push b
 inx h ;is there a colon in 2nd byte.
 mov a,m
 cpi ':'
 jnz dr2
 dcx h ;get drive byte. Must be A,B,C or D,
 mov a,m
 sui 'A'
 jm dr99
 cpi 4
 jm dr3
 sui 20h ;  or a,b,c or d.
 jm dr3
 cpi 4
 jm dr3
dr99 mvi a,254 ;illegal drive signal
 ora a
 jmp bdhret
dr2 mvi c,inqdsk ;default is current drive
 call fdos
 lxi h,driveno
 dad d
 mov m,a
 jmp bdhret
dr3 lxi h,driveno ;driveno in A into EFCB.
 dad d
 mov m,a
 xra a ;success signal
 pop b! pop d! pop h  ;restore environment.
 inx h! inx h  ;bump string pointer past colon.
 ret
;
;safe entry into CP/M.
fdos push h! push d! push b
 call entry
 jmp bdhret
;
;puts fn.ft into EFCB. (HL) points to string ended with
;null byte. (DE) points to EFCB.
fnft push h! push d! push b
 xra a ;0 into ET field
 stax d
 inx d
 mvi b,8 ;length of FN field
 call fomov ;fn into FN
 jz ftdflt ;if 0 then end of string was reached.
fdot mov a,m ;scan for . or null
 inx h
 cpi '.'
 jz ftype
 ora a
 jnz fdot
ftdflt lxi h,dft
ftype mvi b,3 ;mov ft into FT
 call fomov
fex xra a ;0 EX thru RC
 stax d! inx d
 stax d! inx d
 stax d! inx d
 stax d! inx d
 jmp bdhret
dft db 'TC '
;
;moves a string to a field. (HL) points to string. (DE)
;points to field of length (B). Stops on . or null or
;field full. Pads field with blanks if needed. Returns
;last byte examined in A and Z set iff its null.
fomov mov a,m
 ora a
 jz fpad
 cpi '.'
 jz fpad
 cpi '*' ;* => pad with ?'s
 jz qpad
 cpi 61h ;test for lower case alpha
 jc fm2
 cpi 7bh ; 'z'+1
 jnc fm2
 ani 0dfh ;force upper case
fm2 stax d
 inx d
 inx h
 dcr b
 jnz fomov
 ora a ;set or reset Z
 ret ;DE points past moved field
  ;HL points to next byte to examine.
fpad push p ;save char that caused stop
 mvi a,' ' ;blanks into remainder of field
fp2 stax d
 inx d
 dcr b
 jnz fp2
 pop p ;restore character that caused stop
 ora a
 ret
qpad push p
 mvi a,'?'
 jmp fp2
;
;prints (A) in hex, and EFCB
prefcb push psw
 push h! push d! push b
 call ahexout
 mvi a,' '
 call aout
 lxi h,driveno ;drive letter into A
 dad d
 mov a,m
 adi 'A'
 call aout ;send drive letter
 mvi a,':'
 call aout ;send colon
 mvi c,8 ;length of filename
 lxi h,fn ;send filename
 dad d
 call prntnch
 mvi a,'.' ;send period
 call aout
 mvi c,3 ;send filetype
 lxi h,ft
 dad d
 call prntnch
 mvi a,' ' ;send blank
 call aout
 lxi h,ex ;send extent number
 dad d
 mov a,m
 call ahexout
 mvi a,' ' ;send blank
 call aout
 lxi h,rc ;send record count
 dad d
 mov a,m
 call ahexout
 mvi a,' '
 call aout
 lxi h,nr ;send next record number
 dad d
 mov a,m
 call ahexout
 mvi a,' '
 call aout
 lxi h,status ;send status
 dad d
 mov a,m
 call ahexout
 mvi a,' '
 call aout
 lxi h,nxbyte ;send next byte of buffer
 dad d
 mov a,m
 call ahexout
 mvi a,' '
 call aout ;send blank at end
 pop psw
 jmp bdhret
;
;opens a file for tiny-c, as specified in the
;Owner's Manual 6.1.2.  DE (filesize) is ignored.
;All other parameters are used.
fopen push p ;r/w flag
 call cpmbuff ;assure default buffer
 call unit ;set up pointer to EFCB in DE.
 call drive ;drive into EFCB
 jz f2
 pop p ;improper drive. Clear stack.
 call ps ;print filename and bad drive message.
 lxi d,baddr
ferr call pcs ;bad drive message
 xra a ;signal an error
 inr a
 ret
baddr db 'improper drive$'
f2 call fnft ;fn.ft into EFCB
 jz f3
 pop p ;bad filename
 call ps ;clear stack, print filename and bad
 lxi d,badname ;  filename message.
 jmp ferr
badname db 'bad filename$'
f3 lxi h,nr ;0 into NR and NXBYTE
 dad d
 xra a
 mov m,a
 lxi h,nxbyte
 dad d
 mov m,a
 pop p ;restore r/w flag, and put
 lxi h,status ;  into status
 dad d
 mov m,a
 cpi 1 ;what kind of open
 jz ropen
 cpi 2
 jz wopen
 call prefcb ;bad r/w flag, print EFCB and message
 lxi d,badrw
 jmp ferr
badrw db 'rw must be 1 or 2$'
ropen call asudsk ;assure correct disk
 mvi c,openf ;do a cpm open
 call fdos
 cpi 255 ;test for no file
 jnz openok
 call prefcb ;print EFCB and no-file message
 lxi d,nofile
 jmp ferr
nofile db 'cant find file$'
openok xra a ;signal open ok
 ret
wopen call asudsk ;assure correct disk
 mvi c,deletf ;delete old file, if any
 call fdos
 mvi c,creatf
 call fdos
 cpi 255 ;test if disk is full
 jnz openok
 call prefcb ;print EFCB and full message
 lxi d,dirful
 jmp ferr
dirful db 'directory full$'
;
;reads a block. HL points to memory area to read into.
;  BC is a unit. If status of EFCB is not 1, returns an
;  eof signal, and does not read. Otherwise reads one block
;  into memory. If physical eof was reached, an eof signal is
;  returned. Otherwise scans the read block for ^Z, and 
;  returns length of block in DE. Returns 0 in A for ok,
;  -1 for eof, 1 for error. Leaves BC, HL unchanged.
rdblok push b
 push h
 call unit ;efcb into DE
 lxi h,status ;test status
 dad d
 mov a,m
 cpi 1
 jnz rdeof
 pop h
 push h
 call ldbuff ;read the record
 ora a
 jnz rdpeof ;possible eof
 lxi d,0 ;scan for ^Z
 mvi b,1ah ;^Z into A
 mvi c,128 ;scan limit
rdscan mov a,m ;get byte
 cmp b ;is it ^Z
 jz rdout
 inr e ;add to length
 inx h ;to get next byte
 dcr c
 jnz rdscan
rdout pop h ;restore B and H
 pop b
 xra a ;signal ok
 ret
rdpeof cpi reof ;didn't read, see why.
 jnz rderr
rdeof pop h ;eof exit, restore B and H
 pop b
 xra a ;signal eof
 dcr a
 ret
rderr call prefcb ;print error code and efcb
 lxi d,rermsg
 jmp ferr
rermsg db 'read error$'
;
;write a block. Unit in BC. HL..DE bracket a block of
;  memory <= 128 bytes. If status in EFCB is not 2, signal
;  an error. If block < 128 put an ^Z at (DE)+1. Then
;  write the block. Return 0 in A for ok, 1 otherwise.
wrblok mov a,e ;check length
 sub l
 cpi 127 ;E-L==127 implies 128 bytes in block
 jz wr2
 xchg ;short block, put ^Z at (DE)+1
 inx h
 mvi m,1ah
 xchg
wr2 call unit ;efcb into DE
 push h ;save write address
 lxi h,status
 dad d ;test status
 mov a,m
 cpi 2
 pop h ;restore write address
 jnz wrerr ;error if status not 2
 call wrbuff ;write the block
 ora a ;zero signals no problem
 rz
wrerr call prefcb ;print error code and efcb
 lxi d,wermsg
 jmp ferr
wermsg db 'write error$'
;close a file, BC is the unit.
fclose call unit ;EFCB into DE
 call cpmbuff ;assure default buffer
 lxi h,status ;status into A
 dad d
 mov a,m ;test status
 cpi 2
 jnz zstat
 mvi c,closef ;writing, must close the file
 call fdos
 cpi 255
 jz fcerr
zstat xra a ;0 into status
 mov m,a
 ret
fcerr call prefcb
 lxi d,fermsg
 jmp ferr
fermsg db 'close error$'
;
;prints (A) restoring all registers
aout push h! push d! push b! push p
 mvi c,wrcon
 mov e,a
 cpi 0DH
 jnz aout2
 call fdos ;after <cr> also send <lf>
 mvi e,0AH
 mvi c,wrcon
aout2  call fdos
 pop p
 jmp bdhret
;
;prints (A) in hex
ahexout push p
 rrc! rrc! rrc! rrc
 call hexout
 pop p ;and fall into hexout
;prints one hex digit from (A)
hexout push p
 ani 15
 adi 90h
 daa
 aci 40h
 daa
 call aout
 pop p
 ret
;
;prints tiny-c string (null terminated)
ps mov a,m
 ora a
 rz
 call aout
 inx h
 jmp ps
;
;prints (C) chars starting at (HL)
prntnch mov a,m
 call aout
 dcr c
 inx h
 jnz prntnch
 ret
;
;prints cp/m style string, ($ terminated)
pcs mvi c,prbuff
 jmp fdos
;
;Tests for char ready from the terminal, as specified
;in the Owner's Manual, Sec. 6.1.1. HOLD is a software
;buffer shared by chardy and inch, and HOLDF is a flag
;indicating whether or not a char is in HOLD.
chrdy mvi c,chcon ;check the console status
 call fdos
 ani 1 ;mask of least signif bit
 jz tryhold
 mvi c,rdcon ;read from the console
 call fdos
 ani 07fh ;mask out hi bit
 sta hold
 xra a ;set holdf to -1
 dcr a
 sta holdf
tryhold lda holdf ;test hold flag
 ora a
 rz ;no char ready
 lda hold ;got one in hold
 ora a
 rnz
 mvi a,1 ;null byte, return a 1
 ora a
 ret
;
inch lda holdf ;try hold first
 ora a
 jz tryport
 xra a ;have one in hold
 sta holdf ;zero the flag
 lda hold ;return the held char
 cpi 0DH
 rnz
 mvi a,0AH ;echo a line feed when <cr> read
 call aout
 mvi a,0DH
 ret
tryport call chrdy ;hold is empty, so wait for human
 jz tryport ;  to type something.
 jmp inch ;He did it, so use inch to read the character.
holdf db 0
hold db 0
;
;It all starts here.  Cold start if no filename given.
;  Otherwise load the named file, and hot start it.  A
;  default filetype TC is provided.
start lda tfcb+1
 cpi ' '
 jz tcorg ;cold start
 lhld mstack ;set SP
 sphl
 lxi b,-10 ;initialize tiny-c
 lhld bpr
 xchg
 lxi h,inst
 call move
 lhld bpr
 lxi d,9
 dad d
 call hlneg
 shld progend
 lxi h,tbuff ;put null at end of string.
 mov a,m ;get length
 inx h ;beginning of string
 push h
 add l
 mov l,a ;hl -> end of string
 mvi m,0
 pop h ;begin of string
 inx h ;skip over single blank
 lxi b,1 ;unit 1
 mvi a,1 ;rw set to read
 call fopen
 jnz tcorg ;cold start on error
 lhld progend ;where to read
st2 call hlneg
 lxi b,1
 call rdblok
 jnz stout
 dad d
 mvi m,0
 call hlneg
 shld progend
 jmp st2
stout push p ;save last read result
 lxi b,1
 call fclose
 pop p
 cpi 0ffh ;test for end of file
 jnz tcorg ;if not end of file, then error, hence cold start
 jmp tcorg+6 ;hot start
;
efcb ds 36 ;for unit 1
;
;User Machine Calls -- defined in CP/M supplement.
usermc mov a,l
 cpi 1
 jz mc1001
 cpi 2
 jz mc1002
 cpi 3
 jz mc1003
 jmp mceset
;
mc1001 call toptoi ;  FDOS ( fnum, arg )
 push d ;arg -> stack
 call toptoi ;fnum -> C
 mov c,e
 pop d ;arg -> DE
 push b ;save fnum for later
 call entry
 mov e,a ;result -> DE
 mvi d,0
 pop h ;fnum -> L
 mov a,l
 cpi 27 ;only function 27 returns 2 bytes
 jnz pushk
 mov d,b ;hi byte for 27
 jmp pushk
;
mc1002 call toptoi ;sefcb(string,efcb)
 push d
 call toptoi
 xchg ;string -> HL
 pop d ;efcb -> DE
 call drive
 jnz pushk ;illegal drive pushed addr of efcb
 call fnft
 jmp pzero
;
mc1003 call toptoi ;efcb -> DE
 xra a
 call prefcb
 jmp pzero
