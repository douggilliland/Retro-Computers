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
P 2500 3450
F 0 "J1" H 2550 4867 50  0000 C CNN
F 1 "Conn_01x40" H 2550 4776 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x25_P2.54mm_Horizontal" H 2500 3450 50  0001 C CNN
F 3 "~" H 2500 3450 50  0001 C CNN
	1    2500 3450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0101
U 1 1 5FD64472
P 3000 3350
F 0 "#PWR0101" H 3000 3200 50  0001 C CNN
F 1 "+5V" H 3015 3523 50  0000 C CNN
F 2 "" H 3000 3350 50  0001 C CNN
F 3 "" H 3000 3350 50  0001 C CNN
	1    3000 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 3350 2800 3350
$Comp
L power:+5V #PWR0102
U 1 1 5FD65A34
P 2000 3450
F 0 "#PWR0102" H 2000 3300 50  0001 C CNN
F 1 "+5V" H 2015 3623 50  0000 C CNN
F 2 "" H 2000 3450 50  0001 C CNN
F 3 "" H 2000 3450 50  0001 C CNN
	1    2000 3450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 5FD65E00
P 3000 3450
F 0 "#PWR0103" H 3000 3200 50  0001 C CNN
F 1 "GND" H 3005 3277 50  0000 C CNN
F 2 "" H 3000 3450 50  0001 C CNN
F 3 "" H 3000 3450 50  0001 C CNN
	1    3000 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 3450 2800 3450
$Comp
L power:GND #PWR0104
U 1 1 5FD66D1A
P 1850 3300
F 0 "#PWR0104" H 1850 3050 50  0001 C CNN
F 1 "GND" H 1855 3127 50  0000 C CNN
F 2 "" H 1850 3300 50  0001 C CNN
F 3 "" H 1850 3300 50  0001 C CNN
	1    1850 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 3350 2100 3300
Wire Wire Line
	2100 3300 1850 3300
Wire Wire Line
	2100 3350 2300 3350
Text GLabel 2300 2250 0    50   Input ~ 0
A0
Text GLabel 2300 2350 0    50   Input ~ 0
A1
Text GLabel 2300 2450 0    50   Input ~ 0
A2
Text GLabel 2300 2550 0    50   Input ~ 0
A3
Text GLabel 2300 2650 0    50   Input ~ 0
A4
Text GLabel 2300 2750 0    50   Input ~ 0
A5
Text GLabel 2300 2850 0    50   Input ~ 0
A6
Text GLabel 2300 2950 0    50   Input ~ 0
A7
Text GLabel 2300 3050 0    50   Input ~ 0
A8
Text GLabel 2300 3150 0    50   Input ~ 0
A9
Text GLabel 2300 3250 0    50   Input ~ 0
A10
Text GLabel 2300 3550 0    50   Input ~ 0
A11
Text GLabel 2300 3650 0    50   Input ~ 0
A12
Text GLabel 2300 3750 0    50   Input ~ 0
A13
Text GLabel 2300 3850 0    50   Input ~ 0
A14
Text GLabel 2300 3950 0    50   Input ~ 0
A15
Text GLabel 2800 2250 2    50   BiDi ~ 0
D0
Text GLabel 2800 2350 2    50   BiDi ~ 0
D1
Text GLabel 2800 2450 2    50   BiDi ~ 0
D2
Text GLabel 2800 2550 2    50   BiDi ~ 0
D3
Text GLabel 2800 2650 2    50   BiDi ~ 0
D4
Text GLabel 2800 2750 2    50   BiDi ~ 0
D5
Text GLabel 2800 2850 2    50   BiDi ~ 0
D6
Text GLabel 2800 2950 2    50   BiDi ~ 0
D7
Text GLabel 2300 4650 0    50   Input ~ 0
~RESET~
Text GLabel 2800 4650 2    50   BiDi ~ 0
~NMI~
Text GLabel 1750 4050 0    50   Input ~ 0
RDY
Text GLabel 1750 4150 0    50   Input ~ 0
BE
Text GLabel 2300 4250 0    50   Input ~ 0
CLK
Text GLabel 2050 4350 0    50   Input ~ 0
R~W~
Text GLabel 2300 4550 0    50   Input ~ 0
SYNC
Text GLabel 1750 4450 0    50   Input ~ 0
~IRQ~
Text GLabel 2800 4550 2    50   BiDi ~ 0
~IRQ1~
Text GLabel 2800 4450 2    50   BiDi ~ 0
~IRQ2~
Text GLabel 2800 4350 2    50   BiDi ~ 0
~IRQ3~
Text GLabel 2800 4250 2    50   BiDi ~ 0
~IRQ4~
Wire Wire Line
	1750 4450 2300 4450
