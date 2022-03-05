EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 1
Title "Planck computer"
Date "2021-01-10"
Rev "0.1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT0
U 1 1 60434FC0
P 2500 3550
F 0 "SLOT0" H 2550 4967 50  0000 C CNN
F 1 "Conn_02x25" H 2550 4876 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 2500 3550 50  0001 C CNN
F 3 "~" H 2500 3550 50  0001 C CNN
	1    2500 3550
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0101
U 1 1 60434FC1
P 3200 3450
F 0 "#PWR0101" H 3200 3300 50  0001 C CNN
F 1 "+5V" H 3215 3623 50  0000 C CNN
F 2 "" H 3200 3450 50  0001 C CNN
F 3 "" H 3200 3450 50  0001 C CNN
	1    3200 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 3450 2800 3450
$Comp
L power:+5V #PWR0102
U 1 1 60434FC2
P 2000 3550
F 0 "#PWR0102" H 2000 3400 50  0001 C CNN
F 1 "+5V" H 2015 3723 50  0000 C CNN
F 2 "" H 2000 3550 50  0001 C CNN
F 3 "" H 2000 3550 50  0001 C CNN
	1    2000 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 3550 2050 3550
$Comp
L power:GND #PWR0103
U 1 1 60434FC3
P 3200 3550
F 0 "#PWR0103" H 3200 3300 50  0001 C CNN
F 1 "GND" H 3205 3377 50  0000 C CNN
F 2 "" H 3200 3550 50  0001 C CNN
F 3 "" H 3200 3550 50  0001 C CNN
	1    3200 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 3550 2800 3550
$Comp
L power:GND #PWR0104
U 1 1 60434FC4
P 1850 3400
F 0 "#PWR0104" H 1850 3150 50  0001 C CNN
F 1 "GND" H 1855 3227 50  0000 C CNN
F 2 "" H 1850 3400 50  0001 C CNN
F 3 "" H 1850 3400 50  0001 C CNN
	1    1850 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 3450 2100 3400
Wire Wire Line
	2100 3400 1850 3400
Wire Wire Line
	2100 3450 2300 3450
Text GLabel 2300 2350 0    50   Input ~ 0
A0
Text GLabel 2300 2450 0    50   Input ~ 0
A1
Text GLabel 2300 2550 0    50   Input ~ 0
A2
Text GLabel 2300 2650 0    50   Input ~ 0
A3
Text GLabel 2300 2750 0    50   Input ~ 0
A4
Text GLabel 2300 2850 0    50   Input ~ 0
A5
Text GLabel 2300 2950 0    50   Input ~ 0
A6
Text GLabel 2300 3050 0    50   Input ~ 0
A7
Text GLabel 2300 3150 0    50   Input ~ 0
A8
Text GLabel 2300 3250 0    50   Input ~ 0
A9
Text GLabel 2300 3350 0    50   Input ~ 0
A10
Text GLabel 2300 3650 0    50   Input ~ 0
A11
Text GLabel 2300 3750 0    50   Input ~ 0
A12
Text GLabel 2300 3850 0    50   Input ~ 0
A13
Text GLabel 2300 3950 0    50   Input ~ 0
A14
Text GLabel 2300 4050 0    50   Input ~ 0
A15
Text GLabel 2800 2350 2    50   BiDi ~ 0
D0
Text GLabel 2800 2450 2    50   BiDi ~ 0
D1
Text GLabel 2800 2550 2    50   BiDi ~ 0
D2
Text GLabel 2800 2650 2    50   BiDi ~ 0
D3
Text GLabel 2800 2750 2    50   BiDi ~ 0
D4
Text GLabel 2800 2850 2    50   BiDi ~ 0
D5
Text GLabel 2800 2950 2    50   BiDi ~ 0
D6
Text GLabel 2800 3050 2    50   BiDi ~ 0
D7
Text GLabel 2300 4750 0    50   Input ~ 0
~RESET~
Text GLabel 2800 4750 2    50   BiDi ~ 0
~NMI~
Text GLabel 2050 4150 0    50   Input ~ 0
RDY
Text GLabel 2050 4250 0    50   Input ~ 0
BE
Text GLabel 2300 4350 0    50   Input ~ 0
CLK
Text GLabel 2300 4450 0    50   Input ~ 0
R~W~
Text GLabel 2300 4650 0    50   Input ~ 0
SYNC
Text GLabel 2050 4550 0    50   Input ~ 0
~IRQ~
$Comp
L Device:C_Small C1
U 1 1 5FD8C99F
P 1650 3500
F 0 "C1" H 1742 3546 50  0000 L CNN
F 1 "1u" H 1742 3455 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1650 3500 50  0001 C CNN
F 3 "~" H 1650 3500 50  0001 C CNN
	1    1650 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	1650 3400 1850 3400
Connection ~ 1850 3400
Wire Wire Line
	1650 3600 2050 3600
Wire Wire Line
	2050 3600 2050 3550
Connection ~ 2050 3550
Wire Wire Line
	2050 3550 2000 3550
Text GLabel 4550 5800 0    50   BiDi ~ 0
~IRQ4~
Text GLabel 4550 5900 0    50   BiDi ~ 0
~IRQ3~
Text GLabel 4550 6000 0    50   BiDi ~ 0
~IRQ2~
Text GLabel 4550 6100 0    50   BiDi ~ 0
~IRQ1~
Text GLabel 4550 5600 0    50   Input ~ 0
~SLOW~
Text GLabel 4500 5100 0    50   Input ~ 0
RDY
Text GLabel 4500 5300 0    50   Input ~ 0
BE
$Comp
L Device:R_Small R8
U 1 1 5FF07124
P 4650 5300
F 0 "R8" H 4709 5346 50  0000 L CNN
F 1 "10k" H 4709 5255 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 5300 50  0001 C CNN
F 3 "~" H 4650 5300 50  0001 C CNN
	1    4650 5300
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0105
U 1 1 5FF0712A
P 4750 5300
F 0 "#PWR0105" H 4750 5150 50  0001 C CNN
F 1 "+5V" H 4765 5473 50  0000 C CNN
F 2 "" H 4750 5300 50  0001 C CNN
F 3 "" H 4750 5300 50  0001 C CNN
	1    4750 5300
	0    1    1    0   
$EndComp
Wire Wire Line
	4500 5300 4550 5300
Wire Wire Line
	2050 4550 2300 4550
Wire Wire Line
	2050 4150 2300 4150
Wire Wire Line
	2050 4250 2300 4250
$Comp
L Device:R_Small R1
U 1 1 5FF2181F
P 4600 5100
F 0 "R1" H 4659 5146 50  0000 L CNN
F 1 "10k" H 4659 5055 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4600 5100 50  0001 C CNN
F 3 "~" H 4600 5100 50  0001 C CNN
	1    4600 5100
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0106
U 1 1 5FF21825
P 4700 5100
F 0 "#PWR0106" H 4700 4950 50  0001 C CNN
F 1 "+5V" H 4715 5273 50  0000 C CNN
F 2 "" H 4700 5100 50  0001 C CNN
F 3 "" H 4700 5100 50  0001 C CNN
	1    4700 5100
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R2
U 1 1 5FF22418
P 4650 5600
F 0 "R2" V 4454 5600 50  0000 C CNN
F 1 "1k" V 4545 5600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 5600 50  0001 C CNN
F 3 "~" H 4650 5600 50  0001 C CNN
	1    4650 5600
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0107
U 1 1 5FF2241E
P 4750 5600
F 0 "#PWR0107" H 4750 5450 50  0001 C CNN
F 1 "+5V" H 4765 5773 50  0000 C CNN
F 2 "" H 4750 5600 50  0001 C CNN
F 3 "" H 4750 5600 50  0001 C CNN
	1    4750 5600
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R3
U 1 1 5FF23FC7
P 4650 5800
F 0 "R3" V 4454 5800 50  0000 C CNN
F 1 "1k" V 4545 5800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 5800 50  0001 C CNN
F 3 "~" H 4650 5800 50  0001 C CNN
	1    4650 5800
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0108
U 1 1 5FF23FCD
P 4750 5800
F 0 "#PWR0108" H 4750 5650 50  0001 C CNN
F 1 "+5V" H 4765 5973 50  0000 C CNN
F 2 "" H 4750 5800 50  0001 C CNN
F 3 "" H 4750 5800 50  0001 C CNN
	1    4750 5800
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R4
U 1 1 5FF244F6
P 4650 5900
F 0 "R4" V 4454 5900 50  0000 C CNN
F 1 "1k" V 4545 5900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 5900 50  0001 C CNN
F 3 "~" H 4650 5900 50  0001 C CNN
	1    4650 5900
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0109
U 1 1 5FF244FC
P 4750 5900
F 0 "#PWR0109" H 4750 5750 50  0001 C CNN
F 1 "+5V" H 4765 6073 50  0000 C CNN
F 2 "" H 4750 5900 50  0001 C CNN
F 3 "" H 4750 5900 50  0001 C CNN
	1    4750 5900
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R5
U 1 1 5FF249D5
P 4650 6000
F 0 "R5" V 4454 6000 50  0000 C CNN
F 1 "1k" V 4545 6000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 6000 50  0001 C CNN
F 3 "~" H 4650 6000 50  0001 C CNN
	1    4650 6000
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0110
U 1 1 5FF249DB
P 4750 6000
F 0 "#PWR0110" H 4750 5850 50  0001 C CNN
F 1 "+5V" H 4765 6173 50  0000 C CNN
F 2 "" H 4750 6000 50  0001 C CNN
F 3 "" H 4750 6000 50  0001 C CNN
	1    4750 6000
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R6
U 1 1 5FF24EB4
P 4650 6100
F 0 "R6" V 4454 6100 50  0000 C CNN
F 1 "1k" V 4545 6100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 6100 50  0001 C CNN
F 3 "~" H 4650 6100 50  0001 C CNN
	1    4650 6100
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0111
U 1 1 5FF24EBA
P 4750 6100
F 0 "#PWR0111" H 4750 5950 50  0001 C CNN
F 1 "+5V" H 4765 6273 50  0000 C CNN
F 2 "" H 4750 6100 50  0001 C CNN
F 3 "" H 4750 6100 50  0001 C CNN
	1    4750 6100
	0    1    1    0   
$EndComp
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT2
U 1 1 5FF330AA
P 6800 3600
F 0 "SLOT2" H 6850 5017 50  0000 C CNN
F 1 "Conn_02x25" H 6850 4926 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 6800 3600 50  0001 C CNN
F 3 "~" H 6800 3600 50  0001 C CNN
	1    6800 3600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0113
U 1 1 5FF330B0
P 7550 3500
F 0 "#PWR0113" H 7550 3350 50  0001 C CNN
F 1 "+5V" H 7565 3673 50  0000 C CNN
F 2 "" H 7550 3500 50  0001 C CNN
F 3 "" H 7550 3500 50  0001 C CNN
	1    7550 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 3500 7100 3500
$Comp
L power:+5V #PWR0114
U 1 1 5FF330B7
P 6300 3600
F 0 "#PWR0114" H 6300 3450 50  0001 C CNN
F 1 "+5V" H 6315 3773 50  0000 C CNN
F 2 "" H 6300 3600 50  0001 C CNN
F 3 "" H 6300 3600 50  0001 C CNN
	1    6300 3600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0115
U 1 1 5FF330BE
P 7550 3600
F 0 "#PWR0115" H 7550 3350 50  0001 C CNN
F 1 "GND" H 7555 3427 50  0000 C CNN
F 2 "" H 7550 3600 50  0001 C CNN
F 3 "" H 7550 3600 50  0001 C CNN
	1    7550 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 3600 7100 3600
$Comp
L power:GND #PWR0116
U 1 1 5FF330C5
P 6150 3450
F 0 "#PWR0116" H 6150 3200 50  0001 C CNN
F 1 "GND" H 6155 3277 50  0000 C CNN
F 2 "" H 6150 3450 50  0001 C CNN
F 3 "" H 6150 3450 50  0001 C CNN
	1    6150 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 3500 6400 3450
Wire Wire Line
	6400 3450 6150 3450
Wire Wire Line
	6400 3500 6600 3500
Text GLabel 6600 2400 0    50   Input ~ 0
A0
Text GLabel 6600 2500 0    50   Input ~ 0
A1
Text GLabel 6600 2600 0    50   Input ~ 0
A2
Text GLabel 6600 2700 0    50   Input ~ 0
A3
Text GLabel 6600 2800 0    50   Input ~ 0
A4
Text GLabel 6600 2900 0    50   Input ~ 0
A5
Text GLabel 6600 3000 0    50   Input ~ 0
A6
Text GLabel 6600 3100 0    50   Input ~ 0
A7
Text GLabel 6600 3200 0    50   Input ~ 0
A8
Text GLabel 6600 3300 0    50   Input ~ 0
A9
Text GLabel 6600 3400 0    50   Input ~ 0
A10
Text GLabel 6600 3700 0    50   Input ~ 0
A11
Text GLabel 6600 3800 0    50   Input ~ 0
A12
Text GLabel 6600 3900 0    50   Input ~ 0
A13
Text GLabel 6600 4000 0    50   Input ~ 0
A14
Text GLabel 6600 4100 0    50   Input ~ 0
A15
Text GLabel 7100 2400 2    50   BiDi ~ 0
D0
Text GLabel 7100 2500 2    50   BiDi ~ 0
D1
Text GLabel 7100 2600 2    50   BiDi ~ 0
D2
Text GLabel 7100 2700 2    50   BiDi ~ 0
D3
Text GLabel 7100 2800 2    50   BiDi ~ 0
D4
Text GLabel 7100 2900 2    50   BiDi ~ 0
D5
Text GLabel 7100 3000 2    50   BiDi ~ 0
D6
Text GLabel 7100 3100 2    50   BiDi ~ 0
D7
Text GLabel 6600 4800 0    50   Input ~ 0
~RESET~
Text GLabel 7100 4800 2    50   BiDi ~ 0
~NMI~
Text GLabel 6350 4200 0    50   Input ~ 0
RDY
Text GLabel 6350 4300 0    50   Input ~ 0
BE
Text GLabel 6600 4400 0    50   Input ~ 0
CLK
Text GLabel 6600 4500 0    50   Input ~ 0
R~W~
Text GLabel 6600 4700 0    50   Input ~ 0
SYNC
Text GLabel 6350 4600 0    50   Input ~ 0
~IRQ~
Text GLabel 7100 4700 2    50   BiDi ~ 0
~IRQ2~
$Comp
L Device:C_Small C7
U 1 1 5FF330F2
P 7800 3550
F 0 "C7" H 7892 3596 50  0000 L CNN
F 1 "1u" H 7892 3505 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7800 3550 50  0001 C CNN
F 3 "~" H 7800 3550 50  0001 C CNN
	1    7800 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 4600 6600 4600
