<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>
;************************************************************
;        FORMANT SYNTHESIZER WITH GLOTTAL PARAMETERS
;                  Andreas Bergsland, 2009
;************************************************************
       sr     = 44100
       kr     = 4410
       ksmps  = 10
       nchnls = 2

; *****************************************************
;                               TRIGGER INSTRUMENT
;******************************************************

instr 1 ; MIDI triggered instrument (channel 1)
icps cpsmidi
outvalue "f0", icps
kOpenQ  invalue "OQ"
kSpeedQ invalue "SQ"
schedule 10, 0, 3, i(kOpenQ), i(kSpeedQ)
turnoff
endin

instr   9
;               Get value for global source
kOpenQ  invalue "OQ"
kSpeedQ invalue "SQ"
;               On value
kon             invalue "on"

;               Trigger play instrument
schedkwhen      kon, 2, 1, 10, 0, 3, kOpenQ, kSpeedQ
kon=1

endin


; *************************************************************
;                       FORMANT SYNTHESIZER INSTRUMENT
instr   10

;                       Get formant parameters
kcutoff1        invalue "Cutoff1"
kreson1 invalue "Reson1"
kcutoff2        invalue "Cutoff2"
kreson2 invalue "Reson2"
kcutoff3        invalue "Cutoff3"
kreson3 invalue "Reson3"
kcutoff4        invalue "Cutoff4"
kreson4 invalue "Reson4"

iflen   =       4096

;               Get glottal parameters
iOpenQ  =       p4
iSQ             =       p5 * 12/14              ; Speed quotient - compensate for the number of open vs closed segments in the ftable linseg

iOpen   =       iOpenQ * iflen
iClose  =       iflen - iOpen
ip              =       iOpen/26                        ; Calculate duration for segments in the open phase
iO              =       ip * iSQ                        ; Apply speed quotient for opening
iC              =       ip / iSQ                        ; and closing phase

iOp     =       14*iO                           ; Scale so that values fits the open phase
iCl     =       12*iC
iT      =       (iOp + iCl)/iOpen

iO      =       iO / iT                         ; Calulate open
iC      =       iC / iT                         ; and closed segments

;       Values for a glottal waveform taken from Inger Karlsson (1988), "Glottal waveform parameters for different speaker types" (Could be mapped more accurately)
i0      =       0       ;t1
i1      =       .02
i2      =       .05
i3      =       .1
i4      =       .15
i5      =       .24
i6      =       .33
i7      =       .45
i8      =       .575
i9      =       .645
i10     =       .775
i11     =       .845
i12     =       .945
i13     =       .985
i14     =       .99     ; ca.t2
i15     =       .95
i16     =       .8
i17     =       .57
i18     =       .3      ;ca.t3
i19     =       .11
i20     =       .06
i21     =       .04
i22     =       .02
i23     =       .01
i24     =       .002
i25     =       .001
i26     =       0       ;t4

;               Make ftable for glottal waveform
isource ftgen   0, 0, iflen, 7, i0, iO, i1, iO, i2, iO, i3, iO, i4, iO, i5, iO, i6, iO, i7, iO, i8, \
                                       iO, i9, iO,i10,iO,i11,iO,i12,iO,i13,iO,i14,iC,i15, iC, i16, iC, i17,\
                                       iC,i18,iC,i19,iC,i20,iC,i21,iC,i22,iC,i23,iC,i24,iC,i25,iC, i26, iClose, 0

kf0     invalue "f0"
kamp    linen   4000, .2, p3, .35


;***************************************************************
;                       JITTER, three different opcodes
kcpsMin =       8
kcpsMax =       20
kjitamp =       .025
kjit1 jspline kjitamp, kcpsMin, kcpsMax

kjitamp =       .027
kcpsMin =       2
kcpsMax =       20
kjit2   jitter  2.7, 2, 20

ktotamp =       .027
kamp1   =       .2
kcps1   =       1.5
kamp2   =       .25
kcps2   =       4.5
kamp3   =       .3
kcps3   =       15.5
kjit3   jitter2 ktotamp, kamp1, kcps1, kamp2, kcps2, kamp3, kcps3

kjitOn  invalue "JitOn"
kjit            =       kjit3 * kjitOn

;***************************************************************
;               VIBRATO

