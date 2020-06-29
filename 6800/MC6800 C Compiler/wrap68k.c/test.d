* disassembly by dynamite+ of test

* system name equates

indx equ 1
fork equ 3
wait equ 4
term equ 5
close equ 15
gtid equ 32
guid equ 33
time equ 39
stime equ 40
ttime equ 41
update equ 42
urec equ 48
ttynum equ 51

* external label equates

s2957 equ $2957
s2b57 equ $2b57
s2b59 equ $2b59
s2bd7 equ $2bd7
s2bd9 equ $2bd9
s2c57 equ $2c57
s2c59 equ $2c59
s2cd7 equ $2cd7
s2cd9 equ $2cd9
s2d57 equ $2d57
s2d59 equ $2d59
s2d5f equ $2d5f
s2d9f equ $2d9f
s2ddf equ $2ddf
s2e00 equ $2e00
s2e1f equ $2e1f
s2e5f equ $2e5f
s2e60 equ $2e60
s2e61 equ $2e61
s2e62 equ $2e62
s2e72 equ $2e72
s2e9f equ $2e9f
s2ea0 equ $2ea0
s2ea1 equ $2ea1
s2ea2 equ $2ea2
s2edf equ $2edf
s3031 equ $3031
s3100 equ $3100
s312e equ $312e
s3200 equ $3200
s322e equ $322e
s32df equ $32df
s32e1 equ $32e1
s32e3 equ $32e3
s32e5 equ $32e5
s32e7 equ $32e7
s32e9 equ $32e9
s32ea equ $32ea
s32eb equ $32eb
s32ec equ $32ec
s32ed equ $32ed
s32ee equ $32ee
s32ef equ $32ef
s32f0 equ $32f0
s32f1 equ $32f1
s32f2 equ $32f2
s32f3 equ $32f3
s32f5 equ $32f5
s32f7 equ $32f7
s32f8 equ $32f8
s32f9 equ $32f9
s32fa equ $32fa
s32fc equ $32fc
s32ff equ $32ff
s3300 equ $3300
s3301 equ $3301
s3302 equ $3302
s3303 equ $3303
s3306 equ $3306
s3307 equ $3307
s3309 equ $3309
s330f equ $330f
s3310 equ $3310
s3312 equ $3312
s3315 equ $3315
s3316 equ $3316
s3317 equ $3317
s3318 equ $3318
s3319 equ $3319
s331a equ $331a
s331c equ $331c
s331d equ $331d
s331e equ $331e
s331f equ $331f
s3320 equ $3320
s3321 equ $3321
s3322 equ $3322
s3323 equ $3323
s3324 equ $3324
s332c equ $332c
s332e equ $332e
s3330 equ $3330
s3331 equ $3331
s3333 equ $3333
s333b equ $333b
s333d equ $333d
s333e equ $333e
s3340 equ $3340
s3341 equ $3341
s3343 equ $3343
s3345 equ $3345
s3347 equ $3347
s3349 equ $3349
s3a20 equ $3a20
s616e equ $616e
s6173 equ $6173
s6174 equ $6174
s6520 equ $6520
s6563 equ $6563
s6564 equ $6564
s656e equ $656e
s6572 equ $6572
s6573 equ $6573
s686c equ $686c
s696c equ $696c
s696d equ $696d
s696f equ $696f
s6d62 equ $6d62
s6d70 equ $6d70
s6e20 equ $6e20
s6e74 equ $6e74
s7065 equ $7065
s7075 equ $7075
s7261 equ $7261
s7269 equ $7269
s732c equ $732c
s7331 equ $7331
s7332 equ $7332
s7365 equ $7365
s7374 equ $7374
s7420 equ $7420
s7469 equ $7469
s7566 equ $7566
s756c equ $756c