Wire Wire Line
	1750 4050 2300 4050
Wire Wire Line
	1750 4150 2300 4150
Text GLabel 2800 3650 2    50   BiDi ~ 0
~INH~
Text GLabel 2800 3550 2    50   BiDi ~ 0
~SSEL~
Text GLabel 2800 3850 2    50   BiDi ~ 0
LED1
Text GLabel 2800 3950 2    50   BiDi ~ 0
LED2
Text GLabel 2800 4050 2    50   BiDi ~ 0
LED3
Text GLabel 2800 4150 2    50   BiDi ~ 0
~IRQ5~
Text GLabel 2800 3050 2    50   BiDi ~ 0
EX0
Text GLabel 2800 3150 2    50   BiDi ~ 0
EX1
Text GLabel 2800 3250 2    50   BiDi ~ 0
~SLOW~
$Comp
L 65xx:W65C02SxP U2
U 1 1 5FD67072
P 4600 3500
F 0 "U2" H 4600 5231 50  0000 C CNN
F 1 "W65C02SxP" H 4600 5140 50  0000 C CIB
F 2 "Package_DIP:DIP-40_W15.24mm_Socket" H 4600 5500 50  0001 C CNN
F 3 "http://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf" H 4600 5400 50  0001 C CNN
	1    4600 3500
	1    0    0    -1  
$EndComp
Text GLabel 5200 4000 2    50   BiDi ~ 0
D0
Text GLabel 5200 4100 2    50   BiDi ~ 0
D1
Text GLabel 5200 4200 2    50   BiDi ~ 0
D2
Text GLabel 5200 4300 2    50   BiDi ~ 0
D3
Text GLabel 5200 4400 2    50   BiDi ~ 0
D4
Text GLabel 5200 4500 2    50   BiDi ~ 0
D5
Text GLabel 5200 4600 2    50   BiDi ~ 0
D6
Text GLabel 5200 4700 2    50   BiDi ~ 0
D7
Text GLabel 5200 2300 2    50   Output ~ 0
A0
Text GLabel 5200 2400 2    50   Output ~ 0
A1
Text GLabel 5200 2500 2    50   Output ~ 0
A2
Text GLabel 5200 2600 2    50   Output ~ 0
A3
Text GLabel 5200 2700 2    50   Output ~ 0
A4
Text GLabel 5200 2800 2    50   Output ~ 0
A5
Text GLabel 5200 2900 2    50   Output ~ 0
A6
Text GLabel 5200 3000 2    50   Output ~ 0
A7
Text GLabel 5200 3100 2    50   Output ~ 0
A8
Text GLabel 5200 3200 2    50   Output ~ 0
A9
Text GLabel 5200 3300 2    50   Output ~ 0
A10
Text GLabel 5200 3400 2    50   Output ~ 0
A11
Text GLabel 5200 3500 2    50   Output ~ 0
A12
Text GLabel 5200 3600 2    50   Output ~ 0
A13
Text GLabel 5200 3700 2    50   Output ~ 0
A14
Text GLabel 5200 3800 2    50   Output ~ 0
A15
$Comp
L power:GND #PWR0105
U 1 1 5FD6BC9C
P 4600 5050
F 0 "#PWR0105" H 4600 4800 50  0001 C CNN
F 1 "GND" H 4605 4877 50  0000 C CNN
F 2 "" H 4600 5050 50  0001 C CNN
F 3 "" H 4600 5050 50  0001 C CNN
	1    4600 5050
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0106
U 1 1 5FD6C88D
P 4600 1650
F 0 "#PWR0106" H 4600 1500 50  0001 C CNN
F 1 "+5V" H 4615 1823 50  0000 C CNN
F 2 "" H 4600 1650 50  0001 C CNN
F 3 "" H 4600 1650 50  0001 C CNN
	1    4600 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 1950 4600 1700
