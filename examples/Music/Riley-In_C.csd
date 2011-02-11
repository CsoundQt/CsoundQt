;This file is released with CC-by-sa license. http //creativecommons.org

;Created by Stefano Valli - www.triceratupuz.altervista.org - email vallste at libero.it
;www.triceratupuz.altervista.org

;For Csound 5.00 and above
;Ftables inclusion and testing by Joachim Heintz - www.joachimheintz.de - email jh at joachimheintz.de

;Table reading optimization to 1 instrument by Andres Cabrera

;Modified for QuteCsound by Rene, January 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 812


;Notes on modifications from original csd
;	Removed record performance because included in QuteCsound
;	Use of macro

;	This example use the ascii keyboard to control the Players. It uses an always on instrument (99),
;	which listens to key events to turns on and off Players and change Patterns.
;	IT IS IMPORTANT TO GIVE FOCUS TO THE MAIN CSOUND OUTPUT CONSOLE (GIVING FOCUS TO THE WIDGETS WINDOW WILL NOT WORK!)

;	Tables giASCII_Player and giASCII_Next are for a AZERTY keyboard


;My flags on Ubuntu -dm0 -odac -b256 -B1024 -+rtaudio=alsa -+rtmidi=null --old-parser
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr		= 44100
ksmps	= 1024
nchnls	= 2

		zakinit	20, 1


;tables that store ASCII keyboard values for sensekey
;Start/Stop Player keys                              a    z    e    r    t    y    u    i    o
giASCII_Player			ftgen	10, 0, 16, -2, 0, 097, 122, 101, 114, 116, 121, 117, 105, 111 
;Next Pattern keys			                       q    s    d    f    g    h    j    k    l				
giASCII_Next			ftgen	20, 0, 16, -2, 0, 113, 115, 100, 102, 103, 104, 106, 107, 108 

#define SPACE	#32#


;---------------------INITIALIZATION-----------------
gisin	ftgen	1, 0, 16384, 10, 1											; sine wave
gisqu	ftgen	2, 0, 16384, 10, 1, 0, .333, 0, .25, 0, .14285					; square wave
gitri	ftgen	3, 0, 16384, 10, 1, 0, .11111, 0, .04, 0, .0204					; triangle wave
gisaw	ftgen	4, 0, 16384, 10, 1, .5, .3333, .25, .2, .1666, .142857, .125, .111	; sawtooth

