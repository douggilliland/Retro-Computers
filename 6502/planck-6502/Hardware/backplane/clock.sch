EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 2
Title "Planck backplane"
Date "2021-01-10"
Rev "0.1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Oscillator:CXO_DIP8 X?
U 1 1 60045EF8
P 5350 4350
AR Path="/60045EF8" Ref="X?"  Part="1" 
AR Path="/60021B7B/60045EF8" Ref="X?"  Part="1" 
F 0 "X?" H 5694 4396 50  0000 L CNN
F 1 "24MHz" H 5694 4305 50  0000 L CNN
F 2 "Oscillator:Oscillator_DIP-8" H 5800 4000 50  0001 C CNN
F 3 "http://cdn-reichelt.de/documents/datenblatt/B400/OSZI.pdf" H 5250 4350 50  0001 C CNN
	1    5350 4350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60045EFE
P 5350 4650
AR Path="/60045EFE" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045EFE" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 5350 4400 50  0001 C CNN
F 1 "GND" H 5355 4477 50  0000 C CNN
F 2 "" H 5350 4650 50  0001 C CNN
F 3 "" H 5350 4650 50  0001 C CNN
	1    5350 4650
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 60045F04
P 5350 3600
AR Path="/60045F04" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F04" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 5350 3450 50  0001 C CNN
F 1 "+5V" H 5365 3773 50  0000 C CNN
F 2 "" H 5350 3600 50  0001 C CNN
F 3 "" H 5350 3600 50  0001 C CNN
	1    5350 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4050 5350 3750
$Comp
L Device:C_Small C?
U 1 1 60045F0B
P 5600 3750
AR Path="/60045F0B" Ref="C?"  Part="1" 
AR Path="/60021B7B/60045F0B" Ref="C?"  Part="1" 
F 0 "C?" H 5692 3796 50  0000 L CNN
F 1 "C_Small" H 5692 3705 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.42x1.75mm_HandSolder" H 5600 3750 50  0001 C CNN
F 3 "~" H 5600 3750 50  0001 C CNN
	1    5600 3750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5500 3750 5350 3750
Connection ~ 5350 3750
Wire Wire Line
	5350 3750 5350 3600
$Comp
L power:GND #PWR?
U 1 1 60045F14
P 5700 3750
AR Path="/60045F14" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F14" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 5700 3500 50  0001 C CNN
F 1 "GND" H 5705 3577 50  0000 C CNN
F 2 "" H 5700 3750 50  0001 C CNN
F 3 "" H 5700 3750 50  0001 C CNN
	1    5700 3750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS161 U?
U 1 1 60045F1A
P 6950 4400
AR Path="/60045F1A" Ref="U?"  Part="1" 
AR Path="/60021B7B/60045F1A" Ref="U?"  Part="1" 
F 0 "U?" H 6950 5381 50  0000 C CNN
F 1 "74AC161" H 6950 5290 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 6950 4400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS163" H 6950 4400 50  0001 C CNN
	1    6950 4400
	1    0    0    -1  
$EndComp
Text GLabel 6450 4900 0    50   Input ~ 0
~RESET~
Wire Wire Line
	5650 4350 5700 4350
Wire Wire Line
	5700 4350 5700 4700
Wire Wire Line
	5700 4700 6450 4700
$Comp
L power:GND #PWR?
U 1 1 60045F24
P 6950 5200
AR Path="/60045F24" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F24" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 6950 4950 50  0001 C CNN
F 1 "GND" H 6955 5027 50  0000 C CNN
F 2 "" H 6950 5200 50  0001 C CNN
F 3 "" H 6950 5200 50  0001 C CNN
	1    6950 5200
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 60045F2A
P 6950 3150
AR Path="/60045F2A" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F2A" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 6950 3000 50  0001 C CNN
F 1 "+5V" H 6965 3323 50  0000 C CNN
F 2 "" H 6950 3150 50  0001 C CNN
F 3 "" H 6950 3150 50  0001 C CNN
	1    6950 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6950 3600 6950 3300
$Comp
L Device:C_Small C?
U 1 1 60045F31
P 7200 3300
AR Path="/60045F31" Ref="C?"  Part="1" 
AR Path="/60021B7B/60045F31" Ref="C?"  Part="1" 
F 0 "C?" H 7292 3346 50  0000 L CNN
F 1 "C_Small" H 7292 3255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.42x1.75mm_HandSolder" H 7200 3300 50  0001 C CNN
F 3 "~" H 7200 3300 50  0001 C CNN
	1    7200 3300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7100 3300 6950 3300