$Comp
L Device:C_Small C3
U 1 1 5FD6D1DF
P 4800 1700
F 0 "C3" V 4571 1700 50  0000 C CNN
F 1 "10n" V 4662 1700 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 4800 1700 50  0001 C CNN
F 3 "~" H 4800 1700 50  0001 C CNN
	1    4800 1700
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 5FD6E104
P 5050 1700
F 0 "#PWR0107" H 5050 1450 50  0001 C CNN
F 1 "GND" H 5055 1527 50  0000 C CNN
F 2 "" H 5050 1700 50  0001 C CNN
F 3 "" H 5050 1700 50  0001 C CNN
	1    5050 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 1700 4900 1700
Wire Wire Line
	4700 1700 4600 1700
Connection ~ 4600 1700
Wire Wire Line
	4600 1700 4600 1650
Text GLabel 4000 4200 0    50   Input ~ 0
SYNC
Text GLabel 4000 3900 0    50   Input ~ 0
BE
Text GLabel 4000 3800 0    50   Input ~ 0
RDY
Text GLabel 4000 3500 0    50   Input ~ 0
R~W~
Text GLabel 4000 2600 0    50   Input ~ 0
CLK
Text GLabel 4000 2300 0    50   Input ~ 0
~RESET~
Text GLabel 4000 3100 0    50   Input ~ 0
~IRQ~
Text GLabel 4000 3200 0    50   Input ~ 0
~NMI~
$Comp
L Memory_EEPROM:28C256 U4
U 1 1 5FDE4AF9
P 9500 3450
F 0 "U4" H 9500 4731 50  0000 C CNN
F 1 "28C256" H 9500 4640 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm_Socket" H 9500 3450 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 9500 3450 50  0001 C CNN
	1    9500 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 4350 2050 4350
$Comp
L power:+5V #PWR0111
U 1 1 5FE008F9
P 8950 4150
F 0 "#PWR0111" H 8950 4000 50  0001 C CNN
F 1 "+5V" H 8965 4323 50  0000 C CNN
F 2 "" H 8950 4150 50  0001 C CNN
F 3 "" H 8950 4150 50  0001 C CNN
	1    8950 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	9100 4150 8950 4150
Wire Wire Line
	9050 4550 9500 4550
$Comp
L power:GND #PWR0112
U 1 1 5FE02979
P 9500 4550
F 0 "#PWR0112" H 9500 4300 50  0001 C CNN
F 1 "GND" H 9505 4377 50  0000 C CNN
F 2 "" H 9500 4550 50  0001 C CNN
F 3 "" H 9500 4550 50  0001 C CNN
	1    9500 4550
	1    0    0    -1  
