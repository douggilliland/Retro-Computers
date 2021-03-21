/* Include file for CCOPT, the MESCC optimizer */

#asm
rule0
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 1
 DEFB ' LD HL,@=1+2', 0
 DEFB 6

rule1
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 1
 DEFB ' LD HL,@=1-2', 0
 DEFB 8

rule2
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccmul', 0
 DEFB 1
 DEFB ' LD HL,@=1*2', 0
 DEFB 8

rule3
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccdiv', 0
 DEFB 1
 DEFB ' LD HL,@=1/2', 0
 DEFB 8

rule4
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccmod', 0
 DEFB 1
 DEFB ' LD HL,@=1%2', 0
 DEFB 8

rule5
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccor', 0
 DEFB 1
 DEFB ' LD HL,@=1|2', 0
 DEFB 8

rule6
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccand', 0
 DEFB 1
 DEFB ' LD HL,@=1&2', 0
 DEFB 8

rule7
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccxor', 0
 DEFB 1
 DEFB ' LD HL,@=1^2', 0
 DEFB 8

rule8
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccasr', 0
 DEFB 1
 DEFB ' LD HL,@=1>>2', 0
 DEFB 8

rule9
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccasl', 0
 DEFB 1
 DEFB ' LD HL,@=1<<2', 0
 DEFB 8

rule10
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgor', 0
 DEFB 1
 DEFB ' LD HL,@=1||2', 0
 DEFB 8

rule11
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccland', 0
 DEFB 1
 DEFB ' LD HL,@=1&&2', 0
 DEFB 8

rule12
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cceq', 0
 DEFB 1
 DEFB ' LD HL,@=1==2', 0
 DEFB 8

rule13
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccne', 0
 DEFB 1
 DEFB ' LD HL,@=1!=2', 0
 DEFB 8

rule14
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccgt', 0
 DEFB 1
 DEFB ' LD HL,@=1>2', 0
 DEFB 8

rule15
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclt', 0
 DEFB 1
 DEFB ' LD HL,@=1<2', 0
 DEFB 8

rule16
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccge', 0
 DEFB 1
 DEFB ' LD HL,@=1>=2', 0
 DEFB 8

rule17
 DEFB 5
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccle', 0
 DEFB 1
 DEFB ' LD HL,@=1<=2', 0
 DEFB 8

rule18
 DEFB 2
 DEFB ' LD HL,@1', 0
 DEFB ' ADD HL,HL', 0
 DEFB 1
 DEFB ' LD HL,@=1+1', 0
 DEFB 1

rule19
 DEFB 2
 DEFB ' LD HL,@1', 0
 DEFB ' CALL cclgnot', 0
 DEFB 1
 DEFB ' LD HL,@=!1', 0
 DEFB 3

rule20
 DEFB 2
 DEFB ' LD HL,@1', 0
 DEFB ' CALL ccneg', 0
 DEFB 1
 DEFB ' LD HL,@=-1', 0
 DEFB 3

rule21
 DEFB 2
 DEFB ' LD HL,@1', 0
 DEFB ' CALL cccom', 0
 DEFB 1
 DEFB ' LD HL,@=~1', 0
 DEFB 3

rule22
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,0', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 0
 DEFB 6

rule23
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,1', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 1
 DEFB ' INC HL', 0
 DEFB 5

rule24
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,2', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB 4

rule25
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,3', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 3
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB 3

rule26
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,4', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 4
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB 2

rule27
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,5', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 5
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB ' INC HL', 0
 DEFB 1

rule28
 DEFB 5
 DEFB ' LD HL,@a', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 1
 DEFB ' LD HL,@a+@1', 0
 DEFB 6

rule29
 DEFB 5
 DEFB ' LD HL,@a', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 1
 DEFB ' LD HL,@a-@1', 0
 DEFB 8

rule30
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,0', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 0
 DEFB 8

rule31
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 1
 DEFB ' DEC HL', 0
 DEFB 7

rule32
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,2', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 2
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 6

rule33
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,3', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 3
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 5

rule34
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,4', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 4
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 4

rule35
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,5', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 5
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 3

rule36
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,6', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 6
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 2

rule37
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,7', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 7
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB ' DEC HL', 0
 DEFB 1

rule38
 DEFB 5
 DEFB ' LD HL,@a', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@b', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 1
 DEFB ' LD HL,@a+@b', 0
 DEFB 6

rule39
 DEFB 5
 DEFB ' LD HL,@a', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@b', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccsub', 0
 DEFB 1
 DEFB ' LD HL,@a-@b', 0
 DEFB 8

rule40
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2

rule41
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccmul', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccmul', 0
 DEFB 2

rule42
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccumul', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccumul', 0
 DEFB 2

rule43
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccor', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccor', 0
 DEFB 2

rule44
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccand', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccand', 0
 DEFB 2

rule45
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccxor', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccxor', 0
 DEFB 2

rule46
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cceq', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL cceq', 0
 DEFB 2

rule47
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccneq', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL ccneq', 0
 DEFB 2