Wire Wire Line
	6350 4200 6600 4200
Wire Wire Line
	6350 4300 6600 4300
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT4
U 1 1 5FF388F3
P 2450 8200
F 0 "SLOT4" H 2500 9617 50  0000 C CNN
F 1 "Conn_02x25" H 2500 9526 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 2450 8200 50  0001 C CNN
F 3 "~" H 2450 8200 50  0001 C CNN
	1    2450 8200
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0117
U 1 1 5FF388F9
P 3100 8100
F 0 "#PWR0117" H 3100 7950 50  0001 C CNN
F 1 "+5V" H 3115 8273 50  0000 C CNN
F 2 "" H 3100 8100 50  0001 C CNN
F 3 "" H 3100 8100 50  0001 C CNN
	1    3100 8100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 8100 2750 8100
$Comp
L power:+5V #PWR0118
U 1 1 5FF38900
P 1950 8200
F 0 "#PWR0118" H 1950 8050 50  0001 C CNN
F 1 "+5V" H 1965 8373 50  0000 C CNN
F 2 "" H 1950 8200 50  0001 C CNN
F 3 "" H 1950 8200 50  0001 C CNN
	1    1950 8200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0119
U 1 1 5FF38907
P 3100 8200
F 0 "#PWR0119" H 3100 7950 50  0001 C CNN
F 1 "GND" H 3105 8027 50  0000 C CNN
F 2 "" H 3100 8200 50  0001 C CNN
F 3 "" H 3100 8200 50  0001 C CNN
	1    3100 8200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 8200 2750 8200
$Comp
L power:GND #PWR0120
U 1 1 5FF3890E
P 1800 8050
F 0 "#PWR0120" H 1800 7800 50  0001 C CNN
F 1 "GND" H 1805 7877 50  0000 C CNN
F 2 "" H 1800 8050 50  0001 C CNN
F 3 "" H 1800 8050 50  0001 C CNN
	1    1800 8050
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 8100 2050 8050
Wire Wire Line
	2050 8050 1800 8050
Wire Wire Line
	2050 8100 2250 8100
Text GLabel 2250 7000 0    50   Input ~ 0
A0
Text GLabel 2250 7100 0    50   Input ~ 0
A1
Text GLabel 2250 7200 0    50   Input ~ 0
A2
Text GLabel 2250 7300 0    50   Input ~ 0
A3
Text GLabel 2250 7400 0    50   Input ~ 0
A4
Text GLabel 2250 7500 0    50   Input ~ 0
A5
Text GLabel 2250 7600 0    50   Input ~ 0
A6
Text GLabel 2250 7700 0    50   Input ~ 0
A7
Text GLabel 2250 7800 0    50   Input ~ 0
A8
Text GLabel 2250 7900 0    50   Input ~ 0
A9
Text GLabel 2250 8000 0    50   Input ~ 0
A10
Text GLabel 2250 8300 0    50   Input ~ 0
A11
Text GLabel 2250 8400 0    50   Input ~ 0
A12
Text GLabel 2250 8500 0    50   Input ~ 0
A13
Text GLabel 2250 8600 0    50   Input ~ 0
A14
Text GLabel 2250 8700 0    50   Input ~ 0
A15
Text GLabel 2750 7000 2    50   BiDi ~ 0
D0
Text GLabel 2750 7100 2    50   BiDi ~ 0
D1
Text GLabel 2750 7200 2    50   BiDi ~ 0
D2
Text GLabel 2750 7300 2    50   BiDi ~ 0
D3
Text GLabel 2750 7400 2    50   BiDi ~ 0
D4
Text GLabel 2750 7500 2    50   BiDi ~ 0
D5
Text GLabel 2750 7600 2    50   BiDi ~ 0
D6
Text GLabel 2750 7700 2    50   BiDi ~ 0
D7
Text GLabel 2250 9400 0    50   Input ~ 0
~RESET~
Text GLabel 2750 9400 2    50   BiDi ~ 0
~NMI~
Text GLabel 2000 8800 0    50   Input ~ 0
RDY
Text GLabel 2000 8900 0    50   Input ~ 0
BE
Text GLabel 2250 9000 0    50   Input ~ 0
CLK
Text GLabel 2250 9100 0    50   Input ~ 0
R~W~
Text GLabel 2250 9300 0    50   Input ~ 0
SYNC
Text GLabel 2000 9200 0    50   Input ~ 0
~IRQ~
Text GLabel 2750 9300 2    50   BiDi ~ 0
~IRQ4~
$Comp
L Device:C_Small C10
U 1 1 5FF3893B
P 3350 8150
F 0 "C10" H 3442 8196 50  0000 L CNN
F 1 "1u" H 3442 8105 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3350 8150 50  0001 C CNN
F 3 "~" H 3350 8150 50  0001 C CNN
	1    3350 8150
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 9200 2250 9200
Wire Wire Line
	2000 8800 2250 8800
Wire Wire Line
	2000 8900 2250 8900
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT5
U 1 1 5FF3D28D
P 4650 8250
F 0 "SLOT5" H 4700 9667 50  0000 C CNN
F 1 "Conn_02x25" H 4700 9576 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 4650 8250 50  0001 C CNN
F 3 "~" H 4650 8250 50  0001 C CNN
	1    4650 8250
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0121
U 1 1 5FF3D293
P 5350 8150
F 0 "#PWR0121" H 5350 8000 50  0001 C CNN
F 1 "+5V" H 5365 8323 50  0000 C CNN
F 2 "" H 5350 8150 50  0001 C CNN
F 3 "" H 5350 8150 50  0001 C CNN
	1    5350 8150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 8150 4950 8150
$Comp
L power:+5V #PWR0122
U 1 1 5FF3D29A
P 4150 8250
F 0 "#PWR0122" H 4150 8100 50  0001 C CNN
F 1 "+5V" H 4165 8423 50  0000 C CNN
F 2 "" H 4150 8250 50  0001 C CNN
F 3 "" H 4150 8250 50  0001 C CNN
	1    4150 8250
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 8250 4200 8250
$Comp
L power:GND #PWR0123
U 1 1 5FF3D2A1
P 5350 8250
F 0 "#PWR0123" H 5350 8000 50  0001 C CNN
F 1 "GND" H 5355 8077 50  0000 C CNN
F 2 "" H 5350 8250 50  0001 C CNN
F 3 "" H 5350 8250 50  0001 C CNN
	1    5350 8250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 8250 4950 8250
$Comp
L power:GND #PWR0124
U 1 1 5FF3D2A8
P 4000 8100
F 0 "#PWR0124" H 4000 7850 50  0001 C CNN
F 1 "GND" H 4005 7927 50  0000 C CNN
F 2 "" H 4000 8100 50  0001 C CNN
F 3 "" H 4000 8100 50  0001 C CNN
	1    4000 8100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 8150 4250 8100
Wire Wire Line
	4250 8100 4000 8100
Wire Wire Line
	4250 8150 4450 8150
Text GLabel 4450 7050 0    50   Input ~ 0
A0
Text GLabel 4450 7150 0    50   Input ~ 0
A1
Text GLabel 4450 7250 0    50   Input ~ 0
A2
Text GLabel 4450 7350 0    50   Input ~ 0
A3
Text GLabel 4450 7450 0    50   Input ~ 0
A4
Text GLabel 4450 7550 0    50   Input ~ 0
A5
Text GLabel 4450 7650 0    50   Input ~ 0
A6
Text GLabel 4450 7750 0    50   Input ~ 0
A7
Text GLabel 4450 7850 0    50   Input ~ 0
A8
Text GLabel 4450 7950 0    50   Input ~ 0
A9
Text GLabel 4450 8050 0    50   Input ~ 0
A10
Text GLabel 4450 8350 0    50   Input ~ 0
A11
Text GLabel 4450 8450 0    50   Input ~ 0
A12
Text GLabel 4450 8550 0    50   Input ~ 0
A13
Text GLabel 4450 8650 0    50   Input ~ 0
A14
Text GLabel 4450 8750 0    50   Input ~ 0
A15
Text GLabel 4950 7050 2    50   BiDi ~ 0
D0
Text GLabel 4950 7150 2    50   BiDi ~ 0
D1
Text GLabel 4950 7250 2    50   BiDi ~ 0
D2
Text GLabel 4950 7350 2    50   BiDi ~ 0
D3
Text GLabel 4950 7450 2    50   BiDi ~ 0
D4
Text GLabel 4950 7550 2    50   BiDi ~ 0
D5
Text GLabel 4950 7650 2    50   BiDi ~ 0
D6
Text GLabel 4950 7750 2    50   BiDi ~ 0
D7
Text GLabel 4450 9450 0    50   Input ~ 0
~RESET~
Text GLabel 4950 9450 2    50   BiDi ~ 0
~NMI~
Text GLabel 4200 8850 0    50   Input ~ 0
RDY
Text GLabel 4200 8950 0    50   Input ~ 0
BE
Text GLabel 4450 9050 0    50   Input ~ 0
CLK
Text GLabel 4450 9150 0    50   Input ~ 0
R~W~
Text GLabel 4450 9350 0    50   Input ~ 0
SYNC
Text GLabel 4200 9250 0    50   Input ~ 0
~IRQ~
$Comp
L Device:C_Small C11
U 1 1 5FF3D2E3
P 3800 8200
F 0 "C11" H 3892 8246 50  0000 L CNN
F 1 "1u" H 3892 8155 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3800 8200 50  0001 C CNN
F 3 "~" H 3800 8200 50  0001 C CNN
	1    3800 8200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 8100 4000 8100
Connection ~ 4000 8100
Wire Wire Line
	3800 8300 4200 8300
Wire Wire Line
	4200 8300 4200 8250
Connection ~ 4200 8250
Wire Wire Line
	4200 8250 4150 8250
Wire Wire Line
	4200 9250 4450 9250
Wire Wire Line
	4200 8850 4450 8850
Wire Wire Line
	4200 8950 4450 8950
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT1
U 1 1 5FF4AD1B
P 4500 3550
F 0 "SLOT1" H 4550 4967 50  0000 C CNN
F 1 "Conn_02x25" H 4550 4876 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 4500 3550 50  0001 C CNN
F 3 "~" H 4500 3550 50  0001 C CNN
	1    4500 3550
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0125
U 1 1 5FF4AD21
P 5200 3450
F 0 "#PWR0125" H 5200 3300 50  0001 C CNN
F 1 "+5V" H 5215 3623 50  0000 C CNN
F 2 "" H 5200 3450 50  0001 C CNN
F 3 "" H 5200 3450 50  0001 C CNN
	1    5200 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 3450 4800 3450
$Comp
L power:+5V #PWR0126
U 1 1 5FF4AD28
P 4000 3550
F 0 "#PWR0126" H 4000 3400 50  0001 C CNN
F 1 "+5V" H 4015 3723 50  0000 C CNN
F 2 "" H 4000 3550 50  0001 C CNN
F 3 "" H 4000 3550 50  0001 C CNN
	1    4000 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 3550 4050 3550
$Comp
L power:GND #PWR0127
U 1 1 5FF4AD2F
P 5200 3550
F 0 "#PWR0127" H 5200 3300 50  0001 C CNN
F 1 "GND" H 5205 3377 50  0000 C CNN
F 2 "" H 5200 3550 50  0001 C CNN
F 3 "" H 5200 3550 50  0001 C CNN
	1    5200 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 3550 4800 3550
$Comp
L power:GND #PWR0128
U 1 1 5FF4AD36
P 3850 3400
F 0 "#PWR0128" H 3850 3150 50  0001 C CNN
F 1 "GND" H 3855 3227 50  0000 C CNN
F 2 "" H 3850 3400 50  0001 C CNN
F 3 "" H 3850 3400 50  0001 C CNN
	1    3850 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 3450 4100 3400
Wire Wire Line
	4100 3400 3850 3400
Wire Wire Line
	4100 3450 4300 3450