;table that store pattern length
gipattdur	ftgen	100, 0, 64, -2, 11, 22, 33, 44, 55, 66, 77, 88, 99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;pattern tables
;table dimension must be equal or higher of the table recorded numbers
;p6=legato 1 or 0
;middle C = 261.626 C4 Midi60 8.00
itab01 ftgen 101, 0, -54, -2, \
	0,	0,	.1,	30000,	8.00,\
	0,	.1,	.9,	30000,	8.04,\
	0,	1,	.1,	30000,	8.00,\
	0,	1.1,	.9,	30000,	8.04,\
	0,	2,	.1,	30000,	8.00,\
	0,	2.1,	.9,	30000,	8.04,\
	0,	3,	.1,	30000,	8.00,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab02 ftgen 102, 0, -42, -2, \
	0,	0,	0.1,	30000,	8.00,\
	0,	0.1,	0.4,	30000,	8.04,\
	0,	0.5,	0.5,	30000,	8.05,\
	0,	1,	1,	30000,	8.04,\
	0,	2,	0.1,	30000,	8.00,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab03 ftgen 103, 0, -36, -2, \
	0,	0.5,	0.5,	30000,	8.04,\
	0,	1,	0.5,	30000,	8.05,\
	0,	1.5,	0.5,	30000,	8.04,\
	0,	2,	0.5,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab04 ftgen 104, 0, -36, -2, \
	0,	0.5,	0.5,	30000,	8.04,\
	0,	1,	0.5,	30000,	8.05,\
	0,	1.5,	0.5,	30000,	8.07,\
	0,	2,	0.5,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab05 ftgen 105, 0, -36, -2, \
	0,	0,	0.5,	30000,	8.04,\
	0,	0.5,	0.5,	30000,	8.05,\
	0,	1,	0.5,	30000,	8.07,\
	0,	2,	0.5,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab06 ftgen 106, 0, -24, -2, \
	0,	0,	8,	30000,	9.00,\
	0,	8,	8,	30000,	9.00,\
	-1,	8,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab07 ftgen 107, 0, -30, -2, \
	0,	3.5,		0.25,	30000,	8.00,\
	0,	3.75,	0.25,	30000,	8.00,\
	0,	4,		0.50,	30000,	8.00,\
	-1,	9,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab08 ftgen 108, 0, -30, -2, \
	0,	0,	6.00,	30000,	8.07,\
	0,	6,	8.00,	30000,	8.05,\
	0,	14,	6.00,	30000,	8.07,\
	-1,	14,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab09 ftgen 109, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	4,	0.25,	30000,	8.11,\
	-1,	4,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab10 ftgen 110, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab11 ftgen 111, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.05,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab12 ftgen 112, 0, -42, -2, \
	0,	0,	0.50,	30000,	8.05,\
	0,	0.5,	0.50,	30000,	8.07,\
	0,	1,	4.00,	30000,	8.11,\
	0,	5,	1.00,	30000,	9.00,\
	0,	6,	0.50,	30000,	8.05,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab13 ftgen 113, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,0.75,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.07,\
	0,	1.25,0.25,	30000,	8.05,\
	0,	1.5,	0.50,	30000,	8.07,\
	0,	2.75,3.25,	30000,	8.07,\
	0,	6,	0.25,	30000,	8.11,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab14 ftgen 114, 0, -42, -2, \
	0,	0,	4.00,	30000,	9.00,\
	0,	4,	4.00,	30000,	8.11,\
	0,	8,	4.00,	30000,	8.07,\
	0,	12,	4.00,	30000,	8.06,\
	0,	16,	4.00,	30000,	9.00,\
	-1,	16,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab15 ftgen 115, 0, -24, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	4,	0.25,	30000,	8.07,\
	-1,	4,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab16 ftgen 116, 0, -42, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,0.25,	30000,	8.11,\
	0,	0.5,	0.25,	30000,	9.00,\
	0,	0.75,0.25,	30000,	8.11,\
	0,	1,	0.25,	30000,	8.07,\
	-1,	1,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab17 ftgen 117, 0, -48, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,0.25,	30000,	9.00,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,0.25,	30000,	9.00,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.5,	0.25,	30000,	8.11,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab18 ftgen 118, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	8.04,\
	0,	1.75,0.25,	30000,	8.04,\
	0,	2,	0.25,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab19 ftgen 119, 0, -30, -2, \
	0,	0,	1.50,	0,	8.04,\
	0,	1.5,	1.50,30000,	9.07,\
	0,	3,	1.50,	0,	8.04,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab20 ftgen 120, 0, -78, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	7.07,\
	0,	1.75,0.25,	30000,	8.04,\
	0,	2,	1.00,	30000,	8.06,\
	0,	3,	1.00,	30000,	8.04,\
	0,	4,	1.00,	30000,	8.06,\
	0,	5,	1.00,	30000,	8.04,\
	0,	6,	0.25,	30000,	8.04,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab21 ftgen 121, 0, -24, -2, \
	0,	0,	3.00,	30000,	8.06,\
	0,	3,	3.00,	30000,	8.06,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab22 ftgen 122, 0, -72, -2, \
	0,	0,	1.50,	30000,	8.04,\
	0,	1.5,	1.50,	30000,	8.04,\
	0,	3,	1.50,	30000,	8.04,\
	0,	4.5,	1.50,	30000,	8.04,\
	0,	6,	1.50,	30000,	8.04,\
	0,	7.5,	1.50,	30000,	8.06,\
	0,	9,	1.50,	30000,	8.07,\
	0,	10.5,1.50,	30000,	8.09,\
	0,	12,	0.50,	30000,	8.11,\
	0,	12.5,1.50,	30000,	8.04,\
	-1,	12.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab23 ftgen 123, 0, -72, -2, \
	0,	0,	0.50,	30000,	8.04,\
	0,	0.5,	1.50,	30000,	8.06,\
	0,	2,	1.50,	30000,	8.06,\
	0,	3.5,	1.50,	30000,	8.06,\
	0,	5,	1.50,	30000,	8.06,\
	0,	6.5,	1.50,	30000,	8.06,\
	0,	8,	1.50,	30000,	8.07,\
	0,	9.5,	1.50,	30000,	8.09,\
	0,	11,	1.00,	30000,	8.11,\
	0,	12,	0.50,	30000,	8.04,\
	-1,	12,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab24 ftgen 124, 0, -72, -2, \
	0,	0,	0.50,	30000,	8.04,\
	0,	0.5,	0.50,	30000,	8.06,\
	0,	1,	1.50,	30000,	8.07,\
	0,	2.5,	1.50,	30000,	8.07,\
	0,	4,	1.50,	30000,	8.07,\
	0,	5.5,	1.50,	30000,	8.07,\
	0,	7,	1.50,	30000,	8.07,\
	0,	8.5,	1.50,	30000,	8.09,\
	0,	10,	1.00,	30000,	8.11,\
	0,	11,	0.50,	30000,	8.04,\
	-1,	11,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab25 ftgen 125, 0, -72, -2, \
	0,	0,	0.50,	30000,	8.04,\
	0,	0.5,	0.50,	30000,	8.06,\
	0,	1,	0.50,	30000,	8.07,\
	0,	1.5,	1.50,	30000,	8.09,\
	0,	3,	1.50,	30000,	8.09,\
	0,	4.5,	1.50,	30000,	8.09,\
	0,	6,	1.50,	30000,	8.09,\
	0,	7.5,	1.50,	30000,	8.09,\
	0,	9,	1.50,	30000,	8.11,\
	0,	10.5,0.50,	30000,	8.04,\
	-1,	10.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab26 ftgen 126, 0, -72, -2, \
	0,	0,	0.50,	30000,	8.04,\
	0,	0.5,	0.50,	30000,	8.06,\
	0,	1,	0.50,	30000,	8.07,\
	0,	1.5,	0.50,	30000,	8.09,\
	0,	2,	1.50,	30000,	8.11,\
	0,	3.5,	1.50,	30000,	8.11,\
	0,	5,	1.50,	30000,	8.11,\
	0,	6.5,	1.50,	30000,	8.11,\
	0,	8,	1.50,	30000,	8.11,\
	0,	9.5,	0.50,	30000,	8.04,\
	-1,	9.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab27 ftgen 127, 0, -84, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,0.25,	30000,	8.06,\
	0,	1,	0.50,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.04,\
	0,	1.75,0.25,	30000,	8.07,\
	0,	2,	0.25,	30000,	8.06,\
	0,	2.25,0.25,	30000,	8.04,\
	0,	2.5,	0.25,	30000,	8.06,\
	0,	2.75,0.25,	30000,	8.04,\
	0,	3,	0.25,	30000,	8.04,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab28 ftgen 128, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	8.04,\
	0,	1.75,0.25,	30000,	8.04,\
	0,	2,	0.25,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab29 ftgen 129, 0, -36, -2, \
	0,	0,	3.00,	30000,	8.04,\
	0,	3,	3.00,	30000,	8.07,\
	0,	6,	3.00,	30000,	9.00,\
	0,	9,	3.00,	30000,	8.04,\
	-1,	9,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab30 ftgen 130, 0, -24, -2, \
	0,	0,	6.00,	30000,	9.00,\
	0,	6,	6.00,	30000,	9.00,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab31 ftgen 131, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,0.25,	30000,	8.05,\
	0,	0.5,	0.25,	30000,	8.07,\
	0,	0.75,0.25,	30000,	8.11,\
	0,	1,	0.25,	30000,	8.07,\
	0,	1.25,0.25,	30000,	8.11,\
	0,	1.5,	0.25,	30000,	8.07,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab32 ftgen 132, 0, -60, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	0,	0.75,0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,3.25,	30000,	8.05,\
	0,	4.5,	1.50,	30000,	8.07,\
	0,	6,	0.25,	30000,	8.05,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab33 ftgen 133, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,0.25,	30000,	8.05,\
	0,	1,	0.25,	30000,	8.07,\
	-1,	1,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab34 ftgen 134, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,0.25,	30000,	8.05,\
	0,	0.5,	0.25,	30000,	8.07,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab35 ftgen 135, 0, -150, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.11,\
	0,	1.75,0.25,	30000,	8.07,\
	0,	2,	0.25,	30000,	8.11,\
	0,	2.25,0.25,	30000,	8.07,\
	0,	6,	1.00,	30000,	8.10,\
	0,	7,	3.00,	30000,	9.07,\
	0,	10,	0.50,	30000,	9.09,\
	0,	10.5,1.00,	30000,	9.07,\
	0,	11.5,0.50,	30000,	9.11,\
	0,	12,	1.50,	30000,	9.09,\
	0,	13.5,0.50,	30000,	9.07,\
	0,	14,	3.00,	30000,	9.04,\
	0,	17,	0.50,	30000,	9.07,\
	0,	17.5,3.50,	30000,	9.06,\
	0,	23.5,2.50,	30000,	9.04,\
	0,	26,	6.00,	30000,	9.05,\
	0,	32,	0.25,	30000,	8.05,\
	-1,	32,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab36 ftgen 136, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.05,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab37 ftgen 137, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab38 ftgen 138, 0, -36, -2, \
	0,	0,		0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	8.05,\
	-1,	0.75,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab39 ftgen 139, 0, -54, -2, \
	0,	0,		0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.05,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,		0.25,	30000,	8.11,\
	0,	1.25,	0.25,	30000,	9.00,\
	0,	1.5,		0.25,	30000,	8.11,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab40 ftgen 140, 0, -30, -2, \
	0,	0,		0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.05,\
	0,	0.5,		0.25,	30000,	8.11,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab41 ftgen 141, 0, -30, -2, \
	0,	0,		0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.11,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab42 ftgen 142, 0, -42, -2, \
	0,	0,	4.00,	30000,	9.00,\
	0,	4,	4.00,	30000,	8.11,\
	0,	8,	4.00,	30000,	8.09,\
	0,	12,	4.00,	30000,	9.00,\
	0,	16,	4.00,	30000,	9.00,\
	-1,	16,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab43 ftgen 143, 0, -72, -2, \
	0,	0,		0.25,	30000,	9.05,\
	0,	0.25,	0.25,	30000,	9.04,\
	0,	0.5,		0.25,	30000,	9.05,\
	0,	0.75,	0.25,	30000,	9.04,\
	0,	1,		0.50,	30000,	9.04,\
	0,	1.5,		0.50,	30000,	9.04,\
	0,	2,		0.50,	30000,	9.04,\
	0,	2.5,		0.25,	30000,	9.05,\
	0,	2.75,	0.25,	30000,	9.04,\
	0,	3,		0.25,	30000,	9.05,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab44 ftgen 144, 0, -42, -2, \
	0,	0,	0.50,	30000,	9.05,\
	0,	0.5,	1.00,	30000,	9.04,\
	0,	1.5,	0.50,	30000,	9.04,\
	0,	2,	1.00,	30000,	9.00,\
	0,	3,	0.50,	30000,	9.05,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab45 ftgen 145, 0, -36, -2, \
	0,	0,	1.00,	30000,	9.02,\
	0,	1,	1.00,	30000,	9.02,\
	0,	2,	1.00,	30000,	8.07,\
	0,	3,	1.00,	30000,	9.02,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab46 ftgen 146, 0, -84, -2, \
	0,	0,		0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	9.02,\
	0,	0.5,		0.25,	30000,	9.04,\
	0,	0.75,	0.25,	30000,	9.02,\
	0,	1.5,		0.50,	30000,	8.07,\
	0,	2.5,		0.50,	30000,	8.07,\
	0,	3.5,		0.50,	30000,	8.07,\
	0,	4,		0.25,	30000,	8.07,\
	0,	4.25,	0.25,	30000,	9.02,\
	0,	4.5,		0.25,	30000,	9.04,\
	0,	4.75,	0.25,	30000,	9.02,\
	0,	5,		0.25,	30000,	8.07,\
	-1,	5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab47 ftgen 147, 0, -36, -2, \
	0,	0,		0.25,	30000,	9.02,\
	0,	0.25,	0.25,	30000,	9.04,\
	0,	0.5,		0.50,	30000,	9.02,\
	0,	1,		0.25,	30000,	9.02,\
	-1,	1,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab48 ftgen 148, 0, -36, -2, \
	0,	0,	6.00,	30000,	8.07,\
	0,	6,	4.00,	30000,	8.07,\
	0,	10,	5.00,	30000,	8.05,\
	0,	15,	6.00,	30000,	8.07,\
	-1,	15,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab49 ftgen 149, 0, -54, -2, \
	0,	0,		0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.10,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,		0.25,	30000,	8.10,\
	0,	1.25,	0.25,	30000,	8.07,\
	0,	1.5,		0.25,	30000,	8.05,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab50 ftgen 150, 0, -30, -2, \
	0,	0,		0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.05,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab51 ftgen 151, 0, -36, -2, \
	0,	0,		0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.10,\
	0,	0.75,	0.25,	30000,	8.05,\
	-1,	0.75,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab52 ftgen 152, 0, -30, -2, \
	0,	0,		0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	8.10,\
	0,	0.5,		0.25,	30000,	8.07,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab53 ftgen 153, 0, -30, -2, \
	0,	0,		0.25,	30000,	8.10,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,		0.25,	30000,	8.10,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