rule48
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgor', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL cclgor', 0
 DEFB 2

rule49
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgand', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' CALL cclgand', 0
 DEFB 2

rule50
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2

rule51
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccmul', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccmul', 0
 DEFB 2

rule52
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccumul', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccumul', 0
 DEFB 2

rule53
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccor', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccor', 0
 DEFB 2

rule54
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccand', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccand', 0
 DEFB 2

rule55
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccxor', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccxor', 0
 DEFB 2

rule56
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cceq', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL cceq', 0
 DEFB 2

rule57
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccneq', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL ccneq', 0
 DEFB 2

rule58
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgor', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL cclgor', 0
 DEFB 2

rule59
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgand', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' CALL cclgand', 0
 DEFB 2

rule60
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2

rule61
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccmul', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccmul', 0
 DEFB 2

rule62
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccumul', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccumul', 0
 DEFB 2

rule63
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccor', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccor', 0
 DEFB 2

rule64
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccand', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccand', 0
 DEFB 2

rule65
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccxor', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccxor', 0
 DEFB 2

rule66
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cceq', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL cceq', 0
 DEFB 2

rule67
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL ccneq', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL ccneq', 0
 DEFB 2

rule68
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgor', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL cclgor', 0
 DEFB 2

rule69
 DEFB 4
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB ' CALL cclgand', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' CALL cclgand', 0
 DEFB 2

rule70
 DEFB 3
 DEFB ' CALL ccne', 0
 DEFB ' LD A,H', 0
 DEFB ' OR L', 0
 DEFB 1
 DEFB ' CALL ccne', 0
 DEFB 2

rule71
 DEFB 4
 DEFB ' LD HL,@1', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@2', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' LD DE,@1', 0
 DEFB ' LD HL,@2', 0
 DEFB 2

rule72
 DEFB 4
 DEFB ' LD HL,@a', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@b', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' LD DE,@a', 0
 DEFB ' LD HL,@b', 0
 DEFB 2

rule73
 DEFB 4
 DEFB ' LD HL,(@a)', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@b)', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' LD DE,(@a)', 0
 DEFB ' LD HL,(@b)', 0
 DEFB 2

rule74
 DEFB 3
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@1', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' EX DE,HL', 0
 DEFB ' LD HL,@1', 0
 DEFB 1

rule75
 DEFB 3
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,@a', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' EX DE,HL', 0
 DEFB ' LD HL,@a', 0
 DEFB 1

rule76
 DEFB 3
 DEFB ' PUSH HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB ' POP DE', 0
 DEFB 2
 DEFB ' EX DE,HL', 0
 DEFB ' LD HL,(@a)', 0
 DEFB 1

rule77
 DEFB 3
 DEFB ' LD HL,0', 0
 DEFB ' ADD HL,SP', 0
 DEFB ' CALL ccgw', 0
 DEFB 2
 DEFB ' POP HL', 0
 DEFB ' PUSH HL', 0
 DEFB 5

rule78
 DEFB 3
 DEFB ' LD HL,1', 0
 DEFB ' ADD HL,SP', 0
 DEFB ' CALL ccgw', 0
 DEFB 6
 DEFB ' POP HL', 0
 DEFB ' POP BC', 0
 DEFB ' PUSH BC', 0
 DEFB ' PUSH HL', 0
 DEFB ' LD L,H', 0
 DEFB ' LD H,C', 0
 DEFB 1

rule79
 DEFB 3
 DEFB ' LD HL,2', 0
 DEFB ' ADD HL,SP', 0
 DEFB ' CALL ccgw', 0
 DEFB 4
 DEFB ' POP BC', 0
 DEFB ' POP HL', 0
 DEFB ' PUSH HL', 0
 DEFB ' PUSH BC', 0
 DEFB 3

rule80
 DEFB 3
 DEFB ' LD HL,4', 0
 DEFB ' ADD HL,SP', 0
 DEFB ' CALL ccgw', 0
 DEFB 6
 DEFB ' POP BC', 0
 DEFB ' POP DE', 0
 DEFB ' POP HL', 0
 DEFB ' PUSH HL', 0
 DEFB ' PUSH DE', 0
 DEFB ' PUSH BC', 0
 DEFB 1

rule81
 DEFB 4
 DEFB ' LD HL,@1', 0
 DEFB ' ADD HL,SP', 0
 DEFB ' LD DE,@2', 0
 DEFB ' ADD HL,DE', 0
 DEFB 2
 DEFB ' LD HL,@=1+2', 0
 DEFB ' ADD HL,SP', 0
 DEFB 4

rule82
 DEFB 2
 DEFB ' PUSH @a', 0
 DEFB ' POP @a', 0
 DEFB 0
 DEFB 2

rule83
 DEFB 5
 DEFB ' PUSH HL', 0
 DEFB ' POP BC', 0
 DEFB ' POP HL', 0
 DEFB ' PUSH HL', 0
 DEFB ' PUSH BC', 0
 DEFB 4
 DEFB ' EX DE,HL', 0
 DEFB ' POP HL', 0
 DEFB ' PUSH HL', 0
 DEFB ' PUSH DE', 0
 DEFB 1