Text GLabel 4300 2350 0    50   Input ~ 0
A0
Text GLabel 4300 2450 0    50   Input ~ 0
A1
Text GLabel 4300 2550 0    50   Input ~ 0
A2
Text GLabel 4300 2650 0    50   Input ~ 0
A3
Text GLabel 4300 2750 0    50   Input ~ 0
A4
Text GLabel 4300 2850 0    50   Input ~ 0
A5
Text GLabel 4300 2950 0    50   Input ~ 0
A6
Text GLabel 4300 3050 0    50   Input ~ 0
A7
Text GLabel 4300 3150 0    50   Input ~ 0
A8
Text GLabel 4300 3250 0    50   Input ~ 0
A9
Text GLabel 4300 3350 0    50   Input ~ 0
A10
Text GLabel 4300 3650 0    50   Input ~ 0
A11
Text GLabel 4300 3750 0    50   Input ~ 0
A12
Text GLabel 4300 3850 0    50   Input ~ 0
A13
Text GLabel 4300 3950 0    50   Input ~ 0
A14
Text GLabel 4300 4050 0    50   Input ~ 0
A15
Text GLabel 4800 2350 2    50   BiDi ~ 0
D0
Text GLabel 4800 2450 2    50   BiDi ~ 0
D1
Text GLabel 4800 2550 2    50   BiDi ~ 0
D2
Text GLabel 4800 2650 2    50   BiDi ~ 0
D3
Text GLabel 4800 2750 2    50   BiDi ~ 0
D4
Text GLabel 4800 2850 2    50   BiDi ~ 0
D5
Text GLabel 4800 2950 2    50   BiDi ~ 0
D6
Text GLabel 4800 3050 2    50   BiDi ~ 0
D7
Text GLabel 4300 4750 0    50   Input ~ 0
~RESET~
Text GLabel 4800 4750 2    50   BiDi ~ 0
~NMI~
Text GLabel 4050 4150 0    50   Input ~ 0
RDY
Text GLabel 4050 4250 0    50   Input ~ 0
BE
Text GLabel 4300 4350 0    50   Input ~ 0
CLK
Text GLabel 4300 4450 0    50   Input ~ 0
R~W~
Text GLabel 4300 4650 0    50   Input ~ 0
SYNC
Text GLabel 4050 4550 0    50   Input ~ 0
~IRQ~
Text GLabel 4800 4650 2    50   BiDi ~ 0
~IRQ1~
$Comp
L Device:C_Small C3
U 1 1 5FF4AD71
P 3650 3500
F 0 "C3" H 3742 3546 50  0000 L CNN
F 1 "1u" H 3742 3455 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3650 3500 50  0001 C CNN
F 3 "~" H 3650 3500 50  0001 C CNN
	1    3650 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 3400 3850 3400
Connection ~ 3850 3400
Wire Wire Line
	3650 3600 4050 3600
Wire Wire Line
	4050 3600 4050 3550
Connection ~ 4050 3550
Wire Wire Line
	4050 3550 4000 3550
Wire Wire Line
	4050 4550 4300 4550
Wire Wire Line
	4050 4150 4300 4150
Wire Wire Line
	4050 4250 4300 4250
$Comp
L Connector_Generic:Conn_02x25_Odd_Even SLOT3
U 1 1 5FF52D4F
P 9250 3600
F 0 "SLOT3" H 9300 5017 50  0000 C CNN
F 1 "Conn_02x25" H 9300 4926 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 9250 3600 50  0001 C CNN
F 3 "~" H 9250 3600 50  0001 C CNN
	1    9250 3600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0129
U 1 1 5FF52D55
P 10000 3500
F 0 "#PWR0129" H 10000 3350 50  0001 C CNN
F 1 "+5V" H 10015 3673 50  0000 C CNN
F 2 "" H 10000 3500 50  0001 C CNN
F 3 "" H 10000 3500 50  0001 C CNN
	1    10000 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	10000 3500 9550 3500
$Comp
L power:+5V #PWR0130
U 1 1 5FF52D5C
P 8750 3600
F 0 "#PWR0130" H 8750 3450 50  0001 C CNN
F 1 "+5V" H 8765 3773 50  0000 C CNN
F 2 "" H 8750 3600 50  0001 C CNN
F 3 "" H 8750 3600 50  0001 C CNN
	1    8750 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 3600 8800 3600
$Comp
L power:GND #PWR0131
U 1 1 5FF52D63
P 10000 3600
F 0 "#PWR0131" H 10000 3350 50  0001 C CNN
F 1 "GND" H 10005 3427 50  0000 C CNN
F 2 "" H 10000 3600 50  0001 C CNN
F 3 "" H 10000 3600 50  0001 C CNN
	1    10000 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	10000 3600 9550 3600
$Comp
L power:GND #PWR0132
U 1 1 5FF52D6A
P 8600 3450
F 0 "#PWR0132" H 8600 3200 50  0001 C CNN
F 1 "GND" H 8605 3277 50  0000 C CNN
F 2 "" H 8600 3450 50  0001 C CNN
F 3 "" H 8600 3450 50  0001 C CNN
	1    8600 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 3500 8850 3450
Wire Wire Line
	8850 3450 8600 3450
Wire Wire Line
	8850 3500 9050 3500
Text GLabel 9050 2400 0    50   Input ~ 0
A0
Text GLabel 9050 2500 0    50   Input ~ 0
A1
Text GLabel 9050 2600 0    50   Input ~ 0
A2
Text GLabel 9050 2700 0    50   Input ~ 0
A3
Text GLabel 9050 2800 0    50   Input ~ 0
A4
Text GLabel 9050 2900 0    50   Input ~ 0
A5
Text GLabel 9050 3000 0    50   Input ~ 0
A6
Text GLabel 9050 3100 0    50   Input ~ 0
A7
Text GLabel 9050 3200 0    50   Input ~ 0
A8
Text GLabel 9050 3300 0    50   Input ~ 0
A9
Text GLabel 9050 3400 0    50   Input ~ 0
A10
Text GLabel 9050 3700 0    50   Input ~ 0
A11
Text GLabel 9050 3800 0    50   Input ~ 0
A12
Text GLabel 9050 3900 0    50   Input ~ 0
A13
Text GLabel 9050 4000 0    50   Input ~ 0
A14
Text GLabel 9050 4100 0    50   Input ~ 0
A15
Text GLabel 9550 2400 2    50   BiDi ~ 0
D0
Text GLabel 9550 2500 2    50   BiDi ~ 0
D1
Text GLabel 9550 2600 2    50   BiDi ~ 0
D2
Text GLabel 9550 2700 2    50   BiDi ~ 0
D3
Text GLabel 9550 2800 2    50   BiDi ~ 0
D4
Text GLabel 9550 2900 2    50   BiDi ~ 0
D5
Text GLabel 9550 3000 2    50   BiDi ~ 0
D6
Text GLabel 9550 3100 2    50   BiDi ~ 0
D7
Text GLabel 9050 4800 0    50   Input ~ 0
~RESET~
Text GLabel 9550 4800 2    50   BiDi ~ 0
~NMI~
Text GLabel 8800 4200 0    50   Input ~ 0
RDY
Text GLabel 8800 4300 0    50   Input ~ 0
BE
Text GLabel 9050 4400 0    50   Input ~ 0
CLK
Text GLabel 9050 4500 0    50   Input ~ 0
R~W~
Text GLabel 9050 4700 0    50   Input ~ 0
SYNC
Text GLabel 8800 4600 0    50   Input ~ 0
~IRQ~
Text GLabel 9550 4700 2    50   BiDi ~ 0
~IRQ3~
$Comp
L Device:C_Small C8
U 1 1 5FF52D97
P 10250 3550
F 0 "C8" H 10342 3596 50  0000 L CNN
F 1 "1u" H 10342 3505 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 10250 3550 50  0001 C CNN
F 3 "~" H 10250 3550 50  0001 C CNN
	1    10250 3550
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C6
U 1 1 5FF52DA5
P 8400 3550
F 0 "C6" H 8492 3596 50  0000 L CNN
F 1 "1u" H 8492 3505 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 8400 3550 50  0001 C CNN
F 3 "~" H 8400 3550 50  0001 C CNN
	1    8400 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	8400 3450 8600 3450
Connection ~ 8600 3450
Wire Wire Line
	8400 3650 8800 3650
Wire Wire Line
	8800 3650 8800 3600
Connection ~ 8800 3600
Wire Wire Line
	8800 3600 8750 3600
Wire Wire Line
	8800 4600 9050 4600
Wire Wire Line
	8800 4200 9050 4200
Wire Wire Line
	8800 4300 9050 4300
Text GLabel 7100 3200 2    50   BiDi ~ 0
EX0
Text GLabel 7100 3300 2    50   BiDi ~ 0
EX1
Text GLabel 7100 3800 2    50   BiDi ~ 0
~INH~
Text GLabel 7100 3900 2    50   BiDi ~ 0
~SLOT2~
Text GLabel 2800 3950 2    50   BiDi ~ 0
LED1
Text GLabel 2800 4050 2    50   BiDi ~ 0
LED2
Text GLabel 2800 4150 2    50   BiDi ~ 0
LED3
Text GLabel 3200 4300 2    50   BiDi ~ 0
LED4
Text GLabel 2800 3150 2    50   BiDi ~ 0
EX0
Text GLabel 2800 3250 2    50   BiDi ~ 0
EX1
Text GLabel 4800 3150 2    50   BiDi ~ 0
EX0
Text GLabel 4800 3250 2    50   BiDi ~ 0
EX1
Text GLabel 9550 3200 2    50   BiDi ~ 0
EX0
Text GLabel 9550 3300 2    50   BiDi ~ 0
EX1
Text GLabel 2750 7800 2    50   BiDi ~ 0
EX0
Text GLabel 2750 7900 2    50   BiDi ~ 0
EX1
Text GLabel 4950 7850 2    50   BiDi ~ 0
EX0
Text GLabel 4950 7950 2    50   BiDi ~ 0
EX1
$Comp
L Switch:SW_SPST SW1
U 1 1 60031505
P 1900 1050
F 0 "SW1" H 1900 1285 50  0000 C CNN
F 1 "SW_SPST" H 1900 1194 50  0000 C CNN
F 2 "Button_Switch_THT:SW_E-Switch_EG1271_DPDT" H 1900 1050 50  0001 C CNN
F 3 "~" H 1900 1050 50  0001 C CNN
	1    1900 1050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0133
U 1 1 60033398
P 2200 1250
F 0 "#PWR0133" H 2200 1000 50  0001 C CNN
F 1 "GND" H 2205 1077 50  0000 C CNN
F 2 "" H 2200 1250 50  0001 C CNN
F 3 "" H 2200 1250 50  0001 C CNN
	1    2200 1250
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0134
U 1 1 60039848
P 2350 1050
F 0 "#PWR0134" H 2350 900 50  0001 C CNN
F 1 "+5V" H 2365 1223 50  0000 C CNN
F 2 "" H 2350 1050 50  0001 C CNN
F 3 "" H 2350 1050 50  0001 C CNN
	1    2350 1050
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C13
U 1 1 6003A557
P 2200 1150
F 0 "C13" H 2292 1196 50  0000 L CNN
F 1 "47u" H 2292 1105 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D6.3mm_P2.50mm" H 2200 1150 50  0001 C CNN
F 3 "~" H 2200 1150 50  0001 C CNN
	1    2200 1150
	1    0    0    -1  
$EndComp
Text GLabel 9950 1100 2    50   Output ~ 0
~NMI~
Text GLabel 5700 850  2    50   Output ~ 0
~RESET~
$Comp
L power:GND #PWR0135
U 1 1 6008D891
P 8850 1500
F 0 "#PWR0135" H 8850 1250 50  0001 C CNN
F 1 "GND" H 8855 1327 50  0000 C CNN
F 2 "" H 8850 1500 50  0001 C CNN
F 3 "" H 8850 1500 50  0001 C CNN
	1    8850 1500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0137
U 1 1 60098175
P 8550 1450
F 0 "#PWR0137" H 8550 1300 50  0001 C CNN
F 1 "+5V" H 8565 1623 50  0000 C CNN
F 2 "" H 8550 1450 50  0001 C CNN
F 3 "" H 8550 1450 50  0001 C CNN
	1    8550 1450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0138
U 1 1 6009D5D9
P 7050 800
F 0 "#PWR0138" H 7050 650 50  0001 C CNN
F 1 "+5V" H 7065 973 50  0000 C CNN
F 2 "" H 7050 800 50  0001 C CNN
F 3 "" H 7050 800 50  0001 C CNN
	1    7050 800 
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push RESET1
U 1 1 600A3302
P 4550 850
F 0 "RESET1" H 4550 1135 50  0000 C CNN
F 1 "SW_Push" H 4550 1044 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 4550 1050 50  0001 C CNN
F 3 "~" H 4550 1050 50  0001 C CNN
	1    4550 850 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0139
U 1 1 600A3D95
P 4350 850
F 0 "#PWR0139" H 4350 600 50  0001 C CNN
F 1 "GND" H 4355 677 50  0000 C CNN
F 2 "" H 4350 850 50  0001 C CNN
F 3 "" H 4350 850 50  0001 C CNN
	1    4350 850 
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push NMI1
U 1 1 600A9CE7
P 8250 1100
F 0 "NMI1" H 8250 1385 50  0000 C CNN
F 1 "SW_Push" H 8250 1294 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 8250 1300 50  0001 C CNN
F 3 "~" H 8250 1300 50  0001 C CNN
	1    8250 1100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0140
U 1 1 600A9CED
P 8050 1100
F 0 "#PWR0140" H 8050 850 50  0001 C CNN
F 1 "GND" H 8055 927 50  0000 C CNN
F 2 "" H 8050 1100 50  0001 C CNN
F 3 "" H 8050 1100 50  0001 C CNN
	1    8050 1100
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D1
U 1 1 600C2792
P 3450 5900
F 0 "D1" H 3443 6117 50  0000 C CNN
F 1 "LED" H 3443 6026 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 3450 5900 50  0001 C CNN
F 3 "~" H 3450 5900 50  0001 C CNN
	1    3450 5900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0141