s0000 leax 2,s
s0001 equ *-1
s0002 ldd ,s
s0003 equ *-1
s0004 pshs a,b,x
s0005 equ *-1
s0006 jsr s05c6
s0007 equ *-2
s0008 equ *-1
s0009 ldd #$0000
s000a equ *-2
s000b equ *-1
s000c clra
s000d sys term
s000e equ *-2
s0010 pshs y,u
 leay 2,s
 leas >-4,s
s0017 equ *-1
 ldd #$2957
s001a equ *-1
s001b std ,s
s001d ldd s1e08
s0020 subd ,s
 std -6,y
 ldx #s2957
s0025 equ *-2
 stx s1e08
 cmpd #$0000
s002b equ *-3
 lble s0050
s002f equ *-3
 std ,s
 ldx #s2957
s0036 equ *-1
 pshs x
 ldd s1e06
s003a equ *-2
 pshs a,b
 jsr s269f
 leas 4,s
s0043 cmpd -6,y
s0044 equ *-2
s0045 equ *-1
s0046 lbeq s0050
s0049 equ *-1
 ldd #$ffff
s004c equ *-1
s004d lbra s0053
s004e equ *-2
s004f equ *-1
s0050 ldd #$0000
s0052 equ *-1
s0053 leas -2,y
s0054 equ *-1
s0055 puls y,u,pc
s0057 pshs y,u
 leay 2,s
 leas >-2,s
 jsr >s0010
s0061 equ *-1
s0062 cmpd #$ffff
s0063 equ *-3
s0064 equ *-2
s0066 lbne s0070
s0068 equ *-2
s0069 equ *-1
 ldd #$ffff
s006c equ *-1
s006d lbra s007c
s006e equ *-2
s006f equ *-1
s0070 ldd 4,y
s0071 equ *-1
s0072 ldx s1e08
s0073 equ *-2
s0074 equ *-1
s0075 stb ,x+
s0076 equ *-1
s0077 stx s1e08
s0078 equ *-2
 ldd 4,y
s007c leas -2,y
 puls y,u,pc
 pshs y,u
 leay 2,s
 leas >-2,s
 jsr >s0010
s008a equ *-1
 leas -2,y
 puls y,u,pc
 pshs y,u
 leay 2,s
 leas >-2,s
 ldx #s2b57
 cmpx s1e08
 ble s00ad
 ldd 4,y
 ldx s1e08
 stb ,x+
 stx s1e08
s00a7 equ *-2
 sex
 clra
s00ab bra s00b4
s00ad ldd 4,y
 std ,s
 jsr >s0057
s00b4 leas -2,y
 puls y,u,pc
s00b7 equ *-1
s00b8 pshs y,u
 leay 2,s
 leas >-14,s
 leau 4,y
 ldd ,u
 std -14,y
 ldd #$ffff
 std -16,y
 ldd -14,y
 cmpd #$0014
 lbcc s00ec
 leau 2,u
 cmpd s1e06
s00d9 equ *-2
 lbeq s00ec
 jsr >s0010
s00e0 equ *-2
s00e2 ldd s1e06
s00e5 std -16,y
 ldd -14,y
 std s1e06
s00ec leau 2,u
 ldx -2,u
 stx -10,y
s00f2 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
 cmpd #$0025
 lbeq s012c
 cmpd #$0000
 lbeq s012c
 ldx #s2b57
 cmpx s1e08
 ble s0122
 ldd -6,y
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s00f2
s0122 ldd -6,y
 std ,s
 jsr >s0057
 lbra s00f2
s012c ldd -6,y
 lbeq s04ab
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
 ldd #$0000
 std -12,y
 ldd #$0000
 std -14,y
 ldd -6,y
 cmpd #$002d
 lbne s015e
 ldd -14,y
 orb #4
 std -14,y
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
s015e ldd -6,y
 cmpd #$0030
 lbne s0177
 ldd -14,y
 orb #1
 std -14,y
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
s0177 ldd -6,y
 cmpd #$0030
 lblt s01a6
 cmpd #$0039
 lbgt s01a6
 ldd -12,y
 std ,s
 ldd #$000a
 jsr s26b2
 addd -6,y
 addd #$ffd0
 std -12,y
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
 lbra s0177
