;This file is released with CC-by-sa license. http://creativecommons.org

;Created by: Stefano Valli  - www.triceratupuz.altervista.org - email: 
;vallste at libero.it
;www.triceratupuz.altervista.org

;Ftables inclusion and testing by: Joachim Heintz - www.joachimheintz.de - 
;email: jh at joachimheintz.de

;Table reading optimization to 1 instrument by Andres Cabrera

;If you have problems to play this file in QuteCsound,
;go to the Configurations dialog and choose "Run FLTK in Terminal"

<CsoundSynthesizer>
<CsOptions>
-nm0  ;No output messages
</CsOptions>
<CsInstruments>
sr	= 44100
kr	= 4410
nchnls	= 2
zakinit 20, 1
;-------------------------MACROS--------------------------
;Interface column
#define PLAYINT(NUM)
#ix$NUM init 10 + ($NUM - 1) *50
ihandle FLbox "Player $NUM", 8, 1, 12, 50, 23, ix$NUM, 1
gkpatt_index$NUM, giflbuttbank$NUM FLbutBank 12, 1, 53, 50, 672, ix$NUM, 49, -1
gkOnOff$NUM, gihOnOff$NUM FLbutton	"@|>",	1, 0, 2, 50, 30, ix$NUM, 19, 0, 1, 0, -1#

;---------------------INITIALIZATION-----------------
gisin ftgen 1, 0, 16384, 10, 1; sine wave
gisqu ftgen 2, 0, 16384, 10, 1, 0, .333, 0, .25, 0, .14285; square wave
gitri ftgen 3, 0, 16384, 10, 1, 0, .11111, 0, .04, 0, .0204; triangle wave
gisaw ftgen 4, 0, 16384, 10, 1, .5, .3333, .25, .2, .1666, .142857, .125, .111;sawtooth

;table that store pattern length
gipattdur ftgen 100, 0, 64, -2,  11, 22,	33,	44,	55,	66,	77,	88,	99,	0,	0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;pattern tables
;table dimension must be equal or higher of the table recorded numbers and power of 2
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
	0,	3.5,	0.25,	30000,	8.00,\
	0,	3.75,	0.25,	30000,	8.00,\
	0,	4,	0.50,	30000,	8.00,\
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
	0,	0.25,	0.25,	30000,	8.07,\
	0,	4,	0.25,	30000,	8.11,\
	-1,	4,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab10 ftgen 110, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab11 ftgen 111, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,	0.25,	30000,	8.07,\
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
	0,	0.25,	0.75,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.07,\
	0,	1.25,	0.25,	30000,	8.05,\
	0,	1.5,	0.50,	30000,	8.07,\
	0,	2.75,	3.25,	30000,	8.07,\
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
	0,	0.25,	0.25,	30000,	8.11,\
	0,	0.5,	0.25,	30000,	9.00,\
	0,	0.75,	0.25,	30000,	8.11,\
	0,	1,	0.25,	30000,	8.07,\
	-1,	1,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab17 ftgen 117, 0, -48, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	9.00,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	9.00,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.5,	0.25,	30000,	8.11,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab18 ftgen 118, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,	0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,	0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	8.04,\
	0,	1.75,	0.25,	30000,	8.04,\
	0,	2,	0.25,	30000,	8.04,\
	-1,	2,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab19 ftgen 119, 0, -30, -2, \
	0,	0,	1.50,	0,	8.04,\
	0,	1.5,	1.50,	30000,	9.07,\
	0,	3,	1.50,	0,	8.04,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab20 ftgen 120, 0, -78, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,	0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,	0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	7.07,\
	0,	1.75,	0.25,	30000,	8.04,\
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
	0,	10.5,	1.50,	30000,	8.09,\
	0,	12,	0.50,	30000,	8.11,\
	0,	12.5,	1.50,	30000,	8.04,\
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
	0,	10.5,	0.50,	30000,	8.04,\
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
	0,	0.25,	0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,	0.25,	30000,	8.06,\
	0,	1,	0.50,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.04,\
	0,	1.75,	0.25,	30000,	8.07,\
	0,	2,	0.25,	30000,	8.06,\
	0,	2.25,	0.25,	30000,	8.04,\
	0,	2.5,	0.25,	30000,	8.06,\
	0,	2.75,	0.25,	30000,	8.04,\
	0,	3,	0.25,	30000,	8.04,\
	-1,	3,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab28 ftgen 128, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.04,\
	0,	0.25,	0.25,	30000,	8.06,\
	0,	0.5,	0.25,	30000,	8.04,\
	0,	0.75,	0.25,	30000,	8.06,\
	0,	1,	0.75,	30000,	8.04,\
	0,	1.75,	0.25,	30000,	8.04,\
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
	0,	0.25,	0.25,	30000,	8.05,\
	0,	0.5,	0.25,	30000,	8.07,\
	0,	0.75,	0.25,	30000,	8.11,\
	0,	1,	0.25,	30000,	8.07,\
	0,	1.25,	0.25,	30000,	8.11,\
	0,	1.5,	0.25,	30000,	8.07,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab32 ftgen 132, 0, -60, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,	3.25,	30000,	8.05,\
	0,	4.5,	1.50,	30000,	8.07,\
	0,	6,	0.25,	30000,	8.05,\
	-1,	6,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab33 ftgen 133, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	8.05,\
	0,	1,	0.25,	30000,	8.07,\
	-1,	1,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab34 ftgen 134, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	8.05,\
	0,	0.5,	0.25,	30000,	8.07,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab35 ftgen 135, 0, -150, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,	0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.11,\
	0,	1.75,	0.25,	30000,	8.07,\
	0,	2,	0.25,	30000,	8.11,\
	0,	2.25,	0.25,	30000,	8.07,\
	0,	6,	1.00,	30000,	8.10,\
	0,	7,	3.00,	30000,	9.07,\
	0,	10,	0.50,	30000,	9.09,\
	0,	10.5,	1.00,	30000,	9.07,\
	0,	11.5,	0.50,	30000,	9.11,\
	0,	12,	1.50,	30000,	9.09,\
	0,	13.5,	0.50,	30000,	9.07,\
	0,	14,	3.00,	30000,	9.04,\
	0,	17,	0.50,	30000,	9.07,\
	0,	17.5,	3.50,	30000,	9.06,\
	0,	23.5,	2.50,	30000,	9.04,\
	0,	26,	6.00,	30000,	9.05,\
	0,	32,	0.25,	30000,	8.05,\
	-1,	32,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab36 ftgen 136, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,	0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.05,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab37 ftgen 137, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab38 ftgen 138, 0, -36, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
	0,	0.75,	0.25,	30000,	8.05,\
	-1,	0.75,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab39 ftgen 139, 0, -54, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.11,\
	0,	1.25,	0.25,	30000,	9.00,\
	0,	1.5,	0.25,	30000,	8.11,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab40 ftgen 140, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.05,\
	0,	0.5,	0.25,	30000,	8.11,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab41 ftgen 141, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.11,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.11,\
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
	0,	0,	0.25,	30000,	9.05,\
	0,	0.25,	0.25,	30000,	9.04,\
	0,	0.5,	0.25,	30000,	9.05,\
	0,	0.75,	0.25,	30000,	9.04,\
	0,	1,	0.50,	30000,	9.04,\
	0,	1.5,	0.50,	30000,	9.04,\
	0,	2,	0.50,	30000,	9.04,\
	0,	2.5,	0.25,	30000,	9.05,\
	0,	2.75,	0.25,	30000,	9.04,\
	0,	3,	0.25,	30000,	9.05,\
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
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	9.02,\
	0,	0.5,	0.25,	30000,	9.04,\
	0,	0.75,	0.25,	30000,	9.02,\
	0,	1.5,	0.50,	30000,	8.07,\
	0,	2.5,	0.50,	30000,	8.07,\
	0,	3.5,	0.50,	30000,	8.07,\
	0,	4,	0.25,	30000,	8.07,\
	0,	4.25,	0.25,	30000,	9.02,\
	0,	4.5,	0.25,	30000,	9.04,\
	0,	4.75,	0.25,	30000,	9.02,\
	0,	5,	0.25,	30000,	8.07,\
	-1,	5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab47 ftgen 147, 0, -36, -2, \
	0,	0,	0.25,	30000,	9.02,\
	0,	0.25,	0.25,	30000,	9.04,\
	0,	0.5,	0.50,	30000,	9.02,\
	0,	1,	0.25,	30000,	9.02,\
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
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.10,\
	0,	0.75,	0.25,	30000,	8.07,\
	0,	1,	0.25,	30000,	8.10,\
	0,	1.25,	0.25,	30000,	8.07,\
	0,	1.5,	0.25,	30000,	8.05,\
	-1,	1.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab50 ftgen 150, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.05,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab51 ftgen 151, 0, -36, -2, \
	0,	0,	0.25,	30000,	8.05,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.10,\
	0,	0.75,	0.25,	30000,	8.05,\
	-1,	0.75,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab52 ftgen 152, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.07,\
	0,	0.25,	0.25,	30000,	8.10,\
	0,	0.5,	0.25,	30000,	8.07,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1