iSine   ftgen   0, 0, 1024, 10, 1
kvibamp expseg  0.001, p3*.3, 1.5, p3*.7, 2.5
ivibfrek        =               5.6
kvibrand        randh   .1, ivibfrek
kvibfrek        =               ivibfrek + kvibrand

kvibOn  invalue "Vib"
kvib            oscil   kvibamp * kvibOn, kvibfrek, iSine



;***************************************************************
;                       SHIMMER

kShimOn invalue "ShimOn"
iavgshim        =       (ampdb(0.39)/ampdb(0))-1
print   iavgshim
kshimamp        =       kamp * iavgshim * kShimOn
kcpsMin =       8
kcpsMAx =       20
kshim jspline kshimamp, kcpsMin, kcpsMax
;*****************************************************************

;*****************************************************************
;               Overshoot

kOShoot invalue "OShoot"
if0             =       i(kf0)
iOShoot =       i(kOShoot)
iamount =       .08 * if0 * iOShoot

kOShoot linseg  iamount, .06, 0, p3-.05, 0
;******************************************************************

; *****************************************************************
;               MAKE SOURCE SOUND

; Noise
kNoise  invalue "Noise"
anoise  rand    kamp * kNoise
anoise  butbp   anoise, 4500, 4000

; Glottal pulses
avoiced oscili  kamp + kshim, kf0 + (kjit*kf0) + kvib + kOShoot, isource

alyd    =       avoiced  + anoise
;******************************************************************
;               FORMANT FILTERS - reson with double filtering

aform1  reson   alyd,   kcutoff1, kreson1 * kcutoff1 / 100
aform1  reson   aform1, kcutoff1, kreson1 * kcutoff1 / 100
aform2  reson   alyd,   kcutoff2, kreson2 * kcutoff2 / 100
aform2  reson   aform2, kcutoff2, kreson2 * kcutoff2 / 100
aform3  reson   alyd,   kcutoff3, kreson3 * kcutoff3 / 100
aform3  reson   aform3, kcutoff3, kreson3 * kcutoff3 / 100
aform4  reson   alyd,   kcutoff4, kreson4 * kcutoff4 / 100
aform4  reson   aform4, kcutoff4, kreson4 * kcutoff4 / 100

;               add formant jitter (experimental)
kcutoff1        =       kcutoff1 + kcutoff1*kjit3*.3
kcutoff2        =       kcutoff2 + kcutoff2*kjit3*.3
kcutoff3        =       kcutoff3 + kcutoff3*kjit3*.3
kcutoff4        =       kcutoff4 + kcutoff4*kjit3*.3

;aform4 reson   alyd,   kcutoff4, kreson4 * kcutoff4 / 100
;aform3 reson   aform4, kcutoff3, kreson3 * kcutoff3 / 100
;aform2 reson   aform3, kcutoff2, kreson2 * kcutoff2 / 100
;aform1 reson   aform2, kcutoff1, kreson1 * kcutoff1 / 100

;               balance
abal1   balance aform1, alyd
abal2   balance aform2, alyd
abal3   balance aform3, alyd
abal4   balance aform4, alyd

;               get formant amps
kFamp1  invalue "FormAmp1"
kFamp2  invalue "FormAmp2"
kFamp3  invalue "FormAmp3"
kFamp4  invalue "FormAmp4"


;               Mix
afilt   =       abal1 * kFamp1 +abal2 * kFamp2 +abal3 * kFamp3 + abal4*kFamp4

;               Master Volume
kMasterVol invalue      "Vol"
aout            =       afilt * kMasterVol

;               View spectrum
dispfft afilt, 1, 2048 , .05, 0

outs    aout, aout

endin


</CsInstruments>
<CsScore>