;MACROS-----------------------------------------------------------
;Toggle switch with one led
opcode	SWITCH1, k, S
	S_SWITCH 			xin
	S_SWITCH_B		strcat	S_SWITCH, "_B"
	S_SWITCH_L		strcat	S_SWITCH, "_L"

	kB_Status			invalue	S_SWITCH_B
	kTrig			trigger	kB_Status, 0.5, 0
	kStatus_L			invalue	S_SWITCH_L

	if (kTrig == 1) then
		if (kStatus_L == 0) then
			outvalue	S_SWITCH_L, 1
		else
			outvalue	S_SWITCH_L, 0
		endif
	endif
			xout		kStatus_L
endop

instr	1	; Interface
	ktrig		metro	20

	if ktrig == 1 then
		;Metronome
		gkBPM		invalue	"BMP"
		gkmetrovol	invalue	"Pulse_Vol"

		;Pulse
		gkc1			invalue	"C1"
		gkc2			invalue	"C2"
		gkc3			invalue	"C3"
		gkc4			invalue	"C4"
		gkc5			invalue	"C5"
		gkc6			invalue	"C6"
		gkc7			invalue	"C7"
		gkc8			invalue	"C8"

		;Pattern
		gkpatt_index1	invalue	"Patt_index1"
		gkpatt_index2	invalue	"Patt_index2"
		gkpatt_index3	invalue	"Patt_index3"
		gkpatt_index4	invalue	"Patt_index4"
		gkpatt_index5	invalue	"Patt_index5"
		gkpatt_index6	invalue	"Patt_index6"
		gkpatt_index7	invalue	"Patt_index7"
		gkpatt_index8	invalue	"Patt_index8"
		gkpatt_index9	invalue	"Patt_index9"

		;Player
		gkOnOff1		SWITCH1	"OnOff1"
		gkOnOff2		SWITCH1	"OnOff2"
		gkOnOff3		SWITCH1	"OnOff3"
		gkOnOff4		SWITCH1	"OnOff4"
		gkOnOff5		SWITCH1	"OnOff5"
		gkOnOff6		SWITCH1	"OnOff6"
		gkOnOff7		SWITCH1	"OnOff7"
		gkOnOff8		SWITCH1	"OnOff8"
		gkOnOff9		SWITCH1	"OnOff9"

		;Volume
		gkvol1		invalue	"Vol1"
		gkvol2		invalue	"Vol2"
		gkvol3		invalue	"Vol3"
		gkvol4		invalue	"Vol4"
		gkvol5		invalue	"Vol5"
		gkvol6		invalue	"Vol6"
		gkvol7		invalue	"Vol7"
		gkvol8		invalue	"Vol8"
		gkvol9		invalue	"Vol9"

		;Pan
		gkpan1		invalue	"Pan1"
		gkpan2		invalue	"Pan2"
		gkpan3		invalue	"Pan3"
		gkpan4		invalue	"Pan4"
		gkpan5		invalue	"Pan5"
		gkpan6		invalue	"Pan6"
		gkpan7		invalue	"Pan7"
		gkpan8		invalue	"Pan8"
		gkpan9		invalue	"Pan9"

		;Wrong Timing
		gktimi1		invalue	"Timi1"
		gktimi2		invalue	"Timi2"
		gktimi3		invalue	"Timi3"
		gktimi4		invalue	"Timi4"
		gktimi5		invalue	"Timi5"
		gktimi6		invalue	"Timi6"
		gktimi7		invalue	"Timi7"
		gktimi8		invalue	"Timi8"
		gktimi9		invalue	"Timi9"

		;Wrong Intensity
		gkinte1		invalue	"Inte1"
		gkinte2		invalue	"Inte2"
		gkinte3		invalue	"Inte3"
		gkinte4		invalue	"Inte4"
		gkinte5		invalue	"Inte5"
		gkinte6		invalue	"Inte6"
		gkinte7		invalue	"Inte7"
		gkinte8		invalue	"Inte8"
		gkinte9		invalue	"Inte9"

		;Globals
		gkpppfff		invalue	"gVolume"
		gkOnOffAll	SWITCH1 	"OnOffAll"

		gkwet		invalue	"Dry-Wet"
		gkfblvl		invalue	"Feedback"
		gkfcoff		invalue	"Cutoff"
	endif
endin

;Tab readers ---------------------------------------------------
instr	2	;Tab reader
			;find duration of patterns stored into tables
			;read the table pattern length to find the value of the loop
			;lenght of Patterns are analized then stored into a ftable 1
			;Do not use values of -1 in the external file unless used for repeat section

	if p4 == 0 goto calcul ; Just in case...
	iipattdur		init	0
	ipointpattern	init	0
	back:
		iipattdur	table	ipointpattern, 100 + p4
		if (iipattdur == -1) igoto calcul
		ipointpattern = ipointpattern+1
		igoto back
	calcul:
		iipattdur	table	ipointpattern+1, 100 + p4
				tableiw	iipattdur, p4, 100
				prints	"Pattern %i : %f \n", p4, iipattdur
				turnoff
endin

;Control-----------------------------------------------------------
instr	98	;initialize some variables

#define INIT(N)
	#
	gkpatt_index$N			init		0
	gkpatt_duration0$N		table	gkpatt_index$N+1, gipattdur	;table that store pattern length
	gkpatt_duration_new0$N	=		gkpatt_duration0$N
	#

	$INIT(1)
	$INIT(2)
	$INIT(3)
	$INIT(4)
	$INIT(5)
	$INIT(6)
	$INIT(7)
	$INIT(8)
	$INIT(9)
	turnoff
endin

instr	99	;Control

	kPulse			metro	(2*gkBPM/60)
	kpulse_quantize	metro	(2*gkBPM/60)

	kkeypressed, keyactivation	sensekey			;for COmputer Keyboard Control