itab53 ftgen 153, 0, -30, -2, \
	0,	0,	0.25,	30000,	8.10,\
	0,	0.25,	0.25,	30000,	8.07,\
	0,	0.5,	0.25,	30000,	8.10,\
	-1,	0.5,	-1,	-1,	-1,\
	-1,	-1,	-1,	-1,	-1






;------------------------INTERFACE-----------------------
FLpanel "In C Player", 1010, 723, 1, 1, 1, 1, 0
;Metronome
gkBPM, iBMP FLtext "BMP", 20, 200, .5, 1, 70, 40, 550, 20
FLsetVal_i 120, iBMP
gkmetrovol, ihOnOff FLknob "Pulse Vol", 0, 28000, 0, 1, -4, 60, 635, 10, 20
gkc1, ihanc1 FLbutton "C1", 1, 0, 3, 30, 30, 700, 10, -1
gkc2, ihanc1 FLbutton "C2", 1, 0, 3, 30, 30, 740, 10, -1
gkc3, ihanc1 FLbutton "C3", 1, 0, 3, 30, 30, 780, 10, -1
gkc4, ihanc1 FLbutton "C4", 1, 0, 3, 30, 30, 820, 10, -1
gkc5, ihanc1 FLbutton "C5", 1, 0, 3, 30, 30, 700, 50, -1
gkc6, ihanc1 FLbutton "C6", 1, 0, 3, 30, 30, 740, 50, -1
gkc7, ihanc1 FLbutton "C7", 1, 0, 3, 30, 30, 780, 50, -1
gkc8, ihanc1 FLbutton "C8", 1, 0, 3, 30, 30, 820, 50, -1
$PLAYINT(1)
$PLAYINT(2)
$PLAYINT(3)
$PLAYINT(4)
$PLAYINT(5)
$PLAYINT(6)
$PLAYINT(7)
$PLAYINT(8)
$PLAYINT(9)
ihandle FLbox "Player 1", 8, 1, 12, 50, 25, 550, 100
ihandle FLbox "Player 2", 8, 1, 12, 50, 25, 600, 100
ihandle FLbox "Player 3", 8, 1, 12, 50, 25, 650, 100
ihandle FLbox "Player 4", 8, 1, 12, 50, 25, 700, 100
ihandle FLbox "Player 5", 8, 1, 12, 50, 25, 750, 100
ihandle FLbox "Player 6", 8, 1, 12, 50, 25, 800, 100
ihandle FLbox "Player 7", 8, 1, 12, 50, 25, 850, 100
ihandle FLbox "Player 8", 8, 1, 12, 50, 25, 900, 100
ihandle FLbox "Player 9", 8, 1, 12, 50, 25, 950, 100
ihandle FLbox "@|>", 8, 1, 12, 50, 25, 500, 125
ihandle FLbox "q", 8, 1, 12, 50, 25, 550, 125
ihandle FLbox "w", 8, 1, 12, 50, 25, 600, 125
ihandle FLbox "e", 8, 1, 12, 50, 25, 650, 125
ihandle FLbox "r", 8, 1, 12, 50, 25, 700, 125
ihandle FLbox "t", 8, 1, 12, 50, 25, 750, 125
ihandle FLbox "y", 8, 1, 12, 50, 25, 800, 125
ihandle FLbox "u", 8, 1, 12, 50, 25, 850, 125
ihandle FLbox "i", 8, 1, 12, 50, 25, 900, 125
ihandle FLbox "o", 8, 1, 12, 50, 25, 950, 125
ihandle FLbox "Next", 8, 1, 12, 50, 25, 500, 150
ihandle FLbox "a", 8, 1, 12, 50, 25, 550, 150
ihandle FLbox "s", 8, 1, 12, 50, 25, 600, 150
ihandle FLbox "d", 8, 1, 12, 50, 25, 650, 150
ihandle FLbox "f", 8, 1, 12, 50, 25, 700, 150
ihandle FLbox "g", 8, 1, 12, 50, 25, 750, 150
ihandle FLbox "h", 8, 1, 12, 50, 25, 800, 150
ihandle FLbox "j", 8, 1, 12, 50, 25, 850, 150
ihandle FLbox "k", 8, 1, 12, 50, 25, 900, 150
ihandle FLbox "l", 8, 1, 12, 50, 25, 950, 150
ihandle FLbox "Volume", 8, 1, 12, 50, 250, 500, 175
gkvol1, gihanv1 FLslider "", 0, 1, 0, 6, -75, 30, 240, 560, 180
gkvol2, gihanv2 FLslider "", 0, 1, 0, 6, -75, 30, 240, 610, 180
gkvol3, gihanv3 FLslider "", 0, 1, 0, 6, -75, 30, 240, 660, 180
gkvol4, gihanv4 FLslider "", 0, 1, 0, 6, -75, 30, 240, 710, 180
gkvol5, gihanv5 FLslider "", 0, 1, 0, 6, -75, 30, 240, 760, 180
gkvol6, gihanv6 FLslider "", 0, 1, 0, 6, -75, 30, 240, 810, 180
gkvol7, gihanv7 FLslider "", 0, 1, 0, 6, -75, 30, 240, 860, 180
gkvol8, gihanv8 FLslider "", 0, 1, 0, 6, -75, 30, 240, 910, 180
gkvol9, gihanv9 FLslider "", 0, 1, 0, 6, -75, 30, 240, 960, 180
ihandle FLbox "Pan", 8, 1, 12, 50, 25, 500, 425
gkpan1, ihanp1 FLslider "", 0, 1, 0, 5, -75, 50, 25, 550, 425
gkpan2, ihanp2 FLslider "", 0, 1, 0, 5, -75, 50, 25, 600, 425
gkpan3, ihanp3 FLslider "", 0, 1, 0, 5, -75, 50, 25, 650, 425
gkpan4, ihanp4 FLslider "", 0, 1, 0, 5, -75, 50, 25, 700, 425
gkpan5, ihanp5 FLslider "", 0, 1, 0, 5, -75, 50, 25, 750, 425
gkpan6, ihanp6 FLslider "", 0, 1, 0, 5, -75, 50, 25, 800, 425
gkpan7, ihanp7 FLslider "", 0, 1, 0, 5, -75, 50, 25, 850, 425
gkpan8, ihanp8 FLslider "", 0, 1, 0, 5, -75, 50, 25, 900, 425
gkpan9, ihanp9 FLslider "", 0, 1, 0, 5, -75, 50, 25, 950, 425
FLsetVal_i .2, gihanv1
FLsetVal_i .2, gihanv2
FLsetVal_i .2, gihanv3
FLsetVal_i .2, gihanv4
FLsetVal_i .2, gihanv5
FLsetVal_i .2, gihanv6
FLsetVal_i .2, gihanv7
FLsetVal_i .2, gihanv8
FLsetVal_i .2, gihanv9
FLsetVal_i .5, ihanp1
FLsetVal_i .5, ihanp2
FLsetVal_i .5, ihanp3
FLsetVal_i .5, ihanp4
FLsetVal_i .5, ihanp5
FLsetVal_i .5, ihanp6
FLsetVal_i .5, ihanp7
FLsetVal_i .5, ihanp8
FLsetVal_i .5, ihanp9
ihandle FLbox "Wrong\nTiming", 8, 1, 12, 50, 50, 500, 450
gktimi1, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 550, 450, 20
gktimi2, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 600, 450, 20
gktimi3, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 650, 450, 20
gktimi4, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 700, 450, 20
gktimi5, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 750, 450, 20
gktimi6, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 800, 450, 20
gktimi7, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 850, 450, 20
gktimi8, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 900, 450, 20
gktimi9, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 950, 450, 20
ihandle FLbox "Wrong\nIntensity", 8, 1, 12, 50, 50, 500, 500
gkinte1, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 550, 500, 20
gkinte2, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 600, 500, 20
gkinte3, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 650, 500, 20
gkinte4, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 700, 500, 20
gkinte5, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 750, 500, 20
gkinte6, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 800, 500, 20
gkinte7, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 850, 500, 20
gkinte8, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 900, 500, 20
gkinte9, iktimi FLknob "", 0, 1, 0, 1, -1, 50, 950, 500, 20
;Globals
ihandle FLbox "Global", 8, 1, 12, 50, 100, 500, 550
ihandle FLbox "Volume", 8, 1, 12, 60, 25, 550, 550
gkpppfff, ipppfff FLknob "ppp - fff", 0.01, 2, 0, 1, -1, 60, 550, 575, 20 
ihandle FLbox "Alt Key\nAll the\nPlayers\ntogether\nOnOff", 8, 1, 12, 60, 75, 610, 550
gkOnOffAll, gihOnOffAll FLbutton	"@|>",	1, 0, 2, 60, 25, 610, 625, 0, 1, 0, -1
FLsetVal_i 1, ipppfff
ihandle FLbox "Reverb", 8, 1, 12, 180, 25, 670, 550
gkwet, iwet FLknob "dry-wet", 0, 1, 0, 1, -1, 60, 670, 575, 20 
gkfblvl, ifblvl FLknob "feedback", 0, 1, 0, 1, -1, 60, 730, 575, 20
gkfcoff, icuto FLknob "cutoff", 0, sr/2, 0, 1, -1, 60, 790, 575, 20
FLsetVal_i sr/4, icuto
;Record performance
ihandle FLbox "Recording", 8, 1, 12, 100, 25, 850, 550
gkRecPerfo, giRecPerfo FLbutton	"Rec\ndon't\nswitch\nOff",	1, 0, 2, 100, 75, 850, 575, 0, 402, 0, -1
FLpanelEnd
FLrun