U 1 1 600C38C8
P 3100 5900
F 0 "#PWR0141" H 3100 5650 50  0001 C CNN
F 1 "GND" H 3105 5727 50  0000 C CNN
F 2 "" H 3100 5900 50  0001 C CNN
F 3 "" H 3100 5900 50  0001 C CNN
	1    3100 5900
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0142
U 1 1 600C9343
P 3600 5900
F 0 "#PWR0142" H 3600 5750 50  0001 C CNN
F 1 "+5V" H 3615 6073 50  0000 C CNN
F 2 "" H 3600 5900 50  0001 C CNN
F 3 "" H 3600 5900 50  0001 C CNN
	1    3600 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R9
U 1 1 600D37C9
P 3200 5900
F 0 "R9" V 3004 5900 50  0000 C CNN
F 1 "330R" V 3095 5900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 3200 5900 50  0001 C CNN
F 3 "~" H 3200 5900 50  0001 C CNN
	1    3200 5900
	0    1    1    0   
$EndComp
$Comp
L Device:LED LED1
U 1 1 5FD70952
P 2500 5450
F 0 "LED1" H 2493 5667 50  0000 C CNN
F 1 "LED" H 2493 5576 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 2500 5450 50  0001 C CNN
F 3 "~" H 2500 5450 50  0001 C CNN
	1    2500 5450
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R10
U 1 1 5FD7194C
P 2250 5450
F 0 "R10" V 2054 5450 50  0000 C CNN
F 1 "330R" V 2145 5450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 2250 5450 50  0001 C CNN
F 3 "~" H 2250 5450 50  0001 C CNN
	1    2250 5450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0143
U 1 1 5FD72A10
P 2150 5450
F 0 "#PWR0143" H 2150 5200 50  0001 C CNN
F 1 "GND" H 2155 5277 50  0000 C CNN
F 2 "" H 2150 5450 50  0001 C CNN
F 3 "" H 2150 5450 50  0001 C CNN
	1    2150 5450
	1    0    0    -1  
$EndComp
$Comp
L Device:LED LED2
U 1 1 5FD88685
P 2500 5900
F 0 "LED2" H 2493 6117 50  0000 C CNN
F 1 "LED" H 2493 6026 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 2500 5900 50  0001 C CNN
F 3 "~" H 2500 5900 50  0001 C CNN
	1    2500 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R11
U 1 1 5FD8868B
P 2250 5900
F 0 "R11" V 2054 5900 50  0000 C CNN
F 1 "330R" V 2145 5900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 2250 5900 50  0001 C CNN
F 3 "~" H 2250 5900 50  0001 C CNN
	1    2250 5900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0144
U 1 1 5FD88691
P 2150 5900
F 0 "#PWR0144" H 2150 5650 50  0001 C CNN
F 1 "GND" H 2155 5727 50  0000 C CNN
F 2 "" H 2150 5900 50  0001 C CNN
F 3 "" H 2150 5900 50  0001 C CNN
	1    2150 5900
	1    0    0    -1  
$EndComp
$Comp
L Device:LED LED3
U 1 1 5FD8E89F
P 2500 6250
F 0 "LED3" H 2493 6467 50  0000 C CNN
F 1 "LED" H 2493 6376 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 2500 6250 50  0001 C CNN
F 3 "~" H 2500 6250 50  0001 C CNN
	1    2500 6250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R12
U 1 1 5FD8E8A5
P 2250 6250
F 0 "R12" V 2054 6250 50  0000 C CNN
F 1 "330R" V 2145 6250 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 2250 6250 50  0001 C CNN
F 3 "~" H 2250 6250 50  0001 C CNN
	1    2250 6250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0145
U 1 1 5FD8E8AB
P 2150 6250
F 0 "#PWR0145" H 2150 6000 50  0001 C CNN
F 1 "GND" H 2155 6077 50  0000 C CNN
F 2 "" H 2150 6250 50  0001 C CNN
F 3 "" H 2150 6250 50  0001 C CNN
	1    2150 6250
	1    0    0    -1  
$EndComp
$Comp
L Device:LED LED4
U 1 1 5FD9443D
P 3450 5450
F 0 "LED4" H 3443 5667 50  0000 C CNN
F 1 "LED" H 3443 5576 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 3450 5450 50  0001 C CNN
F 3 "~" H 3450 5450 50  0001 C CNN
	1    3450 5450
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R13
U 1 1 5FD94443
P 3200 5450
F 0 "R13" V 3004 5450 50  0000 C CNN
F 1 "330R" V 3095 5450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 3200 5450 50  0001 C CNN
F 3 "~" H 3200 5450 50  0001 C CNN
	1    3200 5450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0146
U 1 1 5FD94449
P 3100 5450
F 0 "#PWR0146" H 3100 5200 50  0001 C CNN
F 1 "GND" H 3105 5277 50  0000 C CNN
F 2 "" H 3100 5450 50  0001 C CNN
F 3 "" H 3100 5450 50  0001 C CNN
	1    3100 5450
	1    0    0    -1  
$EndComp
$Comp
L Logic_Programmable:PAL24 U4
U 1 1 5FDAA30B
P 6350 10100
F 0 "U4" H 6350 11081 50  0000 C CNN
F 1 "PAL24" H 6350 10990 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W7.62mm_Socket" H 6350 10050 50  0001 C CNN
F 3 "~" H 6350 10050 50  0001 C CNN
	1    6350 10100
	1    0    0    -1  
$EndComp
Text GLabel 7100 4000 2    50   BiDi ~ 0
LED1
Text GLabel 7100 4100 2    50   BiDi ~ 0
LED2
Text GLabel 7100 4200 2    50   BiDi ~ 0
LED3
Text GLabel 7100 4300 2    50   BiDi ~ 0
LED4
Text GLabel 2750 8600 2    50   BiDi ~ 0
LED1
Text GLabel 2750 8700 2    50   BiDi ~ 0
LED2
Text GLabel 2750 8800 2    50   BiDi ~ 0
LED3
Text GLabel 2750 8900 2    50   BiDi ~ 0
LED4
Text GLabel 4950 8650 2    50   BiDi ~ 0
LED1
Text GLabel 4950 8750 2    50   BiDi ~ 0
LED2
Text GLabel 4950 8850 2    50   BiDi ~ 0
LED3
Text GLabel 4950 8950 2    50   BiDi ~ 0
LED4
Text GLabel 9550 4000 2    50   BiDi ~ 0
LED1
Text GLabel 9550 4100 2    50   BiDi ~ 0
LED2
Text GLabel 9550 4200 2    50   BiDi ~ 0
LED3
Text GLabel 9550 4300 2    50   BiDi ~ 0
LED4
Text GLabel 4800 3950 2    50   BiDi ~ 0
LED1
Text GLabel 4800 4050 2    50   BiDi ~ 0
LED2
Text GLabel 4800 4150 2    50   BiDi ~ 0
LED3
Text GLabel 4800 4250 2    50   BiDi ~ 0
LED4
Text GLabel 2650 5450 2    50   BiDi ~ 0
LED1
Text GLabel 2650 5900 2    50   BiDi ~ 0
LED2
Text GLabel 2650 6250 2    50   BiDi ~ 0
LED3
Text GLabel 3600 5450 2    50   BiDi ~ 0
LED4
Text GLabel 2800 3650 2    50   BiDi ~ 0
~SSEL~
Text GLabel 2750 8400 2    50   BiDi ~ 0
~INH~
Text GLabel 2750 8500 2    50   BiDi ~ 0
~SLOT4~
Text GLabel 4950 8450 2    50   BiDi ~ 0
~INH~
Text GLabel 4950 8550 2    50   BiDi ~ 0
~SLOT5~
Text GLabel 10400 2950 2    50   BiDi ~ 0
~SLOW~
Text GLabel 9550 3800 2    50   BiDi ~ 0
~INH~
Text GLabel 9550 3900 2    50   BiDi ~ 0
~SLOT3~
Text GLabel 4800 3750 2    50   BiDi ~ 0
~INH~
Text GLabel 4800 3850 2    50   BiDi ~ 0
~SLOT1~
Text GLabel 5750 9700 0    50   Input ~ 0
A4
Text GLabel 5750 9800 0    50   Input ~ 0
A5
Text GLabel 5750 9900 0    50   Input ~ 0
A6
Text GLabel 5750 10000 0    50   Input ~ 0
A7
Text GLabel 5750 10100 0    50   Input ~ 0
A8
Text GLabel 5750 10200 0    50   Input ~ 0
A9
$Comp
L power:+5V #PWR0147
U 1 1 5FE5238B
P 6350 8850
F 0 "#PWR0147" H 6350 8700 50  0001 C CNN
F 1 "+5V" H 6365 9023 50  0000 C CNN
F 2 "" H 6350 8850 50  0001 C CNN
F 3 "" H 6350 8850 50  0001 C CNN
	1    6350 8850
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 9300 6350 9000
Text GLabel 5750 10300 0    50   Input ~ 0
A10
Text GLabel 5750 10400 0    50   Input ~ 0
A11
Text GLabel 5750 10500 0    50   Input ~ 0
A12
Text GLabel 5750 10600 0    50   Input ~ 0
A13
Text GLabel 6950 9500 2    50   Input ~ 0
A14
Text GLabel 6950 10600 2    50   Input ~ 0
A15
Text GLabel 6950 10100 2    50   Output ~ 0
~SLOT4~
Text GLabel 6950 10000 2    50   Output ~ 0
~SLOT3~
Text GLabel 6950 9900 2    50   Output ~ 0
~SLOT2~
Text GLabel 6950 9800 2    50   Output ~ 0
~SLOT1~
$Comp
L power:GND #PWR0148
U 1 1 5FEA08DB
P 6350 10800
F 0 "#PWR0148" H 6350 10550 50  0001 C CNN
F 1 "GND" H 6355 10627 50  0000 C CNN
F 2 "" H 6350 10800 50  0001 C CNN
F 3 "" H 6350 10800 50  0001 C CNN
	1    6350 10800
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C14
U 1 1 5FEA6281
P 6600 9000
F 0 "C14" H 6692 9046 50  0000 L CNN
F 1 "10n" H 6692 8955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6600 9000 50  0001 C CNN
F 3 "~" H 6600 9000 50  0001 C CNN
	1    6600 9000
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6500 9000 6350 9000
Connection ~ 6350 9000
Wire Wire Line
	6350 9000 6350 8850
$Comp
L power:GND #PWR0149
U 1 1 5FEB1537
P 6700 9000
F 0 "#PWR0149" H 6700 8750 50  0001 C CNN
F 1 "GND" H 6705 8827 50  0000 C CNN
F 2 "" H 6700 9000 50  0001 C CNN
F 3 "" H 6700 9000 50  0001 C CNN
	1    6700 9000
	1    0    0    -1  
$EndComp
Text GLabel 6950 10200 2    50   Output ~ 0
~SLOT5~
Text GLabel 6950 10300 2    50   Output ~ 0
~SSEL~
Text GLabel 2800 3750 2    50   BiDi ~ 0
~INH~
Text GLabel 4550 6400 0    50   BiDi ~ 0
~INH~
$Comp
L Device:R_Small R14
U 1 1 5FE6B3EF
P 4650 6400
F 0 "R14" V 4454 6400 50  0000 C CNN
F 1 "1k" V 4545 6400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4650 6400 50  0001 C CNN
F 3 "~" H 4650 6400 50  0001 C CNN
	1    4650 6400
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0150
U 1 1 5FE6B3F5
P 4750 6400
F 0 "#PWR0150" H 4750 6250 50  0001 C CNN
F 1 "+5V" H 4765 6573 50  0000 C CNN
F 2 "" H 4750 6400 50  0001 C CNN
F 3 "" H 4750 6400 50  0001 C CNN
	1    4750 6400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0152
U 1 1 5FE6F83B
P 900 1750
F 0 "#PWR0152" H 900 1500 50  0001 C CNN
F 1 "GND" H 905 1577 50  0000 C CNN
F 2 "" H 900 1750 50  0001 C CNN
F 3 "" H 900 1750 50  0001 C CNN
	1    900  1750
	1    0    0    -1  
$EndComp
$Comp
L cpu_backplane-rescue:USB_B_Micro-Connector J1
U 1 1 5FE9DEAA
P 900 1250
F 0 "J1" H 957 1717 50  0000 C CNN
F 1 "USB_B_Micro" H 957 1626 50  0000 C CNN
F 2 "Connector_USB:USB_Micro-B_Molex-105017-0001" H 1050 1200 50  0001 C CNN
F 3 "~" H 1050 1200 50  0001 C CNN
	1    900  1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  1750 900  1650
Wire Wire Line
	900  1650 800  1650
