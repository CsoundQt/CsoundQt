<CsoundSynthesizer>

<CsOptions>
-o dac -d
</CsOptions>

<CsInstruments>
; Example by Bjorn Houdorf, March 2013

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
           seed       0

instr 1
ktrig      metro      0.8; Trigger frequency, instr. 2
           scoreline  "i 2 0 4", ktrig
endin

instr 2
ital       random     60, 72; random notes
ifrq       =          cpsmidinn(ital)
knumpart1  oscili     4, 0.1, 1
knumpart2  oscili     5, 0.11, 1
; Generate primary signal.....
asig       buzz       0.1, ifrq, knumpart1*knumpart2+1, 1
ipan       random     0, 1; ....make random function...
asigL, asigR pan2     asig, ipan, 1; ...pan it...
           outs       asigL, asigR ;.... and output it..
kran1      randomi    0,4,3
kran2      randomi    0,4,3
asigdel1   delay      asig, 0.1+i(kran1)
asigdel2   delay      asig, 0.1+i(kran2)
; Make secondary signal...
aL, aR     reverbsc   asig+asigdel1, asig+asigdel2, 0.9, 15000
           outs       aL, aR; ...and output it
endin
</CsInstruments>

<CsScore>
f1 0 8192 10 1
i1 0 60
</CsScore>

</CsoundSynthesizer>
