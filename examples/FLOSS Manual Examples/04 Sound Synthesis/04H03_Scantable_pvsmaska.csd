<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
nchnls = 2
sr=44100
ksmps = 32
0dbfs = 1

gipos      ftgen      1, 0, 128, 10, 1                  ;Initial Shape, sine wave range -1 to 1;
gimass     ftgen      2, 0, 128, -7, 1, 128, 1          ;Masses(adj.), constant value 1
gistiff    ftgen      3, 0, 128, -7, 50, 64, 100, 64, 0 ;Stiffness; unipolar triangle range 0 to 100
gidamp     ftgen      4, 0, 128, -7, 1, 128, 1          ;Damping; constant value 1
givel      ftgen      5, 0, 128, -7, 0, 128, 0          ;Initial Velocity; constant value 1
gisin      ftgen      6, 0,8192, 10, 1                  ;Sine wave for buzz opcode

instr 1
iamp       =          .7
kfrq       =          110
a1         buzz       iamp, kfrq, 32, gisin
           outs       a1, a1
endin
instr 2
iamp       =          .7
kfrq       =          110
a0         scantable  1, 10, gipos, gimass, gistiff, gidamp, givel ;
ifftsize   =          128
ioverlap   =          ifftsize / 4
iwinsize   =          ifftsize
iwinshape  =          1; von-Hann window
a1         buzz       iamp, kfrq, 32, gisin
fftin      pvsanal    a1, ifftsize, ioverlap, iwinsize, iwinshape; fft-analysis of file
fmask      pvsmaska   fftin, 1, 1
a2         pvsynth    fmask; resynthesize
           outs       a2, a2
endin
</CsInstruments>
<CsScore>
i 1 0 3
i 2 5 10
e
</CsScore>
</CsoundSynthesizer>
;Example by Christopher Saunders</code>