s01a6 ldd -6,y
 cmpd #$002e
 lbne s01d7
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
s01b9 ldd -6,y
 cmpd #$0030
 lblt s01d7
 cmpd #$0039
 lbgt s01d7
 ldx -10,y
 ldb ,x+
 stx -10,y
 sex
 std -6,y
 lbra s01b9
s01d7 ldd -6,y
 lbeq s04ab
 ldd -6,y
 lbra s047b
 ldd -14,y
 orb #2
 std -14,y
 ldd #$000a
 std -6,y
 lbra s0205
 ldd #$0008
 std -6,y
 lbra s0205
s01f8 ldd #$0002
 std -6,y
 lbra s0205
 ldd #$0010
 std -6,y
s0205 ldd -14,y
 std ,s
 ldd -12,y
 pshs a,b
 ldd -6,y
 pshs a,b
 ldd ,u++
 pshs a,b
 jsr s04bd
 leas 6,s
 lbra s04a8
 ldd ,u++
 clra
 andb #$7f
 std -6,y
 ldd -14,y
 clra
 andb #1
 lbeq s0363
 ldd -6,y
 cmpd #$0020
 blt s023d
 cmpd #$007f
 lbne s0363
s023d ldd -6,y
 lbra s034d
 ldx #s2b57
 cmpx s1e08
 ble s0258
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0260
s0258 ldd #$005c
 std ,s
 jsr >s0057
s0260 ldd #$006e
 std -6,y
 lbra s035c
 ldx #s2b57
 cmpx s1e08
 ble s027e
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0286
s027e ldd #$005c
 std ,s
 jsr >s0057
s0286 ldd #$0072
 std -6,y
 lbra s035c
 ldx #s2b57
 cmpx s1e08
 ble s02a4
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s02ac
s02a4 ldd #$005c
 std ,s
 jsr >s0057
s02ac ldd #$0062
 std -6,y
 lbra s035c
s02b4 ldx #s2b57
 cmpx s1e08
 ble s02ca
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s02d2
s02ca ldd #$005c
 std ,s
 jsr >s0057
s02d2 ldd #$0066
 std -6,y
 lbra s035c
 ldx #s2b57
 cmpx s1e08
 ble s02f0
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s02f8
s02f0 ldd #$005c
 std ,s
 jsr >s0057
s02f8 ldd #$0074
 std -6,y
 lbra s035c
 ldx #s2b57
 cmpx s1e08
 ble s0316
 ldb #$5c
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s031e
s0316 ldd #$005c
 std ,s
 jsr >s0057
s031e ldd #$0065
 std -6,y
 lbra s035c
 ldx #s2b57
 cmpx s1e08
 ble s033c
 ldb #$5e
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0344
s033c ldd #$005e
 std ,s
 jsr >s0057
s0344 ldd -6,y
 eorb #$40
 std -6,y
 lbra s035c
s034d ldx #s1e0a
 std s1e16
s0353 cmpd ,x++
 bne s0353
 jmp >[12,x]
s035c ldd -12,y
 subd #$0001
 std -12,y
s0363 ldx #s2b57
 cmpx s1e08
 ble s0379
 ldd -6,y
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0380
s0379 ldd -6,y
 std ,s
 jsr >s0057
s0380 ldd -12,y
 subd #$0001
 std -12,y
s0387 ldd -12,y
 subd #$0001
 std -12,y
 lblt s03b4
 ldx #s2b57
 cmpx s1e08
 ble s03a9
 ldb #$20
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s0387
s03a9 ldd #$0020
 std ,s
 jsr >s0057
 lbra s0387
s03b4 lbra s04a8
 leau 2,u
 ldx -2,u
 stx -8,y
