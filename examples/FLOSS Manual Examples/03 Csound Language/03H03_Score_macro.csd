<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>
sr 	= 	44100
ksmps 	= 	16
nchnls 	= 	1
0dbfs	=	1


 instr  1 ; bass guitar
a1   wgpluck2 0.98, 0.4, cpsmidinn(p4), 0.1, 0.6
aenv linseg   1,p3-0.1,1,0.1,0
 out	a1*aenv
 endin

</CsInstruments>

<CsScore>
; p4 = pitch as a midi note number
#define RIFF_1(Start'Trans)
#
i 1 [$Start     ]  1     [36+$Trans]
i 1 [$Start+1   ]  0.25  [43+$Trans]
i 1 [$Start+1.25]  0.25  [43+$Trans]
i 1 [$Start+1.75]  0.25  [41+$Trans]
i 1 [$Start+2.5 ]  1     [46+$Trans]
i 1 [$Start+3.25]  1     [48+$Trans]
#
#define RIFF_2(Start'Trans)
#
i 1 [$Start     ]  1     [34+$Trans]
i 1 [$Start+1.25]  0.25  [41+$Trans]
i 1 [$Start+1.5 ]  0.25  [43+$Trans]
i 1 [$Start+1.75]  0.25  [46+$Trans]
i 1 [$Start+2.25]  0.25  [43+$Trans]
i 1 [$Start+2.75]  0.25  [41+$Trans]
i 1 [$Start+3   ]  0.5   [43+$Trans]
i 1 [$Start+3.5 ]  0.25  [46+$Trans]
#
t 0 90
$RIFF_1(0 ' 0)
$RIFF_1(4 ' 0)
$RIFF_2(8 ' 0)
$RIFF_2(12'-5)
$RIFF_1(16'-5)
$RIFF_2(20'-7)
$RIFF_2(24' 0)
$RIFF_2(28' 5)
e
</CsScore>
</CsoundSynthesizer>
; example written by Iain McCurdy