$EndComp
Text GLabel 9100 2550 0    50   Input ~ 0
A0
Text GLabel 9100 2650 0    50   Input ~ 0
A1
Text GLabel 9100 2750 0    50   Input ~ 0
A2
Text GLabel 9100 2850 0    50   Input ~ 0
A3
Text GLabel 9100 2950 0    50   Input ~ 0
A4
Text GLabel 9100 3050 0    50   Input ~ 0
A5
Text GLabel 9100 3150 0    50   Input ~ 0
A6
Text GLabel 9100 3250 0    50   Input ~ 0
A7
Text GLabel 9100 3350 0    50   Input ~ 0
A8
Text GLabel 9100 3450 0    50   Input ~ 0
A9
Text GLabel 9100 3550 0    50   Input ~ 0
A10
Text GLabel 9100 3650 0    50   Input ~ 0
A11
Text GLabel 9100 3750 0    50   Input ~ 0
A12
Text GLabel 9100 3850 0    50   Input ~ 0
A13
Text GLabel 9100 3950 0    50   Input ~ 0
A14
Text GLabel 9900 2550 2    50   BiDi ~ 0
D0
Text GLabel 9900 2650 2    50   BiDi ~ 0
D1
Text GLabel 9900 2750 2    50   BiDi ~ 0
D2
Text GLabel 9900 2850 2    50   BiDi ~ 0
D3
Text GLabel 9900 2950 2    50   BiDi ~ 0
D4
Text GLabel 9900 3050 2    50   BiDi ~ 0
D5
Text GLabel 9900 3150 2    50   BiDi ~ 0
D6
Text GLabel 9900 3250 2    50   BiDi ~ 0
D7
Text GLabel 7100 2750 0    50   Input ~ 0
A0
Text GLabel 7100 2850 0    50   Input ~ 0
A1
Text GLabel 7100 2950 0    50   Input ~ 0
A2
Text GLabel 7100 3050 0    50   Input ~ 0
A3
Text GLabel 7100 3150 0    50   Input ~ 0
A4
Text GLabel 7100 3250 0    50   Input ~ 0
A5
Text GLabel 7100 3350 0    50   Input ~ 0
A6
Text GLabel 7100 3450 0    50   Input ~ 0
A7
Text GLabel 7100 3550 0    50   Input ~ 0
A8
Text GLabel 7100 3650 0    50   Input ~ 0
A9
Text GLabel 7100 3750 0    50   Input ~ 0
A10
Text GLabel 7100 3850 0    50   Input ~ 0
A11
Text GLabel 7100 3950 0    50   Input ~ 0
A12
Text GLabel 7100 4050 0    50   Input ~ 0
A13
Text GLabel 7100 4150 0    50   Input ~ 0
A14
$Comp
L power:GND #PWR0116
U 1 1 5FE2A461
P 7600 4350
F 0 "#PWR0116" H 7600 4100 50  0001 C CNN
F 1 "GND" H 7605 4177 50  0000 C CNN
F 2 "" H 7600 4350 50  0001 C CNN
F 3 "" H 7600 4350 50  0001 C CNN
	1    7600 4350
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0118
U 1 1 5FE2C364
P 7600 2250
F 0 "#PWR0118" H 7600 2100 50  0001 C CNN
F 1 "+5V" H 7615 2423 50  0000 C CNN
F 2 "" H 7600 2250 50  0001 C CNN
F 3 "" H 7600 2250 50  0001 C CNN
	1    7600 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7600 2550 7600 2300
$Comp
L Device:C_Small C1
U 1 1 5FE2C36B
P 7800 2300
F 0 "C1" V 7571 2300 50  0000 C CNN
F 1 "10n" V 7662 2300 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7800 2300 50  0001 C CNN
F 3 "~" H 7800 2300 50  0001 C CNN
	1    7800 2300
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0119
U 1 1 5FE2C371
P 8050 2300
F 0 "#PWR0119" H 8050 2050 50  0001 C CNN
F 1 "GND" H 8055 2127 50  0000 C CNN
F 2 "" H 8050 2300 50  0001 C CNN
F 3 "" H 8050 2300 50  0001 C CNN
	1    8050 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 2300 7900 2300
Wire Wire Line
	7700 2300 7600 2300
Connection ~ 7600 2300
Wire Wire Line
	7600 2300 7600 2250
$Comp
L power:+5V #PWR0120
U 1 1 5FE2E052
P 9500 2050
F 0 "#PWR0120" H 9500 1900 50  0001 C CNN
F 1 "+5V" H 9515 2223 50  0000 C CNN
F 2 "" H 9500 2050 50  0001 C CNN
F 3 "" H 9500 2050 50  0001 C CNN
	1    9500 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	9500 2350 9500 2100
$Comp
L Device:C_Small C2
U 1 1 5FE2E059
P 9700 2100
F 0 "C2" V 9471 2100 50  0000 C CNN
F 1 "10n" V 9562 2100 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 9700 2100 50  0001 C CNN
F 3 "~" H 9700 2100 50  0001 C CNN
	1    9700 2100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0121
U 1 1 5FE2E05F
P 9950 2100
F 0 "#PWR0121" H 9950 1850 50  0001 C CNN
F 1 "GND" H 9955 1927 50  0000 C CNN
F 2 "" H 9950 2100 50  0001 C CNN
F 3 "" H 9950 2100 50  0001 C CNN
	1    9950 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	9950 2100 9800 2100