Text GLabel 7100 3700 2    50   BiDi ~ 0
~SSEL~
Text GLabel 2750 8300 2    50   BiDi ~ 0
~SSEL~
Text GLabel 4950 8350 2    50   BiDi ~ 0
~SSEL~
Text GLabel 9550 3700 2    50   BiDi ~ 0
~SSEL~
Text GLabel 4800 3650 2    50   BiDi ~ 0
~SSEL~
Connection ~ 900  1650
Text GLabel 7100 4400 2    50   BiDi ~ 0
CLK_12M
Text GLabel 7100 4500 2    50   BiDi ~ 0
EX2
Text GLabel 7100 4600 2    50   BiDi ~ 0
EX3
Text GLabel 2750 9000 2    50   BiDi ~ 0
CLK_12M
Text GLabel 4950 9050 2    50   BiDi ~ 0
CLK_12M
Text GLabel 9550 4400 2    50   BiDi ~ 0
CLK_12M
Text GLabel 4800 4350 2    50   BiDi ~ 0
CLK_12M
Text GLabel 2800 4350 2    50   BiDi ~ 0
CLK_12M
Text GLabel 2800 4450 2    50   BiDi ~ 0
EX2
Text GLabel 2800 4550 2    50   BiDi ~ 0
EX3
Text GLabel 2800 4650 2    50   BiDi ~ 0
~IRQ0~
Wire Wire Line
	2350 1050 2200 1050
Connection ~ 2200 1050
Wire Wire Line
	2200 1050 2100 1050
Wire Wire Line
	1200 1050 1700 1050
Text GLabel 5750 9500 0    50   Input ~ 0
CLK
Text GLabel 2750 9100 2    50   BiDi ~ 0
EX2
Text GLabel 2750 9200 2    50   BiDi ~ 0
EX3
Text GLabel 4950 9150 2    50   BiDi ~ 0
EX2
Text GLabel 4950 9250 2    50   BiDi ~ 0
EX3
Text GLabel 9550 4500 2    50   BiDi ~ 0
EX2
Text GLabel 9550 4600 2    50   BiDi ~ 0
EX3
Text GLabel 4800 4450 2    50   BiDi ~ 0
EX2
Text GLabel 4800 4550 2    50   BiDi ~ 0
EX3
Connection ~ 10250 9550
Wire Wire Line
	10150 9550 10250 9550
Wire Wire Line
	10150 9850 10150 9550
Wire Wire Line
	10250 9850 10150 9850
Wire Wire Line
	10250 9550 10250 8950
Wire Wire Line
	10250 8950 10750 8950
Wire Wire Line
	11250 9750 11550 9750
Text Label 9600 10350 0    50   ~ 0
CLK_24M
Text GLabel 11550 9750 2    50   Output ~ 0
CLK
Wire Wire Line
	11500 9550 11250 9550
Text GLabel 11500 9550 2    50   Output ~ 0
CLK_12M
Connection ~ 10250 10250
Wire Wire Line
	10250 10250 10000 10250
$Comp
L power:+5V #PWR0159
U 1 1 5FFE34F5
P 10000 10250
F 0 "#PWR0159" H 10000 10100 50  0001 C CNN
F 1 "+5V" H 10015 10423 50  0000 C CNN
F 2 "" H 10000 10250 50  0001 C CNN
F 3 "" H 10000 10250 50  0001 C CNN
	1    10000 10250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10250 10250 10250 10150
Wire Wire Line
	11400 8500 11400 9850
Wire Wire Line
	10000 10050 10250 10050
Wire Wire Line
	10000 8500 10000 10050
Wire Wire Line
	11400 8500 10000 8500
Wire Wire Line
	11250 9850 11400 9850
$Comp
L power:GND #PWR0158
U 1 1 5FFCE6F5
P 11100 8950
F 0 "#PWR0158" H 11100 8700 50  0001 C CNN
F 1 "GND" H 11105 8777 50  0000 C CNN
F 2 "" H 11100 8950 50  0001 C CNN
F 3 "" H 11100 8950 50  0001 C CNN
	1    11100 8950
	1    0    0    -1  
$EndComp
Wire Wire Line
	10750 8950 10750 8800
Connection ~ 10750 8950
Wire Wire Line
	10900 8950 10750 8950
$Comp
L Device:C_Small C2
U 1 1 5FFCE6EC
P 11000 8950
F 0 "C2" H 11092 8996 50  0000 L CNN
F 1 "10n" H 11092 8905 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 11000 8950 50  0001 C CNN
F 3 "~" H 11000 8950 50  0001 C CNN
	1    11000 8950
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10750 9250 10750 8950
$Comp
L power:+5V #PWR0157
U 1 1 5FFCE6E5
P 10750 8800
F 0 "#PWR0157" H 10750 8650 50  0001 C CNN
F 1 "+5V" H 10765 8973 50  0000 C CNN
F 2 "" H 10750 8800 50  0001 C CNN
F 3 "" H 10750 8800 50  0001 C CNN
	1    10750 8800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0156
U 1 1 5FFC8C82
P 10750 10850
F 0 "#PWR0156" H 10750 10600 50  0001 C CNN
F 1 "GND" H 10755 10677 50  0000 C CNN
F 2 "" H 10750 10850 50  0001 C CNN
F 3 "" H 10750 10850 50  0001 C CNN
	1    10750 10850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8600 10000 8600 10350
Wire Wire Line
	8550 10000 8600 10000
Text GLabel 10250 10550 0    50   Input ~ 0
~RESET~
$Comp
L 74xx:74LS161 U1
U 1 1 5FF93A76
P 10750 10050
F 0 "U1" H 10750 11031 50  0000 C CNN
F 1 "74AC161" H 10750 10940 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket" H 10750 10050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS163" H 10750 10050 50  0001 C CNN
	1    10750 10050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0155
U 1 1 5FE9590F
P 8600 9400
F 0 "#PWR0155" H 8600 9150 50  0001 C CNN
F 1 "GND" H 8605 9227 50  0000 C CNN
F 2 "" H 8600 9400 50  0001 C CNN
F 3 "" H 8600 9400 50  0001 C CNN
	1    8600 9400
	1    0    0    -1  
$EndComp
Wire Wire Line
	8250 9400 8250 9250
Connection ~ 8250 9400
Wire Wire Line
	8400 9400 8250 9400
$Comp
L Device:C_Small C4
U 1 1 5FE95906
P 8500 9400
F 0 "C4" H 8592 9446 50  0000 L CNN
F 1 "10n" H 8592 9355 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 8500 9400 50  0001 C CNN
F 3 "~" H 8500 9400 50  0001 C CNN
	1    8500 9400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8250 9700 8250 9400
$Comp
L power:+5V #PWR0154
U 1 1 5FE958FF
P 8250 9250
F 0 "#PWR0154" H 8250 9100 50  0001 C CNN
F 1 "+5V" H 8265 9423 50  0000 C CNN
F 2 "" H 8250 9250 50  0001 C CNN
F 3 "" H 8250 9250 50  0001 C CNN
	1    8250 9250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0153
U 1 1 5FE8FD3D
P 8250 10300
F 0 "#PWR0153" H 8250 10050 50  0001 C CNN
F 1 "GND" H 8255 10127 50  0000 C CNN
F 2 "" H 8250 10300 50  0001 C CNN
F 3 "" H 8250 10300 50  0001 C CNN
	1    8250 10300
	1    0    0    -1  
$EndComp
$Comp
L Oscillator:CXO_DIP8 X1
U 1 1 5FE8F313
P 8250 10000
F 0 "X1" H 8594 10046 50  0000 L CNN
F 1 "24MHz" H 8594 9955 50  0000 L CNN
F 2 "Oscillator:Oscillator_DIP-8" H 8700 9650 50  0001 C CNN
F 3 "http://cdn-reichelt.de/documents/datenblatt/B400/OSZI.pdf" H 8150 10000 50  0001 C CNN
	1    8250 10000
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 3600 6600 3600
Wire Wire Line
	7550 3500 7650 3500
Wire Wire Line
	7650 3500 7650 3450
Wire Wire Line
	7650 3450 7800 3450
Connection ~ 7550 3500
Wire Wire Line
	7550 3600 7650 3600
Wire Wire Line
	7650 3600 7650 3650
Wire Wire Line
	7650 3650 7800 3650
Connection ~ 7550 3600
Wire Wire Line
	10000 3500 10100 3500
Wire Wire Line
	10100 3500 10100 3450
Wire Wire Line
	10100 3450 10250 3450
Connection ~ 10000 3500
Wire Wire Line
	10250 3650 10100 3650
Wire Wire Line
	10100 3650 10100 3600
Wire Wire Line
	10100 3600 10000 3600
Connection ~ 10000 3600
Wire Wire Line
	1950 8200 2250 8200
Wire Wire Line
	3100 8100 3200 8100
Wire Wire Line
	3200 8100 3200 8050
Wire Wire Line
	3200 8050 3350 8050
Connection ~ 3100 8100
Wire Wire Line
	3350 8250 3200 8250
Wire Wire Line
	3200 8250 3200 8200
Wire Wire Line
	3200 8200 3100 8200
Connection ~ 3100 8200
Text GLabel 8900 9750 0    50   Input ~ 0
~SLOW~
$Comp
L Connector_Generic:Conn_02x02_Odd_Even J2
U 1 1 60150E99
P 9450 9650
F 0 "J2" H 9500 9867 50  0000 C CNN
F 1 "Conn_02x02_Odd_Even" H 9500 9776 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x02_P2.54mm_Vertical" H 9450 9650 50  0001 C CNN
F 3 "~" H 9450 9650 50  0001 C CNN
	1    9450 9650
	1    0    0    -1  
$EndComp
Wire Wire Line
	8600 10350 10250 10350
Wire Wire Line
	9250 9750 9250 9650
Connection ~ 9250 9750
Wire Wire Line
	10250 9650 9750 9650
Text Label 9750 9750 0    50   ~ 0
DS2
Text Label 9750 9650 0    50   ~ 0
DS1
Text GLabel 2800 4250 2    50   BiDi ~ 0
LED4
Text GLabel 4950 9350 2    50   BiDi ~ 0
~IRQ5~
$Comp
L Device:D D7
U 1 1 603C94D3
P 10250 2950
F 0 "D7" H 10250 2685 50  0000 C CNN
F 1 "1N4148" H 10250 2776 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 10250 2950 50  0001 C CNN
F 3 "~" H 10250 2950 50  0001 C CNN
	1    10250 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	10100 2950 9850 2950
Wire Wire Line
	9850 2950 9850 3400
Wire Wire Line
	9850 3400 9550 3400
Text GLabel 7950 2950 2    50   BiDi ~ 0
~SLOW~
$Comp
L Device:D D6
U 1 1 603F44EB
P 7800 2950
F 0 "D6" H 7800 2685 50  0000 C CNN
F 1 "1N4148" H 7800 2776 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 7800 2950 50  0001 C CNN
F 3 "~" H 7800 2950 50  0001 C CNN
	1    7800 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7650 2950 7400 2950
Wire Wire Line
	7400 2950 7400 3400
Text GLabel 5650 2900 2    50   BiDi ~ 0
~SLOW~
$Comp
L Device:D D4
U 1 1 603F9D4C
P 5500 2900
F 0 "D4" H 5500 2635 50  0000 C CNN
F 1 "1N4148" H 5500 2726 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 5500 2900 50  0001 C CNN
F 3 "~" H 5500 2900 50  0001 C CNN
	1    5500 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 2900 5100 2900
Wire Wire Line
	5100 2900 5100 3350
Text GLabel 3650 2900 2    50   BiDi ~ 0
~SLOW~
Wire Wire Line
	3100 2900 3100 3350
Text GLabel 3550 7550 2    50   BiDi ~ 0
~SLOW~
$Comp
L Device:D D2
U 1 1 6040585B
P 3400 7550
F 0 "D2" H 3400 7285 50  0000 C CNN
F 1 "1N4148" H 3400 7376 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 3400 7550 50  0001 C CNN
F 3 "~" H 3400 7550 50  0001 C CNN
	1    3400 7550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 7550 3000 7550
Wire Wire Line
	3000 7550 3000 8000
Text GLabel 5750 7600 2    50   BiDi ~ 0
~SLOW~
$Comp
L Device:D D5
U 1 1 6040B971
P 5600 7600
F 0 "D5" H 5600 7335 50  0000 C CNN
F 1 "1N4148" H 5600 7426 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 5600 7600 50  0001 C CNN
F 3 "~" H 5600 7600 50  0001 C CNN
	1    5600 7600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 7600 5200 7600
Wire Wire Line
	5200 7600 5200 8050
Wire Wire Line
	5200 8050 4950 8050
Wire Wire Line
	3000 8000 2750 8000
Wire Wire Line
	3100 3350 2800 3350
Wire Wire Line
	5100 3350 4800 3350
Wire Wire Line
	7400 3400 7100 3400
Wire Wire Line
	3350 2900 3100 2900
$Comp
L Device:D D3
U 1 1 603FF9D8
P 3500 2900
F 0 "D3" H 3500 2635 50  0000 C CNN
F 1 "1N4148" H 3500 2726 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 3500 2900 50  0001 C CNN
F 3 "~" H 3500 2900 50  0001 C CNN
	1    3500 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 9750 9250 9750
$Comp
L Mechanical:MountingHole_Pad H1
U 1 1 604A8FFB
P 2100 10600
F 0 "H1" H 2200 10649 50  0000 L CNN
F 1 "MountingHole_Pad" H 2200 10558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2100 10600 50  0001 C CNN
F 3 "~" H 2100 10600 50  0001 C CNN
	1    2100 10600
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H2
U 1 1 604B1566
P 2500 10600
F 0 "H2" H 2600 10649 50  0000 L CNN
F 1 "MountingHole_Pad" H 2600 10558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2500 10600 50  0001 C CNN
F 3 "~" H 2500 10600 50  0001 C CNN
	1    2500 10600
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H3
U 1 1 604B8573
P 2900 10600
F 0 "H3" H 3000 10649 50  0000 L CNN
F 1 "MountingHole_Pad" H 3000 10558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2900 10600 50  0001 C CNN
F 3 "~" H 2900 10600 50  0001 C CNN
	1    2900 10600
	1    0    0    -1  