i9 0 3000
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 378 270 799 613
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {54484, 50886, 40092}
ioGraph {6, 4} {780, 228} table 0.000000 1.000000 
ioButton {677, 265} {104, 30} value 1.000000 "on" "Play" "/" 
ioSlider {7, 249} {120, 20} 0.010000 0.990000 0.924667 OQ
ioText {128, 242} {62, 34} display 0.000000 0.00100 "OQ" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.9247
ioSlider {4, 288} {120, 20} 0.800000 4.000000 3.386667 SQ
ioText {127, 282} {64, 34} display 0.000000 0.00100 "SQ" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 3.3867
ioText {188, 242} {171, 36} display 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Open Quotient (OQ)
ioText {188, 282} {171, 36} display 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Speed Quotient (SQ)
ioKnob {598, 234} {67, 66} 0.000000 1.000000 0.010000 0.505051 Vol
ioText {5, 368} {178, 207} display 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Formant 1
ioText {196, 368} {180, 205} display 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Formant 2
ioText {390, 365} {173, 208} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Formant 3
ioText {574, 365} {178, 209} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Formant 4
ioText {613, 301} {39, 30} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Vol
ioKnob {531, 234} {65, 68} 90.000000 800.000000 0.010000 290.808081 f0
ioText {545, 302} {39, 30} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder f0
ioText {538, 325} {52, 29} display 0.000000 0.00100 "f0" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border 290.8081
ioCheckbox {367, 242} {20, 20} off Vib
ioText {389, 240} {59, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Vibr
ioCheckbox {366, 267} {20, 20} on JitOn
ioCheckbox {367, 291} {20, 20} on ShimOn
ioText {390, 265} {59, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Jit
ioText {390, 288} {65, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Shim
ioCheckbox {367, 315} {20, 20} on OShoot
ioText {390, 313} {94, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Overshoot
ioSlider {5, 330} {120, 20} 0.000000 0.200000 0.061667 Noise
ioText {128, 322} {64, 34} display 0.000000 0.00100 "Noise" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0650
ioText {190, 323} {171, 36} display 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Aspiration noise
ioSlider {31, 455} {20, 100} 250.000000 1000.000000 857.500000 Cutoff1
ioText {7, 420} {60, 31} display 0.000000 0.00100 "Cutoff1" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 857.5000
ioSlider {81, 456} {20, 100} 0.500000 30.000000 27.640000 Reson1
ioText {66, 418} {57, 34} display 0.000000 0.00100 "Reson1" left "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 27.9350
ioSlider {220, 457} {20, 100} 800.000000 3200.000000 2264.000000 Cutoff2
ioText {202, 422} {60, 32} display 0.000000 0.00100 "Cutoff2" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 2264.0000
ioSlider {277, 457} {20, 100} 0.500000 30.000000 6.400000 Reson2
ioText {264, 422} {54, 34} display 0.000000 0.00100 "Reson2" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 6.4000
ioSlider {408, 460} {20, 100} 2400.000000 3500.000000 2840.000000 Cutoff3
ioText {394, 425} {60, 33} display 0.000000 0.00100 "Cutoff3" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 2840.0000
ioSlider {460, 462} {20, 100} 0.500000 30.000000 20.265000 Reson3
ioText {448, 424} {55, 34} display 0.000000 0.00100 "Reson3" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 20.5600
ioSlider {132, 455} {20, 100} 0.000000 1.000000 0.930000 FormAmp1
ioText {122, 421} {54, 33} display 0.000000 0.00100 "FormAmp1" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.9800
ioSlider {331, 458} {20, 100} 0.000000 1.000000 0.000000 FormAmp2
ioText {317, 422} {54, 34} display 0.000000 0.00100 "FormAmp2" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioSlider {518, 463} {20, 100} 0.000000 1.000000 0.000000 FormAmp3
ioText {501, 425} {55, 34} display 0.000000 0.00100 "FormAmp3" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioSlider {596, 463} {20, 100} 3500.000000 4500.000000 3570.000000 Cutoff4
ioText {582, 428} {60, 33} display 0.000000 0.00100 "Cutoff4" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 3570.0000
ioSlider {653, 465} {20, 100} 0.500000 50.000000 50.000000 Reson4
ioText {636, 427} {55, 34} display 0.000000 0.00100 "Reson4" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 50.0000
ioSlider {706, 466} {20, 100} 0.000000 1.000000 0.000000 FormAmp4
ioText {689, 428} {55, 34} display 0.000000 0.00100 "FormAmp4" left "MS Shell Dlg 2" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {21, 399} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {74, 398} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {126, 398} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {210, 403} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {269, 402} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {320, 403} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {401, 405} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {454, 404} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {506, 404} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {587, 409} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {640, 408} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {692, 408} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
</MacGUI>

