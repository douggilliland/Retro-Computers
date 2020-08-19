

          org           $100

          ORI           #$FF,D1
          ORI           #$FF,CCR
          ORI           #$FFFF,SR
          BCHG          D2,D1
          BCLR          D2,D1
          BSET          D2,D1
          BTST          D2,D1
          MOVEP         D2,2(A1)
          ANDI          #$FF,D3
          ANDI          #$FF,CCR
          ANDI          #$FFFF,SR
          SUBI.L        #$FFFFFFFF,D0
          ADDI.L        #$FFFFFFFF,D0
          BCHG          #12,D2
          BCLR          #1,D2
          BSET          #4,D2
          BTST          #5,D2
          EORI          #$FF,D6
          EORI          #$FF,CCR
          EORI          #$FFFF,SR
          CMPI.L        #$FFFFFFFF,D4
          MOVEA.W       D1,A1
          MOVEA.L       D1,A1
          MOVE.B        D1,D2
          MOVE.W        D1,D2
          MOVE.L        D1,D2
          NEGX          (A1)
          MOVE          SR,D1
          CHK           D1,D2
          LEA           (A1),A2
          CLR           D4
          NEG           D3
          MOVE          D1,CCR
          NOT           D7
          MOVE          D2,SR
          NBCD          D4
          SWAP          D1
          PEA           (A3)
          EXT.W         D1
          MOVEM         D1,(A2)
          MOVEM         (A1),D1
          EXT.L         D1
          TST           D0
          TAS           D0
          ILLEGAL
          TRAP          #4
          LINK          A1,#3
          UNLK          A1
          MOVE          A1,USP
          MOVE          USP,A2
          RESET
          NOP
          STOP          #41
          RTE
          RTS
          TRAPV
          RTR
          JSR           (A1)
          JMP           (A4)
          ADDQ          #5,D6
          SGT           D1
HERE:     DBGT          D1,HERE
          SUBQ          #4,D1
          BGT           HERE
          BRA           HERE
          BSR           HERE
          MOVEQ         #33,D1
          OR            D1,D2
          DIVU          D1,D2
          SBCD          D1,D2
          DIVS          D1,D2
          SUB           D1,D2
          SUBA          D1,A1
          SUBX          D1,D2
          CMP           D1,D2
          CMPA          D1,A1
          EOR           D1,D2
          CMPM          (A1)+,(A2)+
          AND           D1,D2
          MULU          D1,D2
          ABCD          D1,D2
          EXG           D1,D2
          MULS          D1,D2
          ADD           D1,D2
          ADDA          D1,A1
          ADDX          D1,D2
          ASL           D1,D2
          ASL           #1,D1
          ASL           (A1)
          ASR           D1,D2
          ASR           #1,D1
          ASR           (A1)
          LSL           D1,D2
          LSL           #1,D1
          LSL           (A1)
          LSR           D1,D2
          LSR           #1,D1
          LSR           (A1)

