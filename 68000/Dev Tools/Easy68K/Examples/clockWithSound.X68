*-----------------------------------------------------------
* Title        : clockWithSound
* Written by   : Chuck Kelly
* Date Created : May-19-2002
* Description  : A clock for EASy68k with graphics and sound.
*
* The graphics resolution is 640 x 480 with 0,0 at the top left.
*
* Simulator Trap code for timer
* 8 - Return time in hundredths of a second since midnight in D1.L. 
*
* Simulator Trap codes for graphics (see help)
*
* Modifications:
* March-23-2003 by CK, Added sounds
* April-02-2007 by CK, Added dots around clock face
* May-09-2007 by CK, Converted to structured assembly and added font code
* Oct-17-2008 by CK, Added DELAY
*-----------------------------------------------------------


* Delay for hundredths of a second in param 1
DELAY    MACRO
    move.b  #23,d0                trap task 23
    move.l  #\1,d1                delay amount
    trap    #15
    ENDM

****************************************
*     PROGRAM START
****************************************
    ORG     $1000
START

*** Initialize variables
    move.w  #0,hourHand
    move.w  #0,minHand
    move.w  #0,secHand
    move.b  #0,chimeCount

*** Load sounds into memory
    lea     tick,a1                load wav
    move    #0,d1                sound number 0
    move    #71,d0
    trap    #15

    lea     tock,a1                load wav
    move    #1,d1                sound number 1
    move    #71,d0
    trap    #15

    lea     chime,a1            load wav
    move    #2,d1                sound number 2
    move    #71,d0
    trap    #15

*** draw face of clock
    move.l  #WHITE,d1            font color
    move.l  #FONT,d2            font name, size and style
    move.b  #21,d0
    trap    #15                    set font properties

    move.l  #BLUE,d1
    move.b  #80,d0
    trap    #15                    set line color

    move.l  #NAVY,d1
    move.b  #81,d0
    trap    #15                    set fill color

    move.l  #CENTERX-RADIUS,d1    X1
    move.l  #CENTERY-RADIUS,d2    Y1
    move.l  #CENTERX+RADIUS,d3    X2
    move.l  #CENTERY+RADIUS,d4    Y2
    move.b  #88,d0
    trap    #15                    draw blue circle for clock face
 
    move.l  #CENTERX-7,d1            X1
    move.l  #CENTERY-RADIUS+2,d2    Y1
    lea     num12,a1            display 12
    move.b  #95,d0
    trap    #15

    move.l  #CENTERX+RADIUS-11,d1    X1
    move.l  #CENTERY-9,d2            Y1
    lea     num3,a1                display 3
    move.b  #95,d0
    trap    #15

    move.l  #CENTERX-4,d1            X1
    move.l  #CENTERY+RADIUS-16,d2    Y1
    lea     num6,a1                display 6
    move.b  #95,d0
    trap    #15

    move.l  #CENTERX-RADIUS+3,d1    X1
    move.l  #CENTERY-9,d2            Y1
    lea     num9,a1                display 9
    move.b  #95,d0
    trap    #15