#define METRONOME(N'Pitch)
	#
	;Audio Metronome
	gkc$N		init		0
	if (gkc$N == 1) then
		schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, $Pitch
	endif
	#

	$METRONOME(1'5.00)
	$METRONOME(2'6.00)
	$METRONOME(3'7.00)
	$METRONOME(4'8.00)
	$METRONOME(5'9.00)
	$METRONOME(6'10.00)
	$METRONOME(7'11.00)
	$METRONOME(8'12.00)

#define PLAYER(N)
	#
	;COmputer Keyboard Control
	;Start stop keys
	;Player $N
	kbuttonP$N init		0
	iPlayer$N	table	$N, giASCII_Player
	if (kkeypressed == iPlayer$N && keyactivation == 1) then
		if (kbuttonP$N == 0) then
			kbuttonP$N = 1
			outvalue	"OnOff$N_L", 1
		else
			kbuttonP$N = 0
			outvalue	"OnOff$N_L", 0
		endif
	endif

	;Next pattern keys
	;Player $N
	kbuttonN$N init 0
	iNext$N	table	$N, giASCII_Next
	if (kkeypressed == iNext$N && keyactivation == 1) then
		kbuttonN$N = (kbuttonN$N + 1) % 53
		outvalue	"Patt_index$N", kbuttonN$N
	endif

	;---------------------------------------------------------------
	;Player $N
	;Sync Sequencer-On with metro pulse signal
	if (kpulse_quantize = 1) then
		ktrigOn$N trigger gkOnOff$N, 0.5, 0
			schedkwhen ktrigOn$N, 0, 0, 10$N, 0, -1
	endif
	;Turn Off the trigger instrument and the pattern reader whenever needed without syncro to metronome signal
	ktrigOff$N trigger gkOnOff$N, 0.5, 1
		schedkwhen ktrigOff$N, 0, 0, -10$N, 0, 1
		schedkwhen ktrigOff$N, 0, 0, -20$N, 0, 1
	#

	$PLAYER(1)
	$PLAYER(2)
	$PLAYER(3)
	$PLAYER(4)
	$PLAYER(5)
	$PLAYER(6)
	$PLAYER(7)
	$PLAYER(8)
	$PLAYER(9)
			

	;activate all the players together!
	if (kkeypressed == $SPACE && keyactivation == 1) then
		if (gkOnOffAll == 0) then
			outvalue	"OnOffAll_L", 1
		elseif (gkOnOffAll == 1) then
			outvalue	"OnOffAll_L", 0
		endif
	endif

	ktriggAll changed gkOnOffAll
	if (ktriggAll == 1) then
		if (gkOnOffAll == 1) then
			outvalue	"OnOff1_L", 1
			outvalue	"OnOff2_L", 1
			outvalue	"OnOff3_L", 1
			outvalue	"OnOff4_L", 1
			outvalue	"OnOff5_L", 1
			outvalue	"OnOff6_L", 1
			outvalue	"OnOff7_L", 1
			outvalue	"OnOff8_L", 1
			outvalue	"OnOff9_L", 1
		elseif (gkOnOffAll == 0) then
			outvalue	"OnOff1_L", 0
			outvalue	"OnOff2_L", 0
			outvalue	"OnOff3_L", 0
			outvalue	"OnOff4_L", 0
			outvalue	"OnOff5_L", 0
			outvalue	"OnOff6_L", 0
			outvalue	"OnOff7_L", 0
			outvalue	"OnOff8_L", 0
			outvalue	"OnOff9_L", 0
		endif
	endif
endin


#define TRIGGER(N)
#
instr	10$N	;trigger a performer on providing the table in the pfield
	gkp10$N	init		0
	gkp20$N	init		0
	gkp30$N	init		0
	gkp40$N	init		0
	gkp50$N	init		0
	gkp60$N	init		0
	gkphs0$N	init		1
	kcambio	metro	gkBPM / (gkpatt_duration0$N * 60)

	;Selected Pattern parameters
	gkpatt_duration_new0$N table gkpatt_index$N+1, gipattdur
	;gktablepatt0$N table gkpatt_index$N, gitablepatt
	gktablepatt0$N 	= gkpatt_index$N + 101
	;Instrument pattern change logic
	if (kcambio = 1) then
		kgoto stopstart
	else
		kgoto nothing
	endif
	stopstart:
		;turn off and on the instrument 20$N with the new table number if the pattern is finished
		turnoff2		20$N, 0, 0
		schedkwhen	1, 0, -1, 20$N, 0, -3, gktablepatt0$N, gkpatt_duration_new0$N
		gkpatt_duration0$N = gkpatt_duration_new0$N
	nothing:
endin
#

	$TRIGGER(1)
	$TRIGGER(2)
	$TRIGGER(3)
	$TRIGGER(4)
	$TRIGGER(5)
	$TRIGGER(6)
	$TRIGGER(7)
	$TRIGGER(8)
	$TRIGGER(9)

;-----------------------------------------------------------------------------------------------

#define PATTERN_READER(N)
#
;Pattern reader
instr	20$N	;read the table selected
	ktiming	linrand		(30 / gkBPM) * gktimi$N
	kinte	linrand		gkinte$N
	kvolvar	=			(1 - gkinte$N) + kinte * 2
	kphs		init			1
	;phasor running at BPM speed and pattern duration
	gkphs0$N	phasor		gkBPM / (k(p5)* 60)
	kphs		=			gkphs0$N * k(p5)
	ktrig	timedseq		kphs,p4,gkp10$N,gkp20$N,gkp30$N,gkp40$N,gkp50$N
	gkdur0$N	=			(60/gkBPM) * gkp30$N						;resize duration according to the BPM selected
			schedkwhen	ktrig, -1, -1, 30$N + .001 * ktiming, ktiming, gkdur0$N, gkp40$N * gkvol$N * gkpppfff * kvolvar, gkp50$N
endin
#

	$PATTERN_READER(1)
	$PATTERN_READER(2)
	$PATTERN_READER(3)
	$PATTERN_READER(4)
	$PATTERN_READER(5)
	$PATTERN_READER(6)
	$PATTERN_READER(7)
	$PATTERN_READER(8)
	$PATTERN_READER(9)


;Audio Generators -----------------------------------------------------------------------------
instr	300	;Pulse Sound
	inote	=		cpspch(p5)
	kres		linseg	0, .005, p4 , .01, p4*.8 ,p3-.1, p4*.67, .05, 0
	kston	linseg	1.3, .01, .99 , p3, 1

	a1		oscil	kres, inote, 3, .5
	a2		oscil	kres*.3, inote*2*kston, 3
	a3		oscil	kres*.2, inote*.5*kston, 3
	aenv		=		a1 + a2 + a3
			zawm		aenv, 0
endin

instr	301	;Player 1
	ktot		linseg	0, .01, 1, p3-.03, 1, .015, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.5

	ares		fmvoice	ivol, inote, 1, 0, .002, 4, 3, 1, 1, 1, 3

	kpanl	=		sqrt(1-gkpan1)
	kpanr	=		sqrt(gkpan1)
			zaw		ares*kpanl*ktot, 1
			zaw		ares*kpanr*ktot, 2
endin

instr	302	;Player 2
	ktot		linseg	0, .01, 1, p3-.03, 1, .015, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.1
	kmoden	expseg	inote*4.5, .1, inote *2.1, p3 - .1, inote *1.9
	kenvelope	linseg	0, .05, 1, .05, .95 ,p3-.20, .67, .05, 0
	kmod		oscil	kmoden, inote*.5, 1

	acarr	oscil	ivol, inote+kmod, 1
	acarr	=		acarr * kenvelope

	kpanl	=		sqrt(1-gkpan2)
	kpanr	=		sqrt(gkpan2)
			zaw		acarr*kpanl*ktot, 3
			zaw		acarr*kpanr*ktot, 4
endin

instr	303	;Player 3
	ktot		linseg	0, .01, 1, p3-.03, 1, .015, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.3
	kenvelope	linseg	0, .08, 1, .05, .95 ,p3-.20, .67, .05, 0
	kpw		expseg	.001, p3, .6

	ares		vco		inote*.25, inote, 3, kpw
	acarr	oscil	ivol, inote+ares, 3
	acarr	=		acarr * kenvelope

	kpanl	=		sqrt(1-gkpan3)
	kpanr	=		sqrt(gkpan3)
			zaw		acarr*kpanl*ktot, 5
			zaw		acarr*kpanr*ktot, 6
endin

instr	304	;Player 4
	iplk1	=		.27
	iplk2	=		.2
	ivel		=		p4 *.25
	kamp		linseg	ivel*.1, .01, ivel, p3-.05, ivel*.5, .01, 0				; envelope
	kamp1	linseg	ivel*.05, .008, ivel*.15, p3-.05, ivel*.01, .01, ivel*.01	; envelope
	icps		=		cpspch(p5)
	kpick1	=		.70
	kpick3	=		.88
	krefl	=		.4

	apickup1	wgpluck2	iplk1, kamp*2, icps, kpick1, krefl
	apickup3h	wgpluck2	iplk2, kamp*.7, icps*2.01, kpick3, krefl
	apickup3l	wgpluck2	iplk2, kamp1*.7, icps*1.98, kpick3, krefl
	aout		=		apickup1 +apickup3h + apickup3l
	abass	butterlp	aout, 6000
	amid		butterbp	aout, 3500, 200
	amid		=		3*amid

	kpanl	=		sqrt(1-gkpan4)
	kpanr	=		sqrt(gkpan4)
			zaw		(abass+amid)*kpanl, 7
			zaw		(abass+amid)*kpanr, 8
endin

instr	305	;Player 5
	ktot		linseg	0, .09, 1, p3-.03, 1, .015, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.05
	kenvelope	linseg	0, .09, 1, p3-.15, .97, .05, 0
	kbtt		line		1.2, p3, .6
	kmod		oscil	kbtt, inote * .5, 3

	acarr	oscil	(kmod*ivol), inote, 1

	kpanl	=		sqrt(1-gkpan5)
	kpanr	=		sqrt(gkpan5)
			zaw		acarr*kpanl*ktot, 9
			zaw		acarr*kpanr*ktot, 10
endin

instr	306	;Player 6
	ktot		linseg	0, .01, 1, p3-.03, 1, .015, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.6

	ares		fmvoice	ivol, inote, 11, 0, .03, 4, 3, 1, 1, 1, 3

	kpanl	=		sqrt(1-gkpan6)
	kpanr	=		sqrt(gkpan6)
			zaw		ares*kpanl*ktot, 11
			zaw		ares*kpanr*ktot, 12
endin

instr	307	;Player 7
	ktot		linseg	0, .05, 1, p3-.7, 1, .02, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.5
	kmoden	expseg	inote*4.2, .1, inote *2.15, p3 - .1, inote *1.87
	kenvelope	linseg	0, .1, 1, .02, .91 ,p3-.20, .87, .08, 0
	kmod		oscil	kmoden, inote*.51, 1

	acarr	oscil	ivol, inote+kmod, 1
	acarr	=		acarr * kenvelope

	kpanl	=		sqrt(1-gkpan7)
	kpanr	=		sqrt(gkpan7)
			zaw		acarr*kpanl*ktot, 13
			zaw		acarr*kpanr*ktot, 14
endin

instr	308	;Player 8
	ktot		linseg	0, .2, 1, p3-.3, 1, .1, 0
	inote	=		cpspch(p5)
	ivol		=		p4 *.1
	kenvelope	linseg	0, .096, 1, p3-.15, .97, .1, 0
	kbtt		line		.7, p3, 1.1
	kmod		oscil	kbtt, inote *2, 3

	acarr	oscil	(kmod*ivol), inote, 1

	kpanl	=		sqrt(1-gkpan8)
	kpanr	=		sqrt(gkpan8)
			zaw		acarr*kpanl*ktot, 15
			zaw		acarr*kpanr*ktot, 16
endin

instr	309	;Player 9
	iplk1	=		.37
	iplk2	=		.15
	ivel		=		p4 *.25
	kamp		linseg	ivel*.1, .01, ivel, p3-.05, ivel*.5, .01, 0				; envelope
	kamp1	linseg	ivel*.05, .008, ivel*.15, p3-.05, ivel*.01, .01, ivel*.01	; envelope
	icps		=		cpspch(p5)
	kpick1	=		.50
	kpick3	=		.99
	krefl	=		.4

	apickup1	wgpluck2	iplk1, kamp*2, icps, kpick1, krefl
	apickup3h	wgpluck2	iplk2, kamp*.4, icps*2.3, kpick3, krefl
	apickup3l	wgpluck2	iplk2, kamp1*.9, icps*1.97, kpick3, krefl
	aout		=		apickup1 +apickup3h + apickup3l
	abass	butterlp	aout, 4000
	amid		butterbp	aout, 1000, 100
	amid		=		3*amid

	kpanl	=		sqrt(1-gkpan9)
	kpanr	=		sqrt(gkpan9)
			zaw		(abass+amid)*kpanl, 17
			zaw		(abass+amid)*kpanr, 18
endin

instr	400	;mixer
	apulse		zar 0
	a1l			zar 1
	a1r			zar 2
	a2l			zar 3
	a2r			zar 4
	a3l			zar 5
	a3r			zar 6
	a4l			zar 7
	a4r			zar 8
	a5l			zar 9
	a5r			zar 10
	a6l			zar 11
	a6r			zar 12
	a7l			zar 13
	a7r			zar 14
	a8l			zar 15
	a8r			zar 16
	a9l			zar 17
	a9r			zar 18

	k1correction	init 1
	k2correction	init 1
	k3correction	init 1
	k4correction	init 1
	k5correction	init 1
	k6correction	init 1
	k7correction	init 1
	k8correction	init 1
	k9correction	init 1

	galeft	=	apulse + a1l * k1correction + a2l * k2correction + a3l * k2correction + a4l * k4correction + a5l * k5correction + a6l * k6correction + a7l * k1correction + a8l * k8correction + a9l * k9correction
	garight	=	apulse + a1r * k1correction + a2r * k2correction + a3r * k2correction + a4r * k4correction + a5r * k5correction + a6r * k6correction + a7r * k7correction + a8r * k8correction + a9r * k9correction
			zacl	0, 19
endin

instr	401	;Reverb
	;room
	ipitchm		=		1
	gaoutL, gaoutR	reverbsc	galeft, garight, gkfblvl, gkfcoff, sr, ipitchm
	gaeffLH		=		(galeft * (1 -gkwet) + gaoutL * gkwet)
	gaeffRH		=		(garight * (1 -gkwet) + gaoutR * gkwet)
				outs		gaeffLH, gaeffRH
endin
</CsInstruments>
<CsScore>
#define OPEN #7200#

i 1	0	$OPEN	;Interface

;inst	sta	dur	Insnum
i 2 0 1 1
i 2 0 1 2
i 2 0 1 3
i 2 0 1 4
i 2 0 1 5
i 2 0 1 6
i 2 0 1 7
i 2 0 1 8
i 2 0 1 9
i 2 0 1 10
i 2 0 1 11
i 2 0 1 12
i 2 0 1 13
i 2 0 1 14
i 2 0 1 15
i 2 0 1 16
i 2 0 1 17
i 2 0 1 18
i 2 0 1 19
i 2 0 1 20
i 2 0 1 21
i 2 0 1 22
i 2 0 1 23
i 2 0 1 24
i 2 0 1 25
i 2 0 1 26
i 2 0 1 27
i 2 0 1 28
i 2 0 1 29
i 2 0 1 30
i 2 0 1 31
i 2 0 1 32
i 2 0 1 33
i 2 0 1 34
i 2 0 1 35
i 2 0 1 36
i 2 0 1 37
i 2 0 1 38
i 2 0 1 39
i 2 0 1 40
i 2 0 1 41
i 2 0 1 42
i 2 0 1 43
i 2 0 1 44
i 2 0 1 45
i 2 0 1 46
i 2 0 1 47
i 2 0 1 48
i 2 0 1 49
i 2 0 1 50
i 2 0 1 51
i 2 0 1 52
i 2 0 1 53

i 98		0	1
i 99		0	$OPEN
i 400	0	$OPEN
i 401	0	$OPEN
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>881</x>
 <y>408</y>
 <width>798</width>
 <height>637</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>0</r>
  <g>170</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>52</y>
  <width>530</width>
  <height>60</height>
  <uuid>{da6cfe57-989d-40a9-86f3-f2e86cc76121}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff1_B</objectName>
  <x>58</x>
  <y>67</y>
  <width>63</width>
  <height>30</height>
  <uuid>{e342b7d4-feb1-41a5-bb7c-6dcca2f000e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>77</y>
  <width>10</width>
  <height>10</height>
  <uuid>{72df9346-a468-4b43-ba73-6b96f03f3ad1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff1_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index1</objectName>
  <x>127</x>
  <y>67</y>
  <width>51</width>
  <height>30</height>
  <uuid>{e1f72ed3-3b98-40bf-ad93-03fbbca97031}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>67</y>
  <width>30</width>
  <height>32</height>
  <uuid>{f1785581-04d1-4b06-9cd4-3e62e9edc602}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol1</objectName>
  <x>195</x>
  <y>57</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f1cf09b1-0de3-4108-a85d-8a8f587a21f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan1</objectName>
  <x>255</x>
  <y>57</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6b26739f-fc56-4f39-917f-594a65614836}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01010100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi1</objectName>
  <x>315</x>
  <y>57</y>
  <width>50</width>
  <height>50</height>
  <uuid>{459aefe4-3bef-4fe7-b0bc-a705656c798b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte1</objectName>
  <x>375</x>
  <y>57</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f0bc09f5-d132-4323-bed0-6a082f160a88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01010100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>67</y>
  <width>61</width>
  <height>30</height>
  <uuid>{8c2e7ea1-87db-46be-8b9a-34959085c98d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>a / q</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>530</width>
  <height>45</height>
  <uuid>{0efe3e96-c963-4e12-8833-6592d5935230}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>188</x>
  <y>13</y>
  <width>69</width>
  <height>28</height>
  <uuid>{f04060dd-b782-4aaa-bed7-0c3245c74d9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>253</x>
  <y>13</y>
  <width>55</width>
  <height>27</height>
  <uuid>{ceb53559-22a7-4361-9400-0e9aa359a383}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>308</x>
  <y>2</y>
  <width>67</width>
  <height>46</height>
  <uuid>{18ca374c-8881-4d23-8d54-ff8bb1365d7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wrong
Timing</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>368</x>
  <y>2</y>
  <width>77</width>
  <height>45</height>
  <uuid>{34cc17d2-227a-4264-87ab-2d8da8f218f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wrong
Intensity</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>13</y>
  <width>83</width>
  <height>30</height>
  <uuid>{a888a464-c836-4b7b-bdfe-bd0ec1d45909}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Player</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>440</x>
  <y>2</y>
  <width>91</width>
  <height>46</height>
  <uuid>{c1e0fd56-0e18-466c-868b-8f15b0d92a08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Keyboard
Start / Next</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>120</x>
  <y>13</y>
  <width>68</width>
  <height>28</height>
  <uuid>{3e4b505a-37be-4ee1-94b0-2d6223aa70be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pattern</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>117</y>
  <width>530</width>
  <height>60</height>
  <uuid>{f2f516fb-2e80-46a4-b60a-02194799fb6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff2_B</objectName>
  <x>58</x>
  <y>132</y>
  <width>63</width>
  <height>30</height>
  <uuid>{f4e4e122-97f5-4cdc-9654-26ea43b71932}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>142</y>
  <width>10</width>
  <height>10</height>
  <uuid>{40cc8394-bc6e-4682-bc8a-6639bbb7f8e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff2_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index2</objectName>
  <x>127</x>
  <y>132</y>
  <width>51</width>
  <height>30</height>
  <uuid>{632af272-a979-4681-89cc-72c64f008896}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>132</y>
  <width>30</width>
  <height>32</height>
  <uuid>{203e63b8-085f-4559-bc72-81d419b37ad6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol2</objectName>
  <x>195</x>
  <y>122</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9bd629bf-38a6-494f-b1f8-d0d2328d293a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan2</objectName>
  <x>255</x>
  <y>122</y>
  <width>50</width>
  <height>50</height>
  <uuid>{81e4ddbc-4e90-4e53-9d23-3a842e11b535}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79798000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi2</objectName>
  <x>315</x>
  <y>122</y>
  <width>50</width>
  <height>50</height>
  <uuid>{add2323e-059b-4e6f-94c4-31a79c612707}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01010100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte2</objectName>
  <x>375</x>
  <y>122</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d2dd19b3-d6ff-48f8-83fe-3a9e8757161e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>132</y>
  <width>61</width>
  <height>30</height>
  <uuid>{23eda8e3-d432-4b45-b613-5917f77ce503}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>z / s</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>183</y>
  <width>530</width>
  <height>60</height>
  <uuid>{fbc73574-dd67-486b-936e-6134710bd843}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff3_B</objectName>
  <x>58</x>
  <y>198</y>
  <width>63</width>
  <height>30</height>
  <uuid>{84ea3465-6c0b-4113-9dbe-0d3372e6b2d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>208</y>
  <width>10</width>
  <height>10</height>
  <uuid>{61765893-b147-4bf9-b2d3-9d14f8a94e77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff3_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index3</objectName>
  <x>127</x>
  <y>198</y>
  <width>51</width>
  <height>30</height>
  <uuid>{d38c7936-8c81-4d42-8db2-29c6fa9ce931}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>198</y>
  <width>30</width>
  <height>32</height>
  <uuid>{e4d0a865-91da-4f1a-8593-8348ebbbc9a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol3</objectName>
  <x>195</x>
  <y>188</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8ecc1d8e-f8b1-4918-8cd7-69d83aabdefb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.81818200</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan3</objectName>
  <x>255</x>
  <y>188</y>
  <width>50</width>
  <height>50</height>
  <uuid>{629f47ff-be1f-48f1-b10c-1996d5c5a3d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.07070700</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi3</objectName>
  <x>315</x>
  <y>188</y>
  <width>50</width>
  <height>50</height>
  <uuid>{3143bd60-7b79-49e7-9e05-aeada113b2a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte3</objectName>
  <x>375</x>
  <y>188</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b39e5437-80d2-4cfd-9aae-07ff044c22ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>198</y>
  <width>61</width>
  <height>30</height>
  <uuid>{b1f10662-d376-40f9-8928-c9455cd8ee44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>e / d</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>248</y>
  <width>530</width>
  <height>60</height>
  <uuid>{acacffa0-1c70-4a57-a7d1-3bc185d295e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff4_B</objectName>
  <x>58</x>
  <y>263</y>
  <width>63</width>
  <height>30</height>
  <uuid>{03949409-c304-4b86-9127-81dc57ffba84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>273</y>
  <width>10</width>
  <height>10</height>
  <uuid>{9e9d5e91-d736-4c82-bcdc-74d625d959e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff4_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index4</objectName>
  <x>127</x>
  <y>263</y>
  <width>51</width>
  <height>30</height>
  <uuid>{1502138a-1041-4310-bbde-aee93f8a7730}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>263</y>
  <width>30</width>
  <height>32</height>
  <uuid>{d6249f1f-ef21-4abf-be38-857470ebb4a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol4</objectName>
  <x>195</x>
  <y>253</y>
  <width>50</width>
  <height>50</height>
  <uuid>{51001fd9-810a-4cc2-8e34-1ea1817e702e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan4</objectName>
  <x>255</x>
  <y>253</y>
  <width>50</width>
  <height>50</height>
  <uuid>{1c4ae11d-a9ee-4848-9247-428db580f8b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.77777800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi4</objectName>
  <x>315</x>
  <y>253</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9e6861ac-dafb-49f5-8c13-9e724bdd0c01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte4</objectName>
  <x>375</x>
  <y>253</y>
  <width>50</width>
  <height>50</height>
  <uuid>{35ab4a22-4d1b-4472-9c68-744eff2f61be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>263</y>
  <width>61</width>
  <height>30</height>
  <uuid>{60077f78-df72-480c-bc51-f00989b37ec6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>r / f</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>315</y>
  <width>530</width>
  <height>60</height>
  <uuid>{e323fd82-1de3-4abd-8306-f7211c686697}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff5_B</objectName>
  <x>58</x>
  <y>330</y>
  <width>63</width>
  <height>30</height>
  <uuid>{74ad1171-4f8c-4035-a3e3-094fe9f91239}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>340</y>
  <width>10</width>
  <height>10</height>
  <uuid>{e1962052-5d45-4234-ab7c-982d9abf4a25}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff5_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index5</objectName>
  <x>127</x>
  <y>330</y>
  <width>51</width>
  <height>30</height>
  <uuid>{371bc98e-ec25-47e7-85a0-a2e5d7b8312f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>330</y>
  <width>30</width>
  <height>32</height>
  <uuid>{69c5d968-53fc-4e5e-b83b-1ad3c4ac4b6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol5</objectName>
  <x>195</x>
  <y>320</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7e394781-85da-4048-a870-85ad80f82d1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan5</objectName>
  <x>255</x>
  <y>320</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b08a4557-3e87-4e5c-919b-50b0a7b9b10c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi5</objectName>
  <x>315</x>
  <y>320</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9cce2cc2-d909-46c5-903a-9042d2b8350b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>330</y>
  <width>61</width>
  <height>30</height>
  <uuid>{66ad8a76-6522-4d9a-9a07-139f126cf042}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>t / g</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>380</y>
  <width>530</width>
  <height>60</height>
  <uuid>{61961c85-a9cf-44a9-82e2-83fc79fdb1a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff6_B</objectName>
  <x>58</x>
  <y>395</y>
  <width>63</width>
  <height>30</height>
  <uuid>{b8ecd0d9-13ca-4360-b7de-3b35914546e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>405</y>
  <width>10</width>
  <height>10</height>
  <uuid>{178fc3be-bc09-4f38-8444-446fe2c9f6bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff6_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index6</objectName>
  <x>127</x>
  <y>395</y>
  <width>51</width>
  <height>30</height>
  <uuid>{50283a56-7e3c-431f-8f8a-884470cb0cee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>395</y>
  <width>30</width>
  <height>32</height>
  <uuid>{055cb923-d753-47d2-9b4c-98ea3b254327}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol6</objectName>
  <x>195</x>
  <y>385</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d142ea81-f3f6-4bf5-8668-c95abd7e7867}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan6</objectName>
  <x>255</x>
  <y>385</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6de1a928-bb0b-4bb2-8bdf-49fa7012f1e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79798000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi6</objectName>
  <x>315</x>
  <y>385</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5cf302ae-b433-494b-80e1-d14145e0f87f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte6</objectName>
  <x>375</x>
  <y>385</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8ff63604-2a4d-444e-99da-25662e945516}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>395</y>
  <width>61</width>
  <height>30</height>
  <uuid>{9011a9f4-05f2-4264-a45b-88ff957cc8ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>y / h</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>446</y>
  <width>530</width>
  <height>60</height>
  <uuid>{a65503aa-eff7-46d5-8b27-0c32e3acb0eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff7_B</objectName>
  <x>58</x>
  <y>461</y>
  <width>63</width>
  <height>30</height>
  <uuid>{837b0528-2fee-4a9d-9536-9655fadb4c4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>471</y>
  <width>10</width>
  <height>10</height>
  <uuid>{67dbb7d0-c6a5-4495-a5a5-cf1dbb666db9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff7_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index7</objectName>
  <x>127</x>
  <y>461</y>
  <width>51</width>
  <height>30</height>
  <uuid>{4bde3add-6ca6-4140-bad0-e7c18172b6e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>461</y>
  <width>30</width>
  <height>32</height>
  <uuid>{875aedea-78b5-4af4-ad3c-1625a4bfb1ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol7</objectName>
  <x>195</x>
  <y>451</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7a2d676a-0656-41a2-b698-3cfef7cb70e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan7</objectName>
  <x>255</x>
  <y>451</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b3a6572e-cc44-4333-a8d2-d87f49bdfe92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06060600</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi7</objectName>
  <x>315</x>
  <y>451</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9b1db0e3-42fb-4311-b0f3-6680e86fc202}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte7</objectName>
  <x>375</x>
  <y>451</y>
  <width>50</width>
  <height>50</height>
  <uuid>{17748e91-832f-42a0-9a41-e3a11a6570cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>461</y>
  <width>61</width>
  <height>30</height>
  <uuid>{b7873f1e-6052-48d8-8b39-3cfaa2d90c98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>u / j</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>511</y>
  <width>530</width>
  <height>60</height>
  <uuid>{d9bf38c8-5f12-4a92-887b-04bb41b87d65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff8_B</objectName>
  <x>58</x>
  <y>526</y>
  <width>63</width>
  <height>30</height>
  <uuid>{544533ae-a7d8-425c-aed4-945932947c12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>536</y>
  <width>10</width>
  <height>10</height>
  <uuid>{1d330048-214a-486c-b854-0e37adbf6833}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff8_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index8</objectName>
  <x>127</x>
  <y>526</y>
  <width>51</width>
  <height>30</height>
  <uuid>{7225b1ea-5aca-4ace-bc2e-2cc86526797e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>526</y>
  <width>30</width>
  <height>32</height>
  <uuid>{00bf8145-92f5-454b-aec1-b5bd0b788e33}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol8</objectName>
  <x>195</x>
  <y>516</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0df9dee6-be25-4988-9ca0-e02bc80e4504}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan8</objectName>
  <x>255</x>
  <y>516</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9f0765b5-78f0-46a9-b099-e2b2c6ed26fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79798000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi8</objectName>
  <x>315</x>
  <y>516</y>
  <width>50</width>
  <height>50</height>
  <uuid>{2085e177-16a7-41d2-b19b-8326a8d34d68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte8</objectName>
  <x>375</x>
  <y>516</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8ef04d4d-97d7-4dd9-82c5-6f360d1d95bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>526</y>
  <width>61</width>
  <height>30</height>
  <uuid>{1e90da32-a4cb-432b-a277-d91512f3bb0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>i / k</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>577</y>
  <width>530</width>
  <height>60</height>
  <uuid>{e362dd81-a808-480a-aa2b-0ba4cd1117cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOff9_B</objectName>
  <x>58</x>
  <y>592</y>
  <width>63</width>
  <height>30</height>
  <uuid>{7914eb6d-b0d0-48a1-929c-c913d2f6e2e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>64</x>
  <y>602</y>
  <width>10</width>
  <height>10</height>
  <uuid>{ab1ab987-7da0-4ea6-acac-a593b1cb158c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOff9_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Patt_index9</objectName>
  <x>127</x>
  <y>592</y>
  <width>51</width>
  <height>30</height>
  <uuid>{1cbf393c-7eb2-49ab-a76c-fef576604118}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>00</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>01</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>02</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>03</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>04</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>05</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>06</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>07</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>08</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>09</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>31</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32</name>
    <value>32</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>33</name>
    <value>33</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>34</name>
    <value>34</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>35</name>
    <value>35</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>36</name>
    <value>36</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>37</name>
    <value>37</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>38</name>
    <value>38</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>39</name>
    <value>39</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>40</name>
    <value>40</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>41</name>
    <value>41</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>42</name>
    <value>42</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>43</name>
    <value>43</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>44</name>
    <value>44</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>45</name>
    <value>45</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>46</name>
    <value>46</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>47</name>
    <value>47</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>48</name>
    <value>48</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>49</name>
    <value>49</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>50</name>
    <value>50</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>51</name>
    <value>51</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>52</name>
    <value>52</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>592</y>
  <width>30</width>
  <height>32</height>
  <uuid>{70e68654-d07b-46f1-8e2d-f3d8294ad585}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>72</r>
   <g>72</g>
   <b>72</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol9</objectName>
  <x>195</x>
  <y>582</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f25fed74-4e2e-499b-8755-654e4cb9f0cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan9</objectName>
  <x>255</x>
  <y>582</y>
  <width>50</width>
  <height>50</height>
  <uuid>{3b97ea9d-6c37-424c-948f-ea835f98945b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10101000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Timi9</objectName>
  <x>315</x>
  <y>582</y>
  <width>50</width>
  <height>50</height>
  <uuid>{deca2bab-66c1-47ae-95b0-ceea5f7e65df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01010100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte9</objectName>
  <x>375</x>
  <y>582</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0df386d6-1431-4df1-84ba-25e042b5cd4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>592</y>
  <width>61</width>
  <height>30</height>
  <uuid>{c2d40d34-0ba8-4f3d-b7e4-fdd47c38ef32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>o / l</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>535</x>
  <y>118</y>
  <width>262</width>
  <height>518</height>
  <uuid>{e6e0fd35-8b85-4335-a290-a1f57eafa530}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>540</x>
  <y>136</y>
  <width>64</width>
  <height>30</height>
  <uuid>{7b56c126-7fe0-479a-9354-b9523268b8d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>BMP</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Inte5</objectName>
  <x>375</x>
  <y>320</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c12af5af-8d10-477a-b4fa-2d0881797c80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pulse_Vol</objectName>
  <x>608</x>
  <y>240</y>
  <width>60</width>
  <height>60</height>
  <uuid>{610e6455-0a27-4405-8c6a-eae5cd952663}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>28000.00000000</maximum>
  <value>28000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>BMP</objectName>
  <x>603</x>
  <y>139</y>
  <width>80</width>
  <height>25</height>
  <uuid>{138f11f9-ef71-4bfb-bed3-7d177625adcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>130</value>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>gVolume</objectName>
  <x>608</x>
  <y>378</y>
  <width>60</width>
  <height>60</height>
  <uuid>{c8da2156-e8f8-43e5-8886-4dcc59419a24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.01000000</minimum>
  <maximum>2.00000000</maximum>
  <value>2.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Dry-Wet</objectName>
  <x>613</x>
  <y>493</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d0edf587-6103-4e10-8604-67df4db17dc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Feedback</objectName>
  <x>673</x>
  <y>493</y>
  <width>50</width>
  <height>50</height>
  <uuid>{037c187f-6692-4281-ad0a-b27fa5ee5ef3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Cutoff</objectName>
  <x>733</x>
  <y>493</y>
  <width>50</width>
  <height>50</height>
  <uuid>{680b498f-bbe3-4719-9072-d257b0222fb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>22050.00000000</maximum>
  <value>17640.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>599</x>
  <y>348</y>
  <width>78</width>
  <height>28</height>
  <uuid>{5dc973e4-c4f0-4736-9e58-0ab63c21abc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>540</x>
  <y>503</y>
  <width>75</width>
  <height>29</height>
  <uuid>{43bdad06-adef-4c34-a102-7c340e7f2d80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>REVERB</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>602</x>
  <y>464</y>
  <width>66</width>
  <height>24</height>
  <uuid>{6ef6168d-c4cd-469f-b207-2f888a14433d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>664</x>
  <y>464</y>
  <width>66</width>
  <height>24</height>
  <uuid>{6282a3d5-09fb-4e14-b54f-112e8828b3ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>725</x>
  <y>464</y>
  <width>66</width>
  <height>24</height>
  <uuid>{78104eb5-4d22-4c91-8976-fa13d3920a0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>536</x>
  <y>388</y>
  <width>75</width>
  <height>30</height>
  <uuid>{acb7b198-3258-4931-9746-e6511252c998}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>GLOBAL</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OnOffAll_B</objectName>
  <x>705</x>
  <y>401</y>
  <width>63</width>
  <height>30</height>
  <uuid>{650c9bc2-086d-412e-a6aa-b2b368240fdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>710</x>
  <y>410</y>
  <width>10</width>
  <height>10</height>
  <uuid>{958003d4-d371-4f14-99cc-f160f775bd83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>OnOffAll_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>685</x>
  <y>340</y>
  <width>109</width>
  <height>56</height>
  <uuid>{ea721a49-3b2c-43a7-ae03-2c05585b79d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Space Key
All the players
together On Off</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>599</x>
  <y>210</y>
  <width>81</width>
  <height>29</height>
  <uuid>{6fc43ffc-a9a4-4d0d-80ca-41772498bdfc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C1</objectName>
  <x>696</x>
  <y>208</y>
  <width>15</width>
  <height>15</height>
  <uuid>{b94af8a0-299a-4f69-86e2-2d626eb1aca4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>706</x>
  <y>204</y>
  <width>33</width>
  <height>26</height>
  <uuid>{0a500546-7d0d-4c65-9225-77ec46c4322e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C3</objectName>
  <x>696</x>
  <y>268</y>
  <width>15</width>
  <height>15</height>
  <uuid>{7e4456da-1bb6-4bab-93b0-72e038b0f7b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C2</objectName>
  <x>696</x>
  <y>238</y>
  <width>15</width>
  <height>15</height>
  <uuid>{b001fca6-198a-4271-94c3-65d4cbf9605e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C5</objectName>
  <x>736</x>
  <y>208</y>
  <width>15</width>
  <height>15</height>
  <uuid>{624e52ce-4d3b-4bcf-bbd3-075203d9a3e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>706</x>
  <y>264</y>
  <width>33</width>
  <height>26</height>
  <uuid>{a78bc8d3-36b7-4080-8a80-e47edf3ba76f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C3</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>706</x>
  <y>234</y>
  <width>33</width>
  <height>26</height>
  <uuid>{8a1c1411-09a8-4f13-a1a5-7d44dcb015df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>706</x>
  <y>294</y>
  <width>33</width>
  <height>26</height>
  <uuid>{b3c21240-a3f3-43ed-b944-ddf7708d5fe0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C4</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C4</objectName>
  <x>696</x>
  <y>298</y>
  <width>15</width>
  <height>15</height>
  <uuid>{9673c7f6-9039-40ee-ab97-c7818fbc8cbd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>746</x>
  <y>204</y>
  <width>33</width>
  <height>26</height>
  <uuid>{939c7723-1858-45ef-a7f9-ec062af5ae4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C5</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C7</objectName>
  <x>736</x>
  <y>268</y>
  <width>15</width>
  <height>15</height>
  <uuid>{245e8593-2beb-4875-be06-ac0fab8053cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C6</objectName>
  <x>736</x>
  <y>238</y>
  <width>15</width>
  <height>15</height>
  <uuid>{01b59770-62c6-4be5-997a-03b07a750565}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>C8</objectName>
  <x>736</x>
  <y>298</y>
  <width>15</width>
  <height>15</height>
  <uuid>{4c6875be-177b-4935-bf50-e42f7b81cff2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>746</x>
  <y>264</y>
  <width>33</width>
  <height>26</height>
  <uuid>{b4fb1cde-41d8-472c-93b2-f3b28e10ae01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C7</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>746</x>
  <y>234</y>
  <width>33</width>
  <height>26</height>
  <uuid>{2380bf0b-9966-4257-93e4-7c600d3f31ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C6</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>746</x>
  <y>294</y>
  <width>33</width>
  <height>26</height>
  <uuid>{e02db2e0-7bec-44fa-9a7e-830b52d0ee8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C8</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>536</x>
  <y>2</y>
  <width>262</width>
  <height>111</height>
  <uuid>{3a8981d0-fbea-4f20-9f24-055b2e41e49b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>In C Player
Created by Stefano Valli</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>541</x>
  <y>53</y>
  <width>246</width>
  <height>56</height>
  <uuid>{b220eeac-d31e-4ea1-b4c4-8b7173b62817}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>www.triceratupuz.altervista.org
email: vallste at libero.it
license: http://creativecommons.org</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>540</x>
  <y>252</y>
  <width>64</width>
  <height>30</height>
  <uuid>{1e37e020-7902-4710-8873-6f156b0b3f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>PULSE</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>127</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