s03bd ldb [-8,y]
 lbeq s044b
 ldx -8,y
 ldb ,x+
 stx -8,y
 sex
 clra
 andb #$7f
 std -6,y
 ldd -14,y
 clra
 andb #1
 lbeq s041c
 ldd -6,y
 cmpd #$0020
 blt s03e9
 cmpd #$007f
 lbne s041c
s03e9 ldx #s2b57
 cmpx s1e08
 ble s03ff
 ldb #$5e
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0407
s03ff ldd #$005e
 std ,s
 jsr >s0057
s0407 ldd -12,y
 lbeq s0416
 subd #$0001
 std -12,y
 lble s044b
s0416 ldd -6,y
 eorb #$40
 std -6,y
s041c ldx #s2b57
 cmpx s1e08
 ble s0432
 ldd -6,y
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 bra s0439
s0432 ldd -6,y
 std ,s
 jsr >s0057
s0439 ldd -12,y
 lbeq s03bd
 subd #$0001
 std -12,y
 lble s044b
 lbra s03bd
s044b ldd -12,y
 subd #$0001
 std -12,y
 lblt s0478
 ldx #s2b57
 cmpx s1e08
 ble s046d
 ldb #$20
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s044b
s046d ldd #$0020
 std ,s
 jsr >s0057
 lbra s044b
s0478 lbra s04a8
s047b ldx #s1e26
 std s1e38
s0481 cmpd ,x++
 bne s0481
 jmp >[18,x]
 ldx #s2b57
 cmpx s1e08
 ble s04a1
 ldd -6,y
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s00f2
s04a1 ldd -6,y
 std ,s
 jsr >s0057
s04a8 lbra s00f2
s04ab ldd -16,y
 lblt s04b9
 jsr >s0010
 ldd -16,y
 std s1e06
s04b9 leas -2,y
 puls y,u,pc
s04bd pshs y,u
 leay 2,s
 leas >-25,s
 leau -10,y
 ldd 4,y
 std -6,y
 ldd 6,y
 std -8,y
 ldd #$0000
 std -10,y
 ldd 10,y
 clra
 andb #2
 lbeq s04f8
 ldd 4,y
 lbge s04f8
 inc -9,y
 bne s04e9
 inc -10,y
s04e9 ldd -6,y
 nega
 negb
 sbca #0
 std -6,y
 ldd 8,y
 subd #$0001
 std 8,y
s04f8 clr ,-u
s04fa ldd -6,y
 std ,s
 ldd -8,y
 jsr s26f6
 ldx #s1f6b
 ldb d,x
 stb ,-u
 ldd 8,y
 subd #$0001
 std 8,y
 ldd -6,y
 std ,s
 ldd -8,y
 jsr s2730
 std -6,y
 lbne s04fa
 ldd #$0020
 std -6,y
 ldd 10,y
 clra
 andb #5
 cmpd #$0001
 lbne s053a
 ldd #$0030
 std -6,y
 lbra s0549
s053a ldd -10,y
 lbeq s0549
 ldb #$2d
 stb ,-u
 ldd #$0000
 std -10,y
s0549 ldd 10,y
 clra
 andb #4
 lbne s0564
s0552 ldd 8,y
 subd #$0001
 std 8,y
 lblt s0564
 ldd -6,y
 stb ,-u
 lbra s0552
s0564 ldd -10,y
 lbeq s056e
 ldb #$2d
 stb ,-u
s056e ldb ,u
 lbeq s0596
 ldx #s2b57
 cmpx s1e08
 ble s058b
 ldb ,u+
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s056e
s058b ldb ,u+
 sex
 std ,s
 jsr >s0057
 lbra s056e
s0596 ldd 8,y
 subd #$0001
 std 8,y
 lblt s05c2
 ldx #s2b57
 cmpx s1e08
 ble s05b8
 ldd -6,y
 ldx s1e08
 stb ,x+
 stx s1e08
 sex
 clra
 lbra s0596