*** draw dots
    move.b  #80,d0
    move.l  #WHITE,D1
    trap    #15                    set pen color
    for d5 = #0 to #59 do.s
        move.l  d5,d0
        move.w  #SIZE_S+5,d1    position of dot from center
        bsr     handXY
        move    d3,d1            X
        move    d4,d2            Y
        move.b  #82,d0
        trap    #15
    endf

    while <T> do        ***** INFINITE LOOP *****
        repeat
             DELAY    1                1/100 sec delay to reduce CPU workload 

            *** Read timer, get 100ths of a second since midnight in D1.L
            move.b  #8,d0
            trap    #15
            if.l d1 <HS> #NOON then.s
                sub.l   #NOON,d1    time = time - NOON
            endi

            *** Calculate total minutes (D5), minutes this hour (D6), seconds (D7)
            divu    #100,d1            convert to seconds
            andi.l  #$0000ffff,d1    discard fractional seconds
            divu    #60,d1            convert to minutes
            move.l  d1,d7
            move.l  #16,d0 
            lsr.l   d0,d7            d7 = seconds
            andi.l  #$0000ffff,d1    discard seconds from d1
            move.l  d1,d5            d5 = total minutes
            divu    #60,d1            convert to hours
            move.l  d1,d6
            move.l  #16,d0
            lsr.l   d0,d6            minutes this hour to d6
        until d7 <ne> secHand do.s    until second has elapsed

        *** Check for top of the hour
        if.l d7 <eq> #0 and.l d6 <eq> #0 then.s
            move.l  d5,d1            total minutes
            divu    #60,d1            total minutes/60 = hours
            if <eq> then.s            if 12 o'clock
                move.b  #12,d1
            endi
            move.b  d1,chimeCount    number of times to chime
        endi

        bsr sounds                    play sounds

        *** Calculate new position of clock hands

        *** hour hand
        divu    #12,d5                total minutes/12 = 1 of 60 positions
        andi.l  #$0000ffff,d5        discard remainder

        if.w hourHand <ne> d5 then.s if (new position <> old position)
            *** erase old hour hand
            move.b  #15,d1            set pen width
            move.b  #93,d0
            trap    #15
            move.w  hourHand,d0
            move.w  #SIZE_H,d1        size of hour hand
            bsr     handXY            returns end of hand as X2 in d3, Y2 in d4
            move.l  #NAVY,d1
            move.b  #80,d0
            trap    #15                set line color
            move.l  #CENTERX,d1        X1
            move.l  #CENTERY,d2        Y1
            move.b  #84,d0
            trap    #15                erase hour hand from X1,Y1 to X2,Y2
            move.w  d5,hourHand        save new hour hand position
        endi

        if minHand <ne> d6 then.s    if (new position <> old position)    
            *** erase old minute hand
            move.b  #5,d1            set pen width
            move.b  #93,d0
            trap    #15
            move.w  minHand,d0
            move.w  #SIZE_M,d1        size of minute hand
            bsr     handXY            returns end of hand as X2 in d3, Y2 in d4
            move.l  #NAVY,d1
            move.b  #80,d0
            trap    #15                set line color
            move.l  #CENTERX,d1        X1
            move.l  #CENTERY,d2        Y1
            move.b  #84,d0
            trap    #15                erase minute hand from X1,Y1 to X2,Y2
            move.w  d6,minHand        save new minute hand position
         endi

        *** erase old second hand
        move.b  #2,d1                set pen width
        move.b  #93,d0
        trap    #15
        move.w  secHand,d0
        move.w  #SIZE_S,d1            size of second hand
        bsr     handXY                returns end of hand as X2 in d3, Y2 in d4
        move.l  #NAVY,d1
        move.b  #80,d0
        trap    #15                    set line color
        move.l  #CENTERX,d1            X1
        move.l  #CENTERY,d2            Y1
        move.b  #84,d0
        trap    #15                    erase minute hand from X1,Y1 to X2,Y2
        move.w  d7,secHand            save new second hand position

        *** draw new hour hand
        move.b  #15,d1                set pen width
        move.b  #93,d0
        trap    #15
        move.w  d5,d0
        move.w  #SIZE_H,d1            size of hour hand
        bsr     handXY                returns end of hand as X2 in d3, Y2 in d4
        move.l  #GREEN,d1
        move.b  #80,d0
        trap    #15                    set line color
        move.l  #CENTERX,d1            X1
        move.l  #CENTERY,d2            Y1
        move.b  #84,d0
        trap    #15                    draw hour hand from X1,Y1 to X2,Y2

        *** draw new minute hand
        move.b  #5,d1                set pen width
        move.b  #93,d0
        trap    #15
        move.w  d6,d0
        move.w  #SIZE_M,d1            size of minute hand
        bsr     handXY                returns end of hand as X2 in d3, Y2 in d4
        move.l  #YELLOW,d1
        move.b  #80,d0
        trap    #15                    set line color
        move.l  #CENTERX,d1            X1
        move.l  #CENTERY,d2            Y1
        move.b  #84,d0
        trap    #15

        *** draw new second hand
        move.b  #2,d1                set pen width
        move.b  #93,d0
        trap    #15
        move.w  d7,d0                endif
        move.w  #SIZE_S,d1            size of second hand
        bsr     handXY                returns end of hand as X2 in d3, Y2 in d4
        move.l  #AQUA,d1
        move.b  #80,d0
        trap    #15                    set line color
        move.l  #CENTERX,d1            X1
        move.l  #CENTERY,d2            Y1
        move.b  #84,d0
        trap    #15

    endw        bottom of infinite loop


