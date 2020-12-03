<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
nchnls = 2
sr = 44100
ksmps = 32
0dbfs = 1

gipos ftgen 0,0,128,10,1,1,1,1,1,1     ;Initial Position Shape: impulse-like
gimass ftgen 0,0,128,-5,0.0001,128,.01 ;Masses: exponential 0.0001 to 0.01
gistiff ftgen 0,0,128,-7,0,64,100,64,0 ;Stiffness; triangle range 0 to 100
gidamp ftgen 0,0,128,-7,1,128,1        ;Damping; constant value 1
givel ftgen 0,0,128,-7,0,128,0         ;Initial Velocity; constant value 0
gisin ftgen 0,0,8192,10,1              ;Sine wave for buzz opcode

instr 1
iamp       =          .2
kfrq       =          110
aBuzz      buzz       iamp, kfrq, 32, gisin
aBuzz      linen      aBuzz, .1, p3, 1
           out        aBuzz, aBuzz
endin
instr 2
iamp       =          .4
kfrq       =          110
a0         scantable  0, 0, gipos, gimass, gistiff, gidamp, givel
ifftsize   =          128
ioverlap   =          ifftsize / 4
iwinsize   =          ifftsize
iwinshape  =          1; von-Hann window
aBuzz      buzz       iamp, kfrq, 32, gisin
fBuzz      pvsanal    aBuzz, ifftsize, ioverlap, iwinsize, iwinshape ;fft
fMask      pvsmaska   fBuzz, gipos, 1
aOut       pvsynth    fMask; resynthesize
aOut       linen      aOut, .1, p3, 1
           out        aOut, aOut
endin
</CsInstruments>
<CsScore>
i 1 0 3
i 2 4 20
</CsScore>
</CsoundSynthesizer>
;Example by Christopher Saunders and joachim heintz