s05b8 ldd -6,y
 std ,s
 jsr >s0057
 lbra s0596
s05c2 leas -2,y
 puls y,u,pc
s05c6 pshs y,u
 leay 2,s
 leas >-6,s
 ldd #$0001
 std ,s
 ldd #$0002
 pshs a,b
 jsr s27b7
 tfr d,x
 leas 2,s
 stx s331a
 ldx 6,y
 stx -8,y
 stx s32fa
 ldd #$0000
 std s331c
 std s331e
 std s3320
 std s3322
 ldd 4,y
 cmpd #$0002
 lbge s061c
 ldx #s1f7c
 stx ,s
 ldd #$0002
 pshs a,b
 jsr >s00b8
 leas 2,s
 jsr >s0010
 ldd #$00ff
 std ,s
 jsr >s000c
s061c ldd s32e9
 inc s32ea
 bne s0627
 inc s32e9
s0627 aslb
 rola
 ldx #s2b57
 leax d,x
 stx ,s
 ldx #s1fa0
 stx [,s]
 ldd s32eb
 inc s32ec
 bne s0640
 inc s32eb
s0640 aslb
 rola
 ldx #s2bd7
 leax d,x
 stx ,s
 ldx #s1fa7
 stx [,s]
 ldd s32ed
 inc s32ee
 bne s0659
 inc s32ed
s0659 aslb
 rola
 ldx #s2c57
 leax d,x
 stx ,s
 ldx #s1fae
 stx [,s]
 ldd s32ef
 inc s32f0
 bne s0672
 inc s32ef
s0672 aslb
 rola
 ldx #s2cd7
 leax d,x
 stx ,s
 ldx #s1fb8
 stx [,s]
 ldd s32f1
 inc s32f2
 bne s068b
 inc s32f1
s068b aslb
 rola
 ldx #s2d57
 leax d,x
 stx ,s
 ldx #s1fc0
 stx [,s]
 ldx #s2edf
 stx s32fc
s069f ldx -8,y
 leax 2,x
 stx -8,y
 ldx ,x
 stx -6,y
 lbeq s06c0
 ldb [-6,y]
 cmpb #$2b
 lbne s06bd
 ldx -6,y
 stx ,s
 jsr s0a8f
s06bd lbra s069f
s06c0 ldb s3300
 bne s06d6
 ldb s3316
 bne s06d6
 ldb s330f
 bne s06d6
 ldb s3301
 lbeq s06de
s06d6 ldb #1
 stb s32f7
 lbra s06e1
s06de clr s32f7
s06e1 ldb s3300
 lbeq s06fe
 ldb s3316
 lbeq s06fe
 ldd #$0052
 std ,s
 ldd #$0072
 pshs a,b
 jsr s13ee
 leas 2,s
s06fe ldb s32ff
 lbeq s071b
 ldb s330f
 lbeq s071b
 ldd #$0049
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s071b ldb s32ff
 lbeq s0738
 ldb s3301
 lbeq s0738
 ldd #$0061
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s0738 ldb s32ff
 lbeq s0755
 ldb s3300
 lbeq s0755
 ldd #$0072
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s0755 ldb s32ff
 lbeq s0772
 ldb s3316
 lbeq s0772
 ldd #$0052
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s0772 ldb s32ff
 lbeq s078f
 ldb s3302
 lbeq s078f
 ldd #$006f
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s078f ldb s32ff
 lbeq s07ac
 ldb s3315
 lbeq s07ac
 ldd #$004d
 std ,s
 ldd #$006e
 pshs a,b
 jsr s13ee
 leas 2,s
s07ac ldb s330f
 lbeq s07c9
 ldb s3301
 lbeq s07c9
 ldd #$0061
 std ,s
 ldd #$0049
 pshs a,b
 jsr s13ee
 leas 2,s
