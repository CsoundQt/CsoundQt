<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>
;example by Iain McCurdy

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

;FUNCTION TABLES STORING DATA FOR VARIOUS VOICE FORMANTS
;BASS
giBF1 ftgen 0, 0, -5, -2, 600,   400, 250,   400,  350
giBF2 ftgen 0, 0, -5, -2, 1040, 1620, 1750,  750,  600
giBF3 ftgen 0, 0, -5, -2, 2250, 2400, 2600, 2400, 2400
giBF4 ftgen 0, 0, -5, -2, 2450, 2800, 3050, 2600, 2675
giBF5 ftgen 0, 0, -5, -2, 2750, 3100, 3340, 2900, 2950

giBDb1 ftgen 0, 0, -5, -2,   0,	  0,   0,   0,   0
giBDb2 ftgen 0, 0, -5, -2,  -7,	-12, -30, -11, -20
giBDb3 ftgen 0, 0, -5, -2,  -9,	 -9, -16, -21, -32
giBDb4 ftgen 0, 0, -5, -2,  -9,	-12, -22, -20, -28
giBDb5 ftgen 0, 0, -5, -2, -20,	-18, -28, -40, -36

giBBW1 ftgen 0, 0, -5, -2,  60,  40,  60,  40,  40
giBBW2 ftgen 0, 0, -5, -2,  70,  80,  90,  80,  80
giBBW3 ftgen 0, 0, -5, -2, 110, 100, 100, 100, 100
giBBW4 ftgen 0, 0, -5, -2, 120, 120, 120, 120, 120
giBBW5 ftgen 0, 0, -5, -2, 130, 120, 120, 120, 120

;TENOR
giTF1 ftgen 0, 0, -5, -2,  650,  400,  290,  400,  350
giTF2 ftgen 0, 0, -5, -2, 1080, 1700, 1870,  800,  600
giTF3 ftgen 0, 0, -5, -2, 2650,	2600, 2800, 2600, 2700
giTF4 ftgen 0, 0, -5, -2, 2900,	3200, 3250, 2800, 2900
giTF5 ftgen 0, 0, -5, -2, 3250,	3580, 3540, 3000, 3300

giTDb1 ftgen 0, 0, -5, -2,   0,   0,   0,   0,   0
giTDb2 ftgen 0, 0, -5, -2,  -6, -14, -15, -10, -20
giTDb3 ftgen 0, 0, -5, -2,  -7, -12, -18, -12, -17
giTDb4 ftgen 0, 0, -5, -2,  -8, -14, -20, -12, -14
giTDb5 ftgen 0, 0, -5, -2, -22, -20, -30, -26, -26

giTBW1 ftgen 0, 0, -5, -2,  80,	 70,  40,  40,  40
giTBW2 ftgen 0, 0, -5, -2,  90,	 80,  90,  80,  60
giTBW3 ftgen 0, 0, -5, -2, 120,	100, 100, 100, 100
giTBW4 ftgen 0, 0, -5, -2, 130,	120, 120, 120, 120
giTBW5 ftgen 0, 0, -5, -2, 140,	120, 120, 120, 120

;COUNTER TENOR
giCTF1 ftgen 0, 0, -5, -2,  660,  440,  270,  430,  370
giCTF2 ftgen 0, 0, -5, -2, 1120, 1800, 1850,  820,  630
giCTF3 ftgen 0, 0, -5, -2, 2750, 2700, 2900, 2700, 2750
giCTF4 ftgen 0, 0, -5, -2, 3000, 3000, 3350, 3000, 3000
giCTF5 ftgen 0, 0, -5, -2, 3350, 3300, 3590, 3300, 3400

giTBDb1 ftgen 0, 0, -5, -2,   0,   0,   0,   0,   0
giTBDb2 ftgen 0, 0, -5, -2,  -6, -14, -24, -10, -20
giTBDb3 ftgen 0, 0, -5, -2, -23, -18, -24, -26, -23
giTBDb4 ftgen 0, 0, -5, -2, -24, -20, -36, -22, -30
giTBDb5 ftgen 0, 0, -5, -2, -38, -20, -36, -34, -30

giTBW1 ftgen 0, 0, -5, -2, 80,   70,  40,  40,  40
giTBW2 ftgen 0, 0, -5, -2, 90,   80,  90,  80,  60
giTBW3 ftgen 0, 0, -5, -2, 120, 100, 100, 100, 100
giTBW4 ftgen 0, 0, -5, -2, 130, 120, 120, 120, 120
giTBW5 ftgen 0, 0, -5, -2, 140, 120, 120, 120, 120

;ALTO
giAF1 ftgen 0, 0, -5, -2,  800,  400,  350,  450,  325
giAF2 ftgen 0, 0, -5, -2, 1150, 1600, 1700,  800,  700
giAF3 ftgen 0, 0, -5, -2, 2800, 2700, 2700, 2830, 2530
giAF4 ftgen 0, 0, -5, -2, 3500, 3300, 3700, 3500, 2500
giAF5 ftgen 0, 0, -5, -2, 4950, 4950, 4950, 4950, 4950