Wire Wire Line
	9600 2100 9500 2100
Connection ~ 9500 2100
Wire Wire Line
	9500 2100 9500 2050
Wire Wire Line
	2000 3450 2300 3450
$Comp
L power:GND #PWR0122
U 1 1 5FDC0E22
P 8500 3750
F 0 "#PWR0122" H 8500 3500 50  0001 C CNN
F 1 "GND" H 8505 3577 50  0000 C CNN
F 2 "" H 8500 3750 50  0001 C CNN
F 3 "" H 8500 3750 50  0001 C CNN
	1    8500 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	8500 3750 8250 3750
Wire Wire Line
	8250 3750 8250 3850
Wire Wire Line
	8250 3850 8100 3850
Text GLabel 8100 2750 2    50   BiDi ~ 0
D0
Text GLabel 8100 2850 2    50   BiDi ~ 0
D1
Text GLabel 8100 2950 2    50   BiDi ~ 0
D2
Text GLabel 8100 3050 2    50   BiDi ~ 0
D3
Text GLabel 8100 3150 2    50   BiDi ~ 0
D4
Text GLabel 8100 3250 2    50   BiDi ~ 0
D5
Text GLabel 8100 3350 2    50   BiDi ~ 0
D6
Text GLabel 8100 3450 2    50   BiDi ~ 0
D7
Wire Wire Line
	8450 3500 8350 3500
Wire Wire Line
	8350 3500 8350 3650
Wire Wire Line
	8350 3650 8100 3650
$Comp
L Memory_RAM:HM62256BLP U3
U 1 1 5FDE3197
P 7600 3450
F 0 "U3" H 7600 4531 50  0000 C CNN
F 1 "HM62256BLP" H 7600 4440 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W7.62mm_Socket" H 7600 3350 50  0001 C CNN
F 3 "https://web.mit.edu/6.115/www/document/62256.pdf" H 7600 3350 50  0001 C CNN
	1    7600 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 4550 9050 4350
Wire Wire Line
	9050 4350 9100 4350
Text GLabel 8100 3950 2    50   Input ~ 0
~RAMW~
Text GLabel 8450 3500 2    50   Input ~ 0
~RAM_CS~
Text GLabel 1750 5950 0    50   Input ~ 0
CLK
Text GLabel 1750 6050 0    50   Input ~ 0
~IRQ1~
Text GLabel 1500 6150 0    50   Input ~ 0
~IRQ2~
Text GLabel 1750 6250 0    50   Input ~ 0
~IRQ3~
Text GLabel 1500 6350 0    50   Input ~ 0
~IRQ4~
Text GLabel 2750 5950 2    50   Output ~ 0
~IRQ~
Text GLabel 1500 6650 0    50   Input ~ 0
~SSEL~
Text GLabel 1750 6550 0    50   Input ~ 0
~INH~
Wire Wire Line
	1750 6650 1500 6650
Wire Wire Line
	1750 6350 1500 6350
Wire Wire Line
	1750 6150 1500 6150
Text GLabel 3150 6050 2    50   Output ~ 0
~RAM_CS~
Wire Wire Line
	3150 6050 2750 6050
Text GLabel 1700 6750 0    50   Input ~ 0
A15
Wire Wire Line
	1750 6750 1700 6750
Text GLabel 3150 6200 2    50   Output ~ 0
~ROM_CS~
Text GLabel 3150 6350 2    50   Output ~ 0
~SLOW~
Wire Wire Line
	3100 6350 3100 6200
Wire Wire Line
	3100 6150 2750 6150
Wire Wire Line
	3150 6200 3100 6200
Connection ~ 3100 6200
Wire Wire Line
	3100 6200 3100 6150
Text GLabel 2750 6250 2    50   Output ~ 0
~RAMW~
Text GLabel 9100 4250 0    50   Input ~ 0
~ROM_CS~
$Comp
L power:+5V #PWR0108
U 1 1 60043475
P 2250 5450
F 0 "#PWR0108" H 2250 5300 50  0001 C CNN
F 1 "+5V" H 2265 5623 50  0000 C CNN
F 2 "" H 2250 5450 50  0001 C CNN
F 3 "" H 2250 5450 50  0001 C CNN
	1    2250 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2250 5750 2250 5500