s07c9 ldb s330f
 lbeq s07e6
 ldb s3300
 lbeq s07e6
 ldd #$0072
 std ,s
 ldd #$0049
 pshs a,b
 jsr s13ee
 leas 2,s
s07e6 ldb s330f
 lbeq s0803
 ldb s3316
 lbeq s0803
 ldd #$0052
 std ,s
 ldd #$0049
 pshs a,b
 jsr s13ee
 leas 2,s
s0803 ldb s330f
 lbeq s0820
 ldb s3302
 lbeq s0820
 ldd #$006f
 std ,s
 ldd #$0049
 pshs a,b
 jsr s13ee
 leas 2,s
s0820 ldb s330f
 lbeq s083d
 ldb s3315
 lbeq s083d
 ldd #$004d
 std ,s
 ldd #$0049
 pshs a,b
 jsr s13ee
 leas 2,s
s083d ldb s3301
 lbeq s085a
 ldb s3300
 lbeq s085a
 ldd #$0072
 std ,s
 ldd #$0061
 pshs a,b
 jsr s13ee
 leas 2,s
s085a ldb s3301
 lbeq s0877
 ldb s3316
 lbeq s0877
 ldd #$0052
 std ,s
 ldd #$0061
 pshs a,b
 jsr s13ee
 leas 2,s
s0877 ldb s3301
 lbeq s0894
 ldb s3302
 lbeq s0894
 ldd #$006f
 std ,s
 ldd #$0061
 pshs a,b
 jsr s13ee
 leas 2,s
s0894 ldb s3301
 lbeq s08b1
 ldb s3315
 lbeq s08b1
 ldd #$004d
 std ,s
 ldd #$0061
 pshs a,b
 jsr s13ee
 leas 2,s
s08b1 ldb s3300
 lbeq s08ce
 ldb s3302
 lbeq s08ce
 ldd #$006f
 std ,s
 ldd #$0072
 pshs a,b
 jsr s13ee
 leas 2,s
s08ce ldb s3300
 sex
 std ,s
 ldb s3315
 sex
 anda ,s
 andb 1,s
 cmpd #$0000
 lbeq s08f3
 ldd #$004d
 std ,s
 ldd #$0072
 pshs a,b
 jsr s13ee
 leas 2,s
s08f3 ldb s3316
 lbeq s0910
 ldb s3315
 lbeq s0910
 ldd #$004d
 std ,s
 ldd #$0052
 pshs a,b
 jsr s13ee
 leas 2,s
s0910 ldb s3306
 lbeq s092d
 ldb s3307
 lbeq s092d
 ldd #$0053
 std ,s
 ldd #$0073
 pshs a,b
 jsr s13ee
 leas 2,s
s092d ldd s32ef
 inc s32f0
 bne s0938
 inc s32ef
s0938 aslb
 rola
 ldx #s2cd7
 leax d,x
 stx ,s
 ldx #s1fc6
 stx [,s]
 ldb s3306
 lbne s0970
 ldb s3307
 lbne s0970
 inc s3306
 ldd s32eb
 inc s32ec
 bne s0962
 inc s32eb
s0962 aslb
 rola
 ldx #s2bd7
 leax d,x
 stx ,s
 ldx #s1e60
 stx [,s]
s0970 ldb s3315
 lbne s09de
 ldd s32ed
 inc s32ee
 bne s0982
 inc s32ed
s0982 aslb
 rola
 ldx #s2c57
 leax d,x
 stx ,s
 ldx #s1fca
 stx [,s]
 ldd s32ed
 inc s32ee
 bne s099b
 inc s32ed
s099b aslb
 rola
 ldx #s2c57
 leax d,x
 stx ,s
 ldx #s1fd8
 stx [,s]
 ldd s32ed
 inc s32ee
 bne s09b4
 inc s32ed
s09b4 aslb
 rola
 ldx #s2c57
 leax d,x
 stx ,s
 ldx #s1fe9
 stx [,s]
 ldd s32ed
 inc s3