giADb1 ftgen 0, 0, -5, -2,   0,   0,   0,   0,   0
giADb2 ftgen 0, 0, -5, -2,  -4, -24, -20,  -9, -12
giADb3 ftgen 0, 0, -5, -2, -20, -30, -30, -16, -30
giADb4 ftgen 0, 0, -5, -2, -36, -35, -36, -28, -40
giADb5 ftgen 0, 0, -5, -2, -60, -60, -60, -55, -64

giABW1 ftgen 0, 0, -5, -2, 50,   60,  50,  70,  50
giABW2 ftgen 0, 0, -5, -2, 60,   80, 100,  80,  60
giABW3 ftgen 0, 0, -5, -2, 170, 120, 120, 100, 170
giABW4 ftgen 0, 0, -5, -2, 180, 150, 150, 130, 180
giABW5 ftgen 0, 0, -5, -2, 200, 200, 200, 135, 200

;SOPRANO
giSF1 ftgen 0, 0, -5, -2,  800,  350,  270,  450,  325
giSF2 ftgen 0, 0, -5, -2, 1150, 2000, 2140,  800,  700
giSF3 ftgen 0, 0, -5, -2, 2900, 2800, 2950, 2830, 2700
giSF4 ftgen 0, 0, -5, -2, 3900, 3600, 3900, 3800, 3800
giSF5 ftgen 0, 0, -5, -2, 4950, 4950, 4950, 4950, 4950

giSDb1 ftgen 0, 0, -5, -2,   0,   0,   0,   0,   0
giSDb2 ftgen 0, 0, -5, -2,  -6, -20, -12, -11, -16
giSDb3 ftgen 0, 0, -5, -2, -32, -15, -26, -22, -35
giSDb4 ftgen 0, 0, -5, -2, -20, -40, -26, -22, -40
giSDb5 ftgen 0, 0, -5, -2, -50, -56, -44, -50, -60

giSBW1 ftgen 0, 0, -5, -2,  80,  60,  60,  70,  50
giSBW2 ftgen 0, 0, -5, -2,  90,  90,  90,  80,  60
giSBW3 ftgen 0, 0, -5, -2, 120, 100, 100, 100, 170
giSBW4 ftgen 0, 0, -5, -2, 130, 150, 120, 130, 180
giSBW5 ftgen 0, 0, -5, -2, 140, 200, 120, 135, 200

gisine ftgen 0, 0, 4096, 10, 1
giexp ftgen 0, 0, 1024, 19, 0.5, 0.5, 270, 0.5

instr 1
  kFund    expon     p4,p3,p5               ; fundemental
  kVow     line      p6,p3,p7               ; vowel select
  kBW      line      p8,p3,p9               ; bandwidth factor
  iVoice   =         p10                    ; voice select

  ; read formant cutoff frequenies from tables
  kForm1   tablei    kVow*5,giBF1+(iVoice*15)
  kForm2   tablei    kVow*5,giBF1+(iVoice*15)+1
  kForm3   tablei    kVow*5,giBF1+(iVoice*15)+2
  kForm4   tablei    kVow*5,giBF1+(iVoice*15)+3
  kForm5   tablei    kVow*5,giBF1+(iVoice*15)+4
  ; read formant intensity values from tables
  kDB1     tablei    kVow*5,giBF1+(iVoice*15)+5
  kDB2     tablei    kVow*5,giBF1+(iVoice*15)+6
  kDB3     tablei    kVow*5,giBF1+(iVoice*15)+7
  kDB4     tablei    kVow*5,giBF1+(iVoice*15)+8
  kDB5     tablei    kVow*5,giBF1+(iVoice*15)+9
  ; read formant bandwidths from tables
  kBW1     tablei    kVow*5,giBF1+(iVoice*15)+10
  kBW2     tablei    kVow*5,giBF1+(iVoice*15)+11
  kBW3     tablei    kVow*5,giBF1+(iVoice*15)+12
  kBW4     tablei    kVow*5,giBF1+(iVoice*15)+13
  kBW5     tablei    kVow*5,giBF1+(iVoice*15)+14
  ; create resonant formants using fof opcode
  koct     =         1	
  aForm1   fof       ampdb(kDB1),kFund,kForm1,0,kBW1,0.003,0.02,0.007,\
                       1000,gisine,giexp,3600
  aForm2   fof       ampdb(kDB2),kFund,kForm2,0,kBW2,0.003,0.02,0.007,\
                       1000,gisine,giexp,3600
  aForm3   fof       ampdb(kDB3),kFund,kForm3,0,kBW3,0.003,0.02,0.007,\
                       1000,gisine,giexp,3600
  aForm4   fof       ampdb(kDB4),kFund,kForm4,0,kBW4,0.003,0.02,0.007,\
                       1000,gisine,giexp,3600
  aForm5   fof       ampdb(kDB5),kFund,kForm5,0,kBW5,0.003,0.02,0.007,\
                       1000,gisine,giexp,3600

  ; formants are mixed
  aMix     sum       aForm1,aForm2,aForm3,aForm4,aForm5
  kEnv     linseg    0,3,1,p3-6,1,3,0     ; an amplitude envelope
           outs      aMix*kEnv*0.3, aMix*kEnv*0.3 ; send audio to outputs
endin

</CsInstruments>

<CsScore>
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