;Tab readers ---------------------------------------------------
instr 1
;TABREADER
;find duration of patterns stored into tables
;read the table pattern length to find the value of the loop
;lenght of Patterns are analized then stored into a ftable 1
;Do not use values of -1 in the external file unless used for repeat section
if p4 == 0 goto calcul ; Just in case...
iipattdur init 0
ipointpattern init 0
back:
	iipattdur table ipointpattern, 100 + p4
	if (iipattdur == -1) igoto calcul
	ipointpattern = ipointpattern+1
	igoto back
calcul:
	iipattdur table ipointpattern+1, 100 + p4
	tableiw iipattdur, p4, 100
	prints "Pattern %i : %i \n", p4, iipattdur
	turnoff
endin

;Control-----------------------------------------------------------
instr 98; initialize some variables
gkpatt_index1 init 0
gkpatt_duration01 table gkpatt_index1+1, gipattdur
gkpatt_duration_new01 = gkpatt_duration01

gkpatt_index2 init 0
gkpatt_duration02 table gkpatt_index2+1, gipattdur
gkpatt_duration_new02 = gkpatt_duration02

gkpatt_index3 init 0
gkpatt_duration03 table gkpatt_index3+1, gipattdur
gkpatt_duration_new03 = gkpatt_duration03

gkpatt_index4 init 0
gkpatt_duration04 table gkpatt_index4+1, gipattdur
gkpatt_duration_new04 = gkpatt_duration04