$EndComp
Connection ~ 2500 10700
Wire Wire Line
	2500 10700 2100 10700
Wire Wire Line
	2900 10700 2500 10700
$Comp
L power:GND #PWR0162
U 1 1 604CE063
P 2500 10700
F 0 "#PWR0162" H 2500 10450 50  0001 C CNN
F 1 "GND" H 2505 10527 50  0000 C CNN
F 2 "" H 2500 10700 50  0001 C CNN
F 3 "" H 2500 10700 50  0001 C CNN
	1    2500 10700
	1    0    0    -1  
$EndComp
Text GLabel 15350 5650 2    50   BiDi ~ 0
D0
Text GLabel 15350 5750 2    50   BiDi ~ 0
D1
Text GLabel 15350 5850 2    50   BiDi ~ 0
D2
Text GLabel 15350 5950 2    50   BiDi ~ 0
D3
Text GLabel 15350 6050 2    50   BiDi ~ 0
D4
Text GLabel 15350 6150 2    50   BiDi ~ 0
D5
Text GLabel 15350 6250 2    50   BiDi ~ 0
D6
Text GLabel 15350 6350 2    50   BiDi ~ 0
D7
Text GLabel 15350 3950 2    50   Output ~ 0
A0
Text GLabel 15350 4050 2    50   Output ~ 0
A1
Text GLabel 15350 4150 2    50   Output ~ 0
A2
Text GLabel 15350 4250 2    50   Output ~ 0
A3
Text GLabel 15350 4350 2    50   Output ~ 0
A4
Text GLabel 15350 4450 2    50   Output ~ 0
A5
Text GLabel 15350 4550 2    50   Output ~ 0
A6
Text GLabel 15350 4650 2    50   Output ~ 0
A7
Text GLabel 15350 4750 2    50   Output ~ 0
A8
Text GLabel 15350 4850 2    50   Output ~ 0
A9
Text GLabel 15350 4950 2    50   Output ~ 0
A10
Text GLabel 15350 5050 2    50   Output ~ 0
A11
Text GLabel 15350 5150 2    50   Output ~ 0
A12
Text GLabel 15350 5250 2    50   Output ~ 0
A13
Text GLabel 15350 5350 2    50   Output ~ 0
A14
Text GLabel 15350 5450 2    50   Output ~ 0
A15
$Comp
L power:GND #PWR0163
U 1 1 60442E67
P 14750 6700
F 0 "#PWR0163" H 14750 6450 50  0001 C CNN
F 1 "GND" H 14755 6527 50  0000 C CNN
F 2 "" H 14750 6700 50  0001 C CNN
F 3 "" H 14750 6700 50  0001 C CNN
	1    14750 6700
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0164
U 1 1 60442E6D
P 14750 3300
F 0 "#PWR0164" H 14750 3150 50  0001 C CNN
F 1 "+5V" H 14765 3473 50  0000 C CNN
F 2 "" H 14750 3300 50  0001 C CNN
F 3 "" H 14750 3300 50  0001 C CNN
	1    14750 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	14750 3600 14750 3350
$Comp
L Device:C_Small C9
U 1 1 60442E74
P 14950 3350
F 0 "C9" V 14721 3350 50  0000 C CNN
F 1 "10n" V 14812 3350 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 14950 3350 50  0001 C CNN
F 3 "~" H 14950 3350 50  0001 C CNN
	1    14950 3350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0165
U 1 1 60442E7A
P 15200 3350
F 0 "#PWR0165" H 15200 3100 50  0001 C CNN
F 1 "GND" H 15205 3177 50  0000 C CNN
F 2 "" H 15200 3350 50  0001 C CNN
F 3 "" H 15200 3350 50  0001 C CNN
	1    15200 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	15200 3350 15050 3350
Wire Wire Line
	14850 3350 14750 3350
Connection ~ 14750 3350
Wire Wire Line
	14750 3350 14750 3300
Text GLabel 14150 5850 0    50   Input ~ 0
SYNC
Text GLabel 14150 5550 0    50   Input ~ 0
BE
Text GLabel 14150 5450 0    50   Input ~ 0
RDY
Text GLabel 14150 5150 0    50   Input ~ 0
R~W~
Text GLabel 14150 4250 0    50   Input ~ 0
CLK
Text GLabel 14150 3950 0    50   Input ~ 0
~RESET~
Text GLabel 14150 4750 0    50   Input ~ 0
~IRQ~
Text GLabel 14150 4850 0    50   Input ~ 0
~NMI~
$Comp
L Memory_EEPROM:28C256 U8
U 1 1 60442E8C
P 12400 5500
F 0 "U8" H 12400 6781 50  0000 C CNN
F 1 "28C256" H 12400 6690 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm_Socket" H 12400 5500 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 12400 5500 50  0001 C CNN
	1    12400 5500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0166
U 1 1 60442E93
P 11400 6200
F 0 "#PWR0166" H 11400 6050 50  0001 C CNN
F 1 "+5V" H 11415 6373 50  0000 C CNN
F 2 "" H 11400 6200 50  0001 C CNN
F 3 "" H 11400 6200 50  0001 C CNN
	1    11400 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	11950 6600 12400 6600
$Comp
L power:GND #PWR0167
U 1 1 60442E9B
P 12400 6600
F 0 "#PWR0167" H 12400 6350 50  0001 C CNN
F 1 "GND" H 12405 6427 50  0000 C CNN
F 2 "" H 12400 6600 50  0001 C CNN
F 3 "" H 12400 6600 50  0001 C CNN
	1    12400 6600
	1    0    0    -1  
$EndComp
Text GLabel 12000 4600 0    50   Input ~ 0
A0
Text GLabel 12000 4700 0    50   Input ~ 0
A1
Text GLabel 12000 4800 0    50   Input ~ 0
A2
Text GLabel 12000 4900 0    50   Input ~ 0
A3
Text GLabel 12000 5000 0    50   Input ~ 0
A4
Text GLabel 12000 5100 0    50   Input ~ 0
A5
Text GLabel 12000 5200 0    50   Input ~ 0
A6
Text GLabel 12000 5300 0    50   Input ~ 0
A7
Text GLabel 12000 5400 0    50   Input ~ 0
A8
Text GLabel 12000 5500 0    50   Input ~ 0
A9
Text GLabel 12000 5600 0    50   Input ~ 0
A10
Text GLabel 12000 5700 0    50   Input ~ 0
A11
Text GLabel 12000 5800 0    50   Input ~ 0
A12
Text GLabel 12000 5900 0    50   Input ~ 0
A13
Text GLabel 12000 6000 0    50   Input ~ 0
A14
Text GLabel 12800 4600 2    50   BiDi ~ 0
D0
Text GLabel 12800 4700 2    50   BiDi ~ 0
D1
Text GLabel 12800 4800 2    50   BiDi ~ 0
D2
Text GLabel 12800 4900 2    50   BiDi ~ 0
D3
Text GLabel 12800 5000 2    50   BiDi ~ 0
D4
Text GLabel 12800 5100 2    50   BiDi ~ 0
D5
Text GLabel 12800 5200 2    50   BiDi ~ 0
D6
Text GLabel 12800 5300 2    50   BiDi ~ 0
D7
Text GLabel 9400 6050 0    50   Input ~ 0
A0
Text GLabel 9400 6150 0    50   Input ~ 0
A1
Text GLabel 9400 6250 0    50   Input ~ 0
A2
Text GLabel 9400 6350 0    50   Input ~ 0
A3
Text GLabel 9400 6450 0    50   Input ~ 0
A4
Text GLabel 9400 6550 0    50   Input ~ 0
A5
Text GLabel 9400 6650 0    50   Input ~ 0
A6
Text GLabel 9400 6750 0    50   Input ~ 0
A7
Text GLabel 9400 6850 0    50   Input ~ 0
A8
Text GLabel 9400 6950 0    50   Input ~ 0
A9
Text GLabel 9400 7050 0    50   Input ~ 0
A10
Text GLabel 9400 7150 0    50   Input ~ 0
A11
Text GLabel 9400 7250 0    50   Input ~ 0
A12
Text GLabel 9400 7350 0    50   Input ~ 0
A13
Text GLabel 9400 7450 0    50   Input ~ 0
A14
$Comp
L power:GND #PWR0168
U 1 1 60442EC7
P 9900 7650
F 0 "#PWR0168" H 9900 7400 50  0001 C CNN
F 1 "GND" H 9905 7477 50  0000 C CNN
F 2 "" H 9900 7650 50  0001 C CNN
F 3 "" H 9900 7650 50  0001 C CNN
	1    9900 7650
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0169
U 1 1 60442ECD
P 9900 5550
F 0 "#PWR0169" H 9900 5400 50  0001 C CNN
F 1 "+5V" H 9915 5723 50  0000 C CNN
F 2 "" H 9900 5550 50  0001 C CNN
F 3 "" H 9900 5550 50  0001 C CNN
	1    9900 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	9900 5850 9900 5600
$Comp
L Device:C_Small C12
U 1 1 60442ED4
P 10100 5600
F 0 "C12" V 9871 5600 50  0000 C CNN
F 1 "10n" V 9962 5600 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 10100 5600 50  0001 C CNN
F 3 "~" H 10100 5600 50  0001 C CNN
	1    10100 5600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0170
U 1 1 60442EDA
P 10350 5600
F 0 "#PWR0170" H 10350 5350 50  0001 C CNN
F 1 "GND" H 10355 5427 50  0000 C CNN
F 2 "" H 10350 5600 50  0001 C CNN
F 3 "" H 10350 5600 50  0001 C CNN
	1    10350 5600
	1    0    0    -1  
$EndComp
Wire Wire Line
	10350 5600 10200 5600
Wire Wire Line
	10000 5600 9900 5600
Connection ~ 9900 5600
Wire Wire Line
	9900 5600 9900 5550
$Comp
L power:+5V #PWR0171
U 1 1 60442EE4
P 12400 4100
F 0 "#PWR0171" H 12400 3950 50  0001 C CNN
F 1 "+5V" H 12415 4273 50  0000 C CNN
F 2 "" H 12400 4100 50  0001 C CNN
F 3 "" H 12400 4100 50  0001 C CNN
	1    12400 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	12400 4400 12400 4150
$Comp
L Device:C_Small C15
U 1 1 60442EEB
P 12600 4150
F 0 "C15" V 12371 4150 50  0000 C CNN
F 1 "10n" V 12462 4150 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 12600 4150 50  0001 C CNN
F 3 "~" H 12600 4150 50  0001 C CNN
	1    12600 4150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0172
U 1 1 60442EF1
P 12850 4150
F 0 "#PWR0172" H 12850 3900 50  0001 C CNN
F 1 "GND" H 12855 3977 50  0000 C CNN
F 2 "" H 12850 4150 50  0001 C CNN
F 3 "" H 12850 4150 50  0001 C CNN
	1    12850 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	12850 4150 12700 4150
Wire Wire Line
	12500 4150 12400 4150
Connection ~ 12400 4150
Wire Wire Line
	12400 4150 12400 4100
$Comp
L power:GND #PWR0173
U 1 1 60442EFC
P 10800 7050
F 0 "#PWR0173" H 10800 6800 50  0001 C CNN
F 1 "GND" H 10805 6877 50  0000 C CNN
F 2 "" H 10800 7050 50  0001 C CNN
F 3 "" H 10800 7050 50  0001 C CNN
	1    10800 7050
	1    0    0    -1  
$EndComp
Wire Wire Line
	10800 7050 10550 7050
Wire Wire Line
	10550 7050 10550 7150
Wire Wire Line
	10550 7150 10400 7150
Text GLabel 10400 6050 2    50   BiDi ~ 0
D0
Text GLabel 10400 6150 2    50   BiDi ~ 0
D1
Text GLabel 10400 6250 2    50   BiDi ~ 0
D2
Text GLabel 10400 6350 2    50   BiDi ~ 0
D3
Text GLabel 10400 6450 2    50   BiDi ~ 0
D4
Text GLabel 10400 6550 2    50   BiDi ~ 0
D5
Text GLabel 10400 6650 2    50   BiDi ~ 0
D6
Text GLabel 10400 6750 2    50   BiDi ~ 0
D7
Wire Wire Line
	10750 6800 10650 6800
Wire Wire Line
	10650 6800 10650 6950
Wire Wire Line
	10650 6950 10400 6950
$Comp
L Memory_RAM:HM62256BLP U7
U 1 1 60442F10
P 9900 6750
F 0 "U7" H 9900 7831 50  0000 C CNN
F 1 "HM62256BLP" H 9900 7740 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W7.62mm_Socket" H 9900 6650 50  0001 C CNN
F 3 "https://web.mit.edu/6.115/www/document/62256.pdf" H 9900 6650 50  0001 C CNN
	1    9900 6750
	1    0    0    -1  
$EndComp
Wire Wire Line
	11950 6600 11950 6400
Wire Wire Line
	11950 6400 12000 6400
Text GLabel 10400 7250 2    50   Input ~ 0
~RAMW~
Text GLabel 10750 6800 2    50   Input ~ 0
~RAM_CS~
Text GLabel 12850 1500 0    50   Input ~ 0
CLK
Text GLabel 12850 1700 0    50   Input ~ 0
~IRQ1~
Text GLabel 12600 1800 0    50   Input ~ 0
~IRQ2~
Text GLabel 12850 1900 0    50   Input ~ 0
~IRQ3~
Text GLabel 12600 2000 0    50   Input ~ 0
~IRQ4~
Text GLabel 13850 1500 2    50   Output ~ 0
~IRQ~
Text GLabel 14050 2200 2    50   Input ~ 0
~SSEL~
Text GLabel 13850 2100 2    50   Input ~ 0
~INH~
Wire Wire Line
	12850 2200 12600 2200
