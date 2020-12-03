<CsoundSynthesizer>
<CsOptions>
-odac --env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;file should be found in the 'SourceMaterials' folder
gS_file = "fox.wav"

instr Defaults
 kSpeed = p4   ; playback speed
 iSkip = p5    ; inskip into file (in seconds)
 iLoop = p6    ; looping switch (0=off 1=on)
 aRead[] diskin gS_file, kSpeed, iSkip, iLoop
 out aRead[0], aRead[0] ;output first channel twice
endin

instr Scratch
 kSpeed randomi -1, 1.5, 5, 3
 aRead[] diskin gS_file, kSpeed, 1, 1
 out aRead[0], aRead[0]
endin
</CsInstruments>
<CsScore>
;      dur speed skip loop
i 1 0  4   1     0    0    ;default values
i . 4  3   1     1.7  0    ;skiptime
i . 7  6   0.5   0    0    ;speed
i . 13 6   1     0    1    ;loop
i 2 20 20
</CsScore>
</CsoundSynthesizer>
;example written by Iain McCurdy and joachim heintz