gkpatt_index5 init 0
gkpatt_duration05 table gkpatt_index5+1, gipattdur
gkpatt_duration_new05 = gkpatt_duration05

gkpatt_index6 init 0
gkpatt_duration06 table gkpatt_index6+1, gipattdur
gkpatt_duration_new06 = gkpatt_duration06

gkpatt_index7 init 0
gkpatt_duration07 table gkpatt_index7+1, gipattdur
gkpatt_duration_new07 = gkpatt_duration07

gkpatt_index8 init 0
gkpatt_duration08 table gkpatt_index8+1, gipattdur
gkpatt_duration_new08 = gkpatt_duration08

gkpatt_index9 init 0
gkpatt_duration09 table gkpatt_index9+1, gipattdur
gkpatt_duration_new09 = gkpatt_duration09
turnoff
endin


instr 99
gkc1 init 0
gkc2 init 0
gkc3 init 0
gkc4 init 0
gkc5 init 0
gkc6 init 0
gkc7 init 0
gkc8 init 0
kPulse metro (2*gkBPM/60)
kpulse_quantize metro (2*gkBPM/60)
;Audio Metronome
if (gkc1 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 5.00
endif
if (gkc2 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 6.00
endif
if (gkc3 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 7.00
endif
if (gkc4 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 8.00
endif
if (gkc5 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 9.00
endif
if (gkc6 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 10.00
endif
if (gkc7 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 11.00
endif
if (gkc8 == 1) then
	schedkwhen   kPulse, -1, -1, 300, 0, 15/gkBPM, gkmetrovol*.1, 12.00
endif
;COmputer Keyboard Control
gkkeypressed FLkeyIn
keyactivation changed gkkeypressed
;Start stop keys
;q key
kbuttonq init 0
if (gkkeypressed == 113 && keyactivation == 1) then
	if (kbuttonq == 0) then
		kbuttonq = 1
		FLsetVal 1, kbuttonq, gihOnOff1
	else
		kbuttonq = 0
		FLsetVal 1, kbuttonq, gihOnOff1
	endif
endif
;w key
kbuttonw init 0
if (gkkeypressed == 119 && keyactivation == 1) then
	if (kbuttonw == 0) then
		kbuttonw = 1
		FLsetVal 1, kbuttonw, gihOnOff2
	else
		kbuttonw = 0
		FLsetVal 1, kbuttonw, gihOnOff2
	endif
endif
;e key
kbuttone init 0
if (gkkeypressed == 101 && keyactivation == 1) then
	if (kbuttone == 0) then
		kbuttone = 1
		FLsetVal 1, kbuttone, gihOnOff3
	else
		kbuttone = 0
		FLsetVal 1, kbuttone, gihOnOff3
	endif
endif
;r key
kbuttonr init 0
if (gkkeypressed == 114 && keyactivation == 1) then
	if (kbuttonr == 0) then
		kbuttonr = 1
		FLsetVal 1, kbuttonr, gihOnOff4
	else
		kbuttonr = 0
		FLsetVal 1, kbuttonr, gihOnOff4
	endif
endif
;t key
kbuttont init 0
if (gkkeypressed == 116 && keyactivation == 1) then
	if (kbuttont == 0) then
		kbuttont = 1
		FLsetVal 1, kbuttont, gihOnOff5
	else
		kbuttont = 0
		FLsetVal 1, kbuttont, gihOnOff5
	endif
endif
;y key
kbuttony init 0
if (gkkeypressed == 121 && keyactivation == 1) then
	if (kbuttony == 0) then
		kbuttony = 1
		FLsetVal 1, kbuttony, gihOnOff6
	else
		kbuttony = 0
		FLsetVal 1, kbuttony, gihOnOff6
	endif
endif
;u key
kbuttonu init 0
if (gkkeypressed == 117 && keyactivation == 1) then
	if (kbuttonu == 0) then
		kbuttonu = 1
		FLsetVal 1, kbuttonu, gihOnOff7
	else
		kbuttonu = 0
		FLsetVal 1, kbuttonu, gihOnOff7
	endif
endif
;i key
kbuttoni init 0
if (gkkeypressed == 105 && keyactivation == 1) then
	if (kbuttoni == 0) then
		kbuttoni = 1
		FLsetVal 1, kbuttoni, gihOnOff8
	else
		kbuttoni = 0
		FLsetVal 1, kbuttoni, gihOnOff8
	endif
endif
;o key
kbuttono init 0
if (gkkeypressed == 111 && keyactivation == 1) then
	if (kbuttono == 0) then
		kbuttono = 1
		FLsetVal 1, kbuttono, gihOnOff9
	else
		kbuttono = 0
		FLsetVal 1, kbuttono, gihOnOff9
	endif
endif

;activate all the players together!
kbuttonAlt init 0
if (gkkeypressed == 489 && keyactivation == 1) then
	if (gkOnOffAll == 0) then
		FLsetVal 1, 1, gihOnOffAll
	elseif (gkOnOffAll == 1) then
		FLsetVal 1, 0, gihOnOffAll
	endif
endif

ktriggAll changed gkOnOffAll
if (ktriggAll == 1) then
	if (gkOnOffAll == 1) then
		FLsetVal 1, 1, gihOnOff1
		FLsetVal 1, 1, gihOnOff2
		FLsetVal 1, 1, gihOnOff3
		FLsetVal 1, 1, gihOnOff4
		FLsetVal 1, 1, gihOnOff5
		FLsetVal 1, 1, gihOnOff6
		FLsetVal 1, 1, gihOnOff7
		FLsetVal 1, 1, gihOnOff8
		FLsetVal 1, 1, gihOnOff9
	elseif (gkOnOffAll == 0) then
		FLsetVal 1, 0, gihOnOff1
		FLsetVal 1, 0, gihOnOff2
		FLsetVal 1, 0, gihOnOff3
		FLsetVal 1, 0, gihOnOff4
		FLsetVal 1, 0, gihOnOff5
		FLsetVal 1, 0, gihOnOff6
		FLsetVal 1, 0, gihOnOff7
		FLsetVal 1, 0, gihOnOff8
		FLsetVal 1, 0, gihOnOff9
	endif
endif

;Next pattern keys
;a key
kbuttona init 0
if (gkkeypressed == 97 && keyactivation == 1) then
	if (kbuttona < 52) then
		kbuttona = kbuttona + 1
		FLsetVal 1, kbuttona, giflbuttbank1
	endif
endif
;s key
kbuttons init 0
if (gkkeypressed == 115 && keyactivation == 1) then
	if (kbuttons < 52) then
		kbuttons = kbuttons + 1
		FLsetVal 1, kbuttons, giflbuttbank2
	endif
endif
;d key
kbuttond init 0
if (gkkeypressed == 100 && keyactivation == 1) then
	if (kbuttond < 52) then
		kbuttond = kbuttond + 1
		FLsetVal 1, kbuttond, giflbuttbank3
	endif
endif
;f key
kbuttonf init 0
if (gkkeypressed == 102 && keyactivation == 1) then
	if (kbuttonf < 52) then
		kbuttonf = kbuttonf + 1
		FLsetVal 1, kbuttonf, giflbuttbank4
	endif
endif
;g key
kbuttong init 0
if (gkkeypressed == 103 && keyactivation == 1) then
	if (kbuttong < 52) then
		kbuttong = kbuttong + 1
		FLsetVal 1, kbuttong, giflbuttbank5
	endif
endif
;h key
kbuttonh init 0
if (gkkeypressed == 104 && keyactivation == 1) then
	if (kbuttonh < 52) then
		kbuttonh = kbuttonh + 1
		FLsetVal 1, kbuttonh, giflbuttbank6
	endif
endif
;j key
kbuttonj init 0
if (gkkeypressed == 106 && keyactivation == 1) then
	if (kbuttonj < 52) then
		kbuttonj = kbuttonj + 1
		FLsetVal 1, kbuttonj, giflbuttbank7
	endif
endif
;k key
kbuttonk init 0
if (gkkeypressed == 107 && keyactivation == 1) then
	if (kbuttonk < 52) then
		kbuttonk = kbuttonk + 1
		FLsetVal 1, kbuttonk, giflbuttbank8
	endif
endif
;l key
kbuttonl init 0
if (gkkeypressed == 108 && keyactivation == 1) then
	if (kbuttonl < 52) then
		kbuttonl = kbuttonl + 1
		FLsetVal 1, kbuttonl, giflbuttbank9
	endif
endif




;---------------------------------------------------------------
;Player 1
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn1 trigger gkOnOff1, 0.5, 0
		schedkwhen ktrigOn1, 0, 0, 101, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff1 trigger gkOnOff1, 0.5, 1
	schedkwhen ktrigOff1, 0, 0, -101, 0, 1 
	schedkwhen ktrigOff1, 0, 0, -201, 0, 1  

;Player 2
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn2 trigger gkOnOff2, 0.5, 0
		schedkwhen ktrigOn2, 0, 0, 102, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff2 trigger gkOnOff2, 0.5, 1
	schedkwhen ktrigOff2, 0, 0, -102, 0, 1 
	schedkwhen ktrigOff2, 0, 0, -202, 0, 1  

;Player 3
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn3 trigger gkOnOff3, 0.5, 0
		schedkwhen ktrigOn3, 0, 0, 103, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff3 trigger gkOnOff3, 0.5, 1
	schedkwhen ktrigOff3, 0, 0, -103, 0, 1 
	schedkwhen ktrigOff3, 0, 0, -203, 0, 1  

;Player 4
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn4 trigger gkOnOff4, 0.5, 0
		schedkwhen ktrigOn4, 0, 0, 104, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff4 trigger gkOnOff4, 0.5, 1
	schedkwhen ktrigOff4, 0, 0, -104, 0, 1 
	schedkwhen ktrigOff4, 0, 0, -204, 0, 1  

;Player 5
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn5 trigger gkOnOff5, 0.5, 0
		schedkwhen ktrigOn5, 0, 0, 105, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff5 trigger gkOnOff5, 0.5, 1
	schedkwhen ktrigOff5, 0, 0, -105, 0, 1 
	schedkwhen ktrigOff5, 0, 0, -205, 0, 1  

;Player 6
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn6 trigger gkOnOff6, 0.5, 0
		schedkwhen ktrigOn6, 0, 0, 106, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff6 trigger gkOnOff6, 0.5, 1
	schedkwhen ktrigOff6, 0, 0, -106, 0, 1 
	schedkwhen ktrigOff6, 0, 0, -206, 0, 1  

;Player 7
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn7 trigger gkOnOff7, 0.5, 0
		schedkwhen ktrigOn7, 0, 0, 107, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff7 trigger gkOnOff7, 0.5, 1
	schedkwhen ktrigOff7, 0, 0, -107, 0, 1 
	schedkwhen ktrigOff7, 0, 0, -207, 0, 1  

;Player 8
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn8 trigger gkOnOff8, 0.5, 0
		schedkwhen ktrigOn8, 0, 0, 108, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff8 trigger gkOnOff8, 0.5, 1
	schedkwhen ktrigOff8, 0, 0, -108, 0, 1 
	schedkwhen ktrigOff8, 0, 0, -208, 0, 1  

;Player 9
;Sync Sequencer-On with metro pulse signal
if (kpulse_quantize = 1) then
	ktrigOn9 trigger gkOnOff9, 0.5, 0
		schedkwhen ktrigOn9, 0, 0, 109, 0, -1
endif
;Turn Off the trigger instrument and the pattern reader whenever needed 
;without syncro to metronome signal 
ktrigOff9 trigger gkOnOff9, 0.5, 1
	schedkwhen ktrigOff9, 0, 0, -109, 0, 1 
	schedkwhen ktrigOff9, 0, 0, -209, 0, 1  

endin

instr 101 ;trigger a performer on providing the table in the pfield 
gkp101 init 0
gkp201 init 0
gkp301 init 0
gkp401 init 0
gkp501 init 0
gkp601 init 0
gkphs01 init 1
kcambio metro gkBPM / (gkpatt_duration01 * 60)
;Selected Pattern parameters
gkpatt_duration_new01 table gkpatt_index1+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt01 	= gkpatt_index1 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart201
else
	kgoto nothing
endif
stopstart201:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 201, 0, 0
	schedkwhen   1, 0, -1, 201, 0, -3, gktablepatt01, gkpatt_duration_new01
	gkpatt_duration01 = gkpatt_duration_new01
nothing:
endin

instr 102 ;trigger a performer on providing the table in the pfield 
gkp102 init 0
gkp202 init 0
gkp302 init 0
gkp402 init 0
gkp502 init 0
gkp602 init 0
gkphs02 init 1
kcambio metro gkBPM / (gkpatt_duration02 * 60)
;Selected Pattern parameters
gkpatt_duration_new02 table gkpatt_index2+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt02 	= gkpatt_index2 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart202
else
	kgoto nothing
endif
stopstart202:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 202, 0, 0
	schedkwhen   1, 0, -1, 202, 0, -3, gktablepatt02, gkpatt_duration_new02
	gkpatt_duration02 = gkpatt_duration_new02
nothing:
endin

instr 103 ;trigger a performer on providing the table in the pfield 
gkp103 init 0
gkp203 init 0
gkp303 init 0
gkp403 init 0
gkp503 init 0
gkp603 init 0
gkphs03 init 1
kcambio metro gkBPM / (gkpatt_duration03 * 60)
;Selected Pattern parameters
gkpatt_duration_new03 table gkpatt_index3+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt03 	= gkpatt_index3 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart203
else
	kgoto nothing
endif
stopstart203:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 203, 0, 0
	schedkwhen   1, 0, -1, 203, 0, -3, gktablepatt03, gkpatt_duration_new03
	gkpatt_duration03 = gkpatt_duration_new03
nothing:
endin

instr 104 ;trigger a performer on providing the table in the pfield 
gkp104 init 0
gkp204 init 0
gkp304 init 0
gkp404 init 0
gkp504 init 0
gkp604 init 0
gkphs04 init 1
kcambio metro gkBPM / (gkpatt_duration04 * 60)
;Selected Pattern parameters
gkpatt_duration_new04 table gkpatt_index4+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt04 	= gkpatt_index4 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart204
else
	kgoto nothing
endif
stopstart204:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 204, 0, 0
	schedkwhen   1, 0, -1, 204, 0, -3, gktablepatt04, gkpatt_duration_new04
	gkpatt_duration04 = gkpatt_duration_new04
nothing:
endin

instr 105 ;trigger a performer on providing the table in the pfield 
gkp105 init 0
gkp205 init 0
gkp305 init 0
gkp405 init 0
gkp505 init 0
gkp605 init 0
gkphs05 init 1
kcambio metro gkBPM / (gkpatt_duration05 * 60)
;Selected Pattern parameters
gkpatt_duration_new05 table gkpatt_index5+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt05 	= gkpatt_index5 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart205
else
	kgoto nothing
endif
stopstart205:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 205, 0, 0
	schedkwhen   1, 0, -1, 205, 0, -3, gktablepatt05, gkpatt_duration_new05
	gkpatt_duration05 = gkpatt_duration_new05
nothing:
endin

instr 106 ;trigger a performer on providing the table in the pfield 
gkp106 init 0
gkp206 init 0
gkp306 init 0
gkp406 init 0
gkp506 init 0
gkp606 init 0
gkphs06 init 1
kcambio metro gkBPM / (gkpatt_duration06 * 60)
;Selected Pattern parameters
gkpatt_duration_new06 table gkpatt_index6+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt06 	= gkpatt_index6 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart206
else
	kgoto nothing
endif
stopstart206:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 206, 0, 0
	schedkwhen   1, 0, -1, 206, 0, -3, gktablepatt06, gkpatt_duration_new06
	gkpatt_duration06 = gkpatt_duration_new06
nothing:
endin

instr 107 ;trigger a performer on providing the table in the pfield 
gkp107 init 0
gkp207 init 0
gkp307 init 0
gkp407 init 0
gkp507 init 0
gkp607 init 0
gkphs07 init 1
kcambio metro gkBPM / (gkpatt_duration07 * 60)
;Selected Pattern parameters
gkpatt_duration_new07 table gkpatt_index7+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt07 	= gkpatt_index7 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart207
else
	kgoto nothing
endif
stopstart207:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 207, 0, 0
	schedkwhen   1, 0, -1, 207, 0, -3, gktablepatt07, gkpatt_duration_new07
	gkpatt_duration07 = gkpatt_duration_new07
nothing:
endin

instr 108 ;trigger a performer on providing the table in the pfield 
gkp108 init 0
gkp208 init 0
gkp308 init 0
gkp408 init 0
gkp508 init 0
gkp608 init 0
gkphs08 init 1
kcambio metro gkBPM / (gkpatt_duration08 * 60)
;Selected Pattern parameters
gkpatt_duration_new08 table gkpatt_index8+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt08 	= gkpatt_index8 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart208
else
	kgoto nothing
endif
stopstart208:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 208, 0, 0
	schedkwhen   1, 0, -1, 208, 0, -3, gktablepatt08, gkpatt_duration_new08
	gkpatt_duration08 = gkpatt_duration_new08
nothing:
endin

instr 109 ;trigger a performer on providing the table in the pfield 
gkp109 init 0
gkp209 init 0
gkp309 init 0
gkp409 init 0
gkp509 init 0
gkp609 init 0
gkphs09 init 1
kcambio metro gkBPM / (gkpatt_duration09 * 60)
;Selected Pattern parameters
gkpatt_duration_new09 table gkpatt_index9+1, gipattdur
;gktablepatt01 table gkpatt_index1, gitablepatt
gktablepatt09 	= gkpatt_index9 + 101
;Instrument pattern change logic
if (kcambio = 1) then
	kgoto stopstart209
else
	kgoto nothing
endif
stopstart209:
	;turn off and on the instrument 201 with the new table number if the pattern is finished
	turnoff2 209, 0, 0
	schedkwhen   1, 0, -1, 209, 0, -3, gktablepatt09, gkpatt_duration_new09
	gkpatt_duration09 = gkpatt_duration_new09
nothing:
endin

;-----------------------------------------------------------------------------------------------
;Pattern reader
instr 201 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi1
kinte linrand gkinte1
kvolvar = (1 - gkinte1) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs01 phasor gkBPM / (k(p5)* 60)
kphs = gkphs01 * k(p5)
ktrig   timedseq kphs,p4,gkp101,gkp201,gkp301,gkp401,gkp501
gkdur01 = (60/gkBPM) * gkp301 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 301 + .001 * ktiming, ktiming, gkdur01, gkp401 * (1 - gkvol1) * gkpppfff * kvolvar, gkp501
endin

instr 202 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi2
kinte linrand gkinte2
kvolvar = (1 - gkinte2) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs02 phasor gkBPM / (k(p5)* 60)
kphs = gkphs02 * k(p5)
ktrig   timedseq kphs,p4,gkp102,gkp202,gkp302,gkp402,gkp502
gkdur02 = (60/gkBPM) * gkp302 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 302 + .001 * ktiming, ktiming, gkdur02, gkp402 * (1 - gkvol2) * gkpppfff * kvolvar, gkp502
endin

instr 203 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi3
kinte linrand gkinte3
kvolvar = (1 - gkinte3) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs03 phasor gkBPM / (k(p5)* 60)
kphs = gkphs03 * k(p5)
ktrig   timedseq kphs,p4,gkp103,gkp203,gkp303,gkp403,gkp503
gkdur03 = (60/gkBPM) * gkp303 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 303 + .001 * ktiming, ktiming, gkdur03, gkp403 * (1 - gkvol3) * gkpppfff * kvolvar, gkp503
endin

instr 204 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi4
kinte linrand gkinte4
kvolvar = (1 - gkinte4) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs04 phasor gkBPM / (k(p5)* 60)
kphs = gkphs04 * k(p5)
ktrig   timedseq kphs,p4,gkp104,gkp204,gkp304,gkp404,gkp504
gkdur04 = (60/gkBPM) * gkp304 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 304 + .001 * ktiming, ktiming, gkdur04, gkp404 * (1 - gkvol4) * gkpppfff * kvolvar, gkp504
endin

instr 205 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi5
kinte linrand gkinte5
kvolvar = (1 - gkinte5) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs05 phasor gkBPM / (k(p5)* 60)
kphs = gkphs05 * k(p5)
ktrig   timedseq kphs,p4,gkp105,gkp205,gkp305,gkp405,gkp505
gkdur05 = (60/gkBPM) * gkp305 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 305 + .001 * ktiming, ktiming, gkdur05, gkp405 * (1 - gkvol5) * gkpppfff * kvolvar, gkp505
endin

instr 206 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi6
kinte linrand gkinte6
kvolvar = (1 - gkinte6) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs06 phasor gkBPM / (k(p5)* 60)
kphs = gkphs06 * k(p5)
ktrig   timedseq kphs,p4,gkp106,gkp206,gkp306,gkp406,gkp506
gkdur06 = (60/gkBPM) * gkp306 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 306 + .001 * ktiming, ktiming, gkdur06, gkp406 * (1 - gkvol6) * gkpppfff * kvolvar, gkp506
endin

instr 207 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi7
kinte linrand gkinte7
kvolvar = (1 - gkinte7) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs07 phasor gkBPM / (k(p5)* 60)
kphs = gkphs07 * k(p5)
ktrig   timedseq kphs,p4,gkp107,gkp207,gkp307,gkp407,gkp507
gkdur07 = (60/gkBPM) * gkp307 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 307 + .001 * ktiming, ktiming, gkdur07, gkp407 * (1 - gkvol7) * gkpppfff * kvolvar, gkp507
endin

instr 208 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi8
kinte linrand gkinte8
kvolvar = (1 - gkinte8) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs08 phasor gkBPM / (k(p5)* 60)
kphs = gkphs08 * k(p5)
ktrig   timedseq kphs,p4,gkp108,gkp208,gkp308,gkp408,gkp508
gkdur08 = (60/gkBPM) * gkp308 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 308 + .001 * ktiming, ktiming, gkdur08, gkp408 * (1 - gkvol8) * gkpppfff * kvolvar, gkp508
endin

instr 209 ;read the table selected
ktiming linrand (30 / gkBPM) * gktimi9
kinte linrand gkinte9
kvolvar = (1 - gkinte9) + kinte * 2
kphs init 1
;phasor running at BPM speed and pattern duration
gkphs09 phasor gkBPM / (k(p5)* 60)
kphs = gkphs09 * k(p5)
ktrig   timedseq kphs,p4,gkp109,gkp209,gkp309,gkp409,gkp509
gkdur09 = (60/gkBPM) * gkp309 ;resize duration according to the BPM selected
	schedkwhen   ktrig, -1, -1, 309, ktiming + .001 * ktiming, gkdur09, gkp409 * (1 - gkvol9) * gkpppfff * kvolvar, gkp509
endin


;Audio Generators ----------------------------------------------------------------------------- 
instr 300
;Pulse Sound
inote = cpspch(p5)
kres linseg 0, .005, p4 , .01, p4*.8 ,p3-.1, p4*.67, .05, 0 
kston linseg 1.3, .01, .99 , p3, 1
a1 oscil kres, inote, 3, .5
a2 oscil kres*.3, inote*2*kston, 3
a3 oscil kres*.2, inote*.5*kston, 3
aenv = a1 + a2 + a3
zawm aenv, 0
endin

instr 301
;Player 1
ktot linseg 0, .01, 1, p3-.03, 1, .015, 0
inote = cpspch(p5)
ivol = p4 *.5
ares fmvoice ivol, inote, 1, 0, .002, 4, 3, 1, 1, 1, 3
kpanl = sqrt(1-gkpan1)
kpanr = sqrt(gkpan1)
zaw ares*kpanl*ktot, 1
zaw ares*kpanr*ktot, 2
endin

instr 302
;Player 2
ktot linseg 0, .01, 1, p3-.03, 1, .015, 0
inote = cpspch(p5)
ivol = p4 *.1
kmoden expseg inote*4.5, .1, inote *2.1, p3 - .1, inote *1.9
kenvelope linseg 0, .05, 1, .05, .95 ,p3-.20, .67, .05, 0
kmod oscil kmoden, inote*.5, 1
acarr oscil ivol, inote+kmod, 1
acarr = acarr * kenvelope
kpanl = sqrt(1-gkpan2)
kpanr = sqrt(gkpan2)
zaw acarr*kpanl*ktot, 3
zaw acarr*kpanr*ktot, 4
endin

instr 303
;Player 3
ktot linseg 0, .01, 1, p3-.03, 1, .015, 0
inote = cpspch(p5)
ivol = p4 *.3
kenvelope linseg 0, .08, 1, .05, .95 ,p3-.20, .67, .05, 0
kpw expseg .001, p3, .6 
ares vco inote*.25, inote, 3, kpw
acarr oscil ivol, inote+ares, 3
acarr = acarr * kenvelope
kpanl = sqrt(1-gkpan3)
kpanr = sqrt(gkpan3)
zaw acarr*kpanl*ktot, 5
zaw acarr*kpanr*ktot, 6
endin

instr 304
;Player 4
iplk1 = .27
iplk2 = .2
ivel = p4 *.25
kamp linseg ivel*.1, .01, ivel, p3-.05, ivel*.5, .01, 0; envelope
kamp1 linseg ivel*.05, .008, ivel*.15, p3-.05, ivel*.01, .01, ivel*.01; envelope
icps = cpspch(p5)
kpick1 = .70
kpick3 = .88
krefl = .4
apickup1 wgpluck2 iplk1, kamp*2, icps, kpick1, krefl
apickup3h wgpluck2 iplk2, kamp*.7, icps*2.01, kpick3, krefl
apickup3l wgpluck2 iplk2, kamp1*.7, icps*1.98, kpick3, krefl
aout = apickup1 +apickup3h + apickup3l
abass butterlp aout, 6000
amid butterbp aout, 3500, 200
amid = 3*amid
kpanl = sqrt(1-gkpan4)
kpanr = sqrt(gkpan4)
zaw (abass+amid)*kpanl, 7
zaw (abass+amid)*kpanr, 8
endin

instr 305
;Player 5
ktot linseg 0, .09, 1, p3-.03, 1, .015, 0
inote = cpspch(p5)
ivol = p4 *.05
kenvelope linseg 0, .09, 1, p3-.15, .97, .05, 0
kbtt line 1.2, p3, .6
kmod oscil kbtt, inote * .5, 3
acarr oscil (kmod*ivol), inote, 1
kpanl = sqrt(1-gkpan5)
kpanr = sqrt(gkpan5)
zaw acarr*kpanl*ktot, 9
zaw acarr*kpanr*ktot, 10
endin

instr 306
;Player 6
;Player 1
ktot linseg 0, .01, 1, p3-.03, 1, .015, 0
inote = cpspch(p5)
ivol = p4 *.6
ares fmvoice ivol, inote, 11, 0, .03, 4, 3, 1, 1, 1, 3
kpanl = sqrt(1-gkpan6)
kpanr = sqrt(gkpan6)
zaw ares*kpanl*ktot, 11
zaw ares*kpanr*ktot, 12
endin

instr 307
;Player 7
ktot linseg 0, .05, 1, p3-.7, 1, .02, 0
inote = cpspch(p5)
ivol = p4 *.5
kmoden expseg inote*4.2, .1, inote *2.15, p3 - .1, inote *1.87
kenvelope linseg 0, .1, 1, .02, .91 ,p3-.20, .87, .08, 0
kmod oscil kmoden, inote*.51, 1
acarr oscil ivol, inote+kmod, 1
acarr = acarr * kenvelope
kpanl = sqrt(1-gkpan7)
kpanr = sqrt(gkpan7)
zaw acarr*kpanl*ktot, 13
zaw acarr*kpanr*ktot, 14
endin

instr 308
;Player 8
ktot linseg 0, .2, 1, p3-.3, 1, .1, 0
inote = cpspch(p5)
ivol = p4 *.1
kenvelope linseg 0, .096, 1, p3-.15, .97, .1, 0
kbtt line .7, p3, 1.1 
kmod oscil kbtt, inote *2, 3
acarr oscil (kmod*ivol), inote, 1
kpanl = sqrt(1-gkpan8)
kpanr = sqrt(gkpan8)
zaw acarr*kpanl*ktot, 15
zaw acarr*kpanr*ktot, 16
endin

instr 309
;Player 9
iplk1 = .37
iplk2 = .15
ivel = p4 *.25
kamp linseg ivel*.1, .01, ivel, p3-.05, ivel*.5, .01, 0; envelope
kamp1 linseg ivel*.05, .008, ivel*.15, p3-.05, ivel*.01, .01, ivel*.01; envelope
icps = cpspch(p5)
kpick1 = .50
kpick3 = .99
krefl = .4
apickup1 wgpluck2 iplk1, kamp*2, icps, kpick1, krefl
apickup3h wgpluck2 iplk2, kamp*.4, icps*2.3, kpick3, krefl
apickup3l wgpluck2 iplk2, kamp1*.9, icps*1.97, kpick3, krefl
aout = apickup1 +apickup3h + apickup3l
abass butterlp aout, 4000
amid butterbp aout, 1000, 100
amid = 3*amid
kpanl = sqrt(1-gkpan9)
kpanr = sqrt(gkpan9)
zaw (abass+amid)*kpanl, 17
zaw (abass+amid)*kpanr, 18
endin

instr 400
;mixer
apulse zar 0
a1l zar 1
a1r zar 2
a2l zar 3
a2r zar 4
a3l zar 5
a3r zar 6
a4l zar 7
a4r zar 8
a5l zar 9
a5r zar 10
a6l zar 11
a6r zar 12
a7l zar 13
a7r zar 14
a8l zar 15
a8r zar 16
a9l zar 17
a9r zar 18
k1correction init 1
k2correction init 1
k3correction init 1
k4correction init 1
k5correction init 1
k6correction init 1
k7correction init 1
k8correction init 1
k9correction init 1
;galeft = apulse + a1l + a2l + a3l + a4l + a5l + a6l + a7l + a8l + a9l
;garight = apulse + a1r + a2r + a3r + a4r + a5r + a6r + a7r + a8r + a9r

galeft = apulse + a1l * k1correction + a2l * k2correction + a3l * k2correction + a4l * k4correction + a5l * k5correction + a6l * k6correction + a7l * k1correction + a8l * k8correction + a9l * k9correction
garight = apulse + a1r * k1correction + a2r * k2correction + a3r * k2correction + a4r * k4correction + a5r * k5correction + a6r * k6correction + a7r * k7correction + a8r * k8correction + a9r * k9correction
zacl 0, 19
endin

instr 401
;room
ipitchm = 1
gaoutL, gaoutR reverbsc galeft, garight, gkfblvl, gkfcoff, sr, ipitchm
gaeffLH = (galeft * (1 -gkwet) + gaoutL * gkwet)
gaeffRH = (garight * (1 -gkwet) + gaoutR * gkwet)
outs gaeffLH, gaeffRH
endin

instr 402
;record performance
;if gkRecPerfo == 0 then
;	turnoff
;endif
fout "incout.wav", 14, gaeffLH, gaeffRH
gaeffLH = 0
gaeffRH = 0
endin

</CsInstruments>
<CsScore>
#define TR(INSNUM) #i 1	0 1 $INSNUM#
#define OPEN #7200#
f	0	$OPEN
;inst	sta	dur	note	veloc
$TR(1)
$TR(2)
$TR(3)
$TR(4)
$TR(5)
$TR(6)
$TR(7)
$TR(8)
$TR(9)
$TR(10)
$TR(11)
$TR(12)
$TR(13)
$TR(14)
$TR(15)
$TR(16)
$TR(17)
$TR(18)
$TR(19)
$TR(20)
$TR(21)
$TR(22)
$TR(23)
$TR(24)
$TR(25)
$TR(26)
$TR(27)
$TR(28)
$TR(29)
$TR(30)
$TR(31)
$TR(32)
$TR(33)
$TR(34)
$TR(35)
$TR(36)
$TR(37)
$TR(38)
$TR(39)
$TR(40)
$TR(41)
$TR(42)
$TR(43)
$TR(44)
$TR(45)
$TR(46)
$TR(47)
$TR(48)
$TR(49)
$TR(50)
$TR(51)
$TR(52)
$TR(53)

i 98 0 1
i 99 0 $OPEN
i 400 0 $OPEN
i 401 0 $OPEN
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 746 479 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView nobackground {59110, 56797, 54741}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
ioSlider {45, 5} {20, 100} 0.000000 1.000000 0.000000 slider2
ioSlider {85, 5} {20, 100} 0.000000 1.000000 0.000000 slider3
ioSlider {125, 5} {20, 100} 0.000000 1.000000 0.000000 slider4
ioSlider {165, 5} {20, 100} 0.000000 1.000000 0.000000 slider5
</MacGUI>