Connection ~ 6950 3300
Wire Wire Line
	6950 3300 6950 3150
$Comp
L power:GND #PWR?
U 1 1 60045F3A
P 7300 3300
AR Path="/60045F3A" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F3A" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 7300 3050 50  0001 C CNN
F 1 "GND" H 7305 3127 50  0000 C CNN
F 2 "" H 7300 3300 50  0001 C CNN
F 3 "" H 7300 3300 50  0001 C CNN
	1    7300 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 4200 7600 4200
Wire Wire Line
	7600 2850 6200 2850
Wire Wire Line
	6200 2850 6200 4400
Wire Wire Line
	6200 4400 6450 4400
Wire Wire Line
	7600 2850 7600 4200
Wire Wire Line
	6450 4600 6450 4500
$Comp
L power:+5V #PWR?
U 1 1 60045F46
P 6200 4600
AR Path="/60045F46" Ref="#PWR?"  Part="1" 
AR Path="/60021B7B/60045F46" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 6200 4450 50  0001 C CNN
F 1 "+5V" H 6215 4773 50  0000 C CNN
F 2 "" H 6200 4600 50  0001 C CNN
F 3 "" H 6200 4600 50  0001 C CNN
	1    6200 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 4600 6200 4600
Connection ~ 6450 4600
Text GLabel 7700 3900 2    50   Output ~ 0
CLK_12M
Wire Wire Line
	7700 3900 7450 3900
Text GLabel 7750 4100 2    50   Output ~ 0
CLK
Text Label 5800 4700 0    50   ~ 0
CLK_24M
Wire Wire Line
	7450 4100 7750 4100
Wire Wire Line
	6450 3300 6950 3300
Wire Wire Line
	6450 3900 6450 3300
Wire Wire Line
	6450 4200 6350 4200
Wire Wire Line
	6450 4100 6250 4100
Text GLabel 4250 3600 0    50   Input ~ 0
~SLOW0~
Text GLabel 4250 3700 0    50   Input ~ 0
~SLOW1~
Text GLabel 4250 3800 0    50   Input ~ 0
~SLOW2~
Text GLabel 4250 4100 0    50   Input ~ 0
~SLOW3~
Text GLabel 4250 4200 0    50   Input ~ 0
~SLOW4~
Text GLabel 4250 4300 0    50   Input ~ 0
~SLOW5~
Wire Wire Line
	6250 3050 6250 4100
Wire Wire Line
	6350 4200 6350 3900
Wire Wire Line
	6350 3900 6450 3900
Connection ~ 6450 3900
Wire Wire Line
	6450 4000 6450 4100
Connection ~ 6450 4100
$Comp
L 74xx:74LS11 U?
U 1 1 60045F63
P 4550 3700
AR Path="/60045F63" Ref="U?"  Part="1" 
AR Path="/60021B7B/60045F63" Ref="U?"  Part="1" 
F 0 "U?" H 4550 4025 50  0000 C CNN
F 1 "74AC11" H 4550 3934 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4550 3700 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 4550 3700 50  0001 C CNN
	1    4550 3700
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS11 U?
U 2 1 60045F69
P 4550 4200
AR Path="/60045F69" Ref="U?"  Part="2" 
AR Path="/60021B7B/60045F69" Ref="U?"  Part="2" 
F 0 "U?" H 4550 4525 50  0000 C CNN
F 1 "74AC11" H 4550 4434 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4550 4200 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 4550 4200 50  0001 C CNN
	2    4550 4200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS11 U?
U 3 1 60045F6F
P 5250 3050
AR Path="/60045F6F" Ref="U?"  Part="3" 
AR Path="/60021B7B/60045F6F" Ref="U?"  Part="3" 
F 0 "U?" H 5250 3375 50  0000 C CNN
F 1 "74AC11" H 5250 3284 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 5250 3050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 5250 3050 50  0001 C CNN
	3    5250 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 4200 4900 4200
Wire Wire Line
	5550 3050 6250 3050
Wire Wire Line
	4850 3700 4850 3150
Wire Wire Line
	4850 3150 4950 3150
Wire Wire Line
	4900 4200 4900 3050
Wire Wire Line
	4900 2950 4950 2950
Wire Wire Line
	4950 3050 4900 3050
Connection ~ 4900 3050
Wire Wire Line
	4900 3050 4900 2950
$EndSCHEMATC
