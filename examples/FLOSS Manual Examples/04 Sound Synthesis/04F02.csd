see http://www.flossmanuals.net/csound/ch028_f-granular-synthesis

<CsoundSynthesizer>

<CsOptions>
-odevaudio -b512 -dm0
</CsOptions>

<CsInstruments>
;example by Iain McCurdy

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

instr 1
  kFund    expon     p4,p3,p5               ; fundemental
  kVow     line      p6,p3,p7               ; vowel select
  kBW      line      p8,p3,p9               ; bandwidth factor
  iVoice   =         p10                    ; voice select

  ; read formant cutoff frequenies from tables
  kForm1     table     kVow,1+(iVoice*15),1
  kForm2     table     kVow,2+(iVoice*15),1
  kForm3     table     kVow,3+(iVoice*15),1
  kForm4     table     kVow,4+(iVoice*15),1
  kForm5     table     kVow,5+(iVoice*15),1
  ; read formant intensity values from tables
  kDB1     table     kVow,6+(iVoice*15),1
  kDB2     table     kVow,7+(iVoice*15),1
  kDB3     table     kVow,8+(iVoice*15),1
  kDB4     table     kVow,9+(iVoice*15),1
  kDB5     table     kVow,10+(iVoice*15),1
  ; read formant bandwidths from tables
  kBW1     table     kVow,11+(iVoice*15),1
  kBW2     table     kVow,12+(iVoice*15),1
  kBW3     table     kVow,13+(iVoice*15),1
  kBW4     table     kVow,14+(iVoice*15),1
  kBW5     table     kVow,15+(iVoice*15),1
  ; create resonant formants byt filtering source sound
  koct     =         1  
  aForm1   fof       ampdb(kDB1), kFund, kForm1, 0, kBW1, 0.003, 0.02, 0.007, 1000, 101, 102, 3600
  aForm2   fof       ampdb(kDB2), kFund, kForm2, 0, kBW2, 0.003, 0.02, 0.007, 1000, 101, 102, 3600
  aForm3   fof       ampdb(kDB3), kFund, kForm3, 0, kBW3, 0.003, 0.02, 0.007, 1000, 101, 102, 3600
  aForm4   fof       ampdb(kDB4), kFund, kForm4, 0, kBW4, 0.003, 0.02, 0.007, 1000, 101, 102, 3600
  aForm5   fof       ampdb(kDB5), kFund, kForm5, 0, kBW5, 0.003, 0.02, 0.007, 1000, 101, 102, 3600

  ; formants are mixed and multiplied both by intensity values derived from tables and by the on-screen gain controls for each formant
  aMix     sum       aForm1,aForm2,aForm3,aForm4,aForm5
  kEnv     linseg    0,3,1,p3-6,1,3,0     ; an amplitude envelope
           outs      aMix*kEnv, aMix*kEnv ; send audio to outputs
endin

</CsInstruments>

<CsScore>
f 0 3600        ;DUMMY SCORE EVENT - PERMITS REALTIME PERFORMANCE FOR UP TO 1 HOUR