Wire Wire Line
	12850 2000 12600 2000
Wire Wire Line
	12850 1800 12600 1800
Text GLabel 14250 1600 2    50   Output ~ 0
~RAM_CS~
Wire Wire Line
	14250 1600 13850 1600
Text GLabel 12800 2300 0    50   Input ~ 0
A15
Wire Wire Line
	12850 2300 12800 2300
Text GLabel 14250 1750 2    50   Output ~ 0
~ROM_CS~
Wire Wire Line
	14200 1900 14200 1750
Wire Wire Line
	14200 1700 13850 1700
Wire Wire Line
	14250 1750 14200 1750
Connection ~ 14200 1750
Wire Wire Line
	14200 1750 14200 1700
Text GLabel 13850 1800 2    50   Output ~ 0
~RAMW~
Text GLabel 12000 6300 0    50   Input ~ 0
~ROM_CS~
$Comp
L power:+5V #PWR0174
U 1 1 60442F32
P 13350 1000
F 0 "#PWR0174" H 13350 850 50  0001 C CNN
F 1 "+5V" H 13365 1173 50  0000 C CNN
F 2 "" H 13350 1000 50  0001 C CNN
F 3 "" H 13350 1000 50  0001 C CNN
	1    13350 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	13350 1300 13350 1050
$Comp
L Device:C_Small C5
U 1 1 60442F39
P 13550 1050
F 0 "C5" V 13321 1050 50  0000 C CNN
F 1 "10n" V 13412 1050 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 13550 1050 50  0001 C CNN
F 3 "~" H 13550 1050 50  0001 C CNN
	1    13550 1050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0175
U 1 1 60442F3F
P 13800 1050
F 0 "#PWR0175" H 13800 800 50  0001 C CNN
F 1 "GND" H 13805 877 50  0000 C CNN
F 2 "" H 13800 1050 50  0001 C CNN
F 3 "" H 13800 1050 50  0001 C CNN
	1    13800 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	13800 1050 13650 1050
Wire Wire Line
	13450 1050 13350 1050
Connection ~ 13350 1050
Wire Wire Line
	13350 1050 13350 1000
$Comp
L power:GND #PWR0176
U 1 1 60442F49
P 13350 2700
F 0 "#PWR0176" H 13350 2450 50  0001 C CNN
F 1 "GND" H 13355 2527 50  0000 C CNN
F 2 "" H 13350 2700 50  0001 C CNN
F 3 "" H 13350 2700 50  0001 C CNN
	1    13350 2700
	1    0    0    -1  
$EndComp
$Comp
L Logic_Programmable:GAL16V8 U5
U 1 1 60442F4F
P 13350 2000
F 0 "U5" H 13350 2881 50  0000 C CNN
F 1 "GAL16V8" H 13350 2790 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 13350 2000 50  0001 C CNN
F 3 "" H 13350 2000 50  0001 C CNN
	1    13350 2000
	1    0    0    -1  
$EndComp
Text GLabel 12350 2100 0    50   Input ~ 0
~IRQ5~
Wire Wire Line
	12850 2100 12350 2100
Text GLabel 12850 2400 0    50   Input ~ 0
R~W~
Connection ~ 12400 6600
$Comp
L 65xx:W65C02SxP U6
U 1 1 60442E49
P 14750 5150
F 0 "U6" H 14750 6881 50  0000 C CNN
F 1 "W65C02SxP" H 14750 6790 50  0000 C CIB
F 2 "Package_DIP:DIP-40_W15.24mm_Socket" H 14750 7150 50  0001 C CNN
F 3 "http://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf" H 14750 7050 50  0001 C CNN
	1    14750 5150
	1    0    0    -1  
$EndComp
$Comp
L 65xx:W65C51NxP U9
U 1 1 6057CD3F
P 7550 6950
F 0 "U9" H 7550 8581 50  0000 C CNN
F 1 "W65C51NxP" H 7550 8490 50  0000 C CIB
F 2 "Package_DIP:DIP-28_W15.24mm_Socket" H 7550 7100 50  0001 C CNN
F 3 "http://www.westerndesigncenter.com/wdc/documentation/w65c51n.pdf" H 7550 7100 50  0001 C CNN
	1    7550 6950
	1    0    0    -1  
$EndComp
Text GLabel 6950 7350 0    50   BiDi ~ 0
D0
Text GLabel 6950 7450 0    50   BiDi ~ 0
D1
Text GLabel 6950 7550 0    50   BiDi ~ 0
D2
Text GLabel 6950 7650 0    50   BiDi ~ 0
D3
Text GLabel 6950 7750 0    50   BiDi ~ 0
D4
Text GLabel 6950 7850 0    50   BiDi ~ 0
D5
Text GLabel 6950 7950 0    50   BiDi ~ 0
D6
Text GLabel 6950 8050 0    50   BiDi ~ 0
D7
$Comp
L Mechanical:MountingHole_Pad H5
U 1 1 605B9B93
P 1350 10600
F 0 "H5" H 1450 10649 50  0000 L CNN
F 1 "MountingHole_Pad" H 1450 10558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 1350 10600 50  0001 C CNN
F 3 "~" H 1350 10600 50  0001 C CNN
	1    1350 10600
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H6
U 1 1 605B9B99
P 1750 10600
F 0 "H6" H 1850 10649 50  0000 L CNN
F 1 "MountingHole_Pad" H 1850 10558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 1750 10600 50  0001 C CNN
F 3 "~" H 1750 10600 50  0001 C CNN
	1    1750 10600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 10700 1750 10700
Connection ~ 2100 10700
Connection ~ 1750 10700
Wire Wire Line
	1750 10700 1350 10700
$Comp
L Connector_Generic:Conn_01x06 J3
U 1 1 605F0D96
P 8700 6700
F 0 "J3" H 8780 6692 50  0000 L CNN
F 1 "Conn_01x06" H 8780 6601 50  0000 L CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x06_P2.54mm_Vertical" H 8700 6700 50  0001 C CNN
F 3 "~" H 8700 6700 50  0001 C CNN
	1    8700 6700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0151
U 1 1 605FE7BC
P 7550 8400
F 0 "#PWR0151" H 7550 8150 50  0001 C CNN
F 1 "GND" H 7555 8227 50  0000 C CNN
F 2 "" H 7550 8400 50  0001 C CNN
F 3 "" H 7550 8400 50  0001 C CNN
	1    7550 8400
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0177
U 1 1 60609578
P 7550 5200
F 0 "#PWR0177" H 7550 5050 50  0001 C CNN
F 1 "+5V" H 7565 5373 50  0000 C CNN
F 2 "" H 7550 5200 50  0001 C CNN
F 3 "" H 7550 5200 50  0001 C CNN
	1    7550 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 5500 7550 5250
$Comp
L Device:C_Small C16
U 1 1 6060957F
P 7750 5250
F 0 "C16" V 7521 5250 50  0000 C CNN
F 1 "10n" V 7612 5250 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7750 5250 50  0001 C CNN
F 3 "~" H 7750 5250 50  0001 C CNN
	1    7750 5250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0178
U 1 1 60609585
P 8000 5250
F 0 "#PWR0178" H 8000 5000 50  0001 C CNN
F 1 "GND" H 8005 5077 50  0000 C CNN
F 2 "" H 8000 5250 50  0001 C CNN
F 3 "" H 8000 5250 50  0001 C CNN
	1    8000 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8000 5250 7850 5250
Wire Wire Line
	7650 5250 7550 5250
Connection ~ 7550 5250
Wire Wire Line
	7550 5250 7550 5200
Text GLabel 6950 7150 0    50   Input ~ 0
R~W~
Text GLabel 6950 10500 2    50   Output ~ 0
~SER~
Text GLabel 6950 6450 0    50   Input ~ 0
~SER~
$Comp
L power:+5V #PWR0179
U 1 1 6063F357
P 6600 6350
F 0 "#PWR0179" H 6600 6200 50  0001 C CNN
F 1 "+5V" H 6615 6523 50  0000 C CNN
F 2 "" H 6600 6350 50  0001 C CNN
F 3 "" H 6600 6350 50  0001 C CNN
	1    6600 6350
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R15
U 1 1 6064A578
P 6800 6350
F 0 "R15" V 6604 6350 50  0000 C CNN
F 1 "10k" V 6695 6350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 6800 6350 50  0001 C CNN
F 3 "~" H 6800 6350 50  0001 C CNN
	1    6800 6350
	0    1    1    0   
$EndComp
Wire Wire Line
	6950 6350 6900 6350
Wire Wire Line
	6700 6350 6600 6350
Text GLabel 12600 1600 0    50   Input ~ 0
~IRQ0~
Wire Wire Line
	12850 1600 12600 1600
Text GLabel 12600 2200 0    50   Input ~ 0
~SER_IRQ~
Wire Wire Line
	14050 2200 13850 2200
Text GLabel 15200 1900 2    50   Output ~ 0
~SLOW~
$Comp
L Device:D D8
U 1 1 606E91FA
P 15050 1900
F 0 "D8" H 15050 1635 50  0000 C CNN
F 1 "1N4148" H 15050 1726 50  0000 C CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 15050 1900 50  0001 C CNN
F 3 "~" H 15050 1900 50  0001 C CNN
	1    15050 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	14200 1900 14900 1900
Wire Wire Line
	8500 6600 8350 6600
Wire Wire Line
	8350 6600 8350 6650
Wire Wire Line
	8350 6650 8150 6650
Wire Wire Line
	8500 6700 8300 6700
Wire Wire Line
	8300 6700 8300 6750
Wire Wire Line
	8300 6750 8150 6750
Wire Wire Line
	8200 6500 8500 6500
Text GLabel 6950 6650 0    50   Input ~ 0
A0
Text GLabel 6950 6750 0    50   Input ~ 0
A1
Text GLabel 6950 5850 0    50   Input ~ 0
~RESET~
Wire Wire Line
	8150 7350 8200 7350
Wire Wire Line
	8200 6500 8200 7150
Wire Wire Line
	8250 7550 8150 7550
$Comp
L power:GND #PWR0180
U 1 1 60485CAD
P 8550 7550
F 0 "#PWR0180" H 8550 7300 50  0001 C CNN
F 1 "GND" H 8555 7377 50  0000 C CNN
F 2 "" H 8550 7550 50  0001 C CNN
F 3 "" H 8550 7550 50  0001 C CNN
	1    8550 7550
	1    0    0    -1  
$EndComp
Wire Wire Line
	8500 6900 8400 6900
Wire Wire Line
	8400 6900 8400 6950
Wire Wire Line
	8150 6950 8400 6950
$Comp
L power:GND #PWR0181
U 1 1 604BC9B4
P 8500 7000
F 0 "#PWR0181" H 8500 6750 50  0001 C CNN
F 1 "GND" H 8505 6827 50  0000 C CNN
F 2 "" H 8500 7000 50  0001 C CNN
F 3 "" H 8500 7000 50  0001 C CNN
	1    8500 7000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0182
U 1 1 604CA133
P 8400 6800
F 0 "#PWR0182" H 8400 6650 50  0001 C CNN
F 1 "+5V" H 8415 6973 50  0000 C CNN
F 2 "" H 8400 6800 50  0001 C CNN
F 3 "" H 8400 6800 50  0001 C CNN
	1    8400 6800
	1    0    0    -1  
$EndComp
Wire Wire Line
	8500 6800 8400 6800
Text Label 8150 6650 0    50   ~ 0
TX
Text Label 8150 6750 0    50   ~ 0
RX
Text Label 8150 6950 0    50   ~ 0
~RTS~
Text Label 8150 7050 0    50   ~ 0
~CTS~
Text Label 8250 6500 0    50   ~ 0
~DSR~
Text GLabel 2800 3850 2    50   BiDi ~ 0
~SLOT0~
Text GLabel 6950 9700 2    50   Output ~ 0
~SLOT0~
Wire Wire Line
	8250 7050 8150 7050
Text GLabel 5400 5800 0    50   BiDi ~ 0
~IRQ0~
$Comp
L Device:R_Small R21
U 1 1 605F9E62
P 5500 5800
F 0 "R21" V 5304 5800 50  0000 C CNN
F 1 "1k" V 5395 5800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 5500 5800 50  0001 C CNN
F 3 "~" H 5500 5800 50  0001 C CNN
	1    5500 5800
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0185
U 1 1 605F9E68
P 5600 5800
F 0 "#PWR0185" H 5600 5650 50  0001 C CNN
F 1 "+5V" H 5615 5973 50  0000 C CNN
F 2 "" H 5600 5800 50  0001 C CNN
F 3 "" H 5600 5800 50  0001 C CNN
	1    5600 5800
	0    1    1    0   
