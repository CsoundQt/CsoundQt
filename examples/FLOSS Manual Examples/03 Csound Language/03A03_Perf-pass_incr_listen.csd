<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 441
0dbfs = 1
nchnls = 2

;build a table containing a sine wave
giSine     ftgen      0, 0, 2^10, 10, 1

instr Rise
kFreq      init       100
aSine      poscil     .2, kFreq, giSine
           outs       aSine, aSine
;increment frequency by 10 Hz for each k-cycle
kFreq      =          kFreq + 10
;print out the frequency for the last k-cycle
kLast      release
 if kLast == 1 then
           printk     0, kFreq
 endif
endin

instr Partials
;initialize kCount
kCount     init       100
;get new frequency if kCount equals 100, 200, ...
 if kCount % 100 == 0 then
kFreq      =          kCount
 endif
aSine      poscil     .2, kFreq, giSine
           outs       aSine, aSine
;increment kCount
kCount     =          kCount + 1
;print out kFreq whenever it has changed
           printk2    kFreq
endin
</CsInstruments>
<CsScore>
i "Rise" 0 3
i "Partials" 4 31
</CsScore>
</CsoundSynthesizer>
<p>;example by joachim heintz
</p>