*-----------------------------------------------------------------------------------
* The following subroutine calculates the X,Y position of the end of the clock hand.
* Pre:    d0.w = position of hand as 0 - 60
*         d1.w = length of hand in pixels
* Post:    d3 = X, d4 = Y
handXY:
    movem.l     d0-d2,-(a7)                save registers
    if d0 <hs> #45 then.s            if (position >= 45)
        move.w  #60,d2
        sub.w   d0,d2                index = 60 - position
        move.w  #-1,Ydir            subtract handY from centerY
        move.w  #-1,Xdir            subtract handX from centerX
    else
    if d0 <hs> #30 then.s            else if (position >= 30)
        move.w  d0,d2
        sub.w   #30,d2                index = position - 30
        move.w  #1,Ydir                add handY to centerY
        move.w  #-1,Xdir            subtract handX from centerX
    else 
    if d0 <hs> #15 then.s            else if (position >= 15)
        move.w  #30,d2
        sub.w   d0,d2                index = 30 - position
        move.w  #1,Ydir                add handY to centerY
        move.w  #1,Xdir                add handX to centerX
    else
        move.w  d0,d2                index = position
        move.w  #-1,Ydir            subtract handY from centerY
        move.w  #1,Xdir                add handX to centerX
    endi
    endi
    endi

    asl.w   #1,d2                    endif, index = index * 2 for word data
    lea     cosTable,a0
    move.w  (a0,d2),d3                X = cos(position) * 1000
    mulu    d1,d3                    X = X * length
    divu    #1000,d3                X = X / 1000
    andi.l  #$0000ffff,d3            discard remainder
    muls.w  Xdir,d3                    X = X * Xdir
    add.l   #CENTERX,d3                X = X + CENTERX

    lea     sinTable,a0
    move.w  (a0,d2),d4                Y = sin(position) * 1000
    mulu    d1,d4                    Y = Y * length
    divu    #1000,d4                Y = Y / 1000
    andi.l  #$0000ffff,d4            discard remainder
    muls.w  Ydir,d4                    Y = Y * Ydir
    add.l   #CENTERY,d4                Y = Y + CENTERY

    movem.l (a7)+,d0-d2                restore registers
    rts

*-----------------------------------------------------------------------------------
* Play clock sounds from memory
* Pre:    Sounds are loaded in memory
* Post:    All registers are intact
sounds:
    if.b chimeCount <ne> #0 then.s    if chime
        btst    #0,d7                even or odd seconds?
        if <eq> then.s                if even seconds?
            move    #2,d1            play chime
            move    #72,d0
            trap    #15
            subq.b  #1,chimeCount    decrement chime count
        endi
    else                            else, not chime
        btst    #0,d7                even or odd seconds?
        if <ne> then.s                if odd seconds
            move    #0,d1            play tick
            move    #72,d0
            trap    #15
        else.s                        else, even seconds
            move    #1,d1            play tock
            move    #72,d0
            trap    #15
        endi
    endi
    rts
 

* variables
hourHand    ds.w    1
minHand     ds.w    1
secHand     ds.w    1
Xdir        ds.w    1
Ydir        ds.w    1
chimeCount  ds.b    1

* The following tables are used to calculate the end points of the clock hands
    ds.w    0                        force even memory alignment

* Sin of angle formed at 1 second intervals from 12:00 to 3:00 * 1000
sinTable:
    dc.w    1000                    0 seconds
    dc.w    995
    dc.w    978
    dc.w    951
    dc.w    914
    dc.w    866
    dc.w    809
    dc.w    743
    dc.w    669
    dc.w    588
    dc.w    500
    dc.w    407
    dc.w    309
    dc.w    208
    dc.w    105
    dc.w    0                        15 seconds

* Cos of angle formed at 1 second intervals from 12:00 to 3:00 * 1000
cosTable:
    dc.w    0                        0 seconds
    dc.w    105
    dc.w    208
    dc.w    309
    dc.w    407
    dc.w    500
    dc.w    588
    dc.w    669
    dc.w    743
    dc.w    809
    dc.w    866
    dc.w    914
    dc.w    951
    dc.w    978
    dc.w    995
    dc.w    1000

chime   dc.b    'chime.wav',0        sound file
tick    dc.b    'tick.wav',0
tock    dc.b    'tock.wav',0
num12   dc.b    '12',0
num3    dc.b    '3',0
num6    dc.b    '6',0
num9    dc.b    '9',0

BLACK   EQU        $00000000
MAROON  EQU        $00000080
GREEN   EQU        $00008000
OLIVE   EQU        $00008080
NAVY    EQU        $00800000
PURPLE  EQU        $00800080
TEAL    EQU        $00808000
GRAY    EQU        $00808080
RED     EQU        $000000FF
LIME    EQU        $0000FF00
YELLOW  EQU        $0000FFFF
BLUE    EQU        $00FF0000
FUCHSIA EQU        $00FF00FF
AQUA    EQU        $00FFFF00
LTGRAY  EQU        $00C0C0C0
WHITE   EQU        $00FFFFFF
 
SIZE_H  EQU        120                size of hour hand in pixels
SIZE_M  EQU        160                " " minute " "
SIZE_S  EQU        180                " " second " "

CENTERX EQU        216                X coordinate of clock center
CENTERY EQU        217                Y " " "
RADIUS  EQU        204                RADIUS of clock face

NOON    EQU        12*60*60*100    noon in 100's of a second
FONT    EQU        $01090000        Fixedsys, 9 point, normal


    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
