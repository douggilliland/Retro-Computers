EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_02x25_Odd_Even J1
U 1 1 5FD62DCD
P 2150 3550
F 0 "J1" H 2200 4967 50  0000 C CNN
F 1 "Conn_01x40" H 2200 4876 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x25_P2.54mm_Horizontal" H 2150 3550 50  0001 C CNN
F 3 "~" H 2150 3550 50  0001 C CNN
	1    2150 3550
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0101
U 1 1 5FD64472
P 3050 3450
F 0 "#PWR0101" H 3050 3300 50  0001 C CNN
F 1 "+5V" H 3065 3623 50  0000 C CNN
F 2 "" H 3050 3450 50  0001 C CNN
F 3 "" H 3050 3450 50  0001 C CNN
	1    3050 3450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0102
U 1 1 5FD65A34
P 850 3600
F 0 "#PWR0102" H 850 3450 50  0001 C CNN
F 1 "+5V" H 865 3773 50  0000 C CNN
F 2 "" H 850 3600 50  0001 C CNN
F 3 "" H 850 3600 50  0001 C CNN
	1    850  3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	1950 3550 1700 3550
$Comp
L power:GND #PWR0103
U 1 1 5FD65E00
P 3050 3550
F 0 "#PWR0103" H 3050 3300 50  0001 C CNN
F 1 "GND" H 3055 3377 50  0000 C CNN
F 2 "" H 3050 3550 50  0001 C CNN
F 3 "" H 3050 3550 50  0001 C CNN
	1    3050 3550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 5FD66D1A
P 1100 3300
F 0 "#PWR0104" H 1100 3050 50  0001 C CNN
F 1 "GND" H 1105 3127 50  0000 C CNN
F 2 "" H 1100 3300 50  0001 C CNN
F 3 "" H 1100 3300 50  0001 C CNN
	1    1100 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 3450 1750 3400
Wire Wire Line
	1750 3450 1950 3450
Text GLabel 1950 2350 0    50   Input ~ 0
A0
Text GLabel 1950 2450 0    50   Input ~ 0
A1
Text GLabel 1950 2550 0    50   Input ~ 0
A2
Text GLabel 1950 2650 0    50   Input ~ 0
A3
Text GLabel 1950 2750 0    50   Input ~ 0
A4
Text GLabel 1950 2850 0    50   Input ~ 0
A5
Text GLabel 1950 2950 0    50   Input ~ 0
A6
Text GLabel 1950 3050 0    50   Input ~ 0
A7
Text GLabel 1950 3150 0    50   Input ~ 0
A8
Text GLabel 1950 3250 0    50   Input ~ 0
A9
Text GLabel 1950 3350 0    50   Input ~ 0
A10
Text GLabel 1950 3650 0    50   Input ~ 0
A11
Text GLabel 1950 3750 0    50   Input ~ 0
A12
Text GLabel 1950 3850 0    50   Input ~ 0
A13
Text GLabel 1950 3950 0    50   Input ~ 0
A14
Text GLabel 1950 4050 0    50   Input ~ 0
A15
Text GLabel 2450 2350 2    50   BiDi ~ 0
D0
Text GLabel 2450 2450 2    50   BiDi ~ 0
D1
Text GLabel 2450 2550 2    50   BiDi ~ 0
D2
Text GLabel 2450 2650 2    50   BiDi ~ 0
D3
Text GLabel 2450 2750 2    50   BiDi ~ 0
D4
Text GLabel 2450 2850 2    50   BiDi ~ 0
D5
Text GLabel 2450 2950 2    50   BiDi ~ 0
D6
Text GLabel 2450 3050 2    50   BiDi ~ 0
D7
Text GLabel 1900 4800 0    50   Input ~ 0
~RESET~
Text GLabel 2450 4750 2    50   BiDi ~ 0
~NMI~
Text GLabel 1950 4150 0    50   Input ~ 0
RDY
Text GLabel 1950 4250 0    50   Input ~ 0
BE
Text GLabel 1950 4350 0    50   Input ~ 0
CLK
Text GLabel 1700 4400 0    50   Input ~ 0
R~W~
Text GLabel 1950 4650 0    50   Input ~ 0
SYNC
Text GLabel 1700 4550 0    50   BiDi ~ 0
~IRQ~
Text GLabel 2650 4650 2    50   BiDi ~ 0
~SLOT_IRQ~
Text GLabel 2450 4550 2    50   BiDi ~ 0
EX3
Text GLabel 2450 4450 2    50   BiDi ~ 0
EX2
Text GLabel 2450 4350 2    50   BiDi ~ 0
CLK_12M
Wire Wire Line
	1700 3600 1700 3550
Wire Wire Line
	1700 4550 1950 4550
Text GLabel 2450 3650 2    50   BiDi ~ 0
~SSEL~
Text GLabel 2750 3700 2    50   BiDi ~ 0
~INH~
Text GLabel 2700 3850 2    50   BiDi ~ 0
~SLOT_SEL~
Text GLabel 2450 3950 2    50   BiDi ~ 0
LED1
Text GLabel 2450 4050 2    50   BiDi ~ 0
LED2
Text GLabel 2450 4150 2    50   BiDi ~ 0
LED3
Text GLabel 2450 4250 2    50   BiDi ~ 0
LED4
Text GLabel 2450 3150 2    50   BiDi ~ 0
EX0
Text GLabel 2450 3250 2    50   BiDi ~ 0
EX1
Text GLabel 2450 3350 2    50   BiDi ~ 0
~SLOW~
Wire Wire Line
	2450 3450 3050 3450
Wire Wire Line
	2450 3550 3050 3550
Wire Wire Line
	2750 3700 2700 3700
Wire Wire Line
	2700 3700 2700 3750
Wire Wire Line
	2700 3750 2450 3750
Wire Wire Line
	2650 4650 2450 4650
Wire Wire Line
	1900 4800 1950 4800
Wire Wire Line
	1950 4800 1950 4750
Wire Wire Line
	1700 4400 1750 4400
Wire Wire Line
	1750 4400 1750 4450
Wire Wire Line
	1750 4450 1950 4450
Wire Wire Line
	2700 3850 2450 3850
Wire Wire Line
	1300 3400 1750 3400
Wire Wire Line
	1300 3400 1300 3300
Wire Wire Line
	1300 3300 1100 3300
Wire Wire Line
	850  3600 1700 3600
$EndSCHEMATC
