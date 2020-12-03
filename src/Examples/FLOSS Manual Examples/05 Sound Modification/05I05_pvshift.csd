<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Shift
 aSig diskin "BratscheMono.wav"
 fSig pvsanal aSig, 1024, 256, 1024, 1
 fShift pvshift fSig, p4, p5
 aShift pvsynth fShift
 out aShift, aShift
endin

</CsInstruments>
<CsScore>
i "Shift" 0 9 0 0 ;no shift (base freq is 218)
i . + . 50 0 ;shift all by 50 Hz
i . + . 150 0 ;shift all by 150 Hz
i . + . 500 0 ;shift all by 500 Hz
i . + . 150 230 ;only above 230 Hz by 150 Hz
i . + . . 460 ;only above 460 Hz
i . + . . 920 ;only above 920 Hz
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