;FUNCTION TABLES STORING FORMANT DATA FOR EACH OF THE FIVE VOICE TYPES REPRESENTED
;BASS
f 1  0 32768 -7 600     10922   400     10922   250     10924   350     ;FREQ
f 2  0 32768 -7 1040    10922   1620    10922   1750    10924   600     ;FREQ
f 3  0 32768 -7 2250    10922   2400    10922   2600    10924   2400    ;FREQ
f 4  0 32768 -7 2450    10922   2800    10922   3050    10924   2675    ;FREQ
f 5  0 32768 -7 2750    10922   3100    10922   3340    10924   2950    ;FREQ
f 6  0 32768 -7 0       10922   0       10922   0       10924   0       ;dB
f 7  0 32768 -7 -7      10922   -12     10922   -30     10924   -20     ;dB
f 8  0 32768 -7 -9      10922   -9      10922   -16     10924   -32     ;dB
f 9  0 32768 -7 -9      10922   -12     10922   -22     10924   -28     ;dB
f 10 0 32768 -7 -20     10922   -18     10922   -28     10924   -36     ;dB
f 11 0 32768 -7 60      10922   40      10922   60      10924   40      ;BAND WIDTH
f 12 0 32768 -7 70      10922   80      10922   90      10924   80      ;BAND WIDTH
f 13 0 32768 -7 110     10922   100     10922   100     10924   100     ;BAND WIDTH
f 14 0 32768 -7 120     10922   120     10922   120     10924   120     ;BAND WIDTH
f 15 0 32768 -7 130     10922   120     10922   120     10924   120     ;BAND WIDTH
;TENOR
f 16 0 32768 -7 650     8192    400     8192    290     8192    400     8192    350     ;FREQ
f 17 0 32768 -7 1080    8192    1700    8192    1870    8192    800     8192    600     ;FREQ
f 18 0 32768 -7 2650    8192    2600    8192    2800    8192    2600    8192    2700    ;FREQ
f 19 0 32768 -7 2900    8192    3200    8192    3250    8192    2800    8192    2900    ;FREQ
f 20 0 32768 -7 3250    8192    3580    8192    3540    8192    3000    8192    3300    ;FREQ
f 21 0 32768 -7 0       8192    0       8192    0       8192    0       8192    0       ;dB
f 22 0 32768 -7 -6      8192    -14     8192    -15     8192    -10     8192    -20     ;dB
f 23 0 32768 -7 -7      8192    -12     8192    -18     8192    -12     8192    -17     ;dB
f 24 0 32768 -7 -8      8192    -14     8192    -20     8192    -12     8192    -14     ;dB
f 25 0 32768 -7 -22     8192    -20     8192    -30     8192    -26     8192    -26     ;dB
f 26 0 32768 -7 80      8192    70      8192    40      8192    40      8192    40      ;BAND WIDTH
f 27 0 32768 -7 90      8192    80      8192    90      8192    80      8192    60      ;BAND WIDTH
f 28 0 32768 -7 120     8192    100     8192    100     8192    100     8192    100     ;BAND WIDTH
f 29 0 32768 -7 130     8192    120     8192    120     8192    120     8192    120     ;BAND WIDTH
f 30 0 32768 -7 140     8192    120     8192    120     8192    120     8192    120     ;BAND WIDTH
;COUNTER TENOR
f 31 0 32768 -7 660     8192    440     8192    270     8192    430     8192    370     ;FREQ
f 32 0 32768 -7 1120    8192    1800    8192    1850    8192    820     8192    630     ;FREQ
f 33 0 32768 -7 2750    8192    2700    8192    2900    8192    2700    8192    2750    ;FREQ
f 34 0 32768 -7 3000    8192    3000    8192    3350    8192    3000    8192    3000    ;FREQ
f 35 0 32768 -7 3350    8192    3300    8192    3590    8192    3300    8192    3400    ;FREQ
f 36 0 32768 -7 0       8192    0       8192    0       8192    0       8192    0       ;dB
f 37 0 32768 -7 -6      8192    -14     8192    -24     8192    -10     8192    -20     ;dB
f 38 0 32768 -7 -23     8192    -18     8192    -24     8192    -26     8192    -23     ;dB
f 39 0 32768 -7 -24     8192    -20     8192    -36     8192    -22     8192    -30     ;dB
f 40 0 32768 -7 -38     8192    -20     8192    -36     8192    -34     8192    -30     ;dB
f 41 0 32768 -7 80      8192    70      8192    40      8192    40      8192    40      ;BAND WIDTH
f 42 0 32768 -7 90      8192    80      8192    90      8192    80      8192    60      ;BAND WIDTH
f 43 0 32768 -7 120     8192    100     8192    100     8192    100     8192    100     ;BAND WIDTH
f 44 0 32768 -7 130     8192    120     8192    120     8192    120     8192    120     ;BAND WIDTH
f 45 0 32768 -7 140     8192    120     8192    120     8192    120     8192    120     ;BAND WIDTH
;ALTO
f 46 0 32768 -7 800     8192    400     8192    350     8192    450     8192    325     ;FREQ
f 47 0 32768 -7 1150    8192    1600    8192    1700    8192    800     8192    700     ;FREQ
f 48 0 32768 -7 2800    8192    2700    8192    2700    8192    2830    8192    2530    ;FREQ
f 49 0 32768 -7 3500    8192    3300    8192    3700    8192    3500    8192    2500    ;FREQ
f 50 0 32768 -7 4950    8192    4950    8192    4950    8192    4950    8192    4950    ;FREQ
f 51 0 32768 -7 0       8192    0       8192    0       8192    0       8192    0       ;dB
f 52 0 32768 -7 -4      8192    -24     8192    -20     8192    -9      8192    -12     ;dB
f 53 0 32768 -7 -20     8192    -30     8192    -30     8192    -16     8192    -30     ;dB
f 54 0 32768 -7 -36     8192    -35     8192    -36     8192    -28     8192    -40     ;dB
f 55 0 32768 -7 -60     8192    -60     8192    -60     8192    -55     8192    -64     ;dB
f 56 0 32768 -7 50      8192    60      8192    50      8192    70      8192    50      ;BAND WIDTH
f 57 0 32768 -7 60      8192    80      8192    100     8192    80      8192    60      ;BAND WIDTH
f 58 0 32768 -7 170     8192    120     8192    120     8192    100     8192    170     ;BAND WIDTH
f 59 0 32768 -7 180     8192    150     8192    150     8192    130     8192    180     ;BAND WIDTH
f 60 0 32768 -7 200     8192    200     8192    200     8192    135     8192    200     ;BAND WIDTH
;SOPRANO
f 61 0 32768 -7 800     8192    350     8192    270     8192    450     8192    325     ;FREQ
f 62 0 32768 -7 1150    8192    2000    8192    2140    8192    800     8192    700     ;FREQ
f 63 0 32768 -7 2900    8192    2800    8192    2950    8192    2830    8192    2700    ;FREQ
f 64 0 32768 -7 3900    8192    3600    8192    3900    8192    3800    8192    3800    ;FREQ
f 65 0 32768 -7 4950    8192    4950    8192    4950    8192    4950    8192    4950    ;FREQ
f 66 0 32768 -7 0       8192    0       8192    0       8192    0       8192    0       ;dB
f 67 0 32768 -7 -6      8192    -20     8192    -12     8192    -11     8192    -16     ;dB
f 68 0 32768 -7 -32     8192    -15     8192    -26     8192    -22     8192    -35     ;dB
f 69 0 32768 -7 -20     8192    -40     8192    -26     8192    -22     8192    -40     ;dB
f 70 0 32768 -7 -50     8192    -56     8192    -44     8192    -50     8192    -60     ;dB
f 71 0 32768 -7 80      8192    60      8192    60      8192    70      8192    50      ;BAND WIDTH
f 72 0 32768 -7 90      8192    90      8192    90      8192    80      8192    60      ;BAND WIDTH
f 73 0 32768 -7 120     8192    100     8192    100     8192    100     8192    170     ;BAND WIDTH
f 74 0 32768 -7 130     8192    150     8192    120     8192    130     8192    180     ;BAND WIDTH
f 75 0 32768 -7 140     8192    200     8192    120     8192    135     8192    200     ;BAND WIDTH

f 101 0 4096 10 1                       ;SINE WAVE
f 102 0 1024 19 0.5 0.5 270 0.5         ;EXPONENTIAL CURVE USED TO DEFINE THE ENVELOPE SHAPE OF FOF PULSES

; p4 = fundamental begin value (c.p.s.)
; p5 = fundamental end value
; p6 = vowel begin value (0 - 1 : a e i o u)
; p7 = vowel end value
; p8 = bandwidth factor begin (suggested range 0 - 2)
; p9 = bandwidth factor end
; p10 = voice (0=bass; 1=tenor; 2=counter_tenor; 3=alto; 4=soprano)

; p1 p2  p3  p4  p5  p6  p7  p8  p9 p10
i 1  0   10  50  100 0   1   2   0  0
i 1  8   .   78  77  1   0   1   0  1
i 1  16  .   150 118 0   1   1   0  2
i 1  24  .   200 220 1   0   0.2 0  3
i 1  32  .   400 800 0   1   0.2 0  4
e
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>
