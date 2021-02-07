<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 1

giSine     ftgen      0, 0, 1024, 10, 1

instr 1
iOctStart  =          p4 ;pitch in octave notation at start
iOctEnd    =          p5 ;and end
iDbStart   =          p6 ;dB at start
iDbEnd     =          p7 ;and end
kPitch     expseg     cpsoct(iOctStart), p3, cpsoct(iOctEnd)
kEnv       linseg     iDbStart, p3, iDbEnd
aSine      poscil     ampdb(kEnv), kPitch, giSine
iFad       random     p3/20, p3/5
aOut       linen      aSine, iFad, p3, iFad
           out        aOut
endin
</CsInstruments>
<CsScore>
i 1 0 10 ;will be overwritten by the python score generator
</CsScore>
</CsoundSynthesizer>