$Comp
L Device:C_Small C4
U 1 1 6004347C
P 2450 5500
F 0 "C4" V 2221 5500 50  0000 C CNN
F 1 "10n" V 2312 5500 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 2450 5500 50  0001 C CNN
F 3 "~" H 2450 5500 50  0001 C CNN
	1    2450 5500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0109
U 1 1 60043482
P 2700 5500
F 0 "#PWR0109" H 2700 5250 50  0001 C CNN
F 1 "GND" H 2705 5327 50  0000 C CNN
F 2 "" H 2700 5500 50  0001 C CNN
F 3 "" H 2700 5500 50  0001 C CNN
	1    2700 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2700 5500 2550 5500
Wire Wire Line
	2350 5500 2250 5500
Connection ~ 2250 5500
Wire Wire Line
	2250 5500 2250 5450
$Comp
L power:GND #PWR0110
U 1 1 60044188
P 2250 7150
F 0 "#PWR0110" H 2250 6900 50  0001 C CNN
F 1 "GND" H 2255 6977 50  0000 C CNN
F 2 "" H 2250 7150 50  0001 C CNN
F 3 "" H 2250 7150 50  0001 C CNN
	1    2250 7150
	1    0    0    -1  
$EndComp
$Comp
L Logic_Programmable:GAL16V8 U1
U 1 1 6005DE74
P 2250 6450
F 0 "U1" H 2250 7331 50  0000 C CNN
F 1 "GAL16V8" H 2250 7240 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 2250 6450 50  0001 C CNN
F 3 "" H 2250 6450 50  0001 C CNN
	1    2250 6450
	1    0    0    -1  
$EndComp
Text GLabel 1250 6450 0    50   Input ~ 0
~IRQ5~
Wire Wire Line
	1750 6450 1250 6450
Text GLabel 1750 6850 0    50   Input ~ 0
R~W~
Text Notes 3100 6550 0    50   ~ 0
Diode + pullup provided by backplane
Wire Wire Line
	3150 6350 3100 6350
$Comp
L Connector_Generic:Conn_01x14 J2
U 1 1 61551DA1
P 6450 3400
F 0 "J2" H 6530 3392 50  0000 L CNN
F 1 "Conn_01x14" H 6530 3301 50  0000 L CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x14_P2.54mm_Vertical" H 6450 3400 50  0001 C CNN
F 3 "~" H 6450 3400 50  0001 C CNN
	1    6450 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7600 2300 6100 2300
Wire Wire Line
	6100 2300 6100 2800
Wire Wire Line
	6100 2800 6250 2800
Text GLabel 6250 2900 0    50   Input ~ 0
~RAMW~
Text GLabel 6250 3000 0    50   Input ~ 0
A13
Text GLabel 6250 3100 0    50   Input ~ 0
A8
Text GLabel 6250 3200 0    50   Input ~ 0
A9
Text GLabel 6250 3300 0    50   Input ~ 0
A11
$Comp
L power:GND #PWR0113
U 1 1 6155B08E
P 5950 3400
F 0 "#PWR0113" H 5950 3150 50  0001 C CNN
F 1 "GND" H 5955 3227 50  0000 C CNN
F 2 "" H 5950 3400 50  0001 C CNN
F 3 "" H 5950 3400 50  0001 C CNN
	1    5950 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 3400 5950 3400
Text GLabel 6250 3500 0    50   Input ~ 0
A10
Text GLabel 6250 3600 0    50   Input ~ 0
~RAM_CS~
Text GLabel 6250 4100 0    50   BiDi ~ 0
D3
Text GLabel 6250 4000 0    50   BiDi ~ 0
D4
Text GLabel 6250 3900 0    50   BiDi ~ 0
D5
Text GLabel 6250 3800 0    50   BiDi ~ 0
D6
Text GLabel 6250 3700 0    50   BiDi ~ 0
D7
$EndSCHEMATC
