/********************************************************************************
;*  描述:                                                                       *
;*          lcd1602显示 遥控键值读取器                                          *
;*         lcd1602显示 遥控器接p3.2                                             *
;*          喇叭接p1.5  继电器接p1.4                                            *
;*         17(40h)键按下，继电器吸合。19(04h)键按下，继电器关闭。               *
;*         连接方法：使用红外功能时 J1跳线短接                                                                        *
********************************************************************************/

;-----------------------------------------------
       IRCOM  EQU  20H       ;20H-23H IR使用
        X     EQU  26H       ;LCD 地址变量

       IRIN   EQU  P3.2
       BEEP   EQU  P1.5
       RELAY  EQU  P1.4
       
        RS    EQU  P2.6
        RW    EQU  P2.5
        EN    EQU  P2.7
;------------------------------------------------
         ORG 0000H
         JMP  MAIN
;------------------------------------------------
MAIN:
          MOV   SP,#40H
          MOV   A,#00H
          MOV   R0,#20H
LOOP0:    MOV   @R0,A          ;20H-26H清零
          INC   R0
          CJNE  R0,#27H,LOOP0
          SETB  IRIN
          CALL  SET_LCD
          CALL  MENU1
LOOP1:
          CALL  IR_IN
          CALL  IR_SHOW
          MOV  A,22H
          CJNE  A,#40H,LOOP2    ;K17键按下
          CLR   RELAY           ;继电器吸合
LOOP2:    CJNE  A,#04H,LOOP3    ;K19键按下
          SETB  RELAY           ;继电器关闭
LOOP3:    JMP   LOOP1
          
;-----------------------------------------------------
;  LCD 初始化设置
;-----------------------------------------------------
SET_LCD:
          CLR  EN
          CALL  INIT_LCD     ;初始化 LCD
          CALL  DELAY1
          MOV  DPTR,#INFO1   ;指针指到显示信息1
          MOV  A,#1          ;显示在第一行
          CALL  LCD_SHOW
          MOV  DPTR,#INFO2   ;指针指到显示信息2
          MOV  A,#2          ;显示在第二行
          CALL  LCD_SHOW
          RET
;-----------------------------------------------------
INIT_LCD:                 ;8位I/O控制 LCD 接口初始化
          MOV  A,#38H     ;双列显示，字形5*7点阵
          CALL  WCOM
          CALL  DELAY1
          MOV  A,#38H     ;双列显示，字形5*7点阵
          CALL  WCOM
          CALL  DELAY1
          MOV  A,#38H     ;双列显示，字形5*7点阵
          CALL  WCOM
          CALL  DELAY1
          MOV  A,#0CH     ;开显示，关光标，
          CALL  WCOM
          CALL  DELAY1
          MOV  A,#01H     ;清除 LCD 显示屏
          CALL  WCOM
          CALL  DELAY1
          RET
;----------------------------------------------------
LCD_SHOW:       ;在LCD的第一行或第二行显示信息字符

          CJNE  A,#1,LINE2  ;判断是否为第一行
  LINE1:  MOV  A,#80H       ;设置 LCD 的第一行地址
          CALL  WCOM        ;写入命令
          CALL  CLR_LINE    ;清除该行字符数据
          MOV  A,#80H       ;设置 LCD 的第一行地址
          CALL  WCOM        ;写入命令
          JMP  FILL

  LINE2:  MOV  A,#0C0H      ;设置 LCD 的第二行地址
          CALL  WCOM        ;写入命令
          CALL  CLR_LINE    ;清除该行字符数据
          MOV  A,#0C0H      ;设置 LCD 的第二行地址
          CALL  WCOM
  FILL:   CLR  A            ;填入字符
          MOVC  A,@A+DPTR   ;由消息区取出字符
          CJNE  A,#0,LC1    ;判断是否为结束码
          RET
  LC1:    CALL  WDATA       ;写入数据
          INC  DPTR         ;指针加1
          JMP  FILL         ;继续填入字符
          RET
;---------------------------------------------------
CLR_LINE:                  ;清除该行 LCD 的字符
          MOV  R0,#24
   CL1:   MOV  A,#' '
          CALL  WDATA
          DJNZ  R0,CL1
          RET
;----------------------------------------------------
MENU1:                      ;LCD 显示工作菜单信息
         MOV   DPTR,#MENU2
         MOV   A,#1         ;在第一行显示信息
         CALL  LCD_SHOW
         RET
MENU2:  DB  " Red Control ",0
;-----------------------------------------------------
INFO1:  DB  "              ",0  ;LCD 第一行显示信息
INFO2:  DB  "  IR-CODE: --H  ",0  ;LCD 第二行显示信息
;-----------------------------------------------------

;-----------------------------------------------------
; 写指令、数据使能子程序
;-----------------------------------------------------
WCOM:
          MOV  P0,A        ;写指令使能
          CLR RS           ;RS=L,RW=L,D0-D7=指令码，E=高脉冲
          CLR RW
          SETB EN
          CALL  DELAY0
          CLR EN
          RET
                  