$EndComp
Text GLabel 5400 6050 0    50   BiDi ~ 0
~IRQ5~
$Comp
L Device:R_Small R22
U 1 1 60607564
P 5500 6050
F 0 "R22" V 5304 6050 50  0000 C CNN
F 1 "1k" V 5395 6050 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 5500 6050 50  0001 C CNN
F 3 "~" H 5500 6050 50  0001 C CNN
	1    5500 6050
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0186
U 1 1 6060756A
P 5600 6050
F 0 "#PWR0186" H 5600 5900 50  0001 C CNN
F 1 "+5V" H 5615 6223 50  0000 C CNN
F 2 "" H 5600 6050 50  0001 C CNN
F 3 "" H 5600 6050 50  0001 C CNN
	1    5600 6050
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R23
U 1 1 6051C1DC
P 11500 6200
F 0 "R23" V 11304 6200 50  0000 C CNN
F 1 "10k" V 11395 6200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 11500 6200 50  0001 C CNN
F 3 "~" H 11500 6200 50  0001 C CNN
	1    11500 6200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	11600 6200 12000 6200
Text GLabel 6650 5950 0    50   Input ~ 0
CLK
Wire Wire Line
	6950 5950 6650 5950
Text GLabel 14050 2000 2    50   Input ~ 0
~SIRQ~
Wire Wire Line
	14050 2000 13850 2000
Text GLabel 6550 6150 0    50   Output ~ 0
~SIRQ~
Wire Wire Line
	6950 6150 6550 6150
$Comp
L power:GND #PWR0188
U 1 1 617E26F1
P 8600 6050
F 0 "#PWR0188" H 8600 5800 50  0001 C CNN
F 1 "GND" H 8605 5877 50  0000 C CNN
F 2 "" H 8600 6050 50  0001 C CNN
F 3 "" H 8600 6050 50  0001 C CNN
	1    8600 6050
	1    0    0    -1  
$EndComp
$Comp
L Oscillator:CXO_DIP8 X3
U 1 1 617E26F7
P 8600 5750
F 0 "X3" H 8944 5796 50  0000 L CNN
F 1 "1.8432MHz" H 8944 5705 50  0000 L CNN
F 2 "Oscillator:Oscillator_DIP-8" H 9050 5400 50  0001 C CNN
F 3 "http://cdn-reichelt.de/documents/datenblatt/B400/OSZI.pdf" H 8500 5750 50  0001 C CNN
	1    8600 5750
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0189
U 1 1 617F2EFA
P 8600 5150
F 0 "#PWR0189" H 8600 5000 50  0001 C CNN
F 1 "+5V" H 8615 5323 50  0000 C CNN
F 2 "" H 8600 5150 50  0001 C CNN
F 3 "" H 8600 5150 50  0001 C CNN
	1    8600 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	8600 5450 8600 5200
$Comp
L Device:C_Small C17
U 1 1 617F2F01
P 8800 5200
F 0 "C17" V 8571 5200 50  0000 C CNN
F 1 "10n" V 8662 5200 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 8800 5200 50  0001 C CNN
F 3 "~" H 8800 5200 50  0001 C CNN
	1    8800 5200
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0190
U 1 1 617F2F07
P 9050 5200
F 0 "#PWR0190" H 9050 4950 50  0001 C CNN
F 1 "GND" H 9055 5027 50  0000 C CNN
F 2 "" H 9050 5200 50  0001 C CNN
F 3 "" H 9050 5200 50  0001 C CNN
	1    9050 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 5200 8900 5200
Wire Wire Line
	8700 5200 8600 5200
Connection ~ 8600 5200
Wire Wire Line
	8600 5200 8600 5150
Wire Wire Line
	8900 5750 8900 6350
Wire Wire Line
	8900 6350 8300 6350
Wire Wire Line
	8300 6350 8300 5850
Wire Wire Line
	8300 5850 8150 5850
$Comp
L Device:R_Small R25
U 1 1 6185D2C3
P 8350 7550
F 0 "R25" V 8154 7550 50  0000 C CNN
F 1 "10k" V 8245 7550 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 8350 7550 50  0001 C CNN
F 3 "~" H 8350 7550 50  0001 C CNN
	1    8350 7550
	0    1    1    0   
$EndComp
Wire Wire Line
	8550 7550 8450 7550
$Comp
L Device:R_Small R24
U 1 1 618ACC5D
P 8350 7300
F 0 "R24" V 8154 7300 50  0000 C CNN
F 1 "10k" V 8245 7300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 8350 7300 50  0001 C CNN
F 3 "~" H 8350 7300 50  0001 C CNN
	1    8350 7300
	0    1    1    0   
$EndComp
Wire Wire Line
	8250 7050 8250 7300
Wire Wire Line
	8450 7300 8550 7300
Wire Wire Line
	8550 7300 8550 7550
Connection ~ 8550 7550
$Comp
L Device:R_Small R26
U 1 1 618DE343
P 8400 7150
F 0 "R26" V 8204 7150 50  0000 C CNN
F 1 "10k" V 8295 7150 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 8400 7150 50  0001 C CNN
F 3 "~" H 8400 7150 50  0001 C CNN
	1    8400 7150
	0    1    1    0   
$EndComp
Wire Wire Line
	8300 7150 8200 7150
Connection ~ 8200 7150
Wire Wire Line
	8200 7150 8200 7350
Wire Wire Line
	8500 7150 8550 7150
Wire Wire Line
	8550 7150 8550 7300
Connection ~ 8550 7300
$Comp
L Connector_Generic:Conn_01x14 J4
U 1 1 61BF6BF7
P 11900 7500
F 0 "J4" H 11980 7492 50  0000 L CNN
F 1 "Conn_01x14" H 11980 7401 50  0000 L CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x14_P2.54mm_Vertical" H 11900 7500 50  0001 C CNN
F 3 "~" H 11900 7500 50  0001 C CNN
	1    11900 7500
	1    0    0    -1  
$EndComp
Text GLabel 11700 8200 0    50   BiDi ~ 0
D3
Text GLabel 11700 8100 0    50   BiDi ~ 0
D4
Text GLabel 11700 8000 0    50   BiDi ~ 0
D5
Text GLabel 11700 7900 0    50   BiDi ~ 0
D6
Text GLabel 11700 7800 0    50   BiDi ~ 0
D7
Text GLabel 11700 7700 0    50   Input ~ 0
~RAM_CS~
Text GLabel 11700 7600 0    50   Input ~ 0
A10
$Comp
L power:GND #PWR0187
U 1 1 61C294C6
P 11250 7500
F 0 "#PWR0187" H 11250 7250 50  0001 C CNN
F 1 "GND" H 11255 7327 50  0000 C CNN
F 2 "" H 11250 7500 50  0001 C CNN
F 3 "" H 11250 7500 50  0001 C CNN
	1    11250 7500
	1    0    0    -1  
$EndComp
Wire Wire Line
	11700 7500 11250 7500
Text GLabel 11700 7400 0    50   Input ~ 0
A11
Text GLabel 11700 7200 0    50   Input ~ 0
A8
Text GLabel 11700 7300 0    50   Input ~ 0
A9
Text GLabel 11700 7100 0    50   Input ~ 0
A13
Text GLabel 11700 7000 0    50   Input ~ 0
~RAMW~
Wire Wire Line
	11700 6900 11200 6900
Wire Wire Line
	11200 6900 11200 5900
Wire Wire Line
	11200 5900 10050 5900
Wire Wire Line
	10050 5900 10050 5850
Wire Wire Line
	10050 5850 9900 5850
Connection ~ 9900 5850
$Comp
L power:+5V #PWR0191
U 1 1 61DD3E08
P 13750 6350
F 0 "#PWR0191" H 13750 6200 50  0001 C CNN
F 1 "+5V" H 13765 6523 50  0000 C CNN
F 2 "" H 13750 6350 50  0001 C CNN
F 3 "" H 13750 6350 50  0001 C CNN
	1    13750 6350
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R27
U 1 1 61DD3E0E
P 13850 6350
F 0 "R27" V 13654 6350 50  0000 C CNN
F 1 "10k" V 13745 6350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 13850 6350 50  0001 C CNN
F 3 "~" H 13850 6350 50  0001 C CNN
	1    13850 6350
	0    -1   -1   0   
$EndComp
Wire Wire Line
	14150 6350 13950 6350
Wire Wire Line
	9900 9750 10250 9750
Wire Wire Line
	9750 9750 9900 9750
Connection ~ 9900 9750
Wire Wire Line
	9900 9550 9900 9750
Connection ~ 9750 9650
Wire Wire Line
	9750 9450 9750 9650
Wire Wire Line
	9900 9200 9900 9350
$Comp
L power:+5V #PWR0161
U 1 1 6043B482
P 9900 9200
F 0 "#PWR0161" H 9900 9050 50  0001 C CNN
F 1 "+5V" H 9915 9373 50  0000 C CNN
F 2 "" H 9900 9200 50  0001 C CNN
F 3 "" H 9900 9200 50  0001 C CNN
	1    9900 9200
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R18
U 1 1 6043B47C
P 9900 9450
F 0 "R18" V 9704 9450 50  0000 C CNN
F 1 "1k" V 9795 9450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 9900 9450 50  0001 C CNN
F 3 "~" H 9900 9450 50  0001 C CNN
	1    9900 9450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 9100 9750 9250
$Comp
L power:+5V #PWR0160
U 1 1 60416782
P 9750 9100
F 0 "#PWR0160" H 9750 8950 50  0001 C CNN
F 1 "+5V" H 9765 9273 50  0000 C CNN
F 2 "" H 9750 9100 50  0001 C CNN
F 3 "" H 9750 9100 50  0001 C CNN
	1    9750 9100
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R17
U 1 1 6040FBAF
P 9750 9350
F 0 "R17" V 9554 9350 50  0000 C CNN
F 1 "1k" V 9645 9350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 9750 9350 50  0001 C CNN
F 3 "~" H 9750 9350 50  0001 C CNN
	1    9750 9350
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C18
U 1 1 617BF140
P 5500 8200
F 0 "C18" H 5592 8246 50  0000 L CNN
F 1 "10n" H 5592 8155 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5500 8200 50  0001 C CNN
F 3 "~" H 5500 8200 50  0001 C CNN
	1    5500 8200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 8150 5450 8150
Wire Wire Line
	5450 8150 5450 8100
Wire Wire Line
	5450 8100 5500 8100
Connection ~ 5350 8150
Wire Wire Line
	5500 8300 5450 8300
Wire Wire Line
	5450 8300 5450 8250
Wire Wire Line
	5450 8250 5350 8250
Connection ~ 5350 8250
$Comp
L DS1813-10+:DS1813-10+ IC2
U 1 1 618021F5
P 8850 1300
F 0 "IC2" H 9578 1246 50  0000 L CNN
F 1 "DS1813-10+" H 9578 1155 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92L_Inline" H 9600 1400 50  0001 L CNN
F 3 "" H 9600 1300 50  0001 L CNN
F 4 "TO92 uP supervisor chip,DS1813-10 4.35V" H 9600 1200 50  0001 L CNN "Description"
F 5 "5" H 9600 1100 50  0001 L CNN "Height"
F 6 "" H 9600 1000 50  0001 L CNN "Mouser Part Number"
F 7 "" H 9600 900 50  0001 L CNN "Mouser Price/Stock"
F 8 "Maxim Integrated" H 9600 800 50  0001 L CNN "Manufacturer_Name"
F 9 "DS1813-10+" H 9600 700 50  0001 L CNN "Manufacturer_Part_Number"
	1    8850 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 1400 8700 1400
Wire Wire Line
	8700 1400 8700 1450
Wire Wire Line
	8700 1450 8550 1450
Wire Wire Line
	8450 1100 8850 1100
Wire Wire Line
	8850 1300 8850 1100
Connection ~ 8850 1100
Wire Wire Line
	8850 1100 9950 1100
$Comp
L power:GND #PWR0112
U 1 1 618B82E0
P 4800 1350
F 0 "#PWR0112" H 4800 1100 50  0001 C CNN
F 1 "GND" H 4805 1177 50  0000 C CNN
F 2 "" H 4800 1350 50  0001 C CNN
F 3 "" H 4800 1350 50  0001 C CNN
	1    4800 1350
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0136
U 1 1 618B82E6
P 4500 1300
F 0 "#PWR0136" H 4500 1150 50  0001 C CNN
F 1 "+5V" H 4515 1473 50  0000 C CNN
F 2 "" H 4500 1300 50  0001 C CNN
F 3 "" H 4500 1300 50  0001 C CNN
	1    4500 1300
	1    0    0    -1  
$EndComp
$Comp
L DS1813-10+:DS1813-10+ IC1
U 1 1 618B82F2
P 4800 1150
F 0 "IC1" H 5528 1096 50  0000 L CNN
F 1 "DS1813-10+" H 5528 1005 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92L_Inline" H 5550 1250 50  0001 L CNN
F 3 "" H 5550 1150 50  0001 L CNN
F 4 "TO92 uP supervisor chip,DS1813-10 4.35V" H 5550 1050 50  0001 L CNN "Description"
F 5 "5" H 5550 950 50  0001 L CNN "Height"
F 6 "" H 5550 850 50  0001 L CNN "Mouser Part Number"
F 7 "" H 5550 750 50  0001 L CNN "Mouser Price/Stock"
F 8 "Maxim Integrated" H 5550 650 50  0001 L CNN "Manufacturer_Name"
F 9 "DS1813-10+" H 5550 550 50  0001 L CNN "Manufacturer_Part_Number"
	1    4800 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4800 1250 4650 1250
Wire Wire Line
	4650 1250 4650 1300
Wire Wire Line
	4650 1300 4500 1300
Wire Wire Line
	5700 850  4900 850 
Wire Wire Line
	4800 1150 4800 950 
Wire Wire Line
	4800 950  4900 950 
Wire Wire Line
	4900 950  4900 850 
Connection ~ 4900 850 
Wire Wire Line
	4900 850  4750 850 
$EndSCHEMATC