rule84
 DEFB 1
 DEFB ' CALL ccne', 0
 DEFB 2
 DEFB ' OR A', 0
 DEFB ' SBC HL,DE', 0
 DEFB 0

rule85
 DEFB 2
 DEFB ' CALL @a', 0
 DEFB ' RET', 0
 DEFB 1
 DEFB ' JP @a', 0
 DEFB 1

rule86
 DEFB 3
 DEFB ' RET', 0
 DEFB '@a', 0
 DEFB ' RET', 0
 DEFB 2
 DEFB '@a', 0
 DEFB ' RET', 0
 DEFB 1

rule87
 DEFB 2
 DEFB ' JP @a', 0
 DEFB ' JP @b', 0
 DEFB 1
 DEFB ' JP @a', 0
 DEFB 3

rule88
 DEFB 2
 DEFB ' JP @a', 0
 DEFB ' JP Z,@b', 0
 DEFB 1
 DEFB ' JP @a', 0
 DEFB 3

rule89
 DEFB 2
 DEFB ' JP @a', 0
 DEFB ' JP NZ,@b', 0
 DEFB 1
 DEFB ' JP @a', 0
 DEFB 3

rule90
 DEFB 3
 DEFB ' JP Z,@a', 0
 DEFB ' JP @b', 0
 DEFB '@a', 0
 DEFB 2
 DEFB ' JP NZ,@b', 0
 DEFB '@a', 0
 DEFB 3

rule91
 DEFB 3
 DEFB ' JP Z,@a', 0
 DEFB '@b', 0
 DEFB ' JP @a', 0
 DEFB 2
 DEFB '@b', 0
 DEFB ' JP @a', 0
 DEFB 3

rule92
 DEFB 3
 DEFB ' JP NZ,@a', 0
 DEFB '@b', 0
 DEFB ' JP @a', 0
 DEFB 2
 DEFB '@b', 0
 DEFB ' JP @a', 0
 DEFB 3

rule93
 DEFB 2
 DEFB ' JP @a', 0
 DEFB '@a', 0
 DEFB 1
 DEFB '@a', 0
 DEFB 3

rule94
 DEFB 2
 DEFB ' JP Z,@a', 0
 DEFB '@a', 0
 DEFB 1
 DEFB '@a', 0
 DEFB 3

rule95
 DEFB 2
 DEFB ' JP NZ,@a', 0
 DEFB '@a', 0
 DEFB 1
 DEFB '@a', 0
 DEFB 3

rule96
 DEFB 2
 DEFB ' LD HL,@a', 0
 DEFB ' CALL ccgw', 0
 DEFB 1
 DEFB ' LD HL,(@a)', 0
 DEFB 3

rules
 DEFW rule0
 DEFW rule1
 DEFW rule2
 DEFW rule3
 DEFW rule4
 DEFW rule5
 DEFW rule6
 DEFW rule7
 DEFW rule8
 DEFW rule9
 DEFW rule10
 DEFW rule11
 DEFW rule12
 DEFW rule13
 DEFW rule14
 DEFW rule15
 DEFW rule16
 DEFW rule17
 DEFW rule18
 DEFW rule19
 DEFW rule20
 DEFW rule21
 DEFW rule22
 DEFW rule23
 DEFW rule24
 DEFW rule25
 DEFW rule26
 DEFW rule27
 DEFW rule28
 DEFW rule29
 DEFW rule30
 DEFW rule31
 DEFW rule32
 DEFW rule33
 DEFW rule34
 DEFW rule35
 DEFW rule36
 DEFW rule37
 DEFW rule38
 DEFW rule39
 DEFW rule40
 DEFW rule41
 DEFW rule42
 DEFW rule43
 DEFW rule44
 DEFW rule45
 DEFW rule46
 DEFW rule47
 DEFW rule48
 DEFW rule49
 DEFW rule50
 DEFW rule51
 DEFW rule52
 DEFW rule53
 DEFW rule54
 DEFW rule55
 DEFW rule56
 DEFW rule57
 DEFW rule58
 DEFW rule59
 DEFW rule60
 DEFW rule61
 DEFW rule62
 DEFW rule63
 DEFW rule64
 DEFW rule65
 DEFW rule66
 DEFW rule67
 DEFW rule68
 DEFW rule69
 DEFW rule70
 DEFW rule71
 DEFW rule72
 DEFW rule73
 DEFW rule74
 DEFW rule75
 DEFW rule76
 DEFW rule77
 DEFW rule78
 DEFW rule79
 DEFW rule80
 DEFW rule81
 DEFW rule82
 DEFW rule83
 DEFW rule84
 DEFW rule85
 DEFW rule86
 DEFW rule87
 DEFW rule88
 DEFW rule89
 DEFW rule90
 DEFW rule91
 DEFW rule92
 DEFW rule93
 DEFW rule94
 DEFW rule95
 DEFW rule96

rules_max
 DEFW 97

rules_saved
 DEFS 194
#endasm