WDATA:
          MOV   P0,A      ;写数据使能
          SETB  RS        ;RS=H,RW=L,D0-D7=数据，E=高脉冲
          CLR   RW
          SETB  EN
          CALL  DELAY0
          CLR   EN
          RET

DELAY0:   MOV  R7,#250      ;延时500微秒
          DJNZ  R7,$
          RET
;---------------------------------------------------
;在 LCD 第二行显示字符
;A=ASC DATA, B=LINE X POS
;---------------------------------------------------
LCDP2:                    ;在LCD的第二行显示字符
         PUSH  ACC        ;
         MOV  A,B         ;设置显示地址
         ADD  A,#0C0H     ;设置LCD的第二行地址
         CALL  WCOM       ;写入命令
         POP  ACC         ;由堆栈取出A
         CALL  WDATA      ;写入数据
         RET
;---------------------------------------------------
; IR 译码子程序
;---------------------------------------------------
IR_IN:              
          MOV   R0,#IRCOM
 I1:      JNB  IRIN,I2       ;等待 IR 信号出现
          JMP  I1
 I2:      MOV  R4,#20
 I20:     CALL  DEL
          DJNZ  R4,I20
          JB  IRIN,I1        ;确认IR信号出现
 I21:     JB  IRIN,I3        ;等 IR 变为高电平
          CALL  DEL
          JMP  I21
 I3:      MOV  R3,#0         ;8位数清为0
 LL:      JNB  IRIN,I4       ;等 IR 变为低电平
          CALL  DEL
          JMP  LL
 I4:      JB  IRIN,I5        ;等 IR 变为高电平
          CALL  DEL
          JMP  I4
 I5:      MOV  R2,#0         ;0.14ms 计数
 L1:      CALL  DEL
          JB  IRIN, N1       ;等 IR 变为高电平
                             ;IR=0，检查R2中的计数值 
          MOV  A,#8
          CLR  C
          SUBB  A,R2         ;判断高低位
                             ;IF C=0  BIT=0
          MOV  A,@R0
          RRC  A
          MOV  @R0,A         ;处理完一位
          INC  R3
          CJNE  R3,#8,LL     ;需处理完8位  
          MOV  R3,#0
          INC  R0
          CJNE  R0,#24H,LL   ;收集到4字节了
          JMP  OK
 N1:      INC  R2
          CJNE  R2,#30,L1    ;0.14ms 计数过长则时间到自动离开
 OK:      RET
;--------------------------------------------------------------------
IR_SHOW:
          MOV A,22H
          CPL A                ;将22H取反后和23H比较
          CJNE A,23H,IR_SHOW1  ;如果不等表示接收数据发生错误,放弃。
          CALL   CONV
          CALL  BEEP_BL        ;蜂鸣器鸣响表示解码成功
IR_SHOW1: RET
;--------------------------------------------------------------------
;转换为 ASCII 码并显示
;--------------------------------------------------------------------
CONV:
          MOV   X,#11        ;设置显示起始位置
          MOV   A,22H
          ANL   A,#0F0H      ;取出高四位二进制数
          SWAP  A            ;高四位与低四位互换
          PUSH  ACC          ;压入堆栈
          CLR   C            ;C=0
          SUBB  A,#0AH       ;减10
          POP   ACC          ;弹出堆栈
          JC    ASCII0       ;该数小于10，转ASCII0
          ADD   A,#07H       ;大于10的数加上37H
ASCII0:   ADD   A,#30H       ;小于10的数加上30H
          MOV   B,X
          CALL  LCDP2

          MOV   A,22H
          ANL   A,#0FH        ;取出低四位二进制数
          PUSH  ACC
          CLR   C
          SUBB  A,#0AH        ;减10
          POP   ACC
          JC    ASCII1        ;该数小于10，转ASCII0
          ADD   A,#07H        ;大于10的数加上37H
ASCII1:   ADD   A,#30H        ;小于10的数加上30H
          INC   X
          MOV   B,X
          CALL  LCDP2
          RET
;--------------------------------------------------------
;蜂鸣器响一声子程序
;--------------------------------------------------------
BEEP_BL:
         MOV  R6,#100
  BL1:   CALL  DEX1
         CPL  BEEP
         DJNZ  R6,BL1
         MOV  R5,#25
         CALL  DELAY
         RET
 DEX1:   MOV  R7,#180
 DEX2:   NOP
         DJNZ  R7,DEX2
         RET
 DELAY:                    ;延时R5×10MS
         MOV  R6,#50
  D1:    MOV  R7,#100
         DJNZ  R7,$
         DJNZ  R6,D1
         DJNZ  R5,DELAY
         RET
;------------------------------------------------
; DELAY  R5*0.14MS
DEL:
          MOV  R5,#1       ;IR解码使用
DEL0:     MOV  R6,#2
DEL1:     MOV  R7,#32
DEL2:     DJNZ  R7,DEL2
          DJNZ  R6,DEL1
          DJNZ  R5,DEL0
          RET

DELAY1:                    ;延时5MS
         MOV  R6,#25
  DL2:   MOV  R7,#100
         DJNZ  R7,$
         DJNZ  R6,DL2
         RET
;-------------------------------------------------
        